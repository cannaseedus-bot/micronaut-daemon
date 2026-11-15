#include "store_write.h"
#include <iostream>

int main(int argc,char** argv){
    if(argc==4&&std::string(argv[1])=="--verify"){
        try{micronaut::store_write::verify_shards(argv[2],argv[3]);
            std::cout<<"SHARDS_VERIFIED\n";return 0;}
        catch(const std::exception& error){std::cerr<<"store_write_cli: "<<error.what()<<'\n';return 1;}
    }
    if(argc!=6){std::cerr<<"usage: store_write_cli <source.npy> <new-output-dir> <store-id> <model-id> <rows-per-shard>\n"
                         <<"       store_write_cli --verify <manifest.json> <source.npy>\n";return 2;}
    try{
        auto rows=std::stoul(argv[5]);
        if(rows==0||rows>0xfffffffful)throw std::runtime_error("invalid shard size");
        auto manifest=micronaut::store_write::write_shards(argv[1],argv[2],argv[3],argv[4],std::uint32_t(rows));
        micronaut::store_write::verify_shards(std::string(argv[2])+"/manifest.json",argv[1]);
        std::cout<<"SHARDS_VERIFIED count="<<manifest.at("shards").size()
                 <<" rows="<<manifest.at("rows")<<" dimensions="<<manifest.at("dimensions")<<'\n';
        return 0;
    }catch(const std::exception& error){std::cerr<<"store_write_cli: "<<error.what()<<'\n';return 1;}
}
