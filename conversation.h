#pragma once
#include "relational_keys.h"
#include <nlohmann/json.hpp>
#include <string>
#include <vector>

namespace micronaut::conversation {
struct Context {std::string utterance,that,topic;};
struct Policy {
    std::string id;
    std::string sha256;
    std::string source_sha256;
    double minimum_pattern_score=0.85;
    double minimum_margin=0.03;
};

Policy load_policy(const std::string& path);

// Returns a proposal, never rendered text or a state change.
nlohmann::json propose(const Context& context,const nlohmann::json& retrieval,
                       const std::vector<relational_keys::Key>& keys,
                       const Policy& policy);
}
