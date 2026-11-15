// KHANARY dds_dequant.hlsl
// INT8 packed (R32_UINT → 4 × INT8) to R32_FLOAT dequantization
// Wire format: each uint32 packs 4 signed INT8 values (little-endian)
// Dequant: f = (int8_val - zero_point) * scale

cbuffer DequantConstants : register(b0)
{
    float scale;
    float zero_point;
    uint  n_elements;  // number of float elements in output
    uint  pad;
};

// Input: packed INT8 — 4 values per uint32
StructuredBuffer<uint>    packed : register(t0);  // [ceil(n_elements/4)]
RWStructuredBuffer<float> output : register(u0);  // [n_elements]

[numthreads(64, 1, 1)]
void main(uint3 tid : SV_DispatchThreadID)
{
    uint base_elem = tid.x * 4;
    if (base_elem >= n_elements) return;

    uint packed_val = packed[tid.x];

    // Unpack 4 INT8 values (signed, little-endian order)
    int b0 = (int)((packed_val      ) & 0xFF);  if (b0 > 127) b0 -= 256;
    int b1 = (int)((packed_val >>  8) & 0xFF);  if (b1 > 127) b1 -= 256;
    int b2 = (int)((packed_val >> 16) & 0xFF);  if (b2 > 127) b2 -= 256;
    int b3 = (int)((packed_val >> 24) & 0xFF);  if (b3 > 127) b3 -= 256;

    // Dequantize and write
    if (base_elem     < n_elements) output[base_elem    ] = ((float)b0 - zero_point) * scale;
    if (base_elem + 1 < n_elements) output[base_elem + 1] = ((float)b1 - zero_point) * scale;
    if (base_elem + 2 < n_elements) output[base_elem + 2] = ((float)b2 - zero_point) * scale;
    if (base_elem + 3 < n_elements) output[base_elem + 3] = ((float)b3 - zero_point) * scale;
}
