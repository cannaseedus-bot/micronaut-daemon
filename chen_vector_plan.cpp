#include "chen_vector_plan.h"
#include <cmath>
#include <limits>
#include <stdexcept>
#include <unordered_map>

namespace micronaut::chen_vector_plan {
namespace {
void check(bool valid,const char* message){if(!valid)throw std::runtime_error(message);}
struct Row {unsigned index;unsigned group=64;std::vector<float> values;};
}
std::vector<float> reference(const vector_plan::ResolvedPlan& plan,const float* source,std::size_t values) {
    check(source && values==std::size_t(plan.rows)*plan.dim,"Ch'en source shape mismatch");
    std::unordered_map<std::string,vector_plan::Json> ops;
    for(const auto& op:plan.declaration.at("operators"))ops.emplace(op.at("id").get<std::string>(),op);
    std::vector<Row> rows;rows.reserve(plan.rows);
    for(unsigned r=0;r<plan.rows;++r){
        Row row;row.index=r;row.values.reserve(plan.dim);
        for(unsigned c=0;c<plan.dim;++c){float v=source[std::size_t(r)*plan.dim+c];
            check(std::isfinite(v),"Ch'en source contains non-finite value");row.values.push_back(v);}
        rows.push_back(std::move(row));
    }
    std::string fold_policy,empty_policy;
    for(const auto& id:plan.order){
        const auto& op=ops.at(id);
        const auto kind=op.at("kind").get<std::string>(),policy=op.at("policy").get<std::string>();
        if(kind=="FILTER"){
            std::vector<Row> kept;kept.reserve(rows.size());
            for(auto& row:rows){bool include=false;
                if(policy=="all")include=true;
                else if(policy=="row_range")include=row.index>=op.at("start").get<unsigned>() && row.index<op.at("stop").get<unsigned>();
                else if(policy=="row_mod_eq")include=row.index%op.at("modulus").get<unsigned>()==op.at("remainder").get<unsigned>();
                else if(policy=="norm_min"){
                    double squared=0;for(float x:row.values)squared+=double(x)*double(x);
                    include=std::sqrt(squared)>=op.at("threshold").get<double>();
                }else throw std::runtime_error("Ch'en unsupported FILTER policy");
                if(include)kept.push_back(std::move(row));
            }
            rows.swap(kept);
        }else if(kind=="MAP"){
            if(policy=="row_index_mod")for(auto& row:rows)row.group=row.index%plan.groups;
            else if(policy=="scale"){
                double factor=op.at("factor").get<double>();
                for(auto& row:rows)for(float& x:row.values){double y=double(x)*factor;
                    check(std::isfinite(y)&&std::abs(y)<=std::numeric_limits<float>::max(),"Ch'en MAP scale overflow");
                    x=static_cast<float>(y);}
            }else if(policy=="l2_normalize"){
                for(auto& row:rows){double squared=0;for(float x:row.values)squared+=double(x)*double(x);
                    if(squared>0){double norm=std::sqrt(squared);for(float& x:row.values)x=static_cast<float>(double(x)/norm);}}
            }else throw std::runtime_error("Ch'en unsupported MAP policy");
        }else if(kind=="FOLD"){
            fold_policy=policy;empty_policy=op.at("empty_group_policy").get<std::string>();
        }
    }
    check(!fold_policy.empty(),"Ch'en FOLD missing");
    std::vector<double> accum(std::size_t(plan.groups)*plan.dim,0.0);
    std::vector<unsigned> counts(plan.groups,0);
    for(const auto& row:rows){
        check(row.group<plan.groups,"Ch'en group assignment missing");
        for(unsigned c=0;c<plan.dim;++c){
            double& slot=accum[std::size_t(row.group)*plan.dim+c];double x=row.values[c];
            if(fold_policy=="sum"||fold_policy=="mean")slot+=x;
            else if(fold_policy=="min")slot=counts[row.group]?std::fmin(slot,x):x;
            else if(fold_policy=="max")slot=counts[row.group]?std::fmax(slot,x):x;
            else throw std::runtime_error("Ch'en unsupported FOLD policy");
        }
        ++counts[row.group];
    }
    std::vector<float> output(accum.size());
    for(unsigned g=0;g<plan.groups;++g){
        check(counts[g] || empty_policy=="zero","Ch'en empty group");
        for(unsigned c=0;c<plan.dim;++c){auto i=std::size_t(g)*plan.dim+c;
            double v=counts[g]?(fold_policy=="mean"?accum[i]/counts[g]:accum[i]):0.0;
            check(std::isfinite(v)&&std::abs(v)<=std::numeric_limits<float>::max(),"Ch'en output overflow");
            output[i]=static_cast<float>(v);
        }
    }
    return output;
}
}
