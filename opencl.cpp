#include "opencl.h"
#include <cmath>
#include <cstdint>
#include <sstream>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <set>
#include <vector>
#ifdef _WIN32
#include <windows.h>
#endif

namespace micronaut::opencl {
static std::string kernel_source(const char* name) {
    std::filesystem::path file(name);
#ifdef _WIN32
    char module_path[32768]{};
    DWORD length=GetModuleFileNameA(nullptr,module_path,DWORD(sizeof(module_path)));
    if(length && length<sizeof(module_path))file=std::filesystem::path(module_path).parent_path()/name;
#endif
    std::ifstream in(file,std::ios::binary);
    if(!in)in.open(name,std::ios::binary);
    if(!in)return {};
    std::ostringstream source;source<<in.rdbuf();return source.str();
}
#ifdef _WIN32
using I=std::int32_t; using U=std::uint32_t; using UL=std::uint64_t;
using Handle=void*;
constexpr I OK=0;
constexpr UL DEVICE_ALL=0xffffffffu, DEVICE_CPU=1u<<1, MEM_READ_WRITE=1u<<0, MEM_READ_ONLY=1u<<2, MEM_WRITE_ONLY=1u<<1, MEM_COPY_HOST_PTR=1u<<5;
constexpr U PLATFORM_NAME=0x0902, PLATFORM_VERSION=0x0901, DEVICE_NAME=0x102B, DEVICE_VERSION=0x102F, DEVICE_EXTENSIONS=0x1030;

class Api {
    HMODULE module_ = nullptr;
public:
    using Platforms=I(WINAPI*)(U,Handle*,U*);
    using PlatformInfo=I(WINAPI*)(Handle,U,size_t,void*,size_t*);
    using Devices=I(WINAPI*)(Handle,UL,U,Handle*,U*);
    using DeviceInfoFn=I(WINAPI*)(Handle,U,size_t,void*,size_t*);
    using CreateContext=Handle(WINAPI*)(const intptr_t*,U,const Handle*,void*,void*,I*);
    using CreateQueue=Handle(WINAPI*)(Handle,Handle,UL,I*);
    using CreateProgram=Handle(WINAPI*)(Handle,U,const char**,const size_t*,I*);
    using BuildProgram=I(WINAPI*)(Handle,U,const Handle*,const char*,void*,void*);
    using ProgramInfo=I(WINAPI*)(Handle,Handle,U,size_t,void*,size_t*);
    using CreateKernel=Handle(WINAPI*)(Handle,const char*,I*);
    using CreateBuffer=Handle(WINAPI*)(Handle,UL,size_t,void*,I*);
    using SetArg=I(WINAPI*)(Handle,U,size_t,const void*);
    using EnqueueKernel=I(WINAPI*)(Handle,Handle,U,const size_t*,const size_t*,const size_t*,U,const void*,void*);
    using EnqueueRead=I(WINAPI*)(Handle,Handle,I,size_t,size_t,void*,U,const void*,void*);
    using Release=I(WINAPI*)(Handle);
    Platforms platforms{}; PlatformInfo platform_info{}; Devices devices{}; DeviceInfoFn device_info{};
    CreateContext create_context{};CreateQueue create_queue{};CreateProgram create_program{};BuildProgram build_program{};ProgramInfo program_info{};
    CreateKernel create_kernel{};CreateBuffer create_buffer{};SetArg set_arg{};EnqueueKernel enqueue_kernel{};EnqueueRead enqueue_read{};
    Release release_context{},release_queue{},release_program{},release_kernel{},release_mem{};
    Api(){
        module_=LoadLibraryA("OpenCL.dll");if(!module_)return;
#define LOAD(field, symbol) field=reinterpret_cast<decltype(field)>(GetProcAddress(module_,symbol))
        LOAD(platforms,"clGetPlatformIDs");LOAD(platform_info,"clGetPlatformInfo");LOAD(devices,"clGetDeviceIDs");LOAD(device_info,"clGetDeviceInfo");
        LOAD(create_context,"clCreateContext");LOAD(create_queue,"clCreateCommandQueue");LOAD(create_program,"clCreateProgramWithSource");
        LOAD(build_program,"clBuildProgram");LOAD(program_info,"clGetProgramBuildInfo");LOAD(create_kernel,"clCreateKernel");
        LOAD(create_buffer,"clCreateBuffer");LOAD(set_arg,"clSetKernelArg");LOAD(enqueue_kernel,"clEnqueueNDRangeKernel");LOAD(enqueue_read,"clEnqueueReadBuffer");
        LOAD(release_context,"clReleaseContext");LOAD(release_queue,"clReleaseCommandQueue");LOAD(release_program,"clReleaseProgram");
        LOAD(release_kernel,"clReleaseKernel");LOAD(release_mem,"clReleaseMemObject");
#undef LOAD
    }
    // The installed ICD may terminate the process during DLL detach. Keep the
    // system loader resident for this short-lived probe and process lifetime.
    ~Api()=default;
    bool usable()const{return platforms&&platform_info&&devices&&device_info;}
    bool compute_ready()const{return usable()&&create_context&&create_queue&&create_program&&build_program&&program_info&&create_kernel&&create_buffer&&set_arg&&enqueue_kernel&&enqueue_read&&release_context&&release_queue&&release_program&&release_kernel&&release_mem;}
};
static std::string info(Api& a,Handle h,U key,bool platform){
    size_t n=0;I status=platform?a.platform_info(h,key,0,nullptr,&n):a.device_info(h,key,0,nullptr,&n);
    if(status!=OK||n==0||n>4096)return {};
    std::vector<char> b(n);status=platform?a.platform_info(h,key,n,b.data(),nullptr):a.device_info(h,key,n,b.data(),nullptr);
    if(status!=OK)return {};return std::string(b.data());
}
static bool first_device(Api& a,Handle& platform,Handle& device){
    U count=0;if(a.platforms(0,nullptr,&count)!=OK||!count)return false;
    std::vector<Handle> ps(count);if(a.platforms(count,ps.data(),nullptr)!=OK)return false;
    for(auto type:{DEVICE_CPU,DEVICE_ALL})for(auto p:ps){U n=0;if(a.devices(p,type,0,nullptr,&n)!=OK||!n)continue;std::vector<Handle> ds(n);if(a.devices(p,type,n,ds.data(),nullptr)==OK){platform=p;device=ds[0];return true;}}
    return false;
}
#endif
DeviceInfo inspect(){
    DeviceInfo out;
#ifdef _WIN32
    Api a;Handle platform=nullptr,device=nullptr;
    if(!a.usable()||!first_device(a,platform,device))return out;
    out.available=true;
    out.platform=info(a,platform,PLATFORM_NAME,true);
    out.platform_version=info(a,platform,PLATFORM_VERSION,true);
    out.name=info(a,device,DEVICE_NAME,false);
    out.device_version=info(a,device,DEVICE_VERSION,false);
#endif
    return out;
}
bool vector_math_probe(std::string& diagnostic){
#ifdef _WIN32
    Api a;Handle platform=nullptr,device=nullptr;
    if(!a.compute_ready()||!first_device(a,platform,device)){diagnostic="OpenCL compute API or device unavailable";return false;}
    I status=0;Handle ctx=nullptr,queue=nullptr,program=nullptr,kernel=nullptr,input=nullptr,output=nullptr;
    auto cleanup=[&](){if(output)a.release_mem(output);if(input)a.release_mem(input);if(kernel)a.release_kernel(kernel);if(program)a.release_program(program);if(queue)a.release_queue(queue);if(ctx)a.release_context(ctx);};
    const char* source="__kernel void vector_math(__global const float* x,__global float* y){size_t i=get_global_id(0);y[i]=exp(x[i])+sqrt(x[i]+1.0f);}";
    float x[4]={0.0f,0.25f,0.5f,1.0f},y[4]={};
    ctx=a.create_context(nullptr,1,&device,nullptr,nullptr,&status);
    if(!ctx||status!=OK){diagnostic="clCreateContext: "+std::to_string(status);cleanup();return false;}
    queue=a.create_queue(ctx,device,0,&status);
    if(!queue||status!=OK){diagnostic="clCreateCommandQueue: "+std::to_string(status);cleanup();return false;}
    program=a.create_program(ctx,1,&source,nullptr,&status);
    if(!program||status!=OK){diagnostic="clCreateProgramWithSource: "+std::to_string(status);cleanup();return false;}
    status=a.build_program(program,1,&device,nullptr,nullptr,nullptr);
    if(status!=OK){size_t n=0;a.program_info(program,device,0x1183,0,nullptr,&n);std::vector<char> log(n+1);if(n)a.program_info(program,device,0x1183,n,log.data(),nullptr);diagnostic="clBuildProgram: "+std::to_string(status)+" "+log.data();cleanup();return false;}
    kernel=a.create_kernel(program,"vector_math",&status);
    input=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(x),x,&status);
    output=a.create_buffer(ctx,MEM_WRITE_ONLY,sizeof(y),nullptr,&status);
    if(!kernel||!input||!output||status!=OK){diagnostic="OpenCL kernel/buffer creation failed";cleanup();return false;}
    status=a.set_arg(kernel,0,sizeof(input),&input);status|=a.set_arg(kernel,1,sizeof(output),&output);
    size_t global=4;if(status==OK)status=a.enqueue_kernel(queue,kernel,1,nullptr,&global,nullptr,0,nullptr,nullptr);
    if(status==OK)status=a.enqueue_read(queue,output,1,0,sizeof(y),y,0,nullptr,nullptr);
    if(status!=OK){diagnostic="OpenCL dispatch/read: "+std::to_string(status);cleanup();return false;}
    for(int i=0;i<4;++i)if(!std::isfinite(y[i])||std::fabs(y[i]-(std::exp(x[i])+std::sqrt(x[i]+1.0f)))>0.001f){diagnostic="OpenCL result mismatch";cleanup();return false;}
    std::ostringstream out;out<<"OpenCL exp+sqrt kernel passed: ["<<y[0]<<", "<<y[1]<<", "<<y[2]<<", "<<y[3]<<"]";diagnostic=out.str();
    cleanup();return true;
#else
    diagnostic="OpenCL probe is Windows-only in this build";return false;
#endif
}

