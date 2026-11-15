#include "vector_store.h"
#include "file_digest.h"
#include <nlohmann/json.hpp>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <limits>
#include <stdexcept>
#include <filesystem>
#include <regex>
namespace micronaut::vector_store {
namespace {
unsigned number(const std::string& s,size_t& p){
    while(p<s.size()&&(s[p]==' '||s[p]=='\t'))++p;
    if(p==s.size()||s[p]<'0'||s[p]>'9')throw std::runtime_error("invalid NPY shape");
    unsigned value=0;
    while(p<s.size()&&s[p]>='0'&&s[p]<='9'){
        unsigned digit=unsigned(s[p++]-'0');
        if(value>(std::numeric_limits<unsigned>::max()-digit)/10)throw std::runtime_error("NPY shape overflow");
        value=value*10+digit;
    }
    return value;
}
Header parse_header(std::ifstream& in){
    char magic[8];in.read(magic,8);
    if(!in||std::memcmp(magic,"\x93NUMPY",6)!=0)throw std::runtime_error("invalid NPY magic");
    unsigned major=static_cast<unsigned char>(magic[6]);uint32_t length=0;
    if(major==1){char b[2];in.read(b,2);length=uint32_t(uint8_t(b[0]))|(uint32_t(uint8_t(b[1]))<<8);}
    else if(major==2||major==3){char b[4];in.read(b,4);for(int i=0;i<4;++i)length|=uint32_t(uint8_t(b[i]))<<(8*i);}
    else throw std::runtime_error("unsupported NPY version");
    if(!in||length<16||length>65536)throw std::runtime_error("invalid NPY header length");
    std::string header(length,'\0');in.read(header.data(),length);if(!in)throw std::runtime_error("truncated NPY header");
    if(header.find("'descr': '<f4'")==std::string::npos&&header.find("'descr': '=f4'")==std::string::npos)
        throw std::runtime_error("NPY must be little-endian f32");
    if(header.find("'fortran_order': False")==std::string::npos)throw std::runtime_error("NPY must be C contiguous");
    auto p=header.find("'shape':");if(p==std::string::npos)throw std::runtime_error("NPY shape missing");
    p=header.find('(',p);if(p==std::string::npos)throw std::runtime_error("NPY shape invalid");++p;
    Header m;m.rows=number(header,p);while(p<header.size()&&header[p]==' ')++p;
    if(p==header.size()||header[p++]!=',')throw std::runtime_error("NPY rank must be 2");
    m.dim=number(header,p);while(p<header.size()&&header[p]==' ')++p;
    if(p==header.size()||header[p++]!=')')throw std::runtime_error("NPY rank must be 2");
    if(!m.rows||!m.dim||size_t(m.rows)>std::numeric_limits<size_t>::max()/m.dim/sizeof(float))
        throw std::runtime_error("invalid NPY tensor size");
    size_t count=size_t(m.rows)*m.dim;auto start=in.tellg();in.seekg(0,std::ios::end);
    if(in.tellg()-start!=std::streamoff(count*sizeof(float)))throw std::runtime_error("NPY payload size mismatch");
    m.payload_offset=size_t(start);return m;
}
}
Header inspect_npy(const std::string& path){
    std::ifstream in(path,std::ios::binary);if(!in)throw std::runtime_error("cannot open NPY artifact");
    return parse_header(in);
}
Matrix load_npy(const std::string& path){
    std::ifstream in(path,std::ios::binary);if(!in)throw std::runtime_error("cannot open NPY artifact");
    auto header=parse_header(in);
    const size_t count=size_t(header.rows)*header.dim;
    in.seekg(std::streamoff(header.payload_offset));
    Matrix m;m.rows=header.rows;m.dim=header.dim;m.values.resize(count);
    in.read(reinterpret_cast<char*>(m.values.data()),std::streamsize(count*sizeof(float)));
    if(!in)throw std::runtime_error("truncated NPY payload");
    return m;
}
DomainStore load_domain_store(const std::string& manifest_path){
    namespace fs=std::filesystem;
    std::ifstream in(manifest_path,std::ios::binary);
    if(!in)throw std::runtime_error("cannot open domain store manifest");
    auto manifest=nlohmann::json::parse(in);
    if(manifest.at("schema")!="gemma.bridge.domain-store.v1" ||
       manifest.at("authority")!="data_only" || manifest.at("semantic_commit")!=false ||
       manifest.at("dtype")!="float32-le")
        throw std::runtime_error("unsupported domain store contract");
    const std::regex digest("^[0-9a-f]{64}$");
    auto require_digest=[&](const char* key){
        auto value=manifest.at(key).get<std::string>();
        if(!std::regex_match(value,digest))throw std::runtime_error("invalid domain store digest");
        return value;
    };
    auto resolve_child=[&](const char* key){
        fs::path name=manifest.at(key).get<std::string>();
        if(name.empty()||name.is_absolute()||name.has_parent_path()||name.filename()=="..")
            throw std::runtime_error("domain store path must be a local filename");
        return (fs::path(manifest_path).parent_path()/name).string();
    };
    auto source=resolve_child("source_file"),vectors=resolve_child("vector_file");
    auto source_hash=require_digest("source_sha256"),vector_hash=require_digest("vector_sha256");
    if(file_sha256(source)!=source_hash||file_sha256(vectors)!=vector_hash)
        throw std::runtime_error("domain store digest mismatch");
    DomainStore store;
    store.store_id=manifest.at("store_id").get<std::string>();
    store.model_snapshot=manifest.at("model_snapshot").get<std::string>();
    store.source_sha256=source_hash;
    if(store.store_id.empty()||store.model_snapshot.empty())throw std::runtime_error("domain store identity missing");
    store.vectors=load_npy(vectors);
    if(store.vectors.rows!=manifest.at("rows").get<unsigned>()||
       store.vectors.dim!=manifest.at("dimensions").get<unsigned>())
        throw std::runtime_error("domain store vector shape mismatch");
    return store;
}
}
