#include "phase_gate.h"
namespace micronaut::attention {
bool sek(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Sek)) return false;
    ctx.trace.push_back("phase:Sek:dispatch");
    return advance_phase(ctx, RuntimePhase::Sek, RuntimePhase::Chen);
}
}

