#include "relational_graph.h"
#include "file_digest.h"
#include "relational_keys.h"
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <map>
#include <regex>
#include <set>
#include <stdexcept>

namespace micronaut::relational_graph {
namespace {
using Json=nlohmann::json;
struct Node {unsigned id,row;std::string role,record_id,entity_id;};
struct Edge {unsigned source,target,row;std::string relation;};
void require(bool valid,const char* message){if(!valid)throw std::runtime_error(message);}
std::string trim(std::string s){
    auto first=s.find_first_not_of(" \t\r\n");if(first==std::string::npos)return {};
    auto last=s.find_last_not_of(" \t\r\n");return s.substr(first,last-first+1);
}
std::string local_file(const std::filesystem::path& dir,const Json& manifest,const char* field){
    std::filesystem::path name=manifest.at(field).get<std::string>();
    require(!name.empty()&&!name.is_absolute()&&!name.has_parent_path(),"invalid graph binding path");
    return (dir/name).string();
}
}
Json attach_aiml_pilot(const Json& retrieval,const std::string& root){
    require(retrieval.at("schema")=="gemma.bridge.retrieval.v1"&&
            retrieval.at("authority")=="data_only"&&retrieval.at("graph_evidence")==false,
            "invalid retrieval for graph binding");
    const auto dir=std::filesystem::path(root)/"build/aiml-relational-pilot";
    const auto manifest_path=(dir/"manifest.json").string();
    require(micronaut::file_sha256(manifest_path)==
            "7f354566900fcb71fe5d7447d1664c68e185ea718aaed1751cc64d8fa8796a14",
            "graph binding manifest is not host-pinned");
    std::ifstream manifest_input(manifest_path,std::ios::binary);
    const Json manifest=Json::parse(manifest_input);
    require(manifest.at("schema")=="gemma.bridge.graph-binding.v1"&&
            manifest.at("authority")=="data_only"&&
            manifest.at("store_id")=="aiml-embeddinggemma2"&&
            manifest.at("source_sha256")==retrieval.at("source_sha256"),
            "graph binding source mismatch");
    const auto graph_path=local_file(dir,manifest,"graph_file");
    const auto keys_path=local_file(dir,manifest,"keys_file");
    const auto pairs_path=(std::filesystem::path(root)/
        "build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl").string();
    require(micronaut::file_sha256(graph_path)==manifest.at("graph_sha256")&&
            micronaut::file_sha256(keys_path)==manifest.at("keys_sha256")&&
            micronaut::file_sha256(pairs_path)==manifest.at("pairs_sha256"),
            "graph binding artifact digest mismatch");
    const auto graph_hash=manifest.at("graph_sha256").get<std::string>();
    auto keys=relational_keys::load_jsonl(keys_path,"aiml-embeddinggemma2",
        manifest.at("vector_rows").get<unsigned>(),graph_hash,
        manifest.at("node_count").get<unsigned>());

    const std::regex node_re(R"g(^node \[ id ([0-9]+) role "(pattern|template)" row ([0-9]+) record_id "([^"]+)" entity_id "([^"]+)" \]$)g");
    const std::regex edge_re(R"g(^edge \[ source ([0-9]+) target ([0-9]+) relation "([^"]+)" evidence_row ([0-9]+) \]$)g");
    std::ifstream graph(graph_path,std::ios::binary);require(bool(graph),"cannot open graph");
    std::map<unsigned,Node> nodes;std::vector<Edge> edges;
    std::string line;unsigned stage=0;std::smatch match;
    while(std::getline(graph,line)){
        line=trim(line);if(line.empty())continue;
        if(stage==0){require(line=="graph [","invalid graph opening");stage=1;continue;}
        if(stage==1){require(line=="schema \"gemma.bridge.aiml-graph.v1\"","invalid graph schema");stage=2;continue;}
        if(stage==2){require(line=="directed 1","invalid graph direction");stage=3;continue;}
        if(line=="]"){require(stage==3,"invalid graph closing");stage=4;continue;}
        require(stage==3,"unexpected graph content");
        if(std::regex_match(line,match,node_re)){
            Node node{unsigned(std::stoul(match[1])),unsigned(std::stoul(match[3])),
                match[2],match[4],match[5]};
            require(nodes.emplace(node.id,node).second,"duplicate graph node");
        }else if(std::regex_match(line,match,edge_re)){
            edges.push_back({unsigned(std::stoul(match[1])),unsigned(std::stoul(match[2])),
                unsigned(std::stoul(match[4])),match[3]});
        }else throw std::runtime_error("unsupported graph declaration");
    }
    require(stage==4&&nodes.size()==manifest.at("node_count").get<std::size_t>()&&
            edges.size()==manifest.at("edge_count").get<std::size_t>(),"graph counts mismatch");
    for(unsigned id=0;id<nodes.size();++id)require(nodes.count(id)!=0,"graph node IDs are not dense");
    std::set<unsigned> evidence_rows;
    for(const auto& edge:edges){
        require(nodes.count(edge.source)&&nodes.count(edge.target),"dangling graph edge");
        const auto& from=nodes.at(edge.source);const auto& to=nodes.at(edge.target);
        require(edge.relation=="has_template"&&from.role=="pattern"&&to.role=="template"&&
                from.row==edge.row&&to.row==edge.row&&from.record_id==to.record_id&&
                evidence_rows.insert(edge.row).second,"invalid graph edge evidence");
    }
    require(keys.size()==nodes.size(),"graph keys do not cover nodes");
    for(const auto& key:keys){
        const auto& node=nodes.at(key.graph_node_id);
        require(key.vector_row==node.row&&key.record_id==node.record_id&&
                key.entity_id==node.entity_id&&key.relation_type==node.role,
                "relational key disagrees with graph node");
    }
    std::map<unsigned,Json> pairs;
    std::ifstream pair_input(pairs_path,std::ios::binary);require(bool(pair_input),"cannot open pair evidence");
    unsigned row=0;
    while(std::getline(pair_input,line)){
        if(evidence_rows.count(row)){
            auto pair=Json::parse(line);
            require(pair.at("index")==row&&pair.at("A").at("vector_row")==row&&
                    pair.at("B").at("vector_row")==row&&pair.at("authority")=="data_only",
                    "graph edge pair evidence mismatch");
            pairs.emplace(row,std::move(pair));
        }
        ++row;
    }
    require(row==manifest.at("vector_rows").get<unsigned>()&&pairs.size()==edges.size(),
            "graph edge evidence is incomplete");
    Json output=retrieval;
    output["graph_contract_hash"]=graph_hash;
    for(auto& hit:output["hits"]){
        unsigned hit_row=hit.at("row_id").get<unsigned>();
        hit["graph_bindings"]=Json::array();hit["graph_edges"]=Json::array();
        hit["graph_evidence"]=false;
        if(!evidence_rows.count(hit_row))continue;
        const auto& pair=pairs.at(hit_row);
        require(hit.at("pattern")==pair.at("pattern")&&hit.at("template")==pair.at("template"),
                "retrieved text differs from graph source evidence");
        for(const auto& key:relational_keys::for_row(keys,hit_row))
            hit["graph_bindings"].push_back({{"record_id",key.record_id},
                {"entity_id",key.entity_id},{"role",key.relation_type},
                {"node_id",key.graph_node_id}});
        for(const auto& edge:edges)if(edge.row==hit_row)
            hit["graph_edges"].push_back({{"source",edge.source},{"target",edge.target},
                {"relation",edge.relation},{"evidence_row",edge.row}});
        hit["graph_evidence"]=true;
    }
    return output;
}
}
