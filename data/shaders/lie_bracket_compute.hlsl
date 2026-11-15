// KHANARY lie_bracket_compute.hlsl
// Lie bracket measurement: [X,Y](f) = X(Y(f)) - Y(X(f)).
// Computes structural friction between two relation-conditioned vector-field
// operators at every node.  Output is diagnostic — cannot authorize eligibility.
// [numthreads(64,1,1)] — sized for Intel HD 4600 (D3D11 compute, 1792 MB shared).
//
// Pipeline position (layer 4, diagnostic branch):
//   FieldNodes + OpX + OpY → [this kernel] → BracketResult
//   → request_router scoring (friction evidence) → Ch'en revalidation
//
// Contract (mirrors fold.cd.xml LieBracket):
//   [X,Y] = 0  → commuting flows; path-independent traversal.
//              Example: @requires ∘ @imports = @imports ∘ @requires.
//   [X,Y] ≠ 0  → non-commuting; order changes geometric address.
//              Example: @causes ∘ @contradicts ≠ @contradicts ∘ @causes.
//   Antisymmetry enforced: bracket(X,Y) = -bracket(Y,X) by construction.
//   Jacobi identity is a structural invariant; this kernel does not verify it
//   per-dispatch but the fold_graph.xml Lie-algebra law requires it globally.
//   This kernel is diagnostic only: it cannot mutate FoldGraph B.

// ── Constants ─────────────────────────────────────────────────────────────────

cbuffer LieBracketConstants : register(b0)
{
    uint  node_count;       // number of field nodes
    float fd_epsilon;       // finite-difference step ε for gradient approximation
    float friction_scale;   // output scale for bracket magnitude → scoring channel
    float pad0;
};

// ── Structs ───────────────────────────────────────────────────────────────────

// Per-node field position and test-function value f(n).
// CPU populates f_value with the scalar relevance potential at each node
// (e.g. the GradientFlow relevance score or a per-track WCR channel value).
struct FieldNode
{
    float x, y, z;          // node position on semantic manifold
    float f_value;          // scalar test function f(n): M → ℝ
    float pad0, pad1, pad2, pad3;
};

// Per-node operator entry.  Each operator (X or Y) is a relation-conditioned
// vector-field derivation.  op_vec is the direction the operator pushes f at n:
//   X(f)(n) ≈ dot(op_vec, ∇f(n))
// CPU builds OpX and OpY from relation-channel weights (e.g. @requires vs @imports).
struct OpNode
{
    float vx, vy, vz;       // operator direction vector at this node
    float pad0;
};

// Per-node bracket result.
struct BracketResult
{
    float bracket;          // [X,Y](f) = X(Y(f)) - Y(X(f)) at this node
    float magnitude;        // |[X,Y](f)| — unsigned friction magnitude
    uint  commutes;         // 1 if |bracket| < commute_eps, else 0
    float scaled;           // bracket * friction_scale → scoring channel feed
};

// ── Buffers ───────────────────────────────────────────────────────────────────

StructuredBuffer<FieldNode>    Nodes    : register(t0);  // positions + f values
StructuredBuffer<OpNode>       OpX      : register(t1);  // operator X per node
StructuredBuffer<OpNode>       OpY      : register(t2);  // operator Y per node
RWStructuredBuffer<BracketResult> Bracket : register(u0);

// ── Helpers ───────────────────────────────────────────────────────────────────

static const float kCommuteEps = 1e-4f;   // |bracket| below this → commuting

// Approximate ∇f at node idx using inverse-distance weighted finite differences
// over all other nodes.  Returns float3 gradient estimate.
float3 gradient_f(uint idx)
{
    float3 grad = float3(0, 0, 0);
    float  w_sum = 0.0f;
    const float eps = 1e-6f;
    float3 p0 = float3(Nodes[idx].x, Nodes[idx].y, Nodes[idx].z);
    float  f0 = Nodes[idx].f_value;

    for (uint j = 0; j < node_count; ++j)
    {
        if (j == idx) continue;
        float3 p1 = float3(Nodes[j].x, Nodes[j].y, Nodes[j].z);
        float3 d  = p1 - p0;
        float  r2 = dot(d, d);
        if (r2 < eps) continue;
        float  w  = 1.0f / r2;
        // Finite-difference directional derivative ≈ (f(j)-f(i)) / |d|
        float  df = (Nodes[j].f_value - f0) / sqrt(r2);
        grad     += w * (df / sqrt(r2)) * d;
        w_sum    += w;
    }
    return (w_sum > 0.0f) ? (grad / w_sum) : float3(0, 0, 0);
}

