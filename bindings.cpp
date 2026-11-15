#include "bindings.hpp"
#include <nlohmann/json.hpp>
#include <fstream>
#include <regex>
#include <stdexcept>
#include <utility>
#include <vector>
namespace kuhul::binding {
SyncResult Environment::synchronize(const BindingSync& sync) {
    auto* source = const_cast<Binding*>(resolve(sync.source));
    auto* target = const_cast<Binding*>(resolve(sync.target));
    if (!source || !target) return SyncResult::Conflict;
    if (sync.sourceType != sync.targetType) return SyncResult::RequiresConversion;
    if (sync.source == sync.target) return SyncResult::Cycle;
    auto it = syncs_.find(sync.target);
    if (it != syncs_.end() && it->second.source == sync.source) return SyncResult::Cycle;
    target->value = source->value;
    target->resolved = source->resolved;
    target->typeValid = source->typeValid;
    // Synchronization never copies executeAllowed or semanticAdmitted.
    syncs_[sync.target] = sync;
    ++revision_;
    return SyncResult::Compatible;
}
bool canExecute(const Environment& env, const std::string& lane, bool operatorAuthorized) {
    return operatorAuthorized && env.executable(lane);
}

bool bind_vector_candidate(Environment& env, const std::string& record_path, std::string* error) {
    try {
        std::ifstream in(record_path, std::ios::binary);
        if (!in) throw std::runtime_error("cannot open binding record");
        const auto record = nlohmann::json::parse(in);
        auto require = [](bool condition, const char* message) {
            if (!condition) throw std::runtime_error(message);
        };
        require(record.at("schema") == "ccc4.vector-binding.candidate.v1", "binding schema mismatch");
        require(record.at("status") == "BINDINGS_VALIDATED_CANDIDATE", "binding status mismatch");
        require(record.at("topology_hash") == "af51f5244ce5ea7fdb352d9fae31ddf511aaca86f442515e81471df5726b1116", "topology identity mismatch");
        require(record.at("contract_hash") == "94c9a48fba859b751acfb844fff046f59d6de6b419706614e7daa7fff97b22d6", "tensor contract identity mismatch");
        require(record.at("operator_plan_hash") == "48e1ab4390e7e83ae452861b89f79696c2aa3b963b1429a24cc8dc7417ecd315", "operator plan identity mismatch");
        require(record.at("declared_source_shape") == nlohmann::json::array({99524,256}), "source shape mismatch");
        require(record.at("declared_target_shape") == nlohmann::json::array({64,256}), "target shape mismatch");
        require(record.at("materialized") == false && record.at("execution_authorized") == false &&
                record.at("persistence_authorized") == false, "candidate must grant no execution or persistence");
        const auto& counts=record.at("partition_counts");
        require(counts.is_array() && counts.size()==64, "partition counts mismatch");
        for (std::size_t i=0;i<64;++i)
            require(counts.at(i) == (i<4?1556:1555), "partition count mismatch");
        const auto& artifacts=record.at("artifacts");
        require(artifacts.is_object() && artifacts.size()==3, "artifact set mismatch");
        const std::regex digest("^[0-9a-f]{64}$");
        struct Entry { const char* name; const char* key; };
        const Entry entries[]={{"pattern_vectors.f32.npy","runtime.vector.pattern"},
                               {"template_vectors.f32.npy","runtime.vector.template"},
                               {"category_vectors.f32.npy","runtime.vector.category"}};
        std::vector<Binding> pending;
        for (const auto& entry:entries) {
            const auto& artifact=artifacts.at(entry.name);
            require(artifact.at("shape") == nlohmann::json::array({99524,256}) &&
                    artifact.at("dtype") == "float32", "artifact shape or dtype mismatch");
            const auto digest_value=artifact.at("sha256").get<std::string>();
            require(std::regex_match(digest_value,digest), "artifact digest malformed");
            pending.push_back(Binding{entry.key,digest_value,Kind::Vector,Scope::Lane,
                                      true,true,false,false,false});
        }
        const auto& selected=record.at("selected_artifact");
        require(selected.at("role") == "A_pattern_context" &&
                selected.at("filename") == "pattern_vectors.f32.npy" &&
                selected.at("shape") == nlohmann::json::array({99524,256}) &&
                selected.at("dtype") == "float32" &&
                selected.at("sha256") == artifacts.at("pattern_vectors.f32.npy").at("sha256"),
                "selected artifact binding mismatch");
        const auto& kernel=record.at("kernel");
        require(kernel.at("filename") == "vector_lane.cl" &&
                kernel.at("entry") == "row_mod_mean" &&
                kernel.at("backend") == "OpenCL 1.2" &&
                std::regex_match(kernel.at("sha256").get<std::string>(),digest),
                "kernel binding mismatch");
        for (auto& binding:pending) env.bind(std::move(binding));
        if (error) error->clear();
        return true;
    } catch (const std::exception& e) {
        if (error) *error=e.what();
        return false;
    }
}
}

