#include "file_digest.h"
#include <array>
#include <fstream>
#include <stdexcept>
#include <vector>
#ifdef _WIN32
#include <windows.h>
#include <bcrypt.h>
#pragma comment(lib,"Bcrypt.lib")
#endif
namespace micronaut {
std::string file_sha256(const std::string& path){
#ifdef _WIN32
    BCRYPT_ALG_HANDLE algorithm=nullptr;BCRYPT_HASH_HANDLE hash=nullptr;
    auto close=[&](){if(hash)BCryptDestroyHash(hash);if(algorithm)BCryptCloseAlgorithmProvider(algorithm,0);};
    if(BCryptOpenAlgorithmProvider(&algorithm,BCRYPT_SHA256_ALGORITHM,nullptr,0)<0)
        throw std::runtime_error("cannot open SHA-256 provider");
    DWORD bytes=0,object_size=0;
    if(BCryptGetProperty(algorithm,BCRYPT_OBJECT_LENGTH,reinterpret_cast<PUCHAR>(&object_size),sizeof(object_size),&bytes,0)<0){close();throw std::runtime_error("SHA-256 object length failed");}
    std::vector<unsigned char> object(object_size);
    if(BCryptCreateHash(algorithm,&hash,object.data(),object_size,nullptr,0,0)<0){close();throw std::runtime_error("SHA-256 initialization failed");}
    std::ifstream in(path,std::ios::binary);if(!in){close();throw std::runtime_error("cannot open artifact for digest: "+path);}
    std::vector<char> buffer(1<<20);
    while(in){in.read(buffer.data(),buffer.size());auto n=in.gcount();if(n>0&&BCryptHashData(hash,reinterpret_cast<PUCHAR>(buffer.data()),ULONG(n),0)<0){close();throw std::runtime_error("SHA-256 update failed");}}
    if(!in.eof()){close();throw std::runtime_error("artifact read failed");}
    std::array<unsigned char,32> digest{};
    if(BCryptFinishHash(hash,digest.data(),ULONG(digest.size()),0)<0){close();throw std::runtime_error("SHA-256 finish failed");}
    close();const char* digits="0123456789abcdef";std::string result;
    for(unsigned char value:digest){result+=digits[value>>4];result+=digits[value&15];}
    return result;
#else
    (void)path;throw std::runtime_error("file SHA-256 requires Windows BCrypt in this build");
#endif
}
}
