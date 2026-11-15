#include "attention_ops.h"
#include "attention_math.h"
namespace micronaut::attention {
OpResult qkv_split(AttentionContext& ctx) {
    const Tensor& p = ctx.tensor("packed_qkv"); if (p.shape.empty() || p.shape.back()%3!=0) throw std::runtime_error("packed_qkv last dim must divide by 3");
    Tensor q=p,k=p,v=p; q.name="Q"; k.name="K"; v.name="V"; q.shape.back()/=3; k.shape.back()/=3; v.shape.back()/=3;
    const int64_t inner=q.shape.back(), rows=(int64_t)p.data.size()/(inner*3); q.data.resize(rows*inner); k.data.resize(rows*inner); v.data.resize(rows*inner);
    for(int64_t r=0;r<rows;r++) for(int64_t c=0;c<inner;c++){ q.data[r*inner+c]=p.data[r*inner*3+c]; k.data[r*inner+c]=p.data[r*inner*3+inner+c]; v.data[r*inner+c]=p.data[r*inner*3+inner*2+c]; }
    ctx.tensors["Q"]=q; ctx.tensors["K"]=k; ctx.tensors["V"]=v; stamp(ctx,"WO_QKV_SPLIT:TENSOR:932-939");
    return {true,"WO_QKV_SPLIT","◬","Q,K,V","packed QKV split"};
}}

