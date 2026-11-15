#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult mask(AttentionContext& ctx) {
    const Tensor& scores = ctx.tensors.count("scaled_scores") ? ctx.tensor("scaled_scores") : ctx.tensor("attention_scores");
    Tensor out = make_like(scores,"masked_scores");
    if (ctx.tensors.count("mask")) { const Tensor& m=ctx.tensor("mask"); for(size_t i=0;i<scores.data.size();++i) out.data[i]=scores.data[i]+(i<m.data.size()?m.data[i]:0.0f); }
    else { out.data=scores.data; }
    ctx.tensors[out.name]=out; stamp(ctx,"WO_MASK:TENSOR:924-931");
    return {true,"WO_MASK","◈","masked_scores","mask applied or passthrough"};
}}

