#include "vector_plan.h"
#include "vector_store.h"
#include <cstdlib>
#include <fstream>
#include <iostream>

int main(int argc, char** argv) {
    if (argc<3 || argc>5 || (argc>=4 && std::string(argv[3])!="--execute") ||
        (argc==5 && std::string(argv[4]).empty())) {
        std::cerr<<"usage: vector_plan_cli <plan-v2.json> <source.npy> [--execute [candidate.f32.bin]]\n";return 2;
    }
    try {
        std::ifstream input(argv[1],std::ios::binary);
        if(!input)throw std::runtime_error("cannot open plan");
        const auto document=micronaut::vector_plan::Json::parse(input);
        const auto header=micronaut::vector_store::inspect_npy(argv[2]);
        const auto plan=micronaut::vector_plan::resolve(document,header.rows,header.dim);
        if(argc==3){std::cout<<"BINDINGS_VALIDATED source=["<<plan.rows<<","<<plan.dim
                              <<"] target=["<<plan.groups<<","<<plan.dim<<"] materialized=false\n";return 0;}
        const char* enabled=std::getenv("MICRONAUT_VECTOR_PLAN_V2");
        if(!enabled || std::string(enabled)!="1")throw std::runtime_error("host execution admission missing");
        auto matrix=micronaut::vector_store::load_npy(argv[2]);
        auto result=micronaut::vector_plan::execute(plan,matrix.values.data(),matrix.values.size(),true);
        if(argc==5){
            std::ofstream output(argv[4],std::ios::binary | std::ios::trunc);
            if(!output)throw std::runtime_error("cannot open candidate output");
            output.write(reinterpret_cast<const char*>(result.values.data()),
                         std::streamsize(result.values.size()*sizeof(float)));
            if(!output)throw std::runtime_error("cannot write candidate output");
        }
        std::cout<<"CANDIDATE_COMPUTED shape=["<<result.groups<<","<<result.dim
                 <<"] committed=false operators="<<result.trace.size()<<" first="<<result.values.at(0)<<"\n";
        return 0;
    } catch(const std::exception& error) {
        std::cerr<<"vector_plan_cli: "<<error.what()<<'\n';return 1;
    }
}
