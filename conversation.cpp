#include "conversation.h"
#include "file_digest.h"
#include <algorithm>
#include <cctype>
#include <cmath>
#include <fstream>
#include <set>
#include <stdexcept>

namespace micronaut::conversation {
namespace {
std::string normalize(const std::string& input){
    std::string out;bool space=false;
    for(unsigned char c:input){
        if(c==' '||c=='\t'||c=='\n'||c=='\r'){space=!out.empty();continue;}
        if(space){out.push_back(' ');space=false;}
        out.push_back(c>='a'&&c<='z'?char(c-'a'+'A'):char(c));
    }
    return out;
}
}
Policy load_policy(const std::string& path){
    const auto digest=micronaut::file_sha256(path);
    if(digest!="479ebd2465e78874a5ef51768bce2a0643346ff66a51d8aadcbb390c85ec2acf")
        throw std::runtime_error("response policy is not host-pinned");
    std::ifstream input(path,std::ios::binary);
    auto document=nlohmann::json::parse(input);
    if(document.at("schema")!="gemma.bridge.response-policy.v1"||
       document.at("policy_id")!="aiml-existing-template.v1"||
       document.at("authority")!="proposal_only"||
       document.at("source_store")!="aiml-embeddinggemma2"||
       document.at("exact").at("normalization")!="ascii_upper_collapse_space.v1"||
       document.at("exact").at("require_that_topic")!=true||
       document.at("exact").at("priority")!="before_semantic"||
       document.at("exact").at("tie_break")!="lowest_row_id"||
       document.at("semantic").at("score_field")!="pattern_score"||
       document.at("semantic").at("tie_break")!="lowest_row_id"||
       document.at("ambiguity").at("rule")!="top_two_margin"||
       document.at("ambiguity").at("action")!="fallback"||
       document.at("fallback").at("route")!="existing_aiml"||
       document.at("fallback").at("emit")!=false)
        throw std::runtime_error("unsupported response policy contract");
    Policy policy;
    policy.id=document.at("policy_id").get<std::string>();
    policy.sha256=digest;
    policy.source_sha256=document.at("source_sha256").get<std::string>();
    policy.minimum_pattern_score=document.at("semantic").at("minimum_score").get<double>();
    policy.minimum_margin=document.at("semantic").at("minimum_margin").get<double>();
    if(policy.source_sha256!="68398ce5f05881adeb96fbc9b76bfb65ce8a033e8334796b5cdea0115972b2b4"||
       !std::isfinite(policy.minimum_pattern_score)||!std::isfinite(policy.minimum_margin)||
       policy.minimum_pattern_score< -1||policy.minimum_pattern_score>1||
       policy.minimum_margin<0||policy.minimum_margin>2)
        throw std::runtime_error("invalid response policy values");
    return policy;
}
nlohmann::json propose(const Context& context,const nlohmann::json& retrieval,
                       const std::vector<relational_keys::Key>& keys,const Policy& policy){
    if(retrieval.at("schema")!="gemma.bridge.retrieval.v1" ||
       retrieval.at("authority")!="data_only" || retrieval.at("semantic_commit")!=false ||
       !retrieval.at("hits").is_array()||
       retrieval.at("source_sha256")!=policy.source_sha256)
        throw std::runtime_error("invalid retrieval envelope or source binding");
    if(policy.id!="aiml-existing-template.v1"||
       policy.sha256!="479ebd2465e78874a5ef51768bce2a0643346ff66a51d8aadcbb390c85ec2acf"||
       policy.source_sha256!="68398ce5f05881adeb96fbc9b76bfb65ce8a033e8334796b5cdea0115972b2b4"||
       policy.minimum_pattern_score!=0.85||policy.minimum_margin!=0.03)
        throw std::runtime_error("response policy was not loaded from pinned contract");
    nlohmann::json output={{"schema","gemma.bridge.conversation-proposal.v1"},
        {"authority","proposal_only"},{"semantic_commit",false},
        {"mode","fallback"},{"reason","no_admitted_candidate"},
        {"fallback_route","existing_aiml"},{"emit",false},
        {"policy_id",policy.id},{"policy_sha256",policy.sha256},
        {"source_sha256",retrieval.at("source_sha256")}};
    const auto& hits=retrieval.at("hits");
    if(hits.empty()){output["decision"]={{"rule","no_hit"}};return output;}
    std::set<std::uint32_t> row_ids;
    double previous=2.0;std::uint32_t previous_row=0;
    for(const auto& hit:hits){
        auto row=hit.at("row_id").get<std::uint32_t>();
        double score=hit.at("pattern_score").get<double>();
        if(!row_ids.insert(row).second||!std::isfinite(score)||score< -1||score>1||
           score>previous||(score==previous&&row<previous_row))
            throw std::runtime_error("retrieval ranking invalid");
        previous=score;previous_row=row;
    }
    const auto* chosen=&hits.at(0);
    bool found_exact=false;
    for(const auto& hit:hits){
        if(normalize(hit.at("pattern").get<std::string>())==normalize(context.utterance) &&
           normalize(hit.at("that").get<std::string>())==normalize(context.that) &&
           normalize(hit.at("topic").get<std::string>())==normalize(context.topic)){
            if(!found_exact||hit.at("row_id").get<std::uint32_t>()<
               chosen->at("row_id").get<std::uint32_t>())chosen=&hit;
            found_exact=true;
        }
    }
    const auto& best=*chosen;
    double score=best.at("pattern_score").get<double>();
    if(!std::isfinite(score))throw std::runtime_error("nonfinite retrieval score");
    bool exact=found_exact;
    double second=hits.size()>1?hits.at(1).at("pattern_score").get<double>():-1.0;
    output["decision"]={{"top_score",hits.at(0).at("pattern_score")},
        {"runner_up_score",hits.size()>1?nlohmann::json(second):nlohmann::json(nullptr)},
        {"minimum_score",policy.minimum_pattern_score},{"minimum_margin",policy.minimum_margin},
        {"rule",exact?"exact_context_match":"semantic_top_two_margin"}};
    if(!exact && (score<policy.minimum_pattern_score || score-second<policy.minimum_margin)){
        output["reason"]=score<policy.minimum_pattern_score?"score_below_policy":"ambiguous_candidates";
        return output;
    }
    std::string ast=best.at("template").get<std::string>();
    if(ast.find("<template") == std::string::npos || ast.find("</template>")==std::string::npos)
        throw std::runtime_error("retrieved template is not a template AST");
    auto row=best.at("row_id").get<std::uint32_t>();
    output["mode"]=exact?"exact_aiml":"retrieved_template";
    output.erase("reason");
    output.erase("fallback_route");
    output["row_id"]=row;
    output["pattern_score"]=score;
    output["template_ast"]=ast;
    output["graph_bindings"]=nlohmann::json::array();
    for(const auto& key:relational_keys::for_row(keys,row))
        output["graph_bindings"].push_back({{"record_id",key.record_id},
            {"entity_id",key.entity_id},{"relation_type",key.relation_type},
            {"graph_contract_hash",key.graph_contract_hash},{"graph_node_id",key.graph_node_id}});
    return output;
}
}
