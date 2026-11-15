// Independent C++17 encoder for the fixed CCC4 operator-plan conformance vector.
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <string>
#include <tuple>
#include <vector>
using Bytes=std::vector<uint8_t>;
static void u8(Bytes& b,uint8_t v){b.push_back(v);}
static void u32(Bytes& b,uint32_t v){for(int i=0;i<4;++i)b.push_back(uint8_t(v>>(8*i)));}
static void str(Bytes& b,const std::string& s){u32(b,uint32_t(s.size()));b.insert(b.end(),s.begin(),s.end());}
static void shape(Bytes& b,std::initializer_list<uint32_t> x){u32(b,uint32_t(x.size()));for(auto v:x)u32(b,v);}
struct Port{std::string name;uint32_t dtype;std::vector<uint32_t> dims;};
struct Op{std::string id;uint32_t kind;std::vector<Port> in,out;};
static void ports(Bytes& b,std::vector<Port> p){
    std::sort(p.begin(),p.end(),[](const Port&a,const Port&c){return a.name<c.name;});
    u32(b,uint32_t(p.size()));for(auto& x:p){str(b,x.name);u32(b,x.dtype);u32(b,uint32_t(x.dims.size()));for(auto d:x.dims)u32(b,d);}
}
int main(int argc,char**argv){
    if(argc!=2){std::cerr<<"usage: operator_plan_vector <output.bin>\n";return 2;}
    constexpr uint32_t K=0xffffffffu;
    // Dtypes: f32=0, f64=1, u32=2. K is the symbolic filtered row count.
    std::vector<Op> ops={
        {"source.pattern",0,{},{{"out",0,{99524,256}}}},
        {"filter.rows",1,{{"in",0,{99524,256}}},{{"out",0,{K,256}}}},
        {"map.node_ids",2,{{"in",0,{K,256}}},{{"node_ids",2,{K}},{"vectors",0,{K,256}}}},
        {"fold.groups",3,{{"node_ids",2,{K}},{"vectors",0,{K,256}}},{{"counts",2,{64}},{"sums",1,{64,256}}}},
        {"accumulate.sum_count",4,{},{}} ,
        {"reduce.mean",5,{{"counts",2,{64}},{"sums",1,{64,256}}},{{"out",0,{64,256}}}}
    };
    std::sort(ops.begin(),ops.end(),[](const Op&a,const Op&b){return a.id<b.id;});
    Bytes b;std::string domain="ccc4.operator-plan.v1";b.insert(b.end(),domain.begin(),domain.end());u8(b,0);u32(b,uint32_t(ops.size()));
    for(const auto& op:ops){
        str(b,op.id);u32(b,op.kind);ports(b,op.in);ports(b,op.out);
        switch(op.kind){
        case 0:str(b,"EmbeddingGemma2.pattern_vectors");break;
        case 1:str(b,"row_index_in_range");u8(b,0);break;
        case 2:str(b,"row_index_mod64");u32(b,2);break;
        case 3:str(b,"node_id");u32(b,0);u32(b,1);u32(b,0);u8(b,1);u32(b,0);str(b,"zero_sums_and_counts");break;
        case 4:str(b,"sum_count_step_f64");shape(b,{64,256});break;
        case 5:u32(b,0);u32(b,0);shape(b,{64,256});break;
        }
    }
    std::vector<std::tuple<std::string,std::string,std::string>> containment={{"fold.groups","accumulate.sum_count","owns_accumulator"}};
    u32(b,uint32_t(containment.size()));for(auto& r:containment){str(b,std::get<0>(r));str(b,std::get<1>(r));str(b,std::get<2>(r));}
    std::vector<std::tuple<std::string,std::string,std::string,std::string>> flow={
        {"source.pattern","out","filter.rows","in"},{"filter.rows","out","map.node_ids","in"},
        {"map.node_ids","node_ids","fold.groups","node_ids"},{"map.node_ids","vectors","fold.groups","vectors"},
        {"fold.groups","counts","reduce.mean","counts"},{"fold.groups","sums","reduce.mean","sums"}};
    std::sort(flow.begin(),flow.end());u32(b,uint32_t(flow.size()));
    for(auto& r:flow){str(b,std::get<0>(r));str(b,std::get<1>(r));str(b,std::get<2>(r));str(b,std::get<3>(r));}
    std::vector<std::pair<std::string,std::string>> deps={{"source.pattern","filter.rows"},{"filter.rows","map.node_ids"},{"map.node_ids","fold.groups"},{"fold.groups","reduce.mean"}};
    std::sort(deps.begin(),deps.end());u32(b,uint32_t(deps.size()));for(auto& r:deps){str(b,r.first);str(b,r.second);}
    str(b,"row_index_mod");u32(b,64);u32(b,99524);u32(b,64);
    shape(b,{99524,256});shape(b,{64,256});u8(b,0);
    std::ofstream out(argv[1],std::ios::binary);out.write(reinterpret_cast<const char*>(b.data()),std::streamsize(b.size()));
    if(!out){std::cerr<<"write failed\n";return 1;}std::cout<<b.size()<<" bytes\n";
}
