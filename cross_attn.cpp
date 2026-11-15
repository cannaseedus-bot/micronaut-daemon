#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult cross_attn(AttentionContext& ctx) {
    const Tensor& q = ctx.tensors.count("Q_rotary") ? ctx.tensor("Q_rotary") : ctx.tensor("Q");
    const Tensor& k = ctx.tensors.count("K_rotary") ? ctx.tensor("K_rotary") : ctx.tensor("K");
    const Tensor& v = ctx.tensor("V");
    float scale = ctx.scalar("scale", 1.0f / std::sqrt((float)std::max<int64_t>(1, q.shape.back())));
    Tensor out = scaled_dot_product_attention(q,k,v,scale,"context"); ctx.tensors[out.name]=out;
    stamp(ctx,"WO_CROSS_ATTN:KERNEL:1020-1027");
    return {true,"WO_CROSS_ATTN","◓","context","cross_attn fused CPU fallback completed"};
}}

