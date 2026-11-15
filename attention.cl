// Basic f32 scaled dot-product attention kernels for OpenCL 1.2.
// Host validates shapes, masks, phase authority, and candidate publication.
// These kernels do not implement flash, paged, sparse, or KV cache.
// Each entry is a primitive; a registered fused opcode requires its own
// host-side plan and validation before it may claim OpenCL execution.

__kernel void attention_matmul(__global const float* a, __global const float* b,
                               __global float* out, const uint m, const uint k,
                               const uint n) {
    const uint index=get_global_id(0), row=index/n, col=index%n;
    if(row>=m)return;
    float sum=0.0f;
    for(uint p=0;p<k;++p)sum=sum+a[(size_t)row*k+p]*b[(size_t)p*n+col];
    out[index]=sum;
}

__kernel void attention_scale(__global const float* input, __global float* output,
                              const uint count, const float factor) {
    const uint i=get_global_id(0);
    if(i<count)output[i]=input[i]*factor;
}

__kernel void attention_additive_mask(__global const float* scores,
                                     __global const float* mask,
                                     __global float* output, const uint count) {
    const uint i=get_global_id(0);
    if(i<count)output[i]=scores[i]+mask[i];
}

// Packed rows [Q | K | V], each segment of width D.
__kernel void attention_qkv_split(__global const float* packed,
                                  __global float* q, __global float* k,
                                  __global float* v, const uint rows,
                                  const uint width) {
    const uint i=get_global_id(0), row=i/width, col=i%width;
    if(row>=rows)return;
    const size_t base=(size_t)row*width*3u+col;
    q[i]=packed[base];k[i]=packed[base+width];v[i]=packed[base+width*2u];
}

// Matches the current CPU rotary.cpp convention: angle=(pair_start / width).
__kernel void attention_rotary(__global const float* input,
                               __global float* output, const uint rows,
                               const uint width) {
    const uint pair=get_global_id(0), pairs_per_row=width/2u;
    if(!pairs_per_row || pair>=rows*pairs_per_row)return;
    const uint row=pair/pairs_per_row, col=(pair%pairs_per_row)*2u;
    const size_t i=(size_t)row*width+col;
    const float theta=(float)col/(float)width;
    const float c=cos(theta), s=sin(theta), x=input[i], y=input[i+1u];
    output[i]=x*c-y*s;output[i+1u]=x*s+y*c;
    if((width&1u) && col+2u==width-1u)output[(size_t)row*width+width-1u]=input[(size_t)row*width+width-1u];
}

// Q [queries, width], K [keys, width] -> scores [queries, keys].
__kernel void attention_scores(__global const float* q, __global const float* k,
                               __global float* scores, const uint queries,
                               const uint keys, const uint width, const float scale) {
    const uint index = get_global_id(0);
    const uint row = index / keys, col = index % keys;
    if (row >= queries) return;
    float sum = 0.0f;
    for (uint d = 0; d < width; ++d)
        sum = sum + q[(size_t)row * width + d] * k[(size_t)col * width + d];
    scores[index] = sum * scale;
}

// One work item per query: stable row softmax, deterministic sequential sum.
__kernel void attention_softmax(__global const float* scores,
                                __global float* probabilities,
                                const uint queries, const uint keys) {
    const uint row = get_global_id(0);
    if (row >= queries) return;
    float maximum = scores[(size_t)row * keys];
    for (uint col = 1; col < keys; ++col)
        maximum = fmax(maximum, scores[(size_t)row * keys + col]);
    float denominator = 0.0f;
    for (uint col = 0; col < keys; ++col) {
        float value = exp(scores[(size_t)row * keys + col] - maximum);
        probabilities[(size_t)row * keys + col] = value;
        denominator = denominator + value;
    }
    for (uint col = 0; col < keys; ++col)
        probabilities[(size_t)row * keys + col] /= denominator;
}

// Probabilities [queries, keys], V [keys, value_width] -> [queries, value_width].
__kernel void attention_context(__global const float* probabilities,
                                __global const float* values,
                                __global float* context, const uint queries,
                                const uint keys, const uint value_width) {
    const uint index = get_global_id(0);
    const uint row = index / value_width, col = index % value_width;
    if (row >= queries) return;
    float sum = 0.0f;
    for (uint key = 0; key < keys; ++key)
        sum = sum + probabilities[(size_t)row * keys + key] *
                    values[(size_t)key * value_width + col];
    context[index] = sum;
}
