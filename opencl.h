#pragma once
#include <string>
#include <vector>

namespace micronaut::opencl {
struct DeviceInfo {
    std::string platform, platform_version, name, device_version;
    bool available = false;
};
DeviceInfo inspect();
// Runs an OpenCL C kernel over four floats. Returns false with a diagnostic
// when the installed runtime cannot execute the kernel.
bool vector_math_probe(std::string& diagnostic);
bool attention_probe(std::string& diagnostic);
bool micronaut_probe(std::string& diagnostic);
// Candidate-only CCC4 neuron gradient computation. Inputs and targets are
// sample-major f32 [sample_count,64]; weights [192], biases [64]. Returns
// accumulated f64 gradients [192 directed weights,64 biases].
bool ccc4_neuron_gradients(const float* inputs,const float* targets,
                           unsigned sample_count,const float* weights,
                           const float* biases,std::vector<double>& gradients,
                           std::string& diagnostic);
// Stage-3 candidate only: sequential f64 sum per (node,column), then f32 mean.
// Input must be row-major f32 [rows,dimension]. No persistence or state swap.
bool row_index_mod_mean(const float* rows, unsigned row_count, unsigned dimension,
                        unsigned groups,
                        std::vector<float>& candidate, std::string& diagnostic);
}
