#include "../micronaut_translation.h"
#include "../relational_graph.h"
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>

using Json=nlohmann::json;
namespace mt=micronaut::micronaut_translation;
template<class F> void rejects(F f){try{f();throw std::logic_error("expected rejection");}
    catch(const std::logic_error&){throw;}catch(const std::exception&){}}
int main(){
    try{
        const std::string root=std::filesystem::current_path().string();
        auto policy=micronaut::conversation::load_policy(root+"/build/gemma-response-policy.v1.json");
        std::ifstream pairs(root+"/build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl");
        std::string line;std::getline(pairs,line);auto pair0=Json::parse(line);
        std::getline(pairs,line);auto pair1=Json::parse(line);
        Json hits=Json::array();
        for(const auto& pair:{pair1,pair0})hits.push_back({{"row_id",pair.at("index")},
            {"pattern",pair.at("pattern")},{"that",pair.at("that")},
            {"topic",pair.at("topic")},{"template",pair.at("template")},
            {"pattern_score",pair.at("index")==1?0.95:0.70}});
        Json raw={{"schema","gemma.bridge.retrieval.v1"},{"authority","data_only"},
            {"semantic_commit",false},{"graph_evidence",false},
            {"source_sha256",policy.source_sha256},{"hits",hits}};
        auto retrieval=micronaut::relational_graph::attach_aiml_pilot(raw,root);
        std::ifstream manifest_in(root+"/build/aiml-relational-pilot/manifest.json");
        auto manifest=Json::parse(manifest_in);
        auto keys=micronaut::relational_keys::load_jsonl(root+"/build/aiml-relational-pilot/keys.jsonl",
            "aiml-embeddinggemma2",manifest.at("vector_rows").get<unsigned>(),
            manifest.at("graph_sha256").get<std::string>(),manifest.at("node_count").get<unsigned>());
        micronaut::conversation::Context exact_context{"what is ai","",""};
        auto exact=micronaut::conversation::propose(exact_context,retrieval,keys,policy);
        auto checked=mt::verify_and_translate(root,exact_context,retrieval,exact,policy);
        if(checked.at("mode")!="exact_aiml"||checked.at("row_id")!=1||
           checked.at("template_ast").at("tag")!="template"||
           checked.at("graph_bindings").size()!=2||checked.at("emit")!=false)return 1;
        micronaut::conversation::Context semantic_context{"EXPLAIN AI","",""};
        auto semantic=micronaut::conversation::propose(semantic_context,retrieval,keys,policy);
        if(mt::verify_and_translate(root,semantic_context,retrieval,semantic,policy).at("mode")!=
            "retrieved_template")return 2;
        auto ambiguous_raw=raw;ambiguous_raw["hits"][1]["pattern_score"]=0.94;
        auto ambiguous=micronaut::relational_graph::attach_aiml_pilot(ambiguous_raw,root);
        auto fallback=micronaut::conversation::propose(semantic_context,ambiguous,keys,policy);
        if(mt::verify_and_translate(root,semantic_context,ambiguous,fallback,policy)
            .at("fallback_route")!="existing_aiml")return 3;
        auto empty_raw=raw;empty_raw["hits"]=Json::array();
        auto empty=micronaut::relational_graph::attach_aiml_pilot(empty_raw,root);
        auto no_hit=micronaut::conversation::propose(semantic_context,empty,keys,policy);
        if(mt::verify_and_translate(root,semantic_context,empty,no_hit,policy)
            .at("decision").at("rule")!="no_hit")return 6;
        auto tampered_score=retrieval;tampered_score["hits"][0]["pattern_score"]=0.99;
        rejects([&]{mt::verify_and_translate(root,exact_context,tampered_score,exact,policy);});
        auto changed=exact;changed["decision"]["rule"]="forged";
        rejects([&]{mt::verify_and_translate(root,exact_context,retrieval,changed,policy);});
        rejects([&]{mt::verify_and_translate(root,semantic_context,retrieval,exact,policy);});
        auto altered=retrieval;altered["hits"][0]["template"]="<template>wrong</template>";
        rejects([&]{mt::verify_and_translate(root,exact_context,altered,exact,policy);});
        auto source=retrieval;source["source_sha256"]=std::string(64,'0');
        rejects([&]{mt::verify_and_translate(root,exact_context,source,exact,policy);});
        rejects([]{mt::parse_template_ast("<template><script>bad</script></template>");});
        rejects([]{mt::parse_template_ast("<template><set name=x>bad</template>");});
        rejects([]{mt::parse_template_ast("<template>⟁</template>");});
        rejects([]{mt::parse_template_ast("<template name=x>bad</template>");});
        rejects([]{mt::parse_template_ast("<template><star index=0/></template>");});
        auto parsed=mt::parse_template_ast("<template><think><set name=field>⟁CAR</set></think></template>");
        if(parsed.at("children").at(0).at("tag")!="think")return 4;
        std::cout<<"Micronaut translation and Ch'en checks passed\n";
        return 0;
    }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 5;}
}
