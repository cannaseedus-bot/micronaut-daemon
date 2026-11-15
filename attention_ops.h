#pragma once
#include "attention_types.h"

namespace micronaut::attention {
OpResult matmul(AttentionContext& ctx);
OpResult scale(AttentionContext& ctx);
OpResult softmax(AttentionContext& ctx);
OpResult mask(AttentionContext& ctx);
OpResult qkv_split(AttentionContext& ctx);
OpResult rotary(AttentionContext& ctx);
OpResult flash_attn(AttentionContext& ctx);
OpResult paged_attn(AttentionContext& ctx);
OpResult ring_attn(AttentionContext& ctx);
OpResult local_attn(AttentionContext& ctx);
OpResult kv_cache(AttentionContext& ctx);
OpResult sink_attn(AttentionContext& ctx);
OpResult sliding(AttentionContext& ctx);
OpResult sparse_attn(AttentionContext& ctx);
OpResult linear_attn(AttentionContext& ctx);
OpResult cross_attn(AttentionContext& ctx);
OpResult gqa(AttentionContext& ctx);
OpResult mqa(AttentionContext& ctx);
OpResult mla(AttentionContext& ctx);
OpResult head_routing(AttentionContext& ctx);
OpResult pi_radius(AttentionContext& ctx);
OpResult accumulator(AttentionContext& ctx);

}
