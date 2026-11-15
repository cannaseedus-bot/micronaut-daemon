#include "opencl.h"
#include "svml.h"
#include <iostream>
int main(int argc,char**argv){
    std::string drivers=argc>1?argv[1]:"build/drivers";
    std::cerr<<"Probing installed OpenCL runtime"<<std::endl;
    auto device=micronaut::opencl::inspect();
    std::cerr<<"OpenCL platform: "<<(device.available?device.platform:"unavailable")<<"\n";
    if(device.available)std::cerr<<"Platform version: "<<device.platform_version<<"\nDevice: "<<device.name<<"\nDevice version: "<<device.device_version<<"\n";
    for(auto v:micronaut::svml::inspect(drivers))
        std::cerr<<"SVML "<<v.suffix<<": present="<<v.present<<" loaded_before_kernel="<<v.loaded<<"\n";
    std::string diagnostic;bool ok=micronaut::opencl::vector_math_probe(diagnostic);
    std::cerr<<diagnostic<<"\n";
    std::string attention_diagnostic;bool attention_ok=micronaut::opencl::attention_probe(attention_diagnostic);
    std::cerr<<attention_diagnostic<<"\n";
    std::string micronaut_diagnostic;bool micronaut_ok=micronaut::opencl::micronaut_probe(micronaut_diagnostic);
    std::cerr<<micronaut_diagnostic<<"\n";
    for(auto v:micronaut::svml::inspect(drivers))
        if(v.loaded)std::cerr<<"SVML loaded_after_kernel: "<<v.suffix<<"\n";
    return ok&&attention_ok&&micronaut_ok?0:1;
}
