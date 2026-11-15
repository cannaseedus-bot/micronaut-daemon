#pragma once
#include "common.h"
#include <nlohmann/json.hpp>

namespace micronaut::gemma_bridge_route {
MicronautResult propose_execute(const MicronautOp& op);
// Throws on invalid admission/evidence. Returns verified selection plus optional plain text.
nlohmann::json evaluate(const MicronautOp& op,const std::string& prompt);
}
