#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult scale(AttentionContext& ctx) {
    const Tensor& in = ctx.tensors.count("scores") ? ctx.tensor("scores") : ctx.tensor("attention_scores");
    Tensor out = make_like(in,"scaled_scores"); float s = ctx.scalar("scale", 1.0f / std::sqrt((float)std::max<int64_t>(1, in.shape.back())));
    for(size_t i=0;i<in.data.size();++i) out.data[i]=in.data[i]*s;
    ctx.tensors[out.name]=out; stamp(ctx,"WO_SCALE:TENSOR:908-915");
    return {true,"WO_SCALE","◉","scaled_scores","scale applied"};
}}

