#pragma once
#include <cstdint>
#include <string>
#include <vector>

namespace micronaut::relational_keys {
struct Key {
    std::string store_id;
    std::string record_id;
    std::uint32_t vector_row=0;
    std::string entity_id;
    std::string relation_type;
    std::string graph_contract_hash;
    std::uint32_t graph_node_id=0;
};

// A row may bind several entities; duplicate exact bindings are rejected.
std::vector<Key> load_jsonl(const std::string& path,const std::string& store_id,
                            std::uint32_t vector_rows,const std::string& graph_contract_hash,
                            std::uint32_t graph_nodes);
std::vector<Key> for_row(const std::vector<Key>& keys,std::uint32_t row);
}
