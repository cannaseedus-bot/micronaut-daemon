// Mo-mu candidate scoring, OpenCL C 1.2. No XCFE admission or dispatch occurs
// here. The host supplies already validated W/C/R values and optional physics.
// candidates[i] = (W, C, R, unused); physics = (gravity, entropy, attention,
// pressure). Scores may exceed 1 when pressure amplifies W_eff.
__kernel void micronaut_score(__global const float4* candidates,
                              const uint count,
                              const float4 physics,
                              __global float* scores,
                              __global uchar* passes) {
    const uint i=get_global_id(0);
    if(i>=count)return;
    const float4 mu=candidates[i];
    const float effective_w=mu.x*(1.0f+physics.w*0.1f)/(1.0f+physics.y*0.5f);
    const float gate=0.5f*(1.0f-physics.z*0.1f)*
                     (physics.x>1.0f ? 0.8f : 1.0f);
    const float score=effective_w*mu.y*mu.z;
    scores[i]=score;
    passes[i]=(uchar)(score>=gate);
}

// Deterministic reduction. A single work item avoids device-dependent
// reduction order. Equal scores select the lowest candidate index; the host
// must supply candidates in a stable order. -1 means no candidate passes.
__kernel void micronaut_dominant(__global const float* scores,
                                 __global const uchar* passes,
                                 const uint count,
                                 __global int* winner) {
    if(get_global_id(0)!=0)return;
    int best=-1;
    float best_score=-1.0f;
    for(uint i=0;i<count;++i) {
        if(passes[i]&&scores[i]>best_score) {
            best=(int)i;
            best_score=scores[i];
        }
    }
    winner[0]=best;
}
