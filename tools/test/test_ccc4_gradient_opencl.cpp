#include "../ccc4_learning.h"
#include "../opencl.h"
#include <algorithm>
#include <cmath>
#include <iostream>
#include <stdexcept>
#include <vector>

int main(){
    using namespace micronaut::ccc4_learning;
    auto parameters=initial_parameters();
    for(unsigned i=0;i<kDirectedWeights;++i)
        parameters.weights[i]=float(int(i%13)-6)*0.0025f;
    for(unsigned i=0;i<kNodes;++i)
        parameters.biases[i]=(i%4==0 ? -0.2f : 0.1f);
    const auto original=parameters;
    Dataset data;data.provenance="synthetic.gradient_comparison";
    for(unsigned sample=0;sample<3;++sample){
        Sample row;
        for(unsigned node=0;node<kNodes;++node){
            row.input[node]=float(int((node*7+sample*11)%17)-8)*0.075f;
            row.target[node]=float(int((node*5+sample*3)%11)-5)*0.04f;
        }
        data.samples.push_back(row);
    }
    double worst=0.0;
    for(unsigned count:{1u,3u}){
        Dataset subset=data;subset.samples.resize(count);
        const auto cpu=compute_gradients(parameters,subset);
        std::vector<float> inputs,targets;
        for(const auto& row:subset.samples){
            inputs.insert(inputs.end(),row.input.begin(),row.input.end());
            targets.insert(targets.end(),row.target.begin(),row.target.end());
        }
        std::vector<double> gpu;
        std::string diagnostic;
        if(!micronaut::opencl::ccc4_neuron_gradients(inputs.data(),targets.data(),count,
                parameters.weights.data(),parameters.biases.data(),gpu,diagnostic)){
            std::cerr<<diagnostic<<'\n';return 1;
        }
        if(gpu.size()!=cpu.size())throw std::runtime_error("gradient length mismatch");
        for(unsigned i=0;i<cpu.size();++i){
            const double difference=std::abs(cpu[i]-gpu[i]);
            worst=std::max(worst,difference);
            if(difference>2e-6+2e-5*std::abs(cpu[i])){
                std::cerr<<"gradient mismatch sample_count="<<count<<" index="<<i
                         <<" CPU="<<cpu[i]<<" OpenCL="<<gpu[i]<<" diff="<<difference<<'\n';
                return 2;
            }
        }
    }
    if(parameters.weights!=original.weights||parameters.biases!=original.biases)
        throw std::runtime_error("gradient comparison mutated parameters");
    std::cerr<<"CCC4 CPU/OpenCL gradients agree: 256 components, 1 and 3 samples; max_abs="<<worst<<std::endl;
}
