#include "xcfe_router.h"
#include "chat.h"
#include "process.h"
#include "batches.h"
#include "vector_daemon.h"
#include "reasoning_phase.h"
#include "gemma_bridge_route.h"

namespace micronaut {

void XcfeRouter::register_handler(const std::string& op_prefix, Handler handler) {
    handlers_[op_prefix] = handler;
}

std::string XcfeRouter::route_name(const std::string& op) const {
    for (const auto& [prefix, handler] : handlers_) {
        if (op.rfind(prefix, 0) == 0) return prefix;
    }
    return "";
}

MicronautResult XcfeRouter::route(const MicronautOp& op) const {
    auto start = Clock::now();
    for (const auto& [prefix, handler] : handlers_) {
        if (op.op.rfind(prefix, 0) == 0) {
            return handler(op);
        }
    }

    MicronautResult r;
    r.id = op.id;
    r.op = op.op;
    r.ok = false;
    r.error_code = "XCFE_ROUTE_NOT_FOUND";
    r.error_message = "No route registered for op: " + op.op;
    auto end = Clock::now();
    r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    return r;
}

XcfeRouter& xcfe_router() {
    static XcfeRouter router;
    return router;
}

void register_builtin_handlers() {
    static bool done = false;
    if (done) return;
    done = true;

    xcfe_router().register_handler("chat.", chat_execute);
    xcfe_router().register_handler("batch.", batch_execute);
    xcfe_router().register_handler("dxsk.", process_execute);
    xcfe_router().register_handler("scx.", process_execute);
    xcfe_router().register_handler("node.", process_execute);
    xcfe_router().register_handler("dotnet.", process_execute);
    xcfe_router().register_handler("java.", process_execute);
    xcfe_router().register_handler("gpt2.", process_execute);
    xcfe_router().register_handler("vector.candidate", vector_candidate_execute);
    xcfe_router().register_handler("vector.plan.v2.candidate", vector_candidate_v2_execute);
    xcfe_router().register_handler("reason.propose", reasoning_phase::propose_execute);
    xcfe_router().register_handler("gemma.bridge.propose", gemma_bridge_route::propose_execute);
}

} // namespace micronaut


