// KHANARY moe_router.hlsl
// MoE router: softmax over expert logits + top-k selection via bitonic sort
//
// Lane: required HLSL compile/execution lane (GAP-081). The kernel must compile
// under cs_5_0, so no thread returns before GroupMemoryBarrierWithGroupSync():
// a returning thread makes the barrier divergent and fxc/D3DCompile refuse it
// with X4026. Work is predicated instead, and one thread performs the reduction.
//
// Scope note: one dispatch group serves `n_experts <= 64` experts. The
// groupshared reduction is per-group, so a larger expert count must be reduced
// across groups (not implemented here; the router cap is 64).

cbuffer RouterConstants : register(b0)
{
    uint  n_experts;
    uint  hidden_dim;
    uint  top_k;
    uint  pad;
};

StructuredBuffer<float>   hidden      : register(t0);  // [hidden_dim]
StructuredBuffer<float>   router_w    : register(t1);  // [n_experts * hidden_dim]
StructuredBuffer<float>   router_bias : register(t2);  // [n_experts]
RWStructuredBuffer<float> logits      : register(u0);  // [n_experts]
RWStructuredBuffer<uint>  top_k_ids   : register(u1);  // [top_k]
RWStructuredBuffer<float> top_k_w     : register(u2);  // [top_k]

groupshared float g_logits[64];
groupshared uint  g_ids[64];

[numthreads(64, 1, 1)]
void main(uint3 tid : SV_DispatchThreadID, uint3 gtid : SV_GroupThreadID)
{
    uint e = tid.x;
    uint slot = gtid.x;

    if (slot < 64)
    {
        g_logits[slot] = 0.0f;
        g_ids[slot] = slot;
    }

    if (e < n_experts)
    {
        // Compute logit: dot(router_w[e], hidden) + bias[e]
        float dot_val = 0.0f;
        for (uint d = 0; d < hidden_dim; d++)
            dot_val += router_w[e * hidden_dim + d] * hidden[d];
        dot_val += router_bias[e];
        logits[e] = dot_val;
        g_logits[slot] = dot_val;
        g_ids[slot] = e;
    }

    // Must be reached by every thread: the barrier is illegal in divergent flow.
    GroupMemoryBarrierWithGroupSync();

    // Softmax normalization (single-pass approximation for HD 4600)
    if (gtid.x == 0)
    {
        uint i;
        float max_l = g_logits[0];
        for (i = 1; i < n_experts; i++)
            if (g_logits[i] > max_l) max_l = g_logits[i];

        float sum = 0.0f;
        for (i = 0; i < n_experts; i++)
        {
            g_logits[i] = exp(g_logits[i] - max_l);
            sum += g_logits[i];
        }
        for (i = 0; i < n_experts; i++) g_logits[i] /= sum;

        // Bitonic sort: descending by logit (simple O(N²) for N <= 16)
        for (i = 0; i < n_experts; i++)
        {
            for (uint j = i + 1; j < n_experts; j++)
            {
                if (g_logits[j] > g_logits[i])
                {
                    float tmp_l = g_logits[i]; g_logits[i] = g_logits[j]; g_logits[j] = tmp_l;
                    uint  tmp_i = g_ids[i];    g_ids[i]    = g_ids[j];    g_ids[j]    = tmp_i;
                }
            }
        }

        // Write top-k
        for (i = 0; i < top_k && i < n_experts; i++)
        {
            top_k_ids[i] = g_ids[i];
            top_k_w[i]   = g_logits[i];
        }
    }
}
