#include "semantic_bridge.h"
#include <nlohmann/json.hpp>
#include <cmath>
#include <iostream>
#include <stdexcept>
#include <vector>

int main(){
    try{
#ifndef MICRONAUT_SOURCE_ROOT
        throw std::runtime_error("source root not configured");
#else
        const std::string root=MICRONAUT_SOURCE_ROOT;
#endif
        nlohmann::json input;std::cin>>input;
        if(!input.is_object()||!input.at("utterance").is_string()||
           !input.at("query_vector").is_array()||
           input.at("query_vector").size()!=256||!input.at("attestation").is_object())
            throw std::runtime_error("invalid attested query request");
        const auto utterance=input.at("utterance").get<std::string>();
        if(utterance.empty()||utterance.size()>4096)throw std::runtime_error("invalid utterance");
        const auto top_k=input.value("top_k",5);
        if(top_k<1||top_k>64)throw std::runtime_error("invalid top_k");
        std::vector<float> query;query.reserve(256);
        for(const auto& value:input.at("query_vector")){
            if(!value.is_number())throw std::runtime_error("invalid query value");
            const auto scalar=value.get<float>();
            if(!std::isfinite(scalar))throw std::runtime_error("nonfinite query value");
            query.push_back(scalar);
        }
        nlohmann::json bridge={{"context",{{"utterance",utterance},{"that",""},{"topic",""}}},
            {"query_vector",query},{"attestation",input.at("attestation")},
            {"top_k",top_k},{"retrieval",micronaut::semantic_bridge::retrieve(root,query,top_k)}};
        std::cout<<bridge.dump()<<'\n';return 0;
    }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 2;}
}
