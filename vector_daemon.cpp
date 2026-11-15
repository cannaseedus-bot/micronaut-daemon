#include "vector_daemon.h"
#include "bindings.hpp"
#include "file_digest.h"
#include "kuhul_runtime.h"
#include "vector_store.h"
#include "vector_plan.h"
#include "chen_vector_plan.h"
#include <nlohmann/json.hpp>
#include <cstring>
#include <cstdlib>
#include <fstream>
#include <sstream>
#include <stdexcept>

namespace micronaut {
namespace {
// Host-approved Stage-2 record. Changing the record requires a new build.
constexpr const char* kApprovedRecordSha256 =
    "c0c2816e5e862fae39307eafd45dfdcec0d6b2b4d37abfc09ff54d2233e65702";
}
MicronautResult vector_candidate_execute(const MicronautOp& op) {
    MicronautResult result;result.id=op.id;result.op=op.op;
    auto deny=[&](const std::string& code,const std::string& message){result.ok=false;result.error_code=code;result.error_message=message;return result;};
    // Host-owned gate: the request body cannot set ingress or this environment
    // variable. HTTP currently exposes chat only; the vector route is stdin only.
    const char* enabled=std::getenv("MICRONAUT_VECTOR_CANDIDATE");
    if(op.op!="vector.candidate" || op.ingress!="stdin" || !enabled || std::string(enabled)!="1")
        return deny("XCFE_ADMISSION_DENIED","vector candidate requires host-enabled local stdin ingress");
    for(const auto& field:op.payload.flat)
        if(field.first!="op"&&field.first!="id"&&field.first!="@kind")
            return deny("XCFE_ADMISSION_DENIED","vector candidate accepts no request-selected paths or authority flags");
    try {
#ifndef MICRONAUT_SOURCE_ROOT
        throw std::runtime_error("source root not configured");
#else
        const std::string root=MICRONAUT_SOURCE_ROOT;
#endif
        const std::string record_path=root+"/build/ccc4-vector-binding.candidate.json";
        if(file_sha256(record_path)!=kApprovedRecordSha256)
            return deny("VECTOR_BINDING_INVALID","binding record is not host-approved");
        kuhul::binding::Environment bindings;
        std::string binding_error;
        if(!kuhul::binding::bind_vector_candidate(bindings,record_path,&binding_error))
            return deny("VECTOR_BINDING_INVALID",binding_error);
        if(kuhul::binding::canExecute(bindings,"runtime.vector.pattern",true))
            return deny("VECTOR_BINDING_INVALID","data-only binding unexpectedly executable");
        std::ifstream input(record_path,std::ios::binary);
        auto record=nlohmann::json::parse(input);
        auto check=[&](const std::string& path,const std::string& expected,const char* label){
            if(file_sha256(path)!=expected)throw std::runtime_error(std::string(label)+" digest mismatch");
        };
        const auto vector_dir=root+"/build/io/aiml-embeddinggemma2-vectors/";
        const auto& artifacts=record.at("artifacts");
        for(const char* name:{"pattern_vectors.f32.npy","template_vectors.f32.npy","category_vectors.f32.npy"})
            check(vector_dir+name,artifacts.at(name).at("sha256").get<std::string>(),name);
        check(root+"/vector_lane.cl",record.at("kernel").at("sha256").get<std::string>(),"vector_lane.cl");
        check(root+"/build/ccc4-operator-plan.v1.json",record.at("plan_document_sha256").get<std::string>(),"operator plan");
        check(vector_dir+"manifest.json",record.at("manifest_sha256").get<std::string>(),"manifest");
        check(vector_dir+"aiml_pattern_template_pairs.jsonl",record.at("alignment_digest").get<std::string>(),"alignment");
        check(root+"/build/io/aiml-corpus.jsonl",record.at("source_sha256").get<std::string>(),"AIML source");
        auto matrix=vector_store::load_npy(vector_dir+"pattern_vectors.f32.npy");
        auto candidate=kuhul_runtime::run_row_index_mod64(matrix.values.data(),matrix.rows,matrix.dim,{true,true});
        if(!candidate.ok||!candidate.verified||candidate.committed)
            return deny("VECTOR_CANDIDATE_REJECTED",candidate.error.empty()?"candidate verification failed":candidate.error);
        std::ostringstream body;
        body<<"{\"shape\":[64,256],\"verified\":true,\"committed\":false,\"topology_hash\":\""
            <<record.at("topology_hash").get<std::string>()<<"\",\"operator_plan_hash\":\""
            <<record.at("operator_plan_hash").get<std::string>()<<"\",\"first_values\":["
            <<candidate.values[0]<<","<<candidate.values[1]<<","<<candidate.values[2]<<","<<candidate.values[3]<<"]}";
        result.ok=true;result.result_json=body.str();return result;
    }catch(const std::exception& error){return deny("VECTOR_BINDING_INVALID",error.what());}
}

MicronautResult vector_candidate_v2_execute(const MicronautOp& op) {
    MicronautResult result;result.id=op.id;result.op=op.op;
    auto deny=[&](const std::string& code,const std::string& message){
        result.ok=false;result.error_code=code;result.error_message=message;return result;};
    const char* enabled=std::getenv("MICRONAUT_VECTOR_PLAN_V2_DAEMON");
    if(op.op!="vector.plan.v2.candidate" || op.ingress!="stdin" || !enabled || std::string(enabled)!="1")
        return deny("XCFE_ADMISSION_DENIED","v2 candidate requires host-enabled local stdin ingress");
    for(const auto& field:op.payload.flat)
        if(field.first!="op"&&field.first!="id"&&field.first!="@kind"&&field.first!="plan_id")
            return deny("XCFE_ADMISSION_DENIED","v2 candidate accepts no request-selected paths or authority flags");
    try {
#ifndef MICRONAUT_SOURCE_ROOT
        throw std::runtime_error("source root not configured");
#else
        const std::string root=MICRONAUT_SOURCE_ROOT;
#endif
        const std::string catalog_path=root+"/build/ccc4-v2-admission/catalog.json";
        if(file_sha256(catalog_path)!="bd302e84360f7bfb7d03b7f16f2a74d42a0726516ecb819ca7576c65159c6924")
            return deny("VECTOR_BINDING_INVALID","v2 admission catalog digest mismatch");
        std::ifstream catalog_input(catalog_path,std::ios::binary);
        auto catalog=nlohmann::json::parse(catalog_input);
        std::string plan_id="fold_mean";
        auto selected=op.payload.flat.find("plan_id");
        if(selected!=op.payload.flat.end())plan_id=selected->second;
        if(!catalog.contains(plan_id))return deny("XCFE_ADMISSION_DENIED","unknown v2 plan_id");
        const std::string plan_path=root+"/build/ccc4-v2-admission/"+plan_id+".json";
        const std::string source_path=root+"/build/io/aiml-embeddinggemma2-vectors/pattern_vectors.f32.npy";
        if(file_sha256(plan_path)!=catalog.at(plan_id).at("file_sha256").get<std::string>() ||
           file_sha256(source_path)!="0494c4d5fd143d365478c776edc821c7954a98dc454db1184c58e9ba90b8ef35")
            return deny("VECTOR_BINDING_INVALID","v2 plan or source digest mismatch");
        std::ifstream input(plan_path,std::ios::binary);
        auto declaration=vector_plan::Json::parse(input);
        auto matrix=vector_store::load_npy(source_path);
        auto plan=vector_plan::resolve(declaration,matrix.rows,matrix.dim);
        auto candidate=vector_plan::execute(plan,matrix.values.data(),matrix.values.size(),true);
        auto chen=chen_vector_plan::reference(plan,matrix.values.data(),matrix.values.size());
        if(candidate.values.size()!=chen.size() ||
           std::memcmp(candidate.values.data(),chen.data(),candidate.values.size()*sizeof(float))!=0)
            return deny("VECTOR_CANDIDATE_REJECTED","v2 candidate differs from independent Ch'en reference");
        if(plan_id=="fold_mean"){
            auto legacy=kuhul_runtime::run_row_index_mod64(matrix.values.data(),matrix.rows,matrix.dim,{true,true});
            if(!legacy.ok||!legacy.verified||legacy.committed||legacy.values.size()!=chen.size()||
               std::memcmp(legacy.values.data(),chen.data(),chen.size()*sizeof(float))!=0)
                return deny("VECTOR_CANDIDATE_REJECTED","v2 mean differs from legacy Ch'en reference");
        }
        nlohmann::json body={{"shape",{64,matrix.dim}},{"verified",true},{"committed",false},
            {"plan_id",plan_id},{"operator_plan_hash",catalog.at(plan_id).at("plan_sha256")},
            {"first_values",{candidate.values[0],candidate.values[1],candidate.values[2],candidate.values[3]}}};
        result.ok=true;result.result_json=body.dump();return result;
    }catch(const std::exception& error){return deny("VECTOR_BINDING_INVALID",error.what());}
}
}
