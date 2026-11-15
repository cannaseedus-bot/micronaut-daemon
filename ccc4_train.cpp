#include "ccc4_learning.h"
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>

int main(int argc,char** argv) {
    if(argc!=5) {
        std::cerr<<"usage: ccc4_train <dataset.json> <new-checkpoint.json> <epochs> <learning-rate>\n";
        return 2;
    }
    try {
        std::ifstream input(argv[1],std::ios::binary);
        if(!input)throw std::runtime_error("cannot open training dataset");
        const auto document=nlohmann::json::parse(input);
        const auto dataset=micronaut::ccc4_learning::parse_dataset(document);
        const auto epochs=std::stoul(argv[3]);
        if(epochs>100000)throw std::runtime_error("epoch limit exceeded");
        const double rate=std::stod(argv[4]);
        const std::filesystem::path output(argv[2]);
        if(std::filesystem::exists(output))throw std::runtime_error("checkpoint path already exists");
        auto parameters=micronaut::ccc4_learning::initial_parameters();
        micronaut::ccc4_learning::AdamState optimizer;
        const auto result=micronaut::ccc4_learning::train(parameters,optimizer,dataset,unsigned(epochs),rate);
        std::ofstream file(output,std::ios::binary|std::ios::out|std::ios::trunc);
        if(!file)throw std::runtime_error("cannot create checkpoint");
        file<<micronaut::ccc4_learning::checkpoint(parameters,optimizer,dataset,result).dump(2)<<'\n';
        if(!file)throw std::runtime_error("checkpoint write failed");
        std::cout<<"trained CCC4 neuron: samples="<<dataset.samples.size()
                 <<" epochs="<<epochs<<" loss="<<result.before<<" -> "<<result.after
                 <<" checkpoint="<<output.string()<<'\n';
        return 0;
    }catch(const std::exception& e){std::cerr<<"ccc4_train: "<<e.what()<<'\n';return 1;}
}
