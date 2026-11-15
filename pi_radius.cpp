#include "attention_ops.h"
#include "phase_gate.h"
#include "phase.hpp"
#include <cmath>

namespace micronaut::attention {

// Compact-support cosine radial kernel:
// K(d,r) = 0.5 * (1 + cos(pi*d/r)) for 0 <= d <= r, otherwise 0.
// Input positions is [points, dimensions]; output is [points, points].
OpResult pi_radius(AttentionContext& ctx) {
    if (!phase_is(ctx, RuntimePhase::Sek) ||
        !kuhul::phase::operatorAuthorized(kuhul::phase::Name::Sek, kuhul::phase::Operator::Map))
        return {false, "SEK_PI_RADIUS", "⊙", "", "phase gate: PI_RADIUS is executable only during Sek"};
    try {
        const Tensor& positions = ctx.tensor("positions");
        positions.require_size();
        if (positions.shape.size() != 2 || positions.shape[0] < 1 || positions.shape[1] < 1)
            throw std::runtime_error("positions must have shape [points, dimensions]");
        const float radius = ctx.scalar("radius", 0.0f);
        if (!std::isfinite(radius) || radius <= 0.0f)
            throw std::runtime_error("radius must be finite and greater than zero");

        const int64_t count = positions.shape[0], dimensions = positions.shape[1];
        for (float coordinate : positions.data)
            if (!std::isfinite(coordinate)) throw std::runtime_error("positions must contain only finite float32 values");
        Tensor weights{"pi_radius_weights", {count, count}, std::vector<float>(static_cast<size_t>(count * count), 0.0f)};
        constexpr double pi = 3.141592653589793238462643383279502884;
        for (int64_t i = 0; i < count; ++i) {
            for (int64_t j = 0; j < count; ++j) {
                double squared_distance = 0.0;
                for (int64_t d = 0; d < dimensions; ++d) {
                    const double delta = static_cast<double>(positions.data[i * dimensions + d]) -
                                         static_cast<double>(positions.data[j * dimensions + d]);
                    squared_distance += delta * delta;
                }
                const double distance = std::sqrt(squared_distance);
                if (distance <= radius) {
                    const double ratio = distance / radius;
                    weights.data[i * count + j] = static_cast<float>(0.5 * (1.0 + std::cos(pi * ratio)));
                }
            }
        }
        ctx.tensors[weights.name] = weights;
        ctx.trace.push_back("kernel:SEK_PI_RADIUS:compact_cosine");
        return {true, "SEK_PI_RADIUS", "⊙", weights.name, "compact-support cosine radial weights computed"};
    } catch (const std::exception& error) {
        return {false, "SEK_PI_RADIUS", "⊙", "", error.what()};
    }
}

} // namespace micronaut::attention

