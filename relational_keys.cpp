#include "relational_keys.h"
#include <nlohmann/json.hpp>
#include <fstream>
#include <regex>
#include <set>
#include <stdexcept>
#include <tuple>

namespace micronaut::relational_keys {
std::vector<Key> load_jsonl(const std::string& path,const std::string& store_id,
                            std::uint32_t vector_rows,const std::string& graph_contract_hash,
                            std::uint32_t graph_nodes){
    if(store_id.empty()||!vector_rows||!graph_nodes||graph_contract_hash.empty())
        throw std::runtime_error("invalid relational key store or graph");
    std::ifstream input(path,std::ios::binary);
    if(!input)throw std::runtime_error("cannot open relational keys");
    std::vector<Key> keys;
    std::set<std::tuple<std::string,std::uint32_t,std::string,std::string,std::string,std::uint32_t>> seen;
    const std::regex digest("^[0-9a-f]{64}$");
    std::string line;std::size_t line_number=0;
    while(std::getline(input,line)){
        ++line_number;
        if(line.empty())throw std::runtime_error("empty relational key line");
        auto json=nlohmann::json::parse(line);
        if(json.at("schema")!="gemma.bridge.relational-key.v1" ||
           json.at("store_id")!=store_id || json.at("authority")!="data_only")
            throw std::runtime_error("relational key contract mismatch");
        Key key;
        key.store_id=store_id;
        key.record_id=json.at("record_id").get<std::string>();
        key.vector_row=json.at("vector_row").get<std::uint32_t>();
        key.entity_id=json.at("entity_id").get<std::string>();
        key.relation_type=json.at("relation_type").get<std::string>();
        key.graph_contract_hash=json.at("graph_contract_hash").get<std::string>();
        key.graph_node_id=json.at("graph_node_id").get<std::uint32_t>();
        if(key.record_id.empty()||key.entity_id.empty()||key.relation_type.empty()||
           key.vector_row>=vector_rows||key.graph_node_id>=graph_nodes||
           key.graph_contract_hash!=graph_contract_hash||
           !std::regex_match(key.graph_contract_hash,digest))
            throw std::runtime_error("invalid relational key fields");
        auto identity=std::make_tuple(key.record_id,key.vector_row,key.entity_id,
                                      key.relation_type,key.graph_contract_hash,key.graph_node_id);
        if(!seen.insert(identity).second)throw std::runtime_error("duplicate relational key");
        keys.push_back(std::move(key));
    }
    if(!input.eof())throw std::runtime_error("relational key read failed");
    return keys;
}
std::vector<Key> for_row(const std::vector<Key>& keys,std::uint32_t row){
    std::vector<Key> result;
    for(const auto& key:keys)if(key.vector_row==row)result.push_back(key);
    return result;
}
}
