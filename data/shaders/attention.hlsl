// KHANARY attention.hlsl
// Semantic attention kernel (Yax execution backend), not transformer QKV.
//
// Boundary:
//   Bot Semantics -> Shader Attention -> Attended Semantics
//
// Score law:
//   S_i = W_i * C_i * R_i
//
// Policy law (hard gate, not score shaping):
//   legal_i = capable_i AND policy_ok_i AND xcfe_ok_i
//
// Admission:
//   A_i = 1 when semantic_score_i >= threshold and legal_i == 1
//       = 0 otherwise

cbuffer SemanticAttentionConstants : register(b0)
{
    uint  record_count;
    float admission_threshold;
    float relation_mix;  // [0,1]: blend relation/fold/phase modifiers into S
    float tensor_mix;    // [0,1]: blend micronaut tensor-slot modifier into S

    float geodesic_mix;  // [0,1]: blend optional STB geodesic sidecar modifier into S
    float beta_diffusion; // β^-1: scales geodesic entropy diffusion when sidecar is active
    float reserved_c0;
    float reserved_c1;
};

// Optional frame-transition tensor.  This is a projection-only coordinate
// transform over the tensor slot four-vector:
//     u^i = L^i_j v^j
// The active WCR and policy/XCFE gates remain outside this contraction.
cbuffer LorentzTransitionTensor : register(b1)
{
    float4 boost_row0; // L^0_j
    float4 boost_row1; // L^1_j
    float4 boost_row2; // L^2_j
    float4 boost_row3; // L^3_j

    uint  lorentz_enabled;
    float boost_alignment_mix;
    float boost_mass_scale;
    float boost_reserved;
};

struct SemanticRecord
{
    float W;   // static/pattern-strength channel
    float C;   // confidence channel
    float R;   // relevance channel
    float relation_weight; // neighborhood/relation weighting

    float fold_weight;     // fold compatibility weighting
    float phase_weight;    // phase compatibility weighting
    float policy_ok;       // 1.0 if policy requirement satisfied, else 0.0
    float capable;         // 1.0 if resolver has required capabilities, else 0.0

    float xcfe_ok;         // 1.0 if XCFE authorization holds, else 0.0
    float tensor_mass;      // optional Micronaut slot/STB attraction mass
    float tensor_alignment; // optional Q-to-slot/fiber alignment in [0,1]
    float tensor_health;    // optional projection/runtime health in [0,1]

    float tensor_enabled;   // 1.0 when tensor_* channels are meaningful
    float reserved0;
    float reserved1;
    float reserved2;
};

struct GeodesicMetricRecord
{
    float x;
    float y;
    float z;
    float local_entropy;

    float geodesic_entropy;
    float unruh_temp;
    float divergence;
    float circumradius_R;

    float inradius_r;
};

StructuredBuffer<SemanticRecord> Records : register(t0);
StructuredBuffer<GeodesicMetricRecord> GeodesicMetrics : register(t1);

// BaseScore: raw S_i = W*C*R before relation/fold/phase modifiers.
RWStructuredBuffer<float> BaseScore : register(u0);
// SemanticScore: gated/weighted score used for ranking within legal candidates.
RWStructuredBuffer<float> SemanticScore : register(u1);
// LegalMask: 1 if capability+policy+XCFE all satisfied, else 0.
RWStructuredBuffer<uint> LegalMask : register(u2);
// AdmissionMask: 1 if admitted by threshold and legal gate, else 0.
RWStructuredBuffer<uint> AdmissionMask : register(u3);

float4 tensor_four_vector(SemanticRecord rec)
{
    // x0 is the timelike attraction mass.  reserved0..2 carry x1,x2,x3
    // from HyperbolicAttentionRecord64 without changing the 64-byte stride.
    return float4(rec.tensor_mass, rec.reserved0, rec.reserved1, rec.reserved2);
}

