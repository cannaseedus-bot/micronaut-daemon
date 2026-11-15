// Standalone local probe for the fixed CCC4 vector mapping.
#include "kuhul_runtime.h"
#include "vector_store.h"
#include <iostream>
#include <fstream>
#include <stdexcept>
#include <string>

int main(int argc,char**argv){
    if(argc<2||argc>4){std::cerr<<"usage: vector_lane <pattern_vectors.f32.npy> [--execute [verified.f32.bin]]\n";return 2;}
    try{
        bool execute=argc>=3&&std::string(argv[2])=="--execute";
        if(argc>=3&&!execute)throw std::runtime_error("unknown option");
        auto matrix=micronaut::vector_store::load_npy(argv[1]);
        std::cerr<<"NPY validated: ["<<matrix.rows<<","<<matrix.dim<<"] f32, C contiguous\n";
        if(!execute){std::cerr<<"candidate not materialized; pass --execute to run the OpenCL fold\n";return 0;}
        auto result=micronaut::kuhul_runtime::run_row_index_mod64(
            matrix.values.data(),matrix.rows,matrix.dim,{true,true});
        if(!result.ok)throw std::runtime_error(result.error);
        if(argc==4){
            std::ofstream output(argv[3],std::ios::binary|std::ios::trunc);
            if(!output)throw std::runtime_error("cannot open verified output");
            output.write(reinterpret_cast<const char*>(result.values.data()),
                         std::streamsize(result.values.size()*sizeof(float)));
            if(!output)throw std::runtime_error("cannot write verified output");
        }
        std::cerr<<"verified [64,"<<matrix.dim<<"] f32 candidate, exact host agreement; committed="<<result.committed<<"\n";
        std::cerr<<"first node first 4 values: "<<result.values[0]<<", "<<result.values[1]<<", "<<result.values[2]<<", "<<result.values[3]<<"\n";
        for(const auto& step:result.trace)std::cerr<<step<<"\n";
        return 0;
    }catch(const std::exception& error){std::cerr<<"vector_lane: "<<error.what()<<"\n";return 1;}
}
