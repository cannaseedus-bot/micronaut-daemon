#include "phase_gate.h"
namespace micronaut::attention {
bool chen(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Chen)) return false;
    ctx.trace.push_back("phase:Chen:verify");
    return advance_phase(ctx, RuntimePhase::Chen, RuntimePhase::Xul);
}
}