float4 lorentz_contract(float4 v)
{
    if (lorentz_enabled < 1u)
        return v;

    float4 u;
    // Einstein contraction: u^i = L^i_j v^j. Each dot product contracts j.
    u.x = dot(boost_row0, v);
    u.y = dot(boost_row1, v);
    u.z = dot(boost_row2, v);
    u.w = dot(boost_row3, v);
    return u;
}

float tensor_slot_modifier(SemanticRecord rec)
{
    if (rec.tensor_enabled < 0.5f)
        return 1.0f;

    // Tensor slots are projection/fiber state.  They may bias attention, but
    // they do not verify semantic truth and do not replace policy/XCFE gates.
    float mass = saturate(rec.tensor_mass);
    float alignment = saturate(rec.tensor_alignment);

    if (lorentz_enabled >= 1u) {
        float4 u = lorentz_contract(tensor_four_vector(rec));
        float spatial2 = dot(u.yzw, u.yzw);
        float interval = -u.x * u.x + spatial2;
        float boosted_alignment = (interval <= 0.0f) ? 1.0f : saturate(1.0f / (1.0f + interval));
        mass = saturate(abs(u.x) * max(boost_mass_scale, 0.0f));
        alignment = lerp(alignment, boosted_alignment, saturate(boost_alignment_mix));
    }

    return mass *
           alignment *
           saturate(rec.tensor_health);
}

float geodesic_sidecar_modifier(uint idx)
{
    if (geodesic_mix < 0.5f)
        return 1.0f;

    GeodesicMetricRecord geo = GeodesicMetrics[idx];

    // Entropic sink pull: divergence < 0 means the local field behaves like a
    // coordinate sink.  This is a projection modifier only; Ch'en/Xul still own
    // verification and persistence.
    float entropy_density = saturate(geo.local_entropy +
                                     saturate(beta_diffusion) * geo.geodesic_entropy);
    float entropic_pull = saturate(geo.unruh_temp * entropy_density);
    float sink_mix = saturate(-geo.divergence);
    float gravity_warp = lerp(1.0f, entropic_pull, sink_mix);

    // Euler triangle inequality.  Zero radii mean "not supplied" and remain
    // neutral.  If both radii are present and R < 2r, the local mesh is stressed.
    float mesh_supplied = (geo.circumradius_R > 0.0f && geo.inradius_r > 0.0f) ? 1.0f : 0.0f;
    float mesh_ok = (geo.circumradius_R >= 2.0f * geo.inradius_r) ? 1.0f : 0.1f;
    float mesh_stability = lerp(1.0f, mesh_ok, mesh_supplied);

    return saturate(gravity_warp * mesh_stability);
}

[numthreads(64, 1, 1)]
void main(uint3 tid : SV_DispatchThreadID)
{
    uint idx = tid.x;
    if (idx >= record_count) return;

    SemanticRecord rec = Records[idx];

    float w = saturate(rec.W);
    float c = saturate(rec.C);
    float r = saturate(rec.R);
    float rel = saturate(rec.relation_weight);
    float fold = saturate(rec.fold_weight);
    float phase = saturate(rec.phase_weight);

    float s = w * c * r;
    BaseScore[idx] = s;

    // Semantic weighting layer (still symbolic channels, not token tensors).
    float semantic_modifier = lerp(1.0f, rel * fold * phase, saturate(relation_mix));
    float tensor_modifier = tensor_slot_modifier(rec);
    float geodesic_modifier = geodesic_sidecar_modifier(idx);
    float weighted = s *
                     semantic_modifier *
                     lerp(1.0f, tensor_modifier, saturate(tensor_mix)) *
                     lerp(1.0f, geodesic_modifier, saturate(geodesic_mix));

    // Hard legality gate: policy constrains eligibility, not ranking algebra.
    uint legal = (rec.policy_ok >= 0.5f && rec.capable >= 0.5f && rec.xcfe_ok >= 0.5f) ? 1u : 0u;
    LegalMask[idx] = legal;

    float score = (legal == 1u) ? weighted : 0.0f;
    SemanticScore[idx] = score;
    AdmissionMask[idx] = (legal == 1u && score >= admission_threshold) ? 1u : 0u;
}
