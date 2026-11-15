#include "phase_gate.h"
namespace micronaut::attention {
bool xul(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Xul)) return false;
    ctx.trace.push_back("phase:Xul:close");
    return true;
}
}

