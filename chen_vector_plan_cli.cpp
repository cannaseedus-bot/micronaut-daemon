#include "chen_vector_plan.h"
#include "vector_store.h"
#include <fstream>
#include <iostream>

int main(int argc,char** argv){
    if(argc!=4){std::cerr<<"usage: chen_vector_plan_cli <plan.json> <source.npy> <reference.f32.bin>\n";return 2;}
    try{
        std::ifstream input(argv[1],std::ios::binary);
        if(!input)throw std::runtime_error("cannot open plan");
        auto declaration=micronaut::vector_plan::Json::parse(input);
        auto matrix=micronaut::vector_store::load_npy(argv[2]);
        auto plan=micronaut::vector_plan::resolve(declaration,matrix.rows,matrix.dim);
        auto values=micronaut::chen_vector_plan::reference(plan,matrix.values.data(),matrix.values.size());
        std::ofstream output(argv[3],std::ios::binary|std::ios::trunc);
        if(!output)throw std::runtime_error("cannot open reference output");
        output.write(reinterpret_cast<const char*>(values.data()),std::streamsize(values.size()*sizeof(float)));
        if(!output)throw std::runtime_error("cannot write reference output");
        std::cout<<"CHEN_REFERENCE_COMPUTED shape=["<<plan.groups<<","<<plan.dim<<"]\n";return 0;
    }catch(const std::exception& error){std::cerr<<"chen_vector_plan_cli: "<<error.what()<<'\n';return 1;}
}
