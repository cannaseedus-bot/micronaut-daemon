#include "vector_plan.h"
#include <cmath>
#include <limits>
#include <stdexcept>

namespace micronaut::vector_plan {
std::vector<float> reduce_groups(const Groups& groups) {
    if (!groups.count || !groups.dim ||
        groups.values.size() != std::size_t(groups.count) * groups.dim ||
        groups.counts.size() != groups.count)
        throw std::runtime_error("REDUCE received invalid group shape");
    std::vector<float> result(groups.values.size());
    for (unsigned node = 0; node < groups.count; ++node) {
        if (!groups.counts[node] && groups.empty_policy == "reject")
            throw std::runtime_error("REDUCE encountered an empty group");
        for (unsigned col = 0; col < groups.dim; ++col) {
            const std::size_t i = std::size_t(node) * groups.dim + col;
            const double value = groups.counts[node]
                ? (groups.policy == "mean" ? groups.values[i] / groups.counts[node] : groups.values[i])
                : 0.0;
            if (!std::isfinite(value) || std::abs(value) > std::numeric_limits<float>::max())
                throw std::runtime_error("REDUCE produced non-finite float32 output");
            result[i] = static_cast<float>(value);
        }
    }
    return result;
}
}
