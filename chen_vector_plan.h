#pragma once
#include "vector_plan.h"

namespace micronaut::chen_vector_plan {
// Independent, CPU-only reference for the built-in v2 policy set.
std::vector<float> reference(const vector_plan::ResolvedPlan& plan, const float* source,
                             std::size_t values);
}
