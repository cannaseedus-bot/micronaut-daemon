#include "phase_gate.h"
namespace micronaut::attention {
bool yax(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Yax)) return false;
    ctx.trace.push_back("phase:Yax:expand");
    return advance_phase(ctx, RuntimePhase::Yax, RuntimePhase::Sek);
}
}

