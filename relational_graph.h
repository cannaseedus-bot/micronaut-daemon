#pragma once
#include <nlohmann/json.hpp>
#include <string>

namespace micronaut::relational_graph {
// Annotate retrieval hits with validated graph bindings and source-backed edges.
nlohmann::json attach_aiml_pilot(const nlohmann::json& retrieval,const std::string& root);
}
