#include "phase_gate.h"
namespace micronaut::attention {
bool phase_is(const AttentionContext& ctx, RuntimePhase required) { return ctx.phase == required; }
bool advance_phase(AttentionContext& ctx, RuntimePhase expected, RuntimePhase next) {
    if (ctx.phase != expected || !kuhul::phase::legal(expected, next)) {
        ctx.trace.push_back(std::string("phase-gate:reject:") + phase_name(expected) + ":actual=" + phase_name(ctx.phase));
        return false;
    }
    ctx.phase = next;
    ctx.trace.push_back(std::string("phase:") + phase_name(next));
    return true;
}
}

