#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult mqa(AttentionContext& ctx) {
    const Tensor& q = ctx.tensor("Q"); const Tensor& k = ctx.tensors.count("K_rotary") ? ctx.tensor("K_rotary") : ctx.tensor("K"); const Tensor& v = ctx.tensor("V");
    float scale = ctx.scalar("scale", 1.0f / std::sqrt((float)std::max<int64_t>(1, q.shape.back())));
    Tensor out = scaled_dot_product_attention(q,k,v,scale,"context"); ctx.tensors[out.name]=out;
    stamp(ctx,"WO_MQA:TENSOR:1036-1043");
    return {true,"WO_MQA","◕","context","grouped/multi-query latent attention CPU fallback"};
}}

