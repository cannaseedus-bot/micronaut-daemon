#include "query_attestation.h"
#include <array>
#include <stdexcept>
#include <vector>
#ifdef _WIN32
#include <windows.h>
#include <bcrypt.h>
#pragma comment(lib,"Bcrypt.lib")
#endif

namespace micronaut::query_attestation {
namespace {
std::string digest(const std::string& bytes,const std::string* key){
#ifdef _WIN32
    BCRYPT_ALG_HANDLE algorithm=nullptr;BCRYPT_HASH_HANDLE hash=nullptr;
    auto close=[&]{if(hash)BCryptDestroyHash(hash);if(algorithm)BCryptCloseAlgorithmProvider(algorithm,0);};
    const ULONG flags=key?BCRYPT_ALG_HANDLE_HMAC_FLAG:0;
    if(BCryptOpenAlgorithmProvider(&algorithm,BCRYPT_SHA256_ALGORITHM,nullptr,flags)<0)
        throw std::runtime_error("cannot open SHA-256 provider");
    DWORD written=0,object_size=0;
    if(BCryptGetProperty(algorithm,BCRYPT_OBJECT_LENGTH,
        reinterpret_cast<PUCHAR>(&object_size),sizeof(object_size),&written,0)<0){
        close();throw std::runtime_error("SHA-256 object length failed");}
    std::vector<unsigned char> object(object_size);
    auto key_data=key?reinterpret_cast<PUCHAR>(const_cast<char*>(key->data())):nullptr;
    auto key_size=key?ULONG(key->size()):0;
    if(BCryptCreateHash(algorithm,&hash,object.data(),object_size,key_data,key_size,0)<0){
        close();throw std::runtime_error("SHA-256 initialization failed");}
    if(BCryptHashData(hash,reinterpret_cast<PUCHAR>(const_cast<char*>(bytes.data())),
        ULONG(bytes.size()),0)<0){close();throw std::runtime_error("SHA-256 update failed");}
    std::array<unsigned char,32> output{};
    if(BCryptFinishHash(hash,output.data(),ULONG(output.size()),0)<0){
        close();throw std::runtime_error("SHA-256 finish failed");}
    close();const char* digits="0123456789abcdef";std::string hex;hex.reserve(64);
    for(unsigned char b:output){hex+=digits[b>>4];hex+=digits[b&15];}
    return hex;
#else
    (void)bytes;(void)key;throw std::runtime_error("query attestation requires Windows BCrypt");
#endif
}
}
std::string sha256_hex(const std::string& bytes){return digest(bytes,nullptr);}
std::string hmac_sha256_hex(const std::string& key,const std::string& bytes){return digest(bytes,&key);}
bool equal_digest(const std::string& left,const std::string& right){
    if(left.size()!=64||right.size()!=64)return false;
    unsigned char diff=0;
    for(std::size_t i=0;i<64;++i)diff|=static_cast<unsigned char>(left[i]^right[i]);
    return diff==0;
}
}
