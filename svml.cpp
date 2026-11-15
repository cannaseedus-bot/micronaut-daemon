#include "svml.h"
#ifdef _WIN32
#include <windows.h>
#endif

namespace micronaut::svml {
std::vector<Variant> inspect(const std::string& directory) {
    std::vector<Variant> result;
    for (const char* suffix : {"e9","g9","h8","l9","n8","s9"}) {
        Variant v; v.suffix=suffix;
        v.path=directory+"/ocl_cpu___ocl_svml_"+suffix+".dll";
#ifdef _WIN32
        DWORD attributes=GetFileAttributesA(v.path.c_str());
        v.present=attributes!=INVALID_FILE_ATTRIBUTES && !(attributes&FILE_ATTRIBUTE_DIRECTORY);
        // These libraries are internal to the Intel OpenCL CPU runtime.
        // Do not load or call their private exports from application code.
        if (v.present) {
            HMODULE already=GetModuleHandleA((std::string("ocl_cpu___ocl_svml_")+suffix+".dll").c_str());
            v.loaded=already!=nullptr;
        }
#endif
        result.push_back(v);
    }
    return result;
}
}
