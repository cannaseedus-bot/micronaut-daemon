#include "semantic_bridge.h"
#include "file_digest.h"
#include "vector_store.h"
#include "relational_graph.h"
#include <algorithm>
#include <cmath>
#include <fstream>
#include <limits>
#include <stdexcept>
#include <unordered_map>

namespace micronaut::semantic_bridge {
namespace {
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
struct Hit {unsigned row;double pattern_score;};
double cosine(const float* row,const std::vector<float>& query,unsigned dim){
    double dot=0.0,norm=0.0;
    for(unsigned c=0;c<dim;++c){
        require(std::isfinite(row[c]),"nonfinite artifact vector");
        dot+=double(row[c])*query[c];norm+=double(row[c])*row[c];
    }
    require(norm>0.0,"zero artifact vector");
    return std::clamp(dot/std::sqrt(norm),-1.0,1.0);
}
}
Json retrieve(const std::string& root,const std::vector<float>& query,std::size_t top_k){
    require(query.size()==256 && top_k>=1 && top_k<=64,"invalid query shape or top_k");
    double query_norm=0.0;
    for(float x:query){require(std::isfinite(x),"nonfinite query vector");query_norm+=double(x)*x;}
    require(query_norm>0.0,"zero query vector");
    std::vector<float> normalized(query.size());
    for(std::size_t i=0;i<query.size();++i)normalized[i]=float(double(query[i])/std::sqrt(query_norm));

    const std::string base=root+"/build/io/aiml-embeddinggemma2-vectors/";
    const std::string record_path=root+"/build/ccc4-vector-binding.candidate.json";
    std::ifstream record_input(record_path,std::ios::binary);
    require(bool(record_input),"missing vector binding record");
    const auto record=Json::parse(record_input);
    require(record.at("schema")=="ccc4.vector-binding.candidate.v1" &&
            record.at("materialized")==false && record.at("execution_authorized")==false &&
            record.at("persistence_authorized")==false,"invalid vector binding authority");
    require(file_sha256(base+"manifest.json")==record.at("manifest_sha256").get<std::string>(),
            "vector manifest digest mismatch");
    std::ifstream manifest_input(base+"manifest.json",std::ios::binary);
    const auto manifest=Json::parse(manifest_input);
    require(manifest.at("model")=="google/embeddinggemma-2" &&
            manifest.at("dimensions")==256 && manifest.at("dtype")=="float32" &&
            manifest.at("authority")=="data_only" && manifest.at("semanticCommit")==false,
            "unsupported embedding manifest");
    require(file_sha256(root+"/build/io/aiml-corpus.jsonl")==record.at("source_sha256").get<std::string>(),
            "AIML source digest mismatch");
    const auto& artifacts=record.at("artifacts");
    auto checked=[&](const char* name){
        std::string path=base+name;
        require(file_sha256(path)==artifacts.at(name).at("sha256").get<std::string>(),"vector artifact digest mismatch");
        auto matrix=vector_store::load_npy(path);
        require(matrix.rows==99524 && matrix.dim==256,"vector artifact shape mismatch");
        return matrix;
    };
    auto patterns=checked("pattern_vectors.f32.npy");
    auto templates=checked("template_vectors.f32.npy");
    require(file_sha256(base+"aiml_pattern_template_pairs.jsonl")==record.at("alignment_digest").get<std::string>(),
            "pair alignment digest mismatch");
    std::vector<Hit> hits;hits.reserve(top_k);
    for(unsigned row=0;row<patterns.rows;++row){
        double score=cosine(patterns.values.data()+std::size_t(row)*256,normalized,256);
        Hit hit{row,score};
        auto before=[](const Hit& a,const Hit& b){return a.pattern_score>b.pattern_score ||
            (a.pattern_score==b.pattern_score && a.row<b.row);};
        auto pos=std::lower_bound(hits.begin(),hits.end(),hit,before);
        if(pos!=hits.end() || hits.size()<top_k){hits.insert(pos,hit);if(hits.size()>top_k)hits.pop_back();}
    }
    std::unordered_map<unsigned,Json> pairs;
    for(const auto& hit:hits)pairs.emplace(hit.row,Json{});
    std::ifstream pair_input(base+"aiml_pattern_template_pairs.jsonl",std::ios::binary);
    require(bool(pair_input),"missing pair records");
    std::string line;unsigned index=0;
    while(std::getline(pair_input,line)){
        if(pairs.count(index)){
            Json pair=Json::parse(line);
            require(pair.at("index")==index && pair.at("A").at("vector_row")==index &&
                    pair.at("B").at("vector_row")==index && pair.at("authority")=="data_only" &&
                    pair.at("graph_evidence")==false,"pair row alignment mismatch");
            pairs[index]=std::move(pair);
        }
        ++index;
    }
    require(index==patterns.rows,"pair record count mismatch");
    Json output={{"schema","gemma.bridge.retrieval.v1"},{"authority","data_only"},
                 {"semantic_commit",false},{"graph_evidence",false},
                 {"model","google/embeddinggemma-2"},
                 {"source_sha256",record.at("source_sha256")},
                 {"hits",Json::array()}};
    for(const auto& hit:hits){
        require(!pairs.at(hit.row).is_null(),"missing selected pair");
        const float* template_row=templates.values.data()+std::size_t(hit.row)*256;
        double template_score=cosine(template_row,normalized,256);
        const auto& pair=pairs.at(hit.row);
        output["hits"].push_back({{"row_id",hit.row},{"pattern_score",hit.pattern_score},
            {"template_score",template_score},{"pattern_template_score",pair.at("cosine_similarity")},
            {"pattern",pair.at("pattern")},{"that",pair.at("that")},{"topic",pair.at("topic")},
            {"template",pair.at("template")}});
    }
    return relational_graph::attach_aiml_pilot(output,root);
}
}
