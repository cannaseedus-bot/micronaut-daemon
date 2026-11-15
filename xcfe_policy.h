#pragma once
#include <nlohmann/json.hpp>
#include <string>

namespace micronaut::xcfe_policy {
struct Evidence {
    unsigned observations=0,support=0,exceptions=0,validated=0,failures=0;
};
struct Decision {
    std::string state;
    std::string route;
    double confidence=0;
    bool execution_authorized=false;
};
// Policy is data. Evaluation computes a control decision without executing a
// backend, changing Fold Kernel state, or granting execution authority.
Decision evaluate(const nlohmann::json& policy,const Evidence& evidence,
                  const std::string& previous_state,const std::string& event);
}