bool micronaut_probe(std::string& diagnostic) {
#ifdef _WIN32
    const std::string source_text=kernel_source("micronaut.cl");
    if(source_text.empty()){diagnostic="micronaut.cl not found";return false;}
    Api a;Handle platform=nullptr,device=nullptr;
    if(!a.compute_ready()||!first_device(a,platform,device)){
        diagnostic="OpenCL device unavailable";return false;
    }
    I status=0;Handle ctx=nullptr,queue=nullptr,program=nullptr,score_kernel=nullptr,dominant_kernel=nullptr;
    Handle candidates=nullptr,scores=nullptr,passes=nullptr,winner=nullptr;
    auto cleanup=[&]{
        for(auto h:{candidates,scores,passes,winner})if(h)a.release_mem(h);
        for(auto h:{score_kernel,dominant_kernel})if(h)a.release_kernel(h);
        if(program)a.release_program(program);if(queue)a.release_queue(queue);if(ctx)a.release_context(ctx);
    };
    auto fail=[&](const char* step){diagnostic=std::string(step)+": "+std::to_string(status);cleanup();return false;};
    ctx=a.create_context(nullptr,1,&device,nullptr,nullptr,&status);
    if(!ctx||status!=OK)return fail("micronaut context");
    queue=a.create_queue(ctx,device,0,&status);
    if(!queue||status!=OK)return fail("micronaut queue");
    const char* source=source_text.c_str();
    program=a.create_program(ctx,1,&source,nullptr,&status);
    if(!program||status!=OK)return fail("micronaut program");
    status=a.build_program(program,1,&device,"-cl-std=CL1.2",nullptr,nullptr);
    if(status!=OK){
        size_t n=0;a.program_info(program,device,0x1183,0,nullptr,&n);
        std::vector<char> log(n+1);if(n)a.program_info(program,device,0x1183,n,log.data(),nullptr);
        diagnostic="micronaut.cl build: "+std::to_string(status)+" "+log.data();cleanup();return false;
    }
    score_kernel=a.create_kernel(program,"micronaut_score",&status);
    if(!score_kernel||status!=OK)return fail("micronaut_score kernel");
    dominant_kernel=a.create_kernel(program,"micronaut_dominant",&status);
    if(!dominant_kernel||status!=OK)return fail("micronaut_dominant kernel");
    const float field[8]={0.8f,0.85f,0.9f,0.0f, 0.5f,0.5f,0.5f,0.0f};
    const float physics[4]={1.1f,0.2f,0.5f,0.3f};
    float out[2]{};unsigned char admitted[2]{};int dominant=-2;const U count=2;
    candidates=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(field),(void*)field,&status);
    if(!candidates||status!=OK)return fail("micronaut candidate buffer");
    scores=a.create_buffer(ctx,MEM_READ_WRITE,sizeof(out),nullptr,&status);
    if(!scores||status!=OK)return fail("micronaut score buffer");
    passes=a.create_buffer(ctx,MEM_READ_WRITE,sizeof(admitted),nullptr,&status);
    if(!passes||status!=OK)return fail("micronaut pass buffer");
    winner=a.create_buffer(ctx,MEM_WRITE_ONLY,sizeof(dominant),nullptr,&status);
    if(!winner||status!=OK)return fail("micronaut winner buffer");
    status=a.set_arg(score_kernel,0,sizeof(candidates),&candidates);
    status|=a.set_arg(score_kernel,1,sizeof(count),&count);
    status|=a.set_arg(score_kernel,2,sizeof(physics),physics);
    status|=a.set_arg(score_kernel,3,sizeof(scores),&scores);
    status|=a.set_arg(score_kernel,4,sizeof(passes),&passes);
    size_t two=2,one=1;
    if(status==OK)status=a.enqueue_kernel(queue,score_kernel,1,nullptr,&two,nullptr,0,nullptr,nullptr);
    if(status!=OK)return fail("micronaut score dispatch");
    status=a.set_arg(dominant_kernel,0,sizeof(scores),&scores);
    status|=a.set_arg(dominant_kernel,1,sizeof(passes),&passes);
    status|=a.set_arg(dominant_kernel,2,sizeof(count),&count);
    status|=a.set_arg(dominant_kernel,3,sizeof(winner),&winner);
    if(status==OK)status=a.enqueue_kernel(queue,dominant_kernel,1,nullptr,&one,nullptr,0,nullptr,nullptr);
    if(status==OK)status=a.enqueue_read(queue,scores,1,0,sizeof(out),out,0,nullptr,nullptr);
    if(status==OK)status=a.enqueue_read(queue,passes,1,0,sizeof(admitted),admitted,0,nullptr,nullptr);
    if(status==OK)status=a.enqueue_read(queue,winner,1,0,sizeof(dominant),&dominant,0,nullptr,nullptr);
    if(status!=OK)return fail("micronaut readback");
    const float expected=0.8f*1.03f/1.1f*0.85f*0.9f;
    const bool valid=std::fabs(out[0]-expected)<0.0001f&&admitted[0]==1&&
                     admitted[1]==0&&dominant==0;
    diagnostic=valid?"micronaut.cl WCR candidate probe passed":"micronaut.cl WCR candidate mismatch";
    cleanup();return valid;
