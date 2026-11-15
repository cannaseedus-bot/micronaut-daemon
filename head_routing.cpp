#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult head_routing(AttentionContext& ctx) {
    ctx.ints["active_heads"] = ctx.integer("active_heads", ctx.integer("heads", 1));
    stamp(ctx,"WO_HEAD_ROUTE:CONTROL:1052-1059");
    return {true,"WO_HEAD_ROUTE","◗","route_plan","head route plan emitted"};
}}

