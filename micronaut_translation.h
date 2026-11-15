#pragma once
#include "conversation.h"
#include <nlohmann/json.hpp>
#include <string>

namespace micronaut::micronaut_translation {
// Parse the admitted AIML subset into a bounded, typed tree.
nlohmann::json parse_template_ast(const std::string& source);
// Independent read-only Ch'en check. Returns a typed proposal, never text output.
nlohmann::json verify_and_translate(const std::string& root,
    const conversation::Context& context,const nlohmann::json& retrieval,
    const nlohmann::json& candidate,const conversation::Policy& policy);
}
