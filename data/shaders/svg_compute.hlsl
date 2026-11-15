// KHANARY svg_compute.hlsl
// GPU projection kernel for SVG-3D tensor state.
//
// Responsibility boundary:
// - This shader projects typed numeric tensor channels into geometric parameters.
// - It does NOT infer semantic meaning and does NOT authorize control transitions.
// - Semantic/control authority remains in Mx2LM + XCFE/K'UHUL.
//
// Typical mapping:
//   tensor state T_v = [activation, confidence, relevance, pattern_strength, ...]
//   -> screen position + bar heights + edge geometry/style buffers

cbuffer SvgComputeConstants : register(b0)
{
    uint  node_count;
    uint  edge_count;
    uint  phase_count;     // expected 6 for C6 phase cycle
    uint  pad0;

    float2 screen_center;  // e.g. (512, 400)
    float  world_scale;    // e.g. 150
    float  pad1;

    float  z_to_x;         // isometric z contribution on x
    float  z_to_y;         // isometric z contribution on y
    float  bar_min;        // minimum tensor bar height
    float  bar_max;        // maximum tensor bar height

    float  edge_len_min;   // shortest projected relation span for strong patterns
    float  edge_len_max;   // longest projected relation span for weak patterns
    float2 pad2;
};

struct SvgTensorNode
{
    float3 position;         // world-space semantic position
    float  activation;       // A_v
    float  confidence;       // C_v
    float  relevance;        // R_v
    float  pattern_strength; // P_v
    float  score;            // optional composed score (ex: A*C*R)
    uint   phase;            // C6 phase index
    uint   node_kind;        // semantic/control/tensor discriminator
    float4 block0123;        // Perceive/Learn/Think/Evaluate channels [0..1]
    float4 block456x;        // Confidence/Memory/Evolve channels [0..1], +reserved
};

struct SvgTensorEdge
{
    uint  from_index;
    uint  to_index;
    float association_weight; // pattern strength channel, [0,1]
    float relation_confidence;
};

StructuredBuffer<SvgTensorNode> Nodes : register(t0);
StructuredBuffer<SvgTensorEdge> Edges : register(t1);

// NodeProjection: (x, y, z, phase_angle)
RWStructuredBuffer<float4> NodeProjection : register(u0);
// NodeTensorBars0: projected heights for bars 0..3
RWStructuredBuffer<float4> NodeTensorBars0 : register(u1);
// NodeTensorBars1: projected heights for bars 4..6 (+reserved)
RWStructuredBuffer<float4> NodeTensorBars1 : register(u2);
// NodeTensorState: (score, node_kind, phase_norm, reserved)
RWStructuredBuffer<float4> NodeTensorState : register(u3);

// EdgeProjection: (x1, y1, x2, y2)
RWStructuredBuffer<float4> EdgeProjection : register(u4);
// EdgeTensorState: (association_weight, relation_confidence, geometric_distance, reserved)
RWStructuredBuffer<float4> EdgeTensorState : register(u5);

static const float PI = 3.14159265358979323846f;

float to_bar_height(float channel_value)
{
    float clamped = saturate(channel_value);
    return bar_min + (bar_max - bar_min) * clamped;
}

float2 to_screen_xy(float3 world_pos)
{
    return float2(
        screen_center.x + world_pos.x * world_scale + world_pos.z * z_to_x,
        screen_center.y - world_pos.y * world_scale - world_pos.z * z_to_y
    );
}

[numthreads(64, 1, 1)]
void CSProjectNodes(uint3 tid : SV_DispatchThreadID)
{
    uint idx = tid.x;
    if (idx >= node_count) return;

    SvgTensorNode n = Nodes[idx];

    float2 screen_xy = to_screen_xy(n.position);
    float phase_den = max(1.0f, (float)phase_count);
    float phase_angle = (2.0f * PI / phase_den) * (float)n.phase;

    NodeProjection[idx] = float4(screen_xy, n.position.z, phase_angle);
    NodeTensorBars0[idx] = float4(
        to_bar_height(n.block0123.x),
        to_bar_height(n.block0123.y),
        to_bar_height(n.block0123.z),
        to_bar_height(n.block0123.w)
    );
    NodeTensorBars1[idx] = float4(
        to_bar_height(n.block456x.x),
        to_bar_height(n.block456x.y),
        to_bar_height(n.block456x.z),
        0.0f
    );
    NodeTensorState[idx] = float4(
        n.score,
        (float)n.node_kind,
        ((float)n.phase) / phase_den,
        0.0f
    );
}

[numthreads(64, 1, 1)]
void CSProjectEdges(uint3 tid : SV_DispatchThreadID)
{
    uint idx = tid.x;
    if (idx >= edge_count) return;

    SvgTensorEdge e = Edges[idx];
    if (e.from_index >= node_count || e.to_index >= node_count) {
        EdgeProjection[idx] = float4(0.0f, 0.0f, 0.0f, 0.0f);
        EdgeTensorState[idx] = float4(0.0f, 0.0f, edge_len_max, 0.0f);
        return;
    }

    SvgTensorNode from_node = Nodes[e.from_index];
    SvgTensorNode to_node   = Nodes[e.to_index];

    float2 a = to_screen_xy(from_node.position);
    float2 b = to_screen_xy(to_node.position);

    // Geometric projection law (pattern only):
    // d_ij = 1 - association_weight
    float aw = saturate(e.association_weight);
    float d_norm = 1.0f - aw;
    float d_geom = lerp(edge_len_min, edge_len_max, d_norm);

    EdgeProjection[idx] = float4(a.x, a.y, b.x, b.y);
    EdgeTensorState[idx] = float4(
        aw,
        saturate(e.relation_confidence),
        d_geom,
        0.0f
    );
}
