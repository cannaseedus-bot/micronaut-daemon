#include "store_write.h"
#include "file_digest.h"
#include "vector_store.h"
#include <algorithm>
#include <array>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <limits>
#include <sstream>
#include <stdexcept>

namespace micronaut::store_write {
namespace {
namespace fs=std::filesystem;
void require(bool condition,const char* message){if(!condition)throw std::runtime_error(message);}
std::string shard_name(std::uint32_t index){
    std::ostringstream out;out<<"shard-"<<std::setw(6)<<std::setfill('0')<<index<<".f32.npy";return out.str();
}
void write_header(std::ofstream& out,std::uint32_t rows,std::uint32_t dim){
    const char magic[8]={'\x93','N','U','M','P','Y',1,0};
    std::string header="{'descr': '<f4', 'fortran_order': False, 'shape': ("+
                       std::to_string(rows)+", "+std::to_string(dim)+"), }";
    const std::size_t padded=((10+header.size()+1+15)/16)*16-10;
    require(padded<=65535,"NPY shard header too large");
    header.resize(padded-1,' ');header.push_back('\n');
    char length[2]={char(padded&255),char((padded>>8)&255)};
    out.write(magic,8);out.write(length,2);out.write(header.data(),std::streamsize(header.size()));
}
void copy_exact(std::istream& input,std::ostream& output,std::uint64_t bytes){
    std::array<char,1<<15> buffer{};
    while(bytes){auto n=std::streamsize(std::min<std::uint64_t>(bytes,buffer.size()));
        input.read(buffer.data(),n);require(input.gcount()==n,"source NPY payload truncated");
        output.write(buffer.data(),n);require(bool(output),"shard write failed");bytes-=std::uint64_t(n);}
}
}
nlohmann::json write_shards(const std::string& source_npy,const std::string& output_dir,
                           const std::string& store_id,const std::string& model_id,
                           std::uint32_t rows_per_shard){
    require(!store_id.empty()&&!model_id.empty()&&rows_per_shard>0,"invalid store/model identity or shard size");
    auto header=vector_store::inspect_npy(source_npy);
    fs::path dir(output_dir);
    require(!fs::exists(dir),"shard output directory already exists");
    require(fs::create_directories(dir),"cannot create shard output directory");
    std::ifstream source(source_npy,std::ios::binary);
    require(bool(source),"cannot reopen source NPY");
    source.seekg(std::streamoff(header.payload_offset));
    nlohmann::json manifest={{"schema","gemma.bridge.vector-shards.v1"},
        {"authority","data_only"},{"semantic_commit",false},{"store_id",store_id},
        {"model_id",model_id},
        {"source_sha256",file_sha256(source_npy)},{"rows",header.rows},
        {"dimensions",header.dim},{"dtype","float32-le"},{"shards",nlohmann::json::array()}};
    for(std::uint32_t start=0,index=0;start<header.rows;++index){
        std::uint32_t count=std::min<std::uint32_t>(rows_per_shard,header.rows-start);
        auto name=shard_name(index);auto path=dir/name;
        std::ofstream out(path,std::ios::binary|std::ios::out|std::ios::trunc);
        require(bool(out),"cannot create shard");
        write_header(out,count,header.dim);
        copy_exact(source,out,std::uint64_t(count)*header.dim*sizeof(float));
        out.close();require(bool(out),"shard close failed");
        manifest["shards"].push_back({{"file",name},{"start_row",start},
            {"stop_row",start+count},{"sha256",file_sha256(path.string())}});
        start+=count;
    }
    auto pending=dir/"manifest.json.tmp",final=dir/"manifest.json";
    {std::ofstream out(pending,std::ios::binary|std::ios::out|std::ios::trunc);
        require(bool(out),"cannot create shard manifest");out<<manifest.dump(2)<<'\n';
        out.close();require(bool(out),"manifest write failed");}
    fs::rename(pending,final);
    return manifest;
}
void verify_shards(const std::string& manifest_path,const std::string& source_npy){
    std::ifstream input(manifest_path,std::ios::binary);require(bool(input),"cannot open shard manifest");
    auto manifest=nlohmann::json::parse(input);
    require(manifest.at("schema")=="gemma.bridge.vector-shards.v1"&&
            manifest.at("authority")=="data_only"&&manifest.at("semantic_commit")==false&&
            manifest.at("dtype")=="float32-le"&&
            !manifest.at("store_id").get<std::string>().empty()&&
            !manifest.at("model_id").get<std::string>().empty(),"invalid shard manifest contract");
    auto header=vector_store::inspect_npy(source_npy);
    require(manifest.at("rows")==header.rows&&manifest.at("dimensions")==header.dim&&
            manifest.at("source_sha256")==file_sha256(source_npy),"shard source identity mismatch");
    std::ifstream source(source_npy,std::ios::binary);source.seekg(std::streamoff(header.payload_offset));
    std::uint32_t next=0;
    for(const auto& entry:manifest.at("shards")){
        auto name=entry.at("file").get<std::string>();
        fs::path filename(name);require(filename.filename()==filename&&!filename.empty(),"invalid shard path");
        std::uint32_t start=entry.at("start_row").get<std::uint32_t>();
        std::uint32_t stop=entry.at("stop_row").get<std::uint32_t>();
        require(start==next&&stop>start&&stop<=header.rows,"shard ranges are not contiguous");
        auto path=fs::path(manifest_path).parent_path()/filename;
        require(file_sha256(path.string())==entry.at("sha256").get<std::string>(),"shard digest mismatch");
        auto shard=vector_store::inspect_npy(path.string());
        require(shard.rows==stop-start&&shard.dim==header.dim,"shard shape mismatch");
        std::ifstream shard_input(path,std::ios::binary);shard_input.seekg(std::streamoff(shard.payload_offset));
        std::array<char,1<<15> a{},b{};std::uint64_t remaining=std::uint64_t(shard.rows)*shard.dim*sizeof(float);
        while(remaining){auto n=std::streamsize(std::min<std::uint64_t>(remaining,a.size()));
            source.read(a.data(),n);shard_input.read(b.data(),n);
            require(source.gcount()==n&&shard_input.gcount()==n&&
                    std::equal(a.data(),a.data()+n,b.data()),"shard payload differs from source");
            remaining-=std::uint64_t(n);}
        next=stop;
    }
    require(next==header.rows,"shards do not cover source rows");
}
}
