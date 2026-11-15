#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult softmax(AttentionContext& ctx) {
    const Tensor& in = ctx.tensors.count("masked_scores") ? ctx.tensor("masked_scores") : (ctx.tensors.count("scaled_scores") ? ctx.tensor("scaled_scores") : ctx.tensor("attention_scores"));
    Tensor out = row_softmax(in,"probabilities"); ctx.tensors[out.name]=out; stamp(ctx,"WO_SOFTMAX:TENSOR:916-923");
    return {true,"WO_SOFTMAX","⟐","probabilities","row softmax completed"};
}}