#else
    diagnostic="OpenCL micronaut probe is Windows-only in this build";return false;
#endif
}

bool attention_probe(std::string& diagnostic) {
#ifdef _WIN32
    const std::string source_text=kernel_source("attention.cl");
    if(source_text.empty()){diagnostic="attention.cl not found";return false;}
    Api a;Handle platform=nullptr,device=nullptr;
    if(!a.compute_ready()||!first_device(a,platform,device)){diagnostic="OpenCL device unavailable";return false;}
    I status=0;Handle ctx=nullptr,queue=nullptr,program=nullptr;
    Handle scores_kernel=nullptr,softmax_kernel=nullptr,context_kernel=nullptr;
    Handle qbuf=nullptr,kbuf=nullptr,vbuf=nullptr,sbuf=nullptr,pbuf=nullptr,obuf=nullptr;
    Handle extra1=nullptr,extra2=nullptr,extra3=nullptr,extra4=nullptr,extra5=nullptr;
    Handle primitive=nullptr;
    auto cleanup=[&](){for(auto h:{qbuf,kbuf,vbuf,sbuf,pbuf,obuf,extra1,extra2,extra3,extra4,extra5})if(h)a.release_mem(h);
        for(auto h:{scores_kernel,softmax_kernel,context_kernel,primitive})if(h)a.release_kernel(h);
        if(program)a.release_program(program);if(queue)a.release_queue(queue);if(ctx)a.release_context(ctx);};
    auto error=[&](const char* step){diagnostic=std::string(step)+": "+std::to_string(status);cleanup();return false;};
    ctx=a.create_context(nullptr,1,&device,nullptr,nullptr,&status);if(!ctx||status!=OK)return error("clCreateContext");
    queue=a.create_queue(ctx,device,0,&status);if(!queue||status!=OK)return error("clCreateCommandQueue");
    const char* source=source_text.c_str();program=a.create_program(ctx,1,&source,nullptr,&status);
    if(!program||status!=OK)return error("clCreateProgramWithSource");
    status=a.build_program(program,1,&device,"-cl-opt-disable",nullptr,nullptr);
    if(status!=OK){size_t n=0;a.program_info(program,device,0x1183,0,nullptr,&n);std::vector<char> log(n+1);if(n)a.program_info(program,device,0x1183,n,log.data(),nullptr);diagnostic="attention.cl build: "+std::to_string(status)+" "+log.data();cleanup();return false;}
    scores_kernel=a.create_kernel(program,"attention_scores",&status);if(!scores_kernel||status!=OK)return error("attention_scores");
    softmax_kernel=a.create_kernel(program,"attention_softmax",&status);if(!softmax_kernel||status!=OK)return error("attention_softmax");
    context_kernel=a.create_kernel(program,"attention_context",&status);if(!context_kernel||status!=OK)return error("attention_context");
    float q[4]={1,0,0,1},k[4]={1,0,0,1},v[4]={1,10,2,20},out[4]={};
    qbuf=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(q),q,&status);if(!qbuf||status!=OK)return error("Q buffer");
    kbuf=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(k),k,&status);if(!kbuf||status!=OK)return error("K buffer");
    vbuf=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(v),v,&status);if(!vbuf||status!=OK)return error("V buffer");
    sbuf=a.create_buffer(ctx,MEM_READ_WRITE,sizeof(out),nullptr,&status);if(!sbuf||status!=OK)return error("score buffer");
    pbuf=a.create_buffer(ctx,MEM_READ_WRITE,sizeof(out),nullptr,&status);if(!pbuf||status!=OK)return error("probability buffer");
    obuf=a.create_buffer(ctx,MEM_WRITE_ONLY,sizeof(out),nullptr,&status);if(!obuf||status!=OK)return error("context buffer");
    U two=2;float scale=1.0f;
    auto arg=[&](Handle kernel,U index,size_t bytes,const void* value){if(status==OK)status=a.set_arg(kernel,index,bytes,value);};
    arg(scores_kernel,0,sizeof(qbuf),&qbuf);arg(scores_kernel,1,sizeof(kbuf),&kbuf);arg(scores_kernel,2,sizeof(sbuf),&sbuf);
    arg(scores_kernel,3,sizeof(two),&two);arg(scores_kernel,4,sizeof(two),&two);arg(scores_kernel,5,sizeof(two),&two);arg(scores_kernel,6,sizeof(scale),&scale);
    size_t four=4;if(status==OK)status=a.enqueue_kernel(queue,scores_kernel,1,nullptr,&four,nullptr,0,nullptr,nullptr);
    if(status!=OK)return error("attention_scores dispatch");
    arg(softmax_kernel,0,sizeof(sbuf),&sbuf);arg(softmax_kernel,1,sizeof(pbuf),&pbuf);arg(softmax_kernel,2,sizeof(two),&two);arg(softmax_kernel,3,sizeof(two),&two);
    size_t rows=2;if(status==OK)status=a.enqueue_kernel(queue,softmax_kernel,1,nullptr,&rows,nullptr,0,nullptr,nullptr);
    if(status!=OK)return error("attention_softmax dispatch");
    arg(context_kernel,0,sizeof(pbuf),&pbuf);arg(context_kernel,1,sizeof(vbuf),&vbuf);arg(context_kernel,2,sizeof(obuf),&obuf);
    arg(context_kernel,3,sizeof(two),&two);arg(context_kernel,4,sizeof(two),&two);arg(context_kernel,5,sizeof(two),&two);
    if(status==OK)status=a.enqueue_kernel(queue,context_kernel,1,nullptr,&four,nullptr,0,nullptr,nullptr);
    if(status==OK)status=a.enqueue_read(queue,obuf,1,0,sizeof(out),out,0,nullptr,nullptr);
    if(status!=OK)return error("attention_context dispatch/read");
    const float p=std::exp(1.0f)/(std::exp(1.0f)+1.0f);
    const float expected[4]={p*1+(1-p)*2,p*10+(1-p)*20,(1-p)*1+p*2,(1-p)*10+p*20};
    for(int i=0;i<4;++i)if(!std::isfinite(out[i])||std::fabs(out[i]-expected[i])>0.001f){diagnostic="attention result mismatch";cleanup();return false;}
    auto start=[&](const char* name){
        if(primitive){a.release_kernel(primitive);primitive=nullptr;}
        primitive=a.create_kernel(program,name,&status);
        return primitive && status==OK;
    };
    auto dispatch=[&](size_t global){
        if(status==OK)status=a.enqueue_kernel(queue,primitive,1,nullptr,&global,nullptr,0,nullptr,nullptr);
        return status==OK;
    };
    U count=4;float factor=2.0f;
    if(!start("attention_scale"))return error("attention_scale");
    arg(primitive,0,sizeof(qbuf),&qbuf);arg(primitive,1,sizeof(obuf),&obuf);
    arg(primitive,2,sizeof(count),&count);arg(primitive,3,sizeof(factor),&factor);
    if(!dispatch(4))return error("attention_scale dispatch");
    if(a.enqueue_read(queue,obuf,1,0,sizeof(out),out,0,nullptr,nullptr)!=OK)return error("attention_scale read");
    if(out[0]!=2 || out[1]!=0 || out[2]!=0 || out[3]!=2){diagnostic="attention_scale mismatch";cleanup();return false;}

    if(!start("attention_matmul"))return error("attention_matmul");
    arg(primitive,0,sizeof(qbuf),&qbuf);arg(primitive,1,sizeof(kbuf),&kbuf);
    arg(primitive,2,sizeof(obuf),&obuf);arg(primitive,3,sizeof(two),&two);
    arg(primitive,4,sizeof(two),&two);arg(primitive,5,sizeof(two),&two);
    if(!dispatch(4))return error("attention_matmul dispatch");
    if(a.enqueue_read(queue,obuf,1,0,sizeof(out),out,0,nullptr,nullptr)!=OK)return error("attention_matmul read");
    if(out[0]!=1 || out[1]!=0 || out[2]!=0 || out[3]!=1){diagnostic="attention_matmul mismatch";cleanup();return false;}

    float mask_values[4]={0,-1,-1,0};
    extra1=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(mask_values),mask_values,&status);
    if(!extra1||status!=OK)return error("attention mask buffer");
    if(!start("attention_additive_mask"))return error("attention_additive_mask");
    arg(primitive,0,sizeof(sbuf),&sbuf);arg(primitive,1,sizeof(extra1),&extra1);
    arg(primitive,2,sizeof(obuf),&obuf);arg(primitive,3,sizeof(count),&count);
    if(!dispatch(4))return error("attention_additive_mask dispatch");
    if(a.enqueue_read(queue,obuf,1,0,sizeof(out),out,0,nullptr,nullptr)!=OK)return error("attention_additive_mask read");
    if(out[0]!=1 || out[1]!=-1 || out[2]!=-1 || out[3]!=1){diagnostic="attention_additive_mask mismatch";cleanup();return false;}

    a.release_mem(extra1);extra1=nullptr;
    float packed[6]={1,2,3,4,5,6},split_q[2]{},split_k[2]{},split_v[2]{};
    extra1=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(packed),packed,&status);
    extra2=a.create_buffer(ctx,MEM_WRITE_ONLY,sizeof(split_q),nullptr,&status);
    extra3=a.create_buffer(ctx,MEM_WRITE_ONLY,sizeof(split_k),nullptr,&status);
    extra4=a.create_buffer(ctx,MEM_WRITE_ONLY,sizeof(split_v),nullptr,&status);
    if(!extra1||!extra2||!extra3||!extra4||status!=OK)return error("attention QKV buffers");
    if(!start("attention_qkv_split"))return error("attention_qkv_split");
    U one=1;
    arg(primitive,0,sizeof(extra1),&extra1);arg(primitive,1,sizeof(extra2),&extra2);
    arg(primitive,2,sizeof(extra3),&extra3);arg(primitive,3,sizeof(extra4),&extra4);
    arg(primitive,4,sizeof(one),&one);arg(primitive,5,sizeof(two),&two);
    if(!dispatch(2))return error("attention_qkv_split dispatch");
    if(a.enqueue_read(queue,extra2,1,0,sizeof(split_q),split_q,0,nullptr,nullptr)!=OK ||
       a.enqueue_read(queue,extra3,1,0,sizeof(split_k),split_k,0,nullptr,nullptr)!=OK ||
       a.enqueue_read(queue,extra4,1,0,sizeof(split_v),split_v,0,nullptr,nullptr)!=OK)return error("attention_qkv_split read");
    if(split_q[0]!=1||split_q[1]!=2||split_k[0]!=3||split_k[1]!=4||split_v[0]!=5||split_v[1]!=6){diagnostic="attention_qkv_split mismatch";cleanup();return false;}

    a.release_mem(extra1);extra1=nullptr;
    float rotary_in[4]={1,0,0,1};
    extra1=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(rotary_in),rotary_in,&status);
    if(!extra1||status!=OK)return error("attention rotary buffer");
    if(!start("attention_rotary"))return error("attention_rotary");
    U rotary_width=4;
    arg(primitive,0,sizeof(extra1),&extra1);arg(primitive,1,sizeof(obuf),&obuf);
    arg(primitive,2,sizeof(one),&one);arg(primitive,3,sizeof(rotary_width),&rotary_width);
    if(!dispatch(2))return error("attention_rotary dispatch");
    if(a.enqueue_read(queue,obuf,1,0,sizeof(out),out,0,nullptr,nullptr)!=OK)return error("attention_rotary read");
    if(std::fabs(out[0]-1)>0.0001f||std::fabs(out[1])>0.0001f||
       std::fabs(out[2]+std::sin(0.5f))>0.0001f||std::fabs(out[3]-std::cos(0.5f))>0.0001f){
        diagnostic="attention_rotary mismatch";cleanup();return false;
    }
    std::ostringstream text;text<<"attention.cl scores+softmax+context and matmul/scale/mask/QKV/rotary passed";
    diagnostic=text.str();cleanup();return true;
