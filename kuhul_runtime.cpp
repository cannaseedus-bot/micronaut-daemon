#include "kuhul_runtime.h"
#include "opencl.h"
#include "phase_gate.h"
#include <cmath>
#include <cstring>

namespace micronaut::kuhul_runtime {
Ccc4StateStore::Snapshot Ccc4StateStore::snapshot() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return {generation_, values_};
}
CandidateResult run_row_index_mod_mean(const float* rows, const RowIndexModPlan& plan,
                                       const Admission& admission,
                                       const CommitRequest* commit) {
    CandidateResult result;
    const unsigned row_count=plan.source_rows,dimension=plan.dimension,groups=plan.groups;
    if (commit && (!commit->host_authorized || !commit->store)) {
        result.error="CCC4 commit requires host authorization and a state store";
        return result;
    }
    if (!admission.local_execution_requested || !admission.artifact_shape_validated) {
        result.error="local execution and validated artifact shape are required";
        return result;
    }
    if (!rows || !row_count || !dimension || groups!=64 || row_count<groups ||
        size_t(row_count)>SIZE_MAX/size_t(dimension)/sizeof(float)) {
        result.error="CCC4 row-index-mod plan requires f32 rows, 64 nonempty groups, and a valid dimension";
        return result;
    }
    attention::AttentionContext phase;
    if (!attention::pop(phase) || !attention::wo(phase) || !attention::yax(phase) ||
        !attention::phase_is(phase, attention::RuntimePhase::Sek)) {
        result.error="phase sequence rejected before Sek";
        result.trace=std::move(phase.trace);
        return result;
    }
    std::string diagnostic;
    if (!opencl::row_index_mod_mean(rows,row_count,dimension,groups,result.values,diagnostic)) {
        result.error=diagnostic;result.values.clear();result.trace=std::move(phase.trace);
        return result;
    }
    phase.trace.push_back("candidate:Sek:OpenCL:row_index_mod:f64_sequential");
    if (!attention::sek(phase) || !attention::phase_is(phase,attention::RuntimePhase::Chen)) {
        result.error="phase sequence rejected before Ch'en";
        result.values.clear();result.trace=std::move(phase.trace);
        return result;
    }
    if (result.values.size()!=size_t(groups)*dimension) {
        result.error="candidate shape mismatch";
        result.values.clear();result.trace=std::move(phase.trace);
        return result;
    }
    for (unsigned node=0;node<groups;++node) for (unsigned col=0;col<dimension;++col) {
        double sum=0.0;unsigned count=0;
        for (unsigned row=node;row<row_count;row+=groups) {
            float input=rows[size_t(row)*dimension+col];
            if (!std::isfinite(input)) {
                result.error="source contains non-finite vector value";
                result.values.clear();result.trace=std::move(phase.trace);
                return result;
            }
            sum=sum+static_cast<double>(input);++count;
        }
        if (count != row_count/groups+(node<row_count%groups?1u:0u)) {
            result.error="partition count mismatch";
            result.values.clear();result.trace=std::move(phase.trace);
            return result;
        }
        float expected=static_cast<float>(sum/static_cast<double>(count));
        float actual=result.values[size_t(node)*dimension+col];
        if (!std::isfinite(actual) || std::memcmp(&actual,&expected,sizeof(float))!=0) {
            result.error="candidate differs from sequential f64 host reference";
            result.values.clear();result.trace=std::move(phase.trace);
            return result;
        }
    }
    phase.trace.push_back("candidate:Chen:shape_finite_count_bit_exact_verified");
    result.verified=true;
    if (!attention::chen(phase) || !attention::xul(phase)) {
        result.error="phase sequence rejected at Xul";
        result.values.clear();result.verified=false;result.trace=std::move(phase.trace);
        return result;
    }
    if (commit) {
        std::vector<float> staged=result.values;
        auto& store=*commit->store;
        std::lock_guard<std::mutex> lock(store.mutex_);
        if (store.generation_ != commit->expected_generation) {
            result.error="CCC4 state generation changed before commit";
            result.trace=std::move(phase.trace);
            return result;
        }
        store.values_.swap(staged);
        ++store.generation_;
        result.committed=true;
        phase.trace.push_back("candidate:Xul:in_memory_state_committed");
    } else {
        phase.trace.push_back("candidate:Xul:returned_without_commit");
    }
    result.ok=true;
    result.trace=std::move(phase.trace);
    return result;
}
CandidateResult run_row_index_mod64(const float* rows, unsigned row_count,
                                    unsigned dimension, const Admission& admission,
                                    const CommitRequest* commit) {
    return run_row_index_mod_mean(rows,{row_count,dimension,64},admission,commit);
}
}
