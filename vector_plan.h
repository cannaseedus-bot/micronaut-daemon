#pragma once
#include <nlohmann/json.hpp>
#include <cstdint>
#include <functional>
#include <map>
#include <string>
#include <vector>

namespace micronaut::vector_plan {
using Json = nlohmann::json;
struct Lane {
    unsigned dim = 0;
    std::vector<float> values;
    std::vector<std::uint32_t> row_ids;
    std::vector<std::uint32_t> node_ids;
    std::size_t rows() const { return row_ids.size(); }
};
struct Groups {
    unsigned dim = 0;
    unsigned count = 0;
    std::string policy;
    std::string empty_policy;
    std::vector<double> values;
    std::vector<std::uint32_t> counts;
};
struct ResolvedPlan {
    Json declaration;
    std::string canonical_declaration;
    std::vector<std::string> order;
    unsigned rows = 0;
    unsigned dim = 0;
    unsigned groups = 64;
};
struct Result {
    std::vector<float> values;
    unsigned groups = 0;
    unsigned dim = 0;
    std::vector<std::string> trace;
};
// Host code registers custom policies; JSON can only name an existing callback.
struct PolicyRegistry {
    using Filter = std::function<bool(std::uint32_t, const float*, unsigned, const Json&)>;
    using Map = std::function<void(std::uint32_t, float*, unsigned, std::uint32_t&, const Json&)>;
    using Fold = std::function<double(double, double, bool, const Json&)>;
    std::map<std::string, Filter> filters;
    std::map<std::string, Map> maps;
    std::map<std::string, Fold> folds;
};
ResolvedPlan resolve(const Json& declaration, unsigned artifact_rows, unsigned artifact_dim,
                     const PolicyRegistry* registry = nullptr);
Result execute(const ResolvedPlan& plan, const float* source, std::size_t values,
               bool host_authorized, const PolicyRegistry* registry = nullptr);
std::vector<float> reduce_groups(const Groups& groups);
}
