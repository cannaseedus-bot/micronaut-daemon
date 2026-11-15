#pragma once
#include <nlohmann/json.hpp>
#include <cstddef>
#include <string>
#include <vector>

namespace micronaut::semantic_bridge {
using Json = nlohmann::json;

// Host-supplied query must already satisfy the pinned EmbeddingGemma 2 query
// contract. This read-only primitive performs retrieval; it does not generate
// a response, assign graph meaning, or commit state.
Json retrieve(const std::string& root, const std::vector<float>& query,
              std::size_t top_k = 5);
}
