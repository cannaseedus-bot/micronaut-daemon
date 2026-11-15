#include "../gemma_bridge_route.h"
#include "../semantic_bridge.h"
#include "../vector_store.h"
#include "../query_attestation.h"
#include <nlohmann/json.hpp>
#include <cstdlib>
#include <filesystem>
#include <iostream>

using Json=nlohmann::json;
namespace fs=std::filesystem;
const std::string key="test-only-host-attestation-key-32-bytes";
void attest(Json& bridge){
    const auto query=bridge.at("query_vector").get<std::vector<float>>();
    const auto bytes=std::string(reinterpret_cast<const char*>(query.data()),query.size()*sizeof(float));
    const auto vector_sha=micronaut::query_attestation::sha256_hex(bytes);
    const std::string manifest_sha="6bce89f103aef62513c2b6f34ce760465b6b5f71085afc721f7bc524ff08a01b";
    const auto utterance=bridge.at("context").at("utterance").get<std::string>();
    const auto message="gemma.bridge.query-attestation.v1\n"+utterance+"\n"+vector_sha+"\n"+manifest_sha;
    bridge["attestation"]={{"schema","gemma.bridge.query-attestation.v1"},
        {"model","google/embeddinggemma-2"},{"prompt_name","Retrieval-query"},
        {"manifest_sha256",manifest_sha},{"vector_sha256",vector_sha},
        {"mac_sha256",micronaut::query_attestation::hmac_sha256_hex(key,message)}};
}
int main(int argc,char** argv){
    try{
        const auto root=fs::current_path().string();
        if(argc==2&&std::string(argv[1])=="--fixture-from-stdin"){
            std::string line;std::getline(std::cin,line);
            const auto input=Json::parse(line);
            const auto vector=input.at("query_vector").get<std::vector<float>>();
            const auto utterance=input.at("utterance").get<std::string>();
            Json output={{"context",{{"utterance",utterance},{"that",""},{"topic",""}}},
                {"query_vector",vector},{"attestation",input.at("attestation")},
                {"top_k",5},{"retrieval",micronaut::semantic_bridge::retrieve(root,vector,5)}};
            std::cout<<output.dump()<<'\n';return 0;
        }
        auto matrix=micronaut::vector_store::load_npy(root+
            "/build/io/aiml-embeddinggemma2-vectors/pattern_vectors.f32.npy");
        std::vector<float> query(matrix.values.begin()+2*256,matrix.values.begin()+3*256);
        auto retrieval=micronaut::semantic_bridge::retrieve(root,query,1);
        if(retrieval.at("hits").at(0).at("row_id")!=2)return 1;
        Json bridge={{"context",{{"utterance","WHO CREATED AIML"},{"that",""},{"topic",""}}},
            {"query_vector",query},{"top_k",1},{"retrieval",retrieval}};
        attest(bridge);
        if(argc==2&&std::string(argv[1])=="--fixture"){
            std::cout<<bridge.dump()<<'\n';return 0;
        }
        micronaut::MicronautOp op;op.id="test";op.op="gemma.bridge.propose";
        op.ingress="stdin";op.raw=Json({{"op",op.op},{"bridge",bridge}}).dump();
#ifdef _WIN32
        _putenv_s("MICRONAUT_GEMMA_BRIDGE","");
#else
        unsetenv("MICRONAUT_GEMMA_BRIDGE");
#endif
        if(micronaut::gemma_bridge_route::propose_execute(op).ok)return 2;
#ifdef _WIN32
        _putenv_s("MICRONAUT_GEMMA_BRIDGE","1");
        _putenv_s("MICRONAUT_GEMMA_ATTEST_KEY",key.c_str());
#else
        setenv("MICRONAUT_GEMMA_BRIDGE","1",1);
        setenv("MICRONAUT_GEMMA_ATTEST_KEY",key.c_str(),1);
#endif
        auto admitted=micronaut::gemma_bridge_route::propose_execute(op);
        if(!admitted.ok){std::cerr<<admitted.error_message<<'\n';return 3;}
        auto result=Json::parse(admitted.result_json);
        if(result.at("selection")!="verified_plain_template"||result.contains("text")||
           result.at("row_id")!=2||result.at("retrieval_verified")!=true)return 4;
        op.op="chat.generate";op.raw=Json({{"op",op.op},{"bridge",bridge}}).dump();
        auto selected=micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");
        if(selected.at("text")!="Dr. Richard S. Wallace created AIML.")return 5;
        op.raw=Json({{"op",op.op},{"bridge",bridge},
            {"response_mode","vector_extended_v1"}}).dump();
        auto extended=micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");
        if(extended.at("selection")!="verified_vector_response"||
           extended.at("vector_response").at("key")!="⟁AIML_ROW_2"||
           extended.at("vector_response").at("graph_bindings").size()!=2||
           extended.at("text")!="Dr. Richard S. Wallace created AIML.\n\nVerified AIML pattern: WHO CREATED AIML [⟁AIML_ROW_2]")return 16;
        op.raw=Json({{"op",op.op},{"bridge",bridge},
            {"response_mode","unverified"}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");return 17;}
        catch(const std::exception&){}
        auto semantic_bridge=bridge;
        semantic_bridge["context"]["utterance"]="EXPLAIN AIML";
        attest(semantic_bridge);
        op.raw=Json({{"op",op.op},{"bridge",semantic_bridge}}).dump();
        auto semantic=micronaut::gemma_bridge_route::evaluate(op,"EXPLAIN AIML");
        if(semantic.at("proposal").at("mode")!="retrieved_template"||
           semantic.at("selection")!="verified_plain_template"||
           semantic.at("row_id")!=2)return 6;
        auto nearest=micronaut::semantic_bridge::retrieve(root,query,2);
        const auto neighbor=nearest.at("hits").at(1).at("row_id").get<std::size_t>();
        std::vector<float> midpoint(256);
        for(std::size_t i=0;i<256;++i)
            midpoint[i]=query[i]+matrix.values[neighbor*256+i];
        auto ambiguous_bridge=semantic_bridge;
        ambiguous_bridge["query_vector"]=midpoint;
        ambiguous_bridge["top_k"]=2;
        ambiguous_bridge["retrieval"]=micronaut::semantic_bridge::retrieve(root,midpoint,2);
        attest(ambiguous_bridge);
        op.raw=Json({{"op",op.op},{"bridge",ambiguous_bridge}}).dump();
        auto ambiguous=micronaut::gemma_bridge_route::evaluate(op,"EXPLAIN AIML");
        if(ambiguous.at("proposal").at("mode")!="fallback"||
           ambiguous.at("proposal").at("decision").at("rule")!="semantic_top_two_margin"||
           ambiguous.at("selection")!="existing_aiml"||ambiguous.contains("text"))return 14;
        op.raw=Json({{"op",op.op},{"bridge",bridge}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"different");return 7;}
        catch(const std::exception&){}
        auto tampered=bridge;
        tampered["retrieval"]["hits"][0]["pattern_score"]=0.9;
        op.raw=Json({{"op",op.op},{"bridge",tampered}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");return 8;}
        catch(const std::exception&){}
        auto forged_origin=bridge;
        forged_origin["context"]["utterance"]="SOMETHING ELSE";
        op.raw=Json({{"op",op.op},{"bridge",forged_origin}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"SOMETHING ELSE");return 15;}
        catch(const std::exception&){}
        auto no_hits=bridge;no_hits["retrieval"]["hits"]=Json::array();
        op.raw=Json({{"op",op.op},{"bridge",no_hits}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");return 9;}
        catch(const std::exception&){}
        auto nonfinite=bridge;nonfinite["query_vector"][0]=1e300;
        op.raw=Json({{"op",op.op},{"bridge",nonfinite}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");return 10;}
        catch(const std::exception&){}
        nonfinite=bridge;nonfinite["query_vector"]=Json::array();
        op.raw=Json({{"op",op.op},{"bridge",nonfinite}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");return 11;}
        catch(const std::exception&){}
        op.ingress="http";op.raw=Json({{"op",op.op},{"bridge",bridge}}).dump();
        try{(void)micronaut::gemma_bridge_route::evaluate(op,"WHO CREATED AIML");return 12;}
        catch(const std::exception&){}
        std::cout<<"Gemma bridge v3 attestation, score replay, and semantic selection passed\n";return 0;
    }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 13;}
}