#else
    diagnostic="Windows OpenCL backend only";return false;
#endif
}

bool ccc4_neuron_gradients(const float* inputs,const float* targets,
                           unsigned sample_count,const float* weights,
                           const float* biases,std::vector<double>& gradients,
                           std::string& diagnostic) {
#ifdef _WIN32
    gradients.clear();
    if(!inputs||!targets||!weights||!biases||!sample_count||sample_count>1000000u){
        diagnostic="invalid CCC4 gradient buffers or sample count";return false;
    }
    for(std::size_t i=0;i<std::size_t(sample_count)*64;++i)
        if(!std::isfinite(inputs[i])||!std::isfinite(targets[i])){
            diagnostic="non-finite CCC4 training sample";return false;
        }
    for(unsigned i=0;i<192;++i)if(!std::isfinite(weights[i])){
        diagnostic="non-finite CCC4 weight";return false;
    }
    for(unsigned i=0;i<64;++i)if(!std::isfinite(biases[i])){
        diagnostic="non-finite CCC4 bias";return false;
    }
    const std::string source_text=kernel_source("gradients.cl");
    if(source_text.empty()){diagnostic="gradients.cl not found beside executable or in cwd";return false;}
    Api a;Handle platform=nullptr,device=nullptr;
    if(!a.compute_ready()||!first_device(a,platform,device)){
        diagnostic="OpenCL CPU device unavailable";return false;
    }
    std::set<std::pair<U,U>> canonical;
    for(U x=0;x<16;++x)for(U y=0;y<4;++y){
        const U id=4*x+y;
        auto add=[&](U other){canonical.insert({id<other?id:other,id<other?other:id});};
        add(4*x+((y+1)&3));add(4*(x^(1u<<y))+y);
    }
    if(canonical.size()!=96){diagnostic="CCC4 canonical edge generation failed";return false;}
    U pairs[192]{};unsigned edge=0;
    for(const auto& p:canonical){pairs[2*edge]=p.first;pairs[2*edge+1]=p.second;++edge;}
    I status=0;Handle ctx=nullptr,queue=nullptr,program=nullptr,delta_kernel=nullptr,weight_kernel=nullptr,bias_kernel=nullptr;
    Handle weight_buffer=nullptr,bias_buffer=nullptr,pair_buffer=nullptr;
    Handle input_buffer=nullptr,target_buffer=nullptr,delta_buffer=nullptr,gradient_buffer=nullptr;
    auto cleanup_sample=[&]{
        for(auto* h:{&input_buffer,&target_buffer,&delta_buffer,&gradient_buffer}){
            if(*h){a.release_mem(*h);*h=nullptr;}
        }
    };
    auto cleanup=[&]{
        cleanup_sample();
        for(auto h:{weight_buffer,bias_buffer,pair_buffer})if(h)a.release_mem(h);
        for(auto h:{delta_kernel,weight_kernel,bias_kernel})if(h)a.release_kernel(h);
        if(program)a.release_program(program);if(queue)a.release_queue(queue);if(ctx)a.release_context(ctx);
    };
    auto fail=[&](const char* step){diagnostic=std::string(step)+": "+std::to_string(status);cleanup();gradients.clear();return false;};
    ctx=a.create_context(nullptr,1,&device,nullptr,nullptr,&status);
    if(!ctx||status!=OK)return fail("CCC4 clCreateContext");
    queue=a.create_queue(ctx,device,0,&status);
    if(!queue||status!=OK)return fail("CCC4 clCreateCommandQueue");
    const char* source=source_text.c_str();
    program=a.create_program(ctx,1,&source,nullptr,&status);
    if(!program||status!=OK)return fail("CCC4 clCreateProgramWithSource");
    status=a.build_program(program,1,&device,"-cl-std=CL1.2 -cl-opt-disable",nullptr,nullptr);
    if(status!=OK){
        size_t n=0;a.program_info(program,device,0x1183,0,nullptr,&n);
        std::vector<char> log(n+1);if(n)a.program_info(program,device,0x1183,n,log.data(),nullptr);
        diagnostic="gradients.cl build: "+std::to_string(status)+" "+log.data();
        cleanup();return false;
    }
    delta_kernel=a.create_kernel(program,"ccc4_node_delta",&status);
    if(!delta_kernel||status!=OK)return fail("CCC4 delta kernel");
    weight_kernel=a.create_kernel(program,"ccc4_weight_gradient",&status);
    if(!weight_kernel||status!=OK)return fail("CCC4 weight gradient kernel");
    bias_kernel=a.create_kernel(program,"ccc4_bias_gradient",&status);
    if(!bias_kernel||status!=OK)return fail("CCC4 bias gradient kernel");
    weight_buffer=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,192*sizeof(float),const_cast<float*>(weights),&status);
    if(!weight_buffer||status!=OK)return fail("CCC4 weight buffer");
    bias_buffer=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,64*sizeof(float),const_cast<float*>(biases),&status);
    if(!bias_buffer||status!=OK)return fail("CCC4 bias buffer");
    pair_buffer=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,sizeof(pairs),pairs,&status);
    if(!pair_buffer||status!=OK)return fail("CCC4 edge buffer");
    gradients.assign(256,0.0);
    const float scale=float(2.0/(double(sample_count)*64.0));
    const size_t nodes=64,directed=192;
    for(unsigned sample=0;sample<sample_count;++sample){
        const float* input=inputs+std::size_t(sample)*64;
        const float* target=targets+std::size_t(sample)*64;
        input_buffer=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,64*sizeof(float),const_cast<float*>(input),&status);
        if(!input_buffer||status!=OK)return fail("CCC4 input buffer");
        target_buffer=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,64*sizeof(float),const_cast<float*>(target),&status);
        if(!target_buffer||status!=OK)return fail("CCC4 target buffer");
        delta_buffer=a.create_buffer(ctx,MEM_READ_WRITE,64*sizeof(float),nullptr,&status);
        if(!delta_buffer||status!=OK)return fail("CCC4 delta buffer");
        gradient_buffer=a.create_buffer(ctx,MEM_READ_WRITE,256*sizeof(float),nullptr,&status);
        if(!gradient_buffer||status!=OK)return fail("CCC4 gradient buffer");
        status=a.set_arg(delta_kernel,0,sizeof(input_buffer),&input_buffer);
        status|=a.set_arg(delta_kernel,1,sizeof(target_buffer),&target_buffer);
        status|=a.set_arg(delta_kernel,2,sizeof(weight_buffer),&weight_buffer);
        status|=a.set_arg(delta_kernel,3,sizeof(bias_buffer),&bias_buffer);
        status|=a.set_arg(delta_kernel,4,sizeof(pair_buffer),&pair_buffer);
        status|=a.set_arg(delta_kernel,5,sizeof(scale),&scale);
        status|=a.set_arg(delta_kernel,6,sizeof(delta_buffer),&delta_buffer);
        if(status!=OK)return fail("CCC4 delta arguments");
        status=a.enqueue_kernel(queue,delta_kernel,1,nullptr,&nodes,nullptr,0,nullptr,nullptr);
        if(status!=OK)return fail("CCC4 delta dispatch");
        status=a.set_arg(weight_kernel,0,sizeof(input_buffer),&input_buffer);
        status|=a.set_arg(weight_kernel,1,sizeof(delta_buffer),&delta_buffer);
        status|=a.set_arg(weight_kernel,2,sizeof(pair_buffer),&pair_buffer);
        status|=a.set_arg(weight_kernel,3,sizeof(gradient_buffer),&gradient_buffer);
        if(status!=OK)return fail("CCC4 weight arguments");
        status=a.enqueue_kernel(queue,weight_kernel,1,nullptr,&directed,nullptr,0,nullptr,nullptr);
        if(status!=OK)return fail("CCC4 weight dispatch");
        status=a.set_arg(bias_kernel,0,sizeof(delta_buffer),&delta_buffer);
        status|=a.set_arg(bias_kernel,1,sizeof(gradient_buffer),&gradient_buffer);
        if(status!=OK)return fail("CCC4 bias arguments");
        status=a.enqueue_kernel(queue,bias_kernel,1,nullptr,&nodes,nullptr,0,nullptr,nullptr);
        if(status!=OK)return fail("CCC4 bias dispatch");
        float part[256]{};
        status=a.enqueue_read(queue,gradient_buffer,1,0,sizeof(part),part,0,nullptr,nullptr);
        if(status!=OK)return fail("CCC4 gradient readback");
        for(unsigned i=0;i<256;++i){
            if(!std::isfinite(part[i])){status=-1;return fail("CCC4 non-finite gradient");}
            gradients[i]+=part[i];
        }
        cleanup_sample();
    }
    cleanup();diagnostic="OpenCL CCC4 gradients computed; parameters unchanged";return true;
