// Row-index-mod partition: one work item per (group, column).
// Each work item adds its rows in strictly ascending row index using f64.
// The result is a candidate [64, D] f32 tensor; this kernel cannot commit it.
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
__kernel void row_mod_mean(__global const float* rows, __global float* out,
                           const uint row_count, const uint dim, const uint groups) {
    const uint index = get_global_id(0);
    const uint node = index / dim;
    const uint col = index % dim;
    double sum = 0.0;
    uint count = 0;
    for (uint row = node; row < row_count; row += groups) {
        sum = sum + (double)rows[(size_t)row * (size_t)dim + col];
        ++count;
    }
    out[index] = (float)(sum / (double)count);
}
