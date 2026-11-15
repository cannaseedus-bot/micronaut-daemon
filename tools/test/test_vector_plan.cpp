#include "../vector_plan.h"
#include <iostream>
#include <stdexcept>

using micronaut::vector_plan::Json;
int main() {
    auto plan=Json::parse(R"({
      "contract":"ccc4.operator-plan.v2","source_rows":65,"dimension":2,"groups":64,"materialized":false,
      "operators":[
        {"id":"src","kind":"SOURCE","policy":"artifact","artifact_ref":"test.rows"},
        {"id":"filter","kind":"FILTER","policy":"row_range","start":0,"stop":64},
        {"id":"scale","kind":"MAP","policy":"scale","factor":2.0},
        {"id":"assign","kind":"MAP","policy":"row_index_mod","modulus":64},
        {"id":"fold","kind":"FOLD","policy":"sum","precision":"f64","order":"sequential_row_index_ascending","empty_group_policy":"reject"},
        {"id":"acc","kind":"ACCUMULATE","policy":"f64_sequential"},
        {"id":"reduce","kind":"REDUCE","policy":"to_f32"}
      ],
      "containment":[{"parent":"fold","child":"acc","role":"owns_accumulator"}],
      "data_flow":[{"source":"src","target":"filter"},{"source":"filter","target":"scale"},
                   {"source":"scale","target":"assign"},{"source":"assign","target":"fold"},
                   {"source":"fold","target":"reduce"}],
      "execution_dependencies":[{"before":"src","after":"filter"},{"before":"filter","after":"scale"},
                                {"before":"scale","after":"assign"},{"before":"assign","after":"fold"},
                                {"before":"fold","after":"reduce"}]
    })");
    try {
        auto resolved=micronaut::vector_plan::resolve(plan,65,2);
        float rows[130];for(int r=0;r<65;++r){rows[2*r]=float(r);rows[2*r+1]=1.0f;}
        try { (void)micronaut::vector_plan::execute(resolved,rows,130,false);return 1; }
        catch(const std::runtime_error&) {}
        auto result=micronaut::vector_plan::execute(resolved,rows,130,true);
        if(result.values.size()!=128 || result.values[0]!=0 || result.values[1]!=2 ||
           result.values[2]!=2 || result.values[126]!=126 || result.trace.size()!=7)return 2;
        plan["operators"][4]["policy"]="mean";
        auto mean=micronaut::vector_plan::execute(micronaut::vector_plan::resolve(plan,65,2),rows,130,true);
        if(mean.values[126]!=126)return 3;
        plan["operators"][1]["stop"]=1;
        plan["operators"][4]["empty_group_policy"]="zero";
        auto sparse=micronaut::vector_plan::execute(micronaut::vector_plan::resolve(plan,65,2),rows,130,true);
        if(sparse.values[0]!=0 || sparse.values[2]!=0)return 6;
        plan["operators"][4]["empty_group_policy"]="reject";
        try {(void)micronaut::vector_plan::execute(micronaut::vector_plan::resolve(plan,65,2),rows,130,true);return 7;}
        catch(const std::runtime_error&) {}
        auto custom=plan;
        custom["operators"][1]["policy"]="host.keep_all";
        custom["operators"][2]["policy"]="host.triple";
        custom["operators"][4]["policy"]="host.square_sum";
        micronaut::vector_plan::PolicyRegistry registry;
        registry.filters["host.keep_all"] = [](std::uint32_t,const float*,unsigned,const Json&){return true;};
        registry.maps["host.triple"] = [](std::uint32_t,float* row,unsigned dim,std::uint32_t&,const Json&){
            for(unsigned i=0;i<dim;++i)row[i]*=3.0f;
        };
        registry.folds["host.square_sum"] = [](double current,double x,bool,const Json&){return current+x*x;};
        try {(void)micronaut::vector_plan::resolve(custom,65,2);return 8;}
        catch(const std::runtime_error&) {}
        auto custom_result=micronaut::vector_plan::execute(
            micronaut::vector_plan::resolve(custom,65,2,&registry),rows,130,true,&registry);
        if(custom_result.values[2]!=9.0f || custom_result.values[3]!=9.0f){
            std::cerr<<"custom result: "<<custom_result.values[2]<<", "<<custom_result.values[3]<<'\n';return 9;
        }
        plan["execution_dependencies"].push_back({{"before","reduce"},{"after","src"}});
        try {(void)micronaut::vector_plan::resolve(plan,65,2);return 4;}
        catch(const std::runtime_error&) {}
        std::cerr<<"v2 vector plan: admission, FILTER, MAP, FOLD, ACCUMULATE ownership, REDUCE and dependency checks passed\n";
        return 0;
    } catch(const std::exception& e) {std::cerr<<e.what()<<'\n';return 5;}
}
