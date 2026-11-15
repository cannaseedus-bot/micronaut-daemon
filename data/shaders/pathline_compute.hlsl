// KHANARY pathline_compute.hlsl
// Continuous vector-field pathline integration: GradientFlow γ'(t) = V(γ(t)).
// One forward-Euler step per dispatch; CPU orchestrates multi-step integration.
// [numthreads(64,1,1)] — sized for Intel HD 4600 (D3D11 compute, 1792 MB shared).
//
// Pipeline position (layer 4 of the unified field pipeline):
//   GML nodes/edges → CPU velocity interpolation → [this kernel, step N]
//   → PathState[N+1] → [this kernel, step N+1] → ... → attention.hlsl (scoring)
//
// Admissibility contract (mirrors fold.cd.xml GradientFlow):
//   • This kernel is derived geometry — it cannot mutate FoldGraph B.
//   • A path marked complete (reached a sink) must be validated by Ch'en before
//     its trajectory weight feeds any eligibility decision.
//   • Entropy may inform; this kernel may never authorize.
//
// Memory budget (HD 4600, 1792 MB shared):
//   FieldNode  = 40 bytes × node_count   (typical: ≤4096 nodes  → ~160 KB)
//   PathState  = 32 bytes × path_count   (typical: ≤1024 paths  →  ~32 KB)
//   Total per dispatch: <200 KB — well within VRAM budget.

// ── Constants ────────────────────────────────────────────────────────────────

cbuffer PathlineConstants : register(b0)
{
    uint  node_count;       // number of velocity field nodes
    uint  path_count;       // number of active pathlines this dispatch
    float dt;               // Euler step size (typically 0.05–0.20)
    float sink_threshold;   // divergence ≤ this → path terminates at sink
    float source_repel;     // divergence ≥ this → apply source repulsion weight
    float completion_weight;// weight multiplier for paths that reach a sink
    float pad0;
    float pad1;
};

// ── Structs ───────────────────────────────────────────────────────────────────

// Per-node velocity field entry. CPU pre-interpolates edge (vx,vy,vz) components
// to each node using incident-edge weighted average: V(n) = Σ_e w_e·v_e / Σ w_e.
struct FieldNode
{
    float x,  y,  z;       // node position on semantic manifold
    float vx, vy, vz;      // interpolated velocity vector at this node
    float divergence;       // div V: <0 = sink, >0 = source, 0 = ordinary
    uint  singularity;      // 0=ordinary, 1=source, 2=sink, 3=saddle (index_type enum)
    float pad0, pad1;       // align to 40 bytes
};

// Per-pathline integration state. Read and written each dispatch step.
struct PathState
{
    float px, py, pz;       // current position γ(t)
    float weight;           // accumulated path relevance (product of step weights)
    uint  complete;         // 1 = path terminated (reached sink or boundary)
    uint  steps;            // number of Euler steps taken so far
    float pad0, pad1;
};

// ── Buffers ───────────────────────────────────────────────────────────────────

StructuredBuffer<FieldNode>   FieldNodes  : register(t0);  // velocity field (read)
RWStructuredBuffer<PathState> Paths       : register(u0);  // pathline states (read/write)
RWStructuredBuffer<float>     PathWeights : register(u1);  // per-path final weight output

// ── Helpers ───────────────────────────────────────────────────────────────────

// Find nearest FieldNode to position p using linear scan (correct for small graphs;
// replace with spatial hash when node_count > ~8192).
// Returns the node index.
uint nearest_node(float3 p)
{
    uint  best_idx  = 0;
    float best_dist = 1e30f;
    for (uint i = 0; i < node_count; ++i)
    {
        float3 d = float3(FieldNodes[i].x  - p.x,
                          FieldNodes[i].y  - p.y,
                          FieldNodes[i].z  - p.z);
        float dist = dot(d, d);           // squared distance; no sqrt needed
        if (dist < best_dist)
        {
            best_dist = dist;
            best_idx  = i;
        }
    }
    return best_idx;
}

// Bilinear-in-distance velocity interpolation: weighted average of all nodes,
// weights = 1/(dist² + ε).  More accurate than nearest-node alone and still
// O(node_count) — acceptable on HD 4600 for ≤4096 nodes.
float3 interpolate_velocity(float3 p)
{
    float3 v_sum    = float3(0, 0, 0);
    float  w_sum    = 0.0f;
    const float eps = 1e-6f;

    for (uint i = 0; i < node_count; ++i)
    {
        float3 d    = float3(FieldNodes[i].x - p.x,
                             FieldNodes[i].y - p.y,
                             FieldNodes[i].z - p.z);
        float  w    = 1.0f / (dot(d, d) + eps);
        v_sum      += w * float3(FieldNodes[i].vx, FieldNodes[i].vy, FieldNodes[i].vz);
        w_sum      += w;
    }
    return (w_sum > 0.0f) ? (v_sum / w_sum) : float3(0, 0, 0);
}

// ── Main kernel ───────────────────────────────────────────────────────────────

[numthreads(64, 1, 1)]
void main(uint3 tid : SV_DispatchThreadID)
{
    uint idx = tid.x;
    if (idx >= path_count) return;

    PathState ps = Paths[idx];

    // Skip already-complete paths.
    if (ps.complete != 0u)
    {
        PathWeights[idx] = ps.weight;
        return;
    }

    float3 pos = float3(ps.px, ps.py, ps.pz);

    // ── Forward Euler step: γ(t+dt) = γ(t) + dt·V(γ(t)) ──────────────────
    float3 vel     = interpolate_velocity(pos);
    float  speed   = length(vel);
    float3 pos_new = pos + dt * vel;

    // ── Nearest node at new position — check for sink/source/saddle ───────
    uint nearest = nearest_node(pos_new);
    float div    = FieldNodes[nearest].divergence;
    uint  sing   = FieldNodes[nearest].singularity;

    // Step weight: attenuate near sources (div > 0 = semantic scatter),
    // amplify near sinks (div < 0 = semantic convergence), preserve on saddle.
    float step_weight = 1.0f;
    if (div <= sink_threshold)       // convergence zone
        step_weight = completion_weight;
    else if (div >= source_repel)    // scatter zone: downweight
        step_weight = max(0.1f, 1.0f - saturate(div / (source_repel + 1.0f)));

    float new_weight = ps.weight * step_weight;

    // ── Termination: reached a topological sink ────────────────────────────
    // Poincaré-Hopf constraint: sinks have index = -1; mark path complete and
    // forward to Ch'en for admissibility validation before eligibility use.
    uint complete_flag = 0u;
    if (sing == 2u || div <= sink_threshold)  // sing==2 → "sink"
        complete_flag = 1u;

    // ── Write updated state ────────────────────────────────────────────────
    ps.px       = pos_new.x;
    ps.py       = pos_new.y;
    ps.pz       = pos_new.z;
    ps.weight   = new_weight;
    ps.complete = complete_flag;
    ps.steps    = ps.steps + 1u;

    Paths[idx]       = ps;
    PathWeights[idx] = new_weight;
}
