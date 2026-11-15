#include "../semantic_bridge.h"
#include "../relational_graph.h"
#include "../vector_store.h"
#include <iostream>
#include <limits>

int main(int argc,char** argv){
    if(argc!=2)return 2;
    try{
        const std::string root=argv[1];
        auto matrix=micronaut::vector_store::load_npy(
            root+"/build/io/aiml-embeddinggemma2-vectors/pattern_vectors.f32.npy");
        std::vector<float> query(matrix.values.begin(),matrix.values.begin()+matrix.dim);
        auto result=micronaut::semantic_bridge::retrieve(root,query,64);
        if(result.at("schema")!="gemma.bridge.retrieval.v1" ||
           result.at("authority")!="data_only" ||
           result.at("semantic_commit")!=false ||
           result.at("hits").size()!=64)return 3;
        bool found=false,unbound=false;
        for(const auto& hit:result.at("hits"))if(hit.at("row_id")==0){
            found=true;
            if(hit.at("pattern_score").get<double>()<0.9999)return 4;
            if(hit.at("graph_evidence")!=true||hit.at("graph_bindings").size()!=2||
               hit.at("graph_edges").size()!=1)return 7;
        }else if(hit.at("graph_evidence")==false && hit.at("graph_edges").empty())unbound=true;
        if(!found||!unbound)return 5;
        auto tampered=result;
        tampered["graph_evidence"]=false;
        for(auto& hit:tampered["hits"])if(hit.at("row_id")==0){hit["pattern"]="UNSUPPORTED PATTERN";break;}
        try{(void)micronaut::relational_graph::attach_aiml_pilot(tampered,root);return 8;}
        catch(const std::runtime_error&){}
        try{(void)micronaut::semantic_bridge::retrieve(root,std::vector<float>(256,0),1);return 6;}
        catch(const std::runtime_error&){}
        query[0]=std::numeric_limits<float>::quiet_NaN();
        try{(void)micronaut::semantic_bridge::retrieve(root,query,1);return 9;}
        catch(const std::runtime_error&){}
        query[0]=std::numeric_limits<float>::infinity();
        try{(void)micronaut::semantic_bridge::retrieve(root,query,1);return 10;}
        catch(const std::runtime_error&){}
        std::cout<<"semantic bridge: aligned retrieval and query rejection passed\n";
        return 0;
    }catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}
}
