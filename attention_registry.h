#pragma once
#include "attention_types.h"
namespace micronaut::attention {
const std::vector<Binding>& attention_registry();
const Binding* find_attention_binding(const std::string& glyph_or_opcode);
OpResult execute_attention_glyph(AttentionContext& ctx, const std::string& glyph_or_opcode);
}
