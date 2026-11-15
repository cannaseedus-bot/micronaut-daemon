#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult matmul(AttentionContext& ctx) {
    auto out = matmul_2d(ctx.tensor("Q"), ctx.tensor("K"), "attention_scores");
    ctx.tensors[out.name] = out; stamp(ctx,"WO_MATMUL:TENSOR:900-907");
    return {true,"WO_MATMUL","⨀","attention_scores","Q x K completed"};
}}