#else
    (void)inputs;(void)targets;(void)sample_count;(void)weights;(void)biases;(void)gradients;
    diagnostic="Windows OpenCL backend only";return false;
#endif
}

bool row_index_mod_mean(const float* rows, unsigned row_count, unsigned dimension,
                        unsigned groups,
                        std::vector<float>& candidate, std::string& diagnostic) {
#ifdef _WIN32
    if (!rows || !row_count || !dimension || !groups || row_count < groups ||
        size_t(row_count)>SIZE_MAX/size_t(dimension)/sizeof(float) ||
        size_t(groups)>SIZE_MAX/size_t(dimension)/sizeof(float)) {diagnostic="invalid source shape or group count";return false;}
    Api a;Handle platform=nullptr,device=nullptr;
    if(!a.compute_ready()||!first_device(a,platform,device)){diagnostic="OpenCL CPU device unavailable";return false;}
    auto extensions=info(a,device,DEVICE_EXTENSIONS,false);
    if(extensions.find("cl_khr_fp64")==std::string::npos && extensions.find("cl_amd_fp64")==std::string::npos){diagnostic="device lacks f64 OpenCL extension";return false;}
    const std::string source_text=kernel_source("vector_lane.cl");
    if(source_text.empty()){diagnostic="vector_lane.cl not found beside executable or in cwd";return false;}
    const char* source=source_text.c_str();
    I status=0;Handle ctx=nullptr,queue=nullptr,program=nullptr,kernel=nullptr,input=nullptr,output=nullptr;
    auto cleanup=[&](){if(output)a.release_mem(output);if(input)a.release_mem(input);if(kernel)a.release_kernel(kernel);if(program)a.release_program(program);if(queue)a.release_queue(queue);if(ctx)a.release_context(ctx);};
    auto error=[&](const char* step){diagnostic=std::string(step)+": "+std::to_string(status);cleanup();return false;};
    ctx=a.create_context(nullptr,1,&device,nullptr,nullptr,&status);if(!ctx||status!=OK)return error("clCreateContext");
    queue=a.create_queue(ctx,device,0,&status);if(!queue||status!=OK)return error("clCreateCommandQueue");
    program=a.create_program(ctx,1,&source,nullptr,&status);if(!program||status!=OK)return error("clCreateProgramWithSource");
    status=a.build_program(program,1,&device,"-cl-opt-disable",nullptr,nullptr);
    if(status!=OK){size_t n=0;a.program_info(program,device,0x1183,0,nullptr,&n);std::vector<char> log(n+1);if(n)a.program_info(program,device,0x1183,n,log.data(),nullptr);diagnostic="clBuildProgram: "+std::to_string(status)+" "+log.data();cleanup();return false;}
    kernel=a.create_kernel(program,"row_mod_mean",&status);if(!kernel||status!=OK)return error("clCreateKernel");
    const size_t input_bytes=size_t(row_count)*dimension*sizeof(float),output_bytes=size_t(groups)*dimension*sizeof(float);
    input=a.create_buffer(ctx,MEM_READ_ONLY|MEM_COPY_HOST_PTR,input_bytes,const_cast<float*>(rows),&status);if(!input||status!=OK)return error("input buffer");
    output=a.create_buffer(ctx,MEM_WRITE_ONLY,output_bytes,nullptr,&status);if(!output||status!=OK)return error("output buffer");
    U rc=row_count,d=dimension,g=groups;
    status=a.set_arg(kernel,0,sizeof(input),&input);if(status==OK)status=a.set_arg(kernel,1,sizeof(output),&output);
    if(status==OK)status=a.set_arg(kernel,2,sizeof(rc),&rc);if(status==OK)status=a.set_arg(kernel,3,sizeof(d),&d);
    if(status==OK)status=a.set_arg(kernel,4,sizeof(g),&g);
    if(status!=OK)return error("clSetKernelArg");
    size_t global=size_t(groups)*dimension;
    status=a.enqueue_kernel(queue,kernel,1,nullptr,&global,nullptr,0,nullptr,nullptr);if(status!=OK)return error("clEnqueueNDRangeKernel");
    candidate.resize(size_t(groups)*dimension);
    status=a.enqueue_read(queue,output,1,0,output_bytes,candidate.data(),0,nullptr,nullptr);if(status!=OK)return error("clEnqueueReadBuffer");
    cleanup();diagnostic="OpenCL f64 sequential row-index-mod mean completed";return true;
#else
    (void)rows;(void)row_count;(void)dimension;(void)groups;(void)candidate;diagnostic="Windows OpenCL backend only";return false;
#endif
}
}
