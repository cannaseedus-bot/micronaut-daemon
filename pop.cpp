#include "phase_gate.h"
namespace micronaut::attention {
bool pop(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Pop)) return false;
    ctx.trace.push_back("phase:Pop:admit");
    return advance_phase(ctx, RuntimePhase::Pop, RuntimePhase::Wo);
}
}

