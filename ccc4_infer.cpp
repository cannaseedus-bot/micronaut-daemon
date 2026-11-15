#include "ccc4_learning.h"
#include <fstream>
#include <iostream>
#include <stdexcept>

int main(int argc,char** argv) {
    if(argc!=3){std::cerr<<"usage: ccc4_infer <checkpoint.json> <input-64.json>\n";return 2;}
    try {
        std::ifstream checkpoint_file(argv[1],std::ios::binary),input_file(argv[2],std::ios::binary);
        if(!checkpoint_file||!input_file)throw std::runtime_error("checkpoint or input file missing");
        const auto parameters=micronaut::ccc4_learning::parse_parameters(
            nlohmann::json::parse(checkpoint_file));
        const auto input=micronaut::ccc4_learning::parse_input(nlohmann::json::parse(input_file));
        std::cout<<nlohmann::json(micronaut::ccc4_learning::infer(parameters,input)).dump()<<'\n';
        return 0;
    }catch(const std::exception& e){std::cerr<<"ccc4_infer: "<<e.what()<<'\n';return 1;}
}
