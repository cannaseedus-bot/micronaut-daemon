#include "vector_plan.h"
#include "phase.hpp"
#include <algorithm>
#include <cmath>
#include <limits>
#include <map>
#include <set>
#include <stdexcept>
#include <unordered_map>

namespace micronaut::vector_plan {
namespace {
void require(bool ok, const char* message) { if (!ok) throw std::runtime_error(message); }
std::string value(const Json& j, const char* key) {
    require(j.contains(key) && j.at(key).is_string(), "missing string plan field");
    return j.at(key).get<std::string>();
}
unsigned uint(const Json& j, const char* key) {
    require(j.contains(key) && j.at(key).is_number_integer() &&
            j.at(key).get<std::int64_t>()>=0 &&
            j.at(key).get<std::uint64_t>()<=std::numeric_limits<unsigned>::max(),
            "missing unsigned plan field");
    return j.at(key).get<unsigned>();
}
bool is_kind(const Json& j, const char* kind) { return value(j, "kind") == kind; }
bool is_transform(const Json& j) { return is_kind(j,"FILTER") || is_kind(j,"MAP"); }
void check_policy(const Json& op, unsigned groups, const PolicyRegistry* registry) {
    const auto kind=value(op,"kind"), policy=value(op,"policy");
    if (kind=="SOURCE") require(policy=="artifact", "unsupported SOURCE policy");
    else if (kind=="FILTER") {
        require(policy=="all" || policy=="row_range" || policy=="row_mod_eq" || policy=="norm_min" ||
                (registry && registry->filters.count(policy)), "unknown FILTER policy");
        if (policy=="row_range") require(uint(op,"start")<=uint(op,"stop"), "invalid FILTER range");
        if (policy=="row_mod_eq") require(uint(op,"modulus")>0 && uint(op,"remainder")<uint(op,"modulus"), "invalid FILTER modulus");
        if (policy=="norm_min") require(op.contains("threshold") && op.at("threshold").is_number() &&
            std::isfinite(op.at("threshold").get<double>()) && op.at("threshold").get<double>()>=0,
            "invalid FILTER norm threshold");
    } else if (kind=="MAP") {
        require(policy=="row_index_mod" || policy=="scale" || policy=="l2_normalize" ||
                (registry && registry->maps.count(policy)), "unknown MAP policy");
        if (policy=="row_index_mod") require(uint(op,"modulus")==groups, "MAP modulus must equal group count");
        if (policy=="scale") require(op.contains("factor") && op.at("factor").is_number() &&
            std::isfinite(op.at("factor").get<double>()), "invalid MAP scale factor");
    } else if (kind=="FOLD") {
        require(policy=="mean" || policy=="sum" || policy=="min" || policy=="max" ||
                (registry && registry->folds.count(policy)), "unknown FOLD policy");
        require(value(op,"precision")=="f64" && value(op,"order")=="sequential_row_index_ascending",
            "unsupported FOLD precision or order");
        const auto empty=value(op,"empty_group_policy");
        require(empty=="reject" || empty=="zero", "unsupported empty-group policy");
    } else if (kind=="ACCUMULATE") {
        require(policy=="f64_sequential", "unsupported ACCUMULATE policy");
    } else if (kind=="REDUCE") {
        require(policy=="to_f32", "unsupported REDUCE policy");
    } else throw std::runtime_error("unknown operator kind");
}
void accumulate_row(Groups& group, const Lane& lane, std::size_t row,
                    const Json& fold_op, const PolicyRegistry* registry) {
    const unsigned node=lane.node_ids[row];
    require(node<group.count,"MAP produced out-of-range node");
    for(unsigned col=0;col<group.dim;++col) {
        const double x=lane.values[row*group.dim+col];
        require(std::isfinite(x),"ACCUMULATE source is non-finite");
        auto& a=group.values[std::size_t(node)*group.dim+col];
        if (group.policy=="mean" || group.policy=="sum")a=a+x;
        else if (group.policy=="min")a=group.counts[node]?std::min(a,x):x;
        else if (group.policy=="max")a=group.counts[node]?std::max(a,x):x;
        else {
            require(registry && registry->folds.count(group.policy), "custom FOLD callback unavailable");
            a=registry->folds.at(group.policy)(a,x,group.counts[node]==0,fold_op);
            require(std::isfinite(a), "custom FOLD callback produced non-finite value");
        }
    }
    ++group.counts[node];
}
}

ResolvedPlan resolve(const Json& plan, unsigned artifact_rows, unsigned artifact_dim,
                     const PolicyRegistry* registry) {
    require(value(plan,"contract")=="ccc4.operator-plan.v2", "unknown operator plan version");
    require(plan.contains("materialized") && plan.at("materialized")==false,
        "resolution requires materialized=false");
    require(plan.contains("operators") && plan.at("operators").is_array() &&
            plan.contains("data_flow") && plan.at("data_flow").is_array() &&
            plan.contains("execution_dependencies") && plan.at("execution_dependencies").is_array() &&
            plan.contains("containment") && plan.at("containment").is_array(), "missing operator graph sections");
    require(uint(plan,"source_rows")==artifact_rows && uint(plan,"dimension")==artifact_dim,
        "artifact header does not match declared source shape");
    const unsigned groups=uint(plan,"groups");
    require(groups==64 && artifact_rows && artifact_dim &&
            std::size_t(artifact_rows)<=SIZE_MAX/std::size_t(artifact_dim)/sizeof(float),
            "CCC4 requires 64 groups and a valid source shape");
    std::map<std::string,Json> ops;
    std::map<std::string,unsigned> kind_counts;
    for (const auto& op:plan.at("operators")) {
        const auto id=value(op,"id"), kind=value(op,"kind");
        require(!id.empty() && !ops.count(id), "duplicate or empty operator id");
        check_policy(op,groups,registry);
        ops.emplace(id,op);++kind_counts[kind];
    }
    require(kind_counts["SOURCE"]==1 && kind_counts["FOLD"]==1 &&
            kind_counts["ACCUMULATE"]==1 && kind_counts["REDUCE"]==1,
            "plan needs one SOURCE, FOLD, ACCUMULATE, and REDUCE");
    std::string source,fold,accumulate,reduce;
    for (const auto& [id,op]:ops) {
        if (is_kind(op,"SOURCE")) source=id;
        if (is_kind(op,"FOLD")) fold=id;
        if (is_kind(op,"ACCUMULATE")) accumulate=id;
        if (is_kind(op,"REDUCE")) reduce=id;
    }
    require(value(ops[source],"artifact_ref").size()>0, "SOURCE artifact reference missing");
    require(plan.at("containment").size()==1 &&
            value(plan.at("containment")[0],"parent")==fold &&
            value(plan.at("containment")[0],"child")==accumulate &&
            value(plan.at("containment")[0],"role")=="owns_accumulator",
            "FOLD must own exactly one ACCUMULATE");
    std::map<std::string,std::string> input;
    std::set<std::pair<std::string,std::string>> flows,deps;
    for (const auto& edge:plan.at("data_flow")) {
        const auto from=value(edge,"source"),to=value(edge,"target");
        require(ops.count(from) && ops.count(to) && from!=to &&
                !is_kind(ops[from],"ACCUMULATE") && !is_kind(ops[to],"ACCUMULATE"),
                "invalid data-flow endpoint");
        require(!input.count(to), "operator has multiple data-flow inputs");
        input[to]=from;
        require(flows.insert({from,to}).second, "duplicate data-flow edge");
    }
    for (const auto& edge:plan.at("execution_dependencies")) {
        const auto from=value(edge,"before"),to=value(edge,"after");
        require(ops.count(from) && ops.count(to) && from!=to &&
                !is_kind(ops[from],"ACCUMULATE") && !is_kind(ops[to],"ACCUMULATE"),
                "invalid execution dependency endpoint");
        require(deps.insert({from,to}).second, "duplicate execution dependency");
    }
    require(flows==deps, "execution dependencies must exactly match data flow in v2");
    require(!input.count(source) && !input.count(accumulate) &&
            input.size()==ops.size()-2, "missing or extra data-flow input");
    for (const auto& [id,op]:ops) if (input.count(id)) {
        const auto& upstream=ops.at(input.at(id));
        if (is_kind(op,"FILTER") || is_kind(op,"MAP"))
            require(is_kind(upstream,"SOURCE") || is_transform(upstream), "FILTER/MAP expects lane input");
        if (is_kind(op,"FOLD"))
            require(is_kind(upstream,"SOURCE") || is_transform(upstream), "FOLD expects lane input");
        if (is_kind(op,"REDUCE")) require(is_kind(upstream,"FOLD"), "REDUCE expects FOLD output");
    }
    std::map<std::string,unsigned> indegree;
    for (const auto& [id,op]:ops) if (id!=accumulate) indegree[id]=0;
    for (const auto& [a,b]:deps) ++indegree[b];
    std::set<std::string> ready;
    for (const auto& [id,n]:indegree) if (!n) ready.insert(id);
    std::vector<std::string> order;
    while (!ready.empty()) {
        auto id=*ready.begin();ready.erase(ready.begin());order.push_back(id);
        for (const auto& [a,b]:deps) if (a==id && --indegree[b]==0) ready.insert(b);
    }
    require(order.size()==ops.size()-1 && order.front()==source && order.back()==reduce,
            "execution graph is cyclic or disconnected");
    ResolvedPlan result;result.declaration=plan;result.canonical_declaration=plan.dump();result.order=order;
    result.rows=artifact_rows;result.dim=artifact_dim;result.groups=groups;return result;
}

Result execute(const ResolvedPlan& plan, const float* source, std::size_t values,
               bool host_authorized, const PolicyRegistry* registry) {
    require(host_authorized, "operator execution requires host admission");
    require(kuhul::phase::operatorAuthorized(kuhul::phase::Name::Sek,kuhul::phase::Operator::Fold) &&
            kuhul::phase::operatorAuthorized(kuhul::phase::Name::Sek,kuhul::phase::Operator::Map) &&
            kuhul::phase::operatorAuthorized(kuhul::phase::Name::Sek,kuhul::phase::Operator::Filter) &&
            kuhul::phase::operatorAuthorized(kuhul::phase::Name::Sek,kuhul::phase::Operator::Reduce),
            "Sek operator phase gate rejected vector plan");
    require(plan.declaration.dump()==plan.canonical_declaration,
            "resolved declaration changed before execution");
    // Recheck named callbacks; the registry is host-owned and may differ from
    // the one used at resolution time.
    for (const auto& op:plan.declaration.at("operators"))check_policy(op,plan.groups,registry);
    require(source && values==std::size_t(plan.rows)*plan.dim, "source payload shape mismatch");
    for(std::size_t i=0;i<values;++i)require(std::isfinite(source[i]),"source contains non-finite value");
    std::map<std::string,Json> ops;
    std::map<std::string,std::string> input;
    for (const auto& op:plan.declaration.at("operators"))ops[value(op,"id")]=op;
    for (const auto& edge:plan.declaration.at("data_flow"))input[value(edge,"target")]=value(edge,"source");
    const auto& ownership=plan.declaration.at("containment").at(0);
    const auto accumulate_id=value(ownership,"child");
    std::map<std::string,Lane> lanes;
    std::map<std::string,Groups> aggregates;
    Result out;out.groups=plan.groups;out.dim=plan.dim;
    for (const auto& id:plan.order) {
        const auto& op=ops.at(id);
        const auto kind=value(op,"kind"),policy=value(op,"policy");
        out.trace.push_back(id+":"+kind+":"+policy);
        if (kind=="SOURCE") {
            Lane lane;lane.dim=plan.dim;lane.values.assign(source,source+values);
            lane.row_ids.resize(plan.rows);
            for (unsigned i=0;i<plan.rows;++i)lane.row_ids[i]=i;
            lanes[id]=std::move(lane);
        } else if (kind=="FILTER") {
            const auto& prior=lanes.at(input.at(id));Lane lane;lane.dim=prior.dim;
            for (std::size_t r=0;r<prior.rows();++r) {
                const auto row=prior.row_ids[r];bool keep=true;
                if (policy=="row_range")keep=row>=uint(op,"start") && row<uint(op,"stop");
                else if (policy=="row_mod_eq")keep=row%uint(op,"modulus")==uint(op,"remainder");
                else if (policy=="norm_min") {
                    double norm=0.0;for(unsigned col=0;col<lane.dim;++col){double x=prior.values[r*lane.dim+col];norm+=x*x;}
                    keep=std::sqrt(norm)>=op.at("threshold").get<double>();
                } else if (policy!="all") {
                    require(registry && registry->filters.count(policy),"custom FILTER callback unavailable");
                    keep=registry->filters.at(policy)(row,prior.values.data()+r*lane.dim,lane.dim,op);
                }
                if (!keep)continue;
                lane.row_ids.push_back(row);
                if (!prior.node_ids.empty())lane.node_ids.push_back(prior.node_ids[r]);
                lane.values.insert(lane.values.end(),prior.values.begin()+r*lane.dim,
                                   prior.values.begin()+(r+1)*lane.dim);
            }
            lanes[id]=std::move(lane);
        } else if (kind=="MAP") {
            Lane lane=lanes.at(input.at(id));
            if (policy=="row_index_mod") {
                lane.node_ids.resize(lane.rows());
                for(std::size_t r=0;r<lane.rows();++r)lane.node_ids[r]=lane.row_ids[r]%plan.groups;
            } else if (policy=="scale") {
                const double factor=op.at("factor").get<double>();
                for (auto& x:lane.values) {
                    const double y=double(x)*factor;
                    require(std::isfinite(y) && std::abs(y)<=std::numeric_limits<float>::max(),"MAP scale overflow");
                    x=float(y);
                }
            } else if (policy=="l2_normalize") {
                for(std::size_t r=0;r<lane.rows();++r) {
                    double norm=0.0;for(unsigned c=0;c<lane.dim;++c){double x=lane.values[r*lane.dim+c];norm+=x*x;}
                    if (norm>0)for(unsigned c=0;c<lane.dim;++c)lane.values[r*lane.dim+c]=float(double(lane.values[r*lane.dim+c])/std::sqrt(norm));
                }
            } else {
                require(registry && registry->maps.count(policy),"custom MAP callback unavailable");
                if(lane.node_ids.empty())lane.node_ids.assign(lane.rows(),UINT32_MAX);
                for(std::size_t r=0;r<lane.rows();++r)
                    registry->maps.at(policy)(lane.row_ids[r],lane.values.data()+r*lane.dim,
                                              lane.dim,lane.node_ids[r],op);
            }
            lanes[id]=std::move(lane);
        } else if (kind=="FOLD") {
            const auto& lane=lanes.at(input.at(id));
            require(lane.node_ids.size()==lane.rows(),"FOLD needs a MAP node assignment");
            require(value(ownership,"parent")==id && is_kind(ops.at(accumulate_id),"ACCUMULATE"),
                "FOLD accumulator ownership changed after resolution");
            out.trace.push_back(accumulate_id+":ACCUMULATE:"+value(ops.at(accumulate_id),"policy"));
            Groups group;group.dim=lane.dim;group.count=plan.groups;group.policy=policy;
            group.empty_policy=value(op,"empty_group_policy");
            group.values.assign(std::size_t(group.count)*group.dim,0.0);
            group.counts.assign(group.count,0);
            for(std::size_t r=0;r<lane.rows();++r)accumulate_row(group,lane,r,op,registry);
            aggregates[id]=std::move(group);
        } else if (kind=="REDUCE") {
            out.values=reduce_groups(aggregates.at(input.at(id)));
        }
    }
    return out;
}
}