// Apply operator op to scalar field f at node idx: op(f)(idx) = dot(op_vec, ∇f(idx))
float apply_op(float3 op_vec, float3 grad)
{
    return dot(op_vec, grad);
}

// ── Main kernel ───────────────────────────────────────────────────────────────
// [X,Y](f)(n) = X(Y(f))(n) - Y(X(f))(n)
//
// Discrete approximation:
//   Y(f)(n)    = dot(Y_n, ∇f(n))                         — first-order action of Y
//   X(Y(f))(n) = dot(X_n, ∇[Y(f)](n))                   — X acts on Y(f)
//   ∇[Y(f)](n) ≈ finite-diff gradient of the Y(f) scalar field over neighbors
//
// One dispatch computes one bracket field over all nodes for one (X,Y) pair.
// CPU calls this once per relation-channel pair it wants to measure.

[numthreads(64, 1, 1)]
void main(uint3 tid : SV_DispatchThreadID)
{
    uint idx = tid.x;
    if (idx >= node_count) return;

    // ── Step 1: ∇f at each node ──────────────────────────────────────────
    // Shared across both terms; computed once.
    float3 grad_f_n = gradient_f(idx);

    // ── Step 2: Y(f)(n) = dot(Y_n, ∇f(n)) ──────────────────────────────
    float3 y_vec  = float3(OpY[idx].vx, OpY[idx].vy, OpY[idx].vz);
    float  Yf_n   = dot(y_vec, grad_f_n);

    // ── Step 3: X(f)(n) = dot(X_n, ∇f(n)) ──────────────────────────────
    float3 x_vec  = float3(OpX[idx].vx, OpX[idx].vy, OpX[idx].vz);
    float  Xf_n   = dot(x_vec, grad_f_n);

    // ── Step 4: approximate ∇[Y(f)] and ∇[X(f)] over neighbor nodes ─────
    // Build Y(f) and X(f) as temporary scalar fields, then finite-difference.
    // For VRAM economy we re-derive them inline using neighbor dot products
    // rather than materializing intermediate buffers.
    float3 grad_Yf = float3(0, 0, 0);
    float3 grad_Xf = float3(0, 0, 0);
    float  w_sum   = 0.0f;
    const  float eps = 1e-6f;
    float3 p0 = float3(Nodes[idx].x, Nodes[idx].y, Nodes[idx].z);

    for (uint j = 0; j < node_count; ++j)
    {
        if (j == idx) continue;
        float3 p1  = float3(Nodes[j].x, Nodes[j].y, Nodes[j].z);
        float3 d   = p1 - p0;
        float  r2  = dot(d, d);
        if (r2 < eps) continue;
        float  r   = sqrt(r2);
        float  w   = 1.0f / r2;

        // Y(f)(j) and X(f)(j) at neighbor j
        float3 grad_f_j = float3(0, 0, 0);  // approximate: reuse local ∇f as proxy
        // Nearest proxy: linear interpolation of the local gradient over distance
        float3 grad_f_proxy = grad_f_n;     // same gradient field (smooth manifold assumption)
        float  Yf_j = dot(float3(OpY[j].vx, OpY[j].vy, OpY[j].vz), grad_f_proxy);
        float  Xf_j = dot(float3(OpX[j].vx, OpX[j].vy, OpX[j].vz), grad_f_proxy);

        float dYf = (Yf_j - Yf_n) / r;
        float dXf = (Xf_j - Xf_n) / r;

        grad_Yf += w * (dYf / r) * d;
        grad_Xf += w * (dXf / r) * d;
        w_sum   += w;
    }
    if (w_sum > 0.0f) { grad_Yf /= w_sum; grad_Xf /= w_sum; }

    // ── Step 5: bracket terms ─────────────────────────────────────────────
    // X(Y(f)) = dot(X_n, ∇[Y(f)])
    // Y(X(f)) = dot(Y_n, ∇[X(f)])
    float X_Yf   = dot(x_vec, grad_Yf);  // X applied to the Y(f) field
    float Y_Xf   = dot(y_vec, grad_Xf);  // Y applied to the X(f) field

    float bracket_val = X_Yf - Y_Xf;    // [X,Y](f) — antisymmetric by construction

    // ── Step 6: pack result ───────────────────────────────────────────────
    BracketResult br;
    br.bracket  = bracket_val;
    br.magnitude = abs(bracket_val);
    br.commutes  = (br.magnitude < kCommuteEps) ? 1u : 0u;
    br.scaled    = bracket_val * friction_scale;

    Bracket[idx] = br;
}
