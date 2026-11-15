#pragma once
#include "attention_types.h"

namespace micronaut::attention {
bool advance_phase(AttentionContext& ctx, RuntimePhase expected, RuntimePhase next);
bool phase_is(const AttentionContext& ctx, RuntimePhase required);
bool pop(AttentionContext& ctx);
bool wo(AttentionContext& ctx);
bool yax(AttentionContext& ctx);
bool sek(AttentionContext& ctx);
bool chen(AttentionContext& ctx);
bool xul(AttentionContext& ctx);
}
