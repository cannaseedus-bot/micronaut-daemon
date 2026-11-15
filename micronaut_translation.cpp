#include "micronaut_translation.h"
#include "file_digest.h"
#include "relational_graph.h"
#include "relational_keys.h"
#include <algorithm>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <set>
#include <stdexcept>

namespace micronaut::micronaut_translation {
namespace {
using Json=nlohmann::json;
void require(bool valid,const char* message){if(!valid)throw std::runtime_error(message);}
const std::set<std::string> tags={"template","think","set","get","srai","star","thatstar",
    "topicstar","bot","condition","random","li","uppercase","lowercase","formal","sentence","br","p"};
const std::set<std::string> attrs={"name","value","index"};
bool ascii_name(char ch){return (ch>='a'&&ch<='z')||(ch>='A'&&ch<='Z')||
    (ch>='0'&&ch<='9')||ch=='_'||ch=='-';}
void check_keys(const std::string& value){
    const std::string marker="⟁";
    std::size_t pos=0;
    while((pos=value.find(marker,pos))!=std::string::npos){
        pos+=marker.size();
        std::size_t start=pos;
        while(pos<value.size()&&((value[pos]>='A'&&value[pos]<='Z')||
             (value[pos]>='0'&&value[pos]<='9')||value[pos]=='_'||value[pos]=='-'))++pos;
        require(pos>start,"invalid K'UHUL key token");
    }
}
class AstParser {
    const std::string& text_;
    std::size_t pos_=0,nodes_=0;
    void space(){while(pos_<text_.size()&&std::isspace(static_cast<unsigned char>(text_[pos_])))++pos_;}
    std::string name(){
        std::size_t start=pos_;while(pos_<text_.size()&&ascii_name(text_[pos_]))++pos_;
        require(pos_>start,"invalid template tag or attribute name");return text_.substr(start,pos_-start);
    }
    Json parse_node(unsigned depth){
        require(depth<=32&&++nodes_<=4096,"template AST limit exceeded");
        if(text_[pos_]!='<'){
            std::size_t start=pos_;while(pos_<text_.size()&&text_[pos_]!='<')++pos_;
            auto value=text_.substr(start,pos_-start);check_keys(value);
            return {{"tag","text"},{"value",value}};
        }
        ++pos_;require(pos_<text_.size()&&text_[pos_]!='/'&&text_[pos_]!='!'&&text_[pos_]!='?',
                       "unsupported template markup");
        auto tag=name();require(tags.count(tag)!=0,"unsupported AIML template tag");
        Json attributes=Json::object();
        while(true){
            space();require(pos_<text_.size(),"truncated template tag");
            if(text_[pos_]=='>'||text_[pos_]=='/')break;
            auto key=name();require(attrs.count(key)!=0&&!attributes.contains(key),"unsupported template attribute");
            space();require(pos_<text_.size()&&text_[pos_++]=='=',"invalid template attribute");
            space();require(pos_<text_.size(),"truncated template attribute");
            std::string value;
            if(text_[pos_]=='\"'||text_[pos_]=='\''){
                char quote=text_[pos_++];std::size_t start=pos_;
                while(pos_<text_.size()&&text_[pos_]!=quote)++pos_;
                require(pos_<text_.size(),"unterminated template attribute");
                value=text_.substr(start,pos_-start);++pos_;
            }else{
                std::size_t start=pos_;
                while(pos_<text_.size()&&!std::isspace(static_cast<unsigned char>(text_[pos_]))&&
                      text_[pos_]!='>'&&text_[pos_]!='/')++pos_;
                require(pos_>start,"empty template attribute");value=text_.substr(start,pos_-start);
            }
            check_keys(value);attributes[key]=value;
        }
        bool self_closing=text_[pos_]=='/';
        if(self_closing)++pos_;
        require(pos_<text_.size()&&text_[pos_++]=='>' ,"invalid template tag closure");
        if((tag=="star"||tag=="thatstar"||tag=="topicstar"||tag=="get"||tag=="bot"||tag=="br")&&!self_closing)
            throw std::runtime_error("AIML leaf tag must self-close");
        if((tag=="set"||tag=="get"||tag=="bot")&&!attributes.contains("name"))
            throw std::runtime_error("AIML tag missing name");
        for(auto it=attributes.begin();it!=attributes.end();++it){
            const bool allowed=(it.key()=="name"&&(tag=="set"||tag=="get"||tag=="bot"||tag=="condition"))||
                (it.key()=="value"&&(tag=="li"||tag=="condition"))||
                (it.key()=="index"&&(tag=="star"||tag=="thatstar"||tag=="topicstar"));
            require(allowed,"attribute is invalid for AIML tag");
            require(!it.value().get<std::string>().empty(),"empty AIML attribute value");
            if(it.key()=="index"){
                const auto number=it.value().get<std::string>();
                require(number.size()<=3&&number[0]>='1'&&number[0]<='9'&&
                    std::all_of(number.begin(),number.end(),[](char c){return c>='0'&&c<='9';}),
                    "invalid AIML wildcard index");
            }
        }
        Json children=Json::array();
        if(!self_closing){
            while(true){
                require(pos_<text_.size(),"unclosed AIML template tag");
                if(text_.compare(pos_,2,"</")==0){
                    pos_+=2;auto close=name();space();
                    require(close==tag&&pos_<text_.size()&&text_[pos_++]=='>',"mismatched AIML closing tag");
                    break;
                }
                children.push_back(parse_node(depth+1));
            }
        }
        return {{"tag",tag},{"attrs",attributes},{"children",children}};
    }
public:
    explicit AstParser(const std::string& text):text_(text){}
    Json parse(){
        require(!text_.empty()&&text_.size()<=65536,"invalid template AST size");
        space();require(pos_<text_.size()&&text_[pos_]=='<',"template AST root missing");
        auto root=parse_node(0);space();
        require(root.at("tag")=="template"&&pos_==text_.size(),"invalid template AST root or trailing data");
        return root;
    }
};
}
Json parse_template_ast(const std::string& source){return AstParser(source).parse();}
Json verify_and_translate(const std::string& root,const conversation::Context& context,
                          const Json& retrieval,const Json& candidate,const conversation::Policy& policy){
    const auto source_path=std::filesystem::path(root)/"build/io/aiml-corpus.jsonl";
    require(micronaut::file_sha256(source_path.string())==policy.source_sha256,
            "Ch'en AIML source identity mismatch");
    const auto annotated=relational_graph::attach_aiml_pilot(retrieval,root);
    require(annotated==retrieval,"Ch'en graph evidence mismatch");
    const auto manifest_path=std::filesystem::path(root)/"build/aiml-relational-pilot/manifest.json";
    std::ifstream manifest_input(manifest_path,std::ios::binary);
    const auto manifest=Json::parse(manifest_input);
    auto keys=relational_keys::load_jsonl(
        (std::filesystem::path(root)/"build/aiml-relational-pilot/keys.jsonl").string(),
        "aiml-embeddinggemma2",manifest.at("vector_rows").get<unsigned>(),
        manifest.at("graph_sha256").get<std::string>(),manifest.at("node_count").get<unsigned>());
    auto expected=conversation::propose(context,retrieval,keys,policy);
    require(candidate==expected,"Ch'en response policy outcome mismatch");
    Json result={{"schema","gemma.bridge.micronaut-proposal.v1"},
        {"authority","proposal_only"},{"verified",true},{"emit",false},
        {"source_sha256",policy.source_sha256},{"policy_id",policy.id},
        {"policy_sha256",policy.sha256},{"mode",candidate.at("mode")},
        {"decision",candidate.at("decision")}};
    if(candidate.at("mode")=="fallback"){
        result["fallback_route"]="existing_aiml";return result;
    }
    auto row=candidate.at("row_id").get<unsigned>();
    const auto pair_path=std::filesystem::path(root)/
        "build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl";
    std::ifstream pair_input(pair_path,std::ios::binary);require(bool(pair_input),"Ch'en pair source missing");
    std::string line;unsigned current=0;
    while(current<=row&&std::getline(pair_input,line))++current;
    require(current==row+1,"Ch'en selected pair row missing");
    const auto pair=Json::parse(line);
    require(pair.at("index")==row&&pair.at("A").at("vector_row")==row&&
            pair.at("B").at("vector_row")==row&&pair.at("authority")=="data_only"&&
            pair.at("template")==candidate.at("template_ast"),
            "Ch'en selected pair provenance mismatch");
    const auto& hits=retrieval.at("hits");
    auto selected=std::find_if(hits.begin(),hits.end(),[row](const Json& hit){
        return hit.at("row_id").get<unsigned>()==row;});
    require(selected!=hits.end()&&pair.at("pattern")==selected->at("pattern")&&
            pair.at("that")==selected->at("that")&&pair.at("topic")==selected->at("topic")&&
            pair.at("template")==selected->at("template"),
            "Ch'en selected hit provenance mismatch");
    const auto ast=parse_template_ast(candidate.at("template_ast").get<std::string>());
    result["row_id"]=row;
    result["template_ast"]=ast;
    result["graph_bindings"]=candidate.at("graph_bindings");
    result["key_grammar"]="glyph-token-v1";
    return result;
}
}
