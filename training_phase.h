#pragma once
#include <optional>
#include <string>
#include <vector>

namespace micronaut::training_phase {
struct MuScore {
    std::string name;
    double W=0.5,C=0.5,R=0.5;
};
struct Physics {
    double gravity_gate=1.0;
    double entropy=0.0;
    double attention=0.0;
    double pressure=0.0;
};
struct Entry {
    std::string name;
    double base_score=0;
    double effective_score=0;
    bool passes_gate=false;
};
struct Selection {
    double gate=0.5;
    std::vector<Entry> field;
    std::optional<std::string> dominant;
    bool xcfe_admitted=false;
    bool executed=false;
};
// Pure Yax score candidate. Entries are sorted by name; tied scores select
// the first name. OpenCL callers must submit candidates in this same order.
// Physics follows the documented HLSL formula;
// the caller must separately obtain XCFE admission before any Sek dispatch.
Selection score_field(const std::vector<MuScore>& field,
                      const std::optional<Physics>& physics=std::nullopt);
}
