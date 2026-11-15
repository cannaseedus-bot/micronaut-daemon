// CCC4 neuron gradient candidate kernels. No optimizer or parameter mutation.
// edge_pairs is 96 sorted canonical (min,max) uint2 pairs. weights[2*id]
// addresses min->max; weights[2*id+1] addresses max->min.
// One work item computes one node delta; a second computes one directed weight
// gradient. The host must verify topology/contract identities and input shapes.
__kernel void ccc4_node_delta(__global const float* input,
                              __global const float* target,
                              __global const float* weights,
                              __global const float* biases,
                              __global const uint2* edge_pairs,
                              const float scale,
                              __global float* delta) {
    const uint node=get_global_id(0);
    if(node>=64)return;
    float z=biases[node];
    for(uint e=0;e<96;++e) {
        const uint2 pair=edge_pairs[e];
        if(pair.y==node)z+=weights[2*e]*input[pair.x];
        if(pair.x==node)z+=weights[2*e+1]*input[pair.y];
    }
    delta[node]=z>0.0f ? scale*(z-target[node]) : 0.0f;
}

__kernel void ccc4_weight_gradient(__global const float* input,
                                   __global const float* delta,
                                   __global const uint2* edge_pairs,
                                   __global float* gradient) {
    const uint index=get_global_id(0);
    if(index>=192)return;
    const uint2 pair=edge_pairs[index/2];
    gradient[index]=(index&1) ? delta[pair.x]*input[pair.y]
                               : delta[pair.y]*input[pair.x];
}

__kernel void ccc4_bias_gradient(__global const float* delta,
                                 __global float* gradient) {
    const uint node=get_global_id(0);
    if(node<64)gradient[192+node]=delta[node];
}
