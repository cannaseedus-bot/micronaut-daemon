#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
static void apply_rope(Tensor& t){ if(t.shape.empty()) return; int64_t d=t.shape.back(); for(size_t base=0;base<t.data.size();base+=d){ for(int64_t i=0;i+1<d;i+=2){ float theta=(float)i/(float)std::max<int64_t>(1,d); float c=std::cos(theta), s=std::sin(theta); float x=t.data[base+i], y=t.data[base+i+1]; t.data[base+i]=x*c-y*s; t.data[base+i+1]=x*s+y*c; } } }
OpResult rotary(AttentionContext& ctx) {
    Tensor q=ctx.tensor("Q"), k=ctx.tensor("K"); q.name="Q_rotary"; k.name="K_rotary"; apply_rope(q); apply_rope(k); ctx.tensors[q.name]=q; ctx.tensors[k.name]=k; stamp(ctx,"WO_ROTARY:TENSOR:940-947");
    return {true,"WO_ROTARY","⌬","Q_rotary,K_rotary","RoPE applied"};
}}

