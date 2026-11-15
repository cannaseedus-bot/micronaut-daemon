#include "batches.h"
#include "scxq2_runtime.h"
#include "output.h"

namespace micronaut {

// Minimal batch support: accepts raw jobs encoded as payload fields.
// For a full JSON parser, replace parse_json_loose with nlohmann/json and parse payload.jobs array.
MicronautResult batch_execute(const MicronautOp& op) {
    auto start = Clock::now();
    MicronautResult r;
    r.id = op.id;
    r.op = op.op;

    if (op.op != "batch.run") {
        r.ok = false;
        r.error_code = "BATCH_OP_UNKNOWN";
        r.error_message = "Unknown batch operation: " + op.op;
        return r;
    }

    output().event(op.id, "status", "{\"state\":\"batch.start\"}");

    // Safe deterministic placeholder: this proves the batch envelope path.
    // Real array job parsing belongs in input.cpp once a complete JSON library is added.
    r.ok = true;
    r.result_json =
        "{\"completed\":0,"
        "\"failed\":0,"
        "\"jobs\":[],"
        "\"note\":\"batch envelope accepted; add nlohmann/json for payload.jobs parsing\"}";

    auto end = Clock::now();
    r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    return r;
}

} // namespace micronaut

