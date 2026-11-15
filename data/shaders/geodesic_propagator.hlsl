/* ═══════════════════════════════════════════════════════════════════════════
   KHANARY Geodesic Path-Integral Propagator — data/shaders/geodesic_propagator.hlsl
   Target: D3D11 / Shader Model 5.0 (cs_5_0)
   Thread layout: [numthreads(64, 1, 1)] — one thread per field node.
   Struct strides: FieldNode = 52 bytes (12×float + 1×uint), FieldEdge = 40 bytes.

   Computes the Feynman-style path-integral distribution K(x,y;τ) across the
   active FoldGraph field overlay.  For each target node the shader sums over
   all incident edges:

       amplitude_e = exp(-S_e) * src.static_weight * src.confidence
       S_e         = ½ ||V_total||² * edge.length          (action integral, Euler approx)
       V_total     = -(pos_target - pos_source) + β⁻¹ * edge.entropy_gradient

   Geodesic entropy update (Raychaudhuri bound check):
       H_G_new = -log(total_flux / node_count)       if total_flux > eps
               = H_G_old + 0.01                      if isolated sink

   Math contract: data/grammar/vectors.mml  §PropagatorKernel, §RaychaudhuriFlow
   OpenMath CD:   data/grammar/fold.cd.xml  §GeodesicEntropy, §PropagatorKernel
   Schema:        data/world/entropic_wells.json  §structural_entropy_metrics

   Boundary: derived geometry only — no FoldGraph B mutation, no eligibility
   authorization.  All outputs are read by field_dag.cpp for the next step.
   ═══════════════════════════════════════════════════════════════════════════ */

#define THREAD_GROUP_SIZE 64

// ── Structs ───────────────────────────────────────────────────────────────────

struct FieldNode
{
    float3 position;          // geodesic vector (x, y, z)
    float  confidence;        // WCR C
    float  static_weight;     // WCR W
    float  local_entropy;     // H(x): point-wise Shannon uncertainty
    float  geodesic_entropy;  // H_G:  shortest-path distribution entropy (updated here)
    float  unruh_temp;        // T:    holographic boundary temperature
    float  divergence;        // div V: negative = gravity well pull
    float  circumradius_R;    // triangle circumcircle horizon
    float  inradius_r;        // triangle incircle compression boundary
    uint   singularity_type;  // 0=ordinary 1=source 2=sink 3=saddle
    float  pad0;              // align structured element to 52 bytes
};

struct FieldEdge
{
    uint   source_id;
    uint   target_id;
    float  weight;
    float  length;            // L_e: metric interval distance
    float3 velocity;          // tangent field (vx, vy, vz)
    float3 entropy_gradient;  // entropic force direction (eh_x, eh_y, eh_z)
};

// ── Resource bindings ────────────────────────────────────────────────────────

StructuredBuffer<FieldNode>   NodeIn   : register(t0);
StructuredBuffer<FieldEdge>   EdgeIn   : register(t1);
RWStructuredBuffer<FieldNode> NodeOut  : register(u0);

cbuffer PropagatorConstants : register(b0)
{
    float kb_boltzmann;        // k_B proxy; 1.0 in natural units
    float beta_diffusion_inv;  // β⁻¹: entropy diffusion scale (tunes explore vs. focus)
    uint  total_node_count;
    uint  total_edge_count;
};

// ── Kernel ───────────────────────────────────────────────────────────────────

[numthreads(THREAD_GROUP_SIZE, 1, 1)]
void CSMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    uint node_idx = dispatchThreadID.x;
    if (node_idx >= total_node_count) return;

    FieldNode node = NodeIn[node_idx];

    float3 accumulated_flow = float3(0.0f, 0.0f, 0.0f);
    float  total_flux       = 0.0f;

    // Each thread scans all edges; process those targeting this node.
    // For graphs ≤ 4096 nodes/edges this linear scan is correct on HD 4600.
    for (uint e = 0; e < total_edge_count; ++e)
    {
        FieldEdge edge = EdgeIn[e];
        if (edge.target_id != node_idx) continue;

        FieldNode src = NodeIn[edge.source_id];

        // ── Unified flow velocity: V = -∇f + β⁻¹ ∇H ────────────────────────
        // Relevance gradient approximated by positional displacement.
        float3 relevance_grad = node.position - src.position;
        float3 v_total = -relevance_grad + beta_diffusion_inv * edge.entropy_gradient;

        // ── Entropic gravity tension along the metric interval ───────────────
        // F_e = T * ||∇H||  (Verlinde-Jacobson F = T∇H)
        float entropic_force = node.unruh_temp * length(edge.entropy_gradient);

        // ── Feynman action S_e = ½ ||V||² · L_e  (Euler approximation) ──────
        float action = 0.5f * dot(v_total, v_total) * edge.length;

        // Path amplitude: exp(-S) weighted by source credibility.
        // Entropic force adds a Boltzmann-like push along the gravity channel.
        float amplitude = exp(-action) * src.static_weight * src.confidence
                        + kb_boltzmann * entropic_force * edge.weight;

        accumulated_flow += v_total * amplitude;
        total_flux       += amplitude;
    }

    // ── Geodesic entropy update (Raychaudhuri bound) ─────────────────────────
    const float eps = 1e-5f;
    if (total_flux > eps)
    {
        // H_G = -log(normalized flux)  — low flux = high uncertainty
        node.geodesic_entropy = -log(total_flux / (float)total_node_count);

        // Dynamic positional acceleration driven by entropic gravity wells.
        // Negative divergence = sink pull; positive = repulsion.
        node.position += accumulated_flow * node.divergence * 0.001f;
    }
    else
    {
        // Isolated sink: entropy grows slowly toward diffuse limit.
        node.geodesic_entropy += 0.01f;
    }

    NodeOut[node_idx] = node;
}
