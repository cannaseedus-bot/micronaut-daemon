#include "phase_gate.h"
namespace micronaut::attention {
bool wo(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Wo)) return false;
    ctx.trace.push_back("phase:Wo:normalize");
    return advance_phase(ctx, RuntimePhase::Wo, RuntimePhase::Yax);
}
}

