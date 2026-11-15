#include "../conversation.h"
#include "../file_digest.h"
#include "../relational_keys.h"
#include "../vector_store.h"
#include <filesystem>
#include <fstream>
#include <iostream>

int main(){
    namespace fs=std::filesystem;
    auto folder=fs::temp_directory_path()/"micronaut-domain-bridge-test";
    try{
        fs::create_directories(folder);
        {std::ofstream source(folder/"records.jsonl");source<<"{\"id\":\"r0\"}\n{\"id\":\"r1\"}\n";}
        {std::ofstream out(folder/"vectors.npy",std::ios::binary);
            const char magic[8]={'\x93','N','U','M','P','Y',1,0};out.write(magic,8);
            std::string header="{'descr': '<f4', 'fortran_order': False, 'shape': (2, 2), }";
            header.resize(117,' ');header.push_back('\n');
            char length[2]={118,0};out.write(length,2);out.write(header.data(),header.size());
            float values[4]={1,0,0,1};out.write(reinterpret_cast<char*>(values),sizeof(values));}
        nlohmann::json manifest={{"schema","gemma.bridge.domain-store.v1"},{"authority","data_only"},
            {"semantic_commit",false},{"store_id","test"},{"model_snapshot","fixture"},
            {"dtype","float32-le"},{"rows",2},{"dimensions",2},
            {"source_file","records.jsonl"},{"vector_file","vectors.npy"},
            {"source_sha256",micronaut::file_sha256((folder/"records.jsonl").string())},
            {"vector_sha256",micronaut::file_sha256((folder/"vectors.npy").string())}};
        {std::ofstream out(folder/"manifest.json");out<<manifest.dump();}
        auto store=micronaut::vector_store::load_domain_store((folder/"manifest.json").string());
        if(store.vectors.rows!=2||store.vectors.dim!=2||store.vectors.values[3]!=1)return 1;
        const std::string graph_hash(64,'a');
        nlohmann::json key={{"schema","gemma.bridge.relational-key.v1"},{"authority","data_only"},
            {"store_id","test"},{"record_id","r0"},{"vector_row",0},{"entity_id","entity:0"},
            {"relation_type","mentions"},{"graph_contract_hash",graph_hash},{"graph_node_id",1}};
        {std::ofstream out(folder/"keys.jsonl");out<<key.dump()<<'\n';}
        auto keys=micronaut::relational_keys::load_jsonl((folder/"keys.jsonl").string(),"test",2,graph_hash,4);
        if(keys.size()!=1||micronaut::relational_keys::for_row(keys,0).size()!=1)return 2;
        {std::ofstream out(folder/"duplicate.jsonl");out<<key.dump()<<'\n'<<key.dump()<<'\n';}
        try{(void)micronaut::relational_keys::load_jsonl((folder/"duplicate.jsonl").string(),"test",2,graph_hash,4);return 7;}
        catch(const std::runtime_error&){}
        nlohmann::json hits=nlohmann::json::array({
            {{"row_id",0},{"pattern","WHAT IS AI"},{"that",""},{"topic",""},
             {"template","<template>Artificial intelligence.</template>"},{"pattern_score",0.9}},
            {{"row_id",1},{"pattern","HELLO"},{"that",""},{"topic",""},
             {"template","<template>Hello.</template>"},{"pattern_score",0.7}}});
        nlohmann::json retrieval={{"schema","gemma.bridge.retrieval.v1"},{"authority","data_only"},
            {"semantic_commit",false},{"source_sha256","68398ce5f05881adeb96fbc9b76bfb65ce8a033e8334796b5cdea0115972b2b4"},{"hits",hits}};
        auto policy=micronaut::conversation::load_policy("build/gemma-response-policy.v1.json");
        {std::ofstream out(folder/"changed-policy.json");out<<"{}";}
        try{(void)micronaut::conversation::load_policy((folder/"changed-policy.json").string());return 14;}
        catch(const std::runtime_error&){}
        auto exact=micronaut::conversation::propose({"What is AI","",""},retrieval,keys,policy);
        if(exact.at("mode")!="exact_aiml"||exact.at("graph_bindings").size()!=1||
           exact.at("policy_sha256")!=policy.sha256)return 3;
        auto semantic=micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,policy);
        if(semantic.at("mode")!="retrieved_template")return 4;
        auto lower_exact=micronaut::conversation::propose({"Hello","",""},retrieval,keys,policy);
        if(lower_exact.at("mode")!="exact_aiml"||lower_exact.at("row_id")!=1)return 9;
        auto tied_exact=retrieval;
        tied_exact["hits"][0]["row_id"]=1;
        tied_exact["hits"][1]["row_id"]=0;
        tied_exact["hits"][0]["pattern"]="HELLO";
        auto lowest=micronaut::conversation::propose({"Hello","",""},tied_exact,keys,policy);
        if(lowest.at("row_id")!=0)return 16;
        retrieval["hits"][1]["pattern_score"]=0.88;
        auto fallback=micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,policy);
        if(fallback.at("mode")!="fallback"||fallback.at("reason")!="ambiguous_candidates"||
           fallback.at("fallback_route")!="existing_aiml")return 5;
        retrieval["hits"][0]["pattern_score"]=0.8;
        retrieval["hits"][1]["pattern_score"]=0.7;
        auto low=micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,policy);
        if(low.at("reason")!="score_below_policy")return 10;
        retrieval["hits"][1]["pattern_score"]=0.9;
        try{(void)micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,policy);return 15;}
        catch(const std::runtime_error&){}
        retrieval["hits"]=nlohmann::json::array();
        auto no_hits=micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,policy);
        if(no_hits.at("mode")!="fallback"||no_hits.at("reason")!="no_admitted_candidate")return 11;
        auto forged=policy;forged.minimum_margin=0;
        try{(void)micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,forged);return 13;}
        catch(const std::runtime_error&){}
        retrieval["source_sha256"]=std::string(64,'0');
        try{(void)micronaut::conversation::propose({"Explain AI","",""},retrieval,keys,policy);return 12;}
        catch(const std::runtime_error&){}
        manifest["vector_sha256"]=std::string(64,'0');
        {std::ofstream out(folder/"bad-manifest.json");out<<manifest.dump();}
        try{(void)micronaut::vector_store::load_domain_store((folder/"bad-manifest.json").string());return 8;}
        catch(const std::runtime_error&){}
        fs::remove_all(folder);
        std::cout<<"domain store, relational keys, and conversation proposals passed\n";return 0;
    }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 6;}
}
