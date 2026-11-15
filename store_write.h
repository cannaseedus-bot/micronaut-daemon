#pragma once
#include <nlohmann/json.hpp>
#include <cstdint>
#include <string>

namespace micronaut::store_write {
// Creates a new directory of contiguous row shards. Never overwrites a store.
nlohmann::json write_shards(const std::string& source_npy,const std::string& output_dir,
                           const std::string& store_id,const std::string& model_id,
                           std::uint32_t rows_per_shard);
void verify_shards(const std::string& manifest_path,const std::string& source_npy);
}
