#include "scxq2_runtime.h"
#include "xcfe_router.h"
#include "output.h"

namespace micronaut {

Scxq2Frame scxq2_encode(const MicronautOp& op) {
    Scxq2Frame f;

    // DICT lane: stable metadata.
    f.dict["@kind"] = op.kind;
    f.dict["id"] = op.id;
    f.dict["op"] = op.op;

    // FIELD lane: payload fields.
    for (const auto& [k, v] : op.payload.flat) {
        if (k != "@kind" && k != "op" && k != "id") {
            f.field[k] = v;
        }
    }

    // EDGE lane: route to handler.
    std::string prefix = xcfe_router().route_name(op.op);
    f.edge.push_back({"request", prefix.empty() ? "unrouted" : prefix});

    // LANE lane: deterministic schedule.
    f.lane = {"validate", "route", "execute", "emit"};

    return f;
}

static bool scxq2_validate(const Scxq2Frame& f, std::string& error) {
    if (!f.dict.count("@kind")) {
        error = "missing @kind";
        return false;
    }
    if (!f.dict.count("op") || f.dict.at("op").empty()) {
        error = "missing op";
        return false;
    }
    if (!f.dict.count("id") || f.dict.at("id").empty()) {
        error = "missing id";
        return false;
    }
    return true;
}

MicronautResult scxq2_execute(const MicronautOp& op) {
    auto start = Clock::now();
    Scxq2Frame frame = scxq2_encode(op);

    output().event(op.id, "scxq2.frame",
        "{\"dict\":{\"op\":\"" + json_escape(op.op) + "\",\"id\":\"" + json_escape(op.id) + "\"},"
        "\"lane\":[\"validate\",\"route\",\"execute\",\"emit\"]}");

    std::string validation_error;
    if (!scxq2_validate(frame, validation_error)) {
        MicronautResult r;
        r.ok = false;
        r.id = op.id;
        r.op = op.op;
        r.error_code = "SCXQ2_VALIDATE_FAILED";
        r.error_message = validation_error;
        auto end = Clock::now();
        r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
        return r;
    }

    MicronautResult r = xcfe_router().route(op);
    auto end = Clock::now();
    if (r.duration_ms == 0) {
        r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    }
    return r;
}

} // namespace micronaut

