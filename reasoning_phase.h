#pragma once
#include "common.h"
#include <set>

namespace micronaut::reasoning_phase {
struct Proposal {
    std::string operator_name;
    std::string entity_a;
    std::string entity_b;
    unsigned depth=0;
    unsigned max_depth=8;
    std::set<std::string> visited;
};
struct Candidate {
    bool valid=false;
    bool admitted=false;
    bool executed=false;
    std::string error;
    std::vector<std::string> phases;
};
Candidate prepare(const Proposal& proposal);
MicronautResult propose_execute(const MicronautOp& op);
}
