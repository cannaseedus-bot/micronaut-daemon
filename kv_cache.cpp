#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult kv_cache(AttentionContext& ctx) {
    if(ctx.tensors.count("K")) ctx.tensors["cache_K"] = ctx.tensor("K");
    if(ctx.tensors.count("V")) ctx.tensors["cache_V"] = ctx.tensor("V");
    stamp(ctx,"WO_KV_CACHE:MEMORY:980-987");
    return {true,"WO_KV_CACHE","◈","cache_state","K/V cached for paged decode"};
}}

