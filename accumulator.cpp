#include "attention_ops.h"
#include "phase_gate.h"
#include "phase.hpp"

#include <cmath>
#include <stdexcept>

namespace micronaut::attention {

// Weighted tensor-fold accumulator. The first contribution may omit the
// accumulator tensor; subsequent calls add into the previous fold result.
// This is a Sek/Reduce operation and only emits a candidate tensor result.
OpResult accumulator(AttentionContext& ctx) {
    constexpr const char* opcode = "SEK_FOLD_ACCUMULATE";
    constexpr const char* glyph = "⊗";

    if (!phase_is(ctx, RuntimePhase::Sek) ||
        !kuhul::phase::operatorAuthorized(kuhul::phase::Name::Sek,
                                          kuhul::phase::Operator::Reduce)) {
        return {false, opcode, glyph, "", "phase gate: accumulator is executable only during Sek"};
    }

    try {
        const Tensor& contribution = ctx.tensor("contribution");
        contribution.require_size();
        for (float value : contribution.data)
            if (!std::isfinite(value))
                throw std::runtime_error("contribution must contain only finite float32 values");

        const float weight = ctx.scalar("weight", 1.0f);
        if (!std::isfinite(weight))
            throw std::runtime_error("weight must be finite");

        Tensor result{"accumulator", contribution.shape,
                      std::vector<float>(contribution.data.size(), 0.0f)};
        const auto existing = ctx.tensors.find("accumulator");
        const bool had_accumulator = existing != ctx.tensors.end();
        if (had_accumulator) {
            const Tensor& prior = existing->second;
            prior.require_size();
            if (prior.shape != contribution.shape)
                throw std::runtime_error("accumulator and contribution shapes must match");
            for (float value : prior.data)
                if (!std::isfinite(value))
                    throw std::runtime_error("accumulator must contain only finite float32 values");
            result.data = prior.data;
        }

        for (size_t i = 0; i < contribution.data.size(); ++i) {
            result.data[i] += weight * contribution.data[i];
            if (!std::isfinite(result.data[i]))
                throw std::runtime_error("weighted accumulation produced a non-finite value");
        }

        ctx.tensors[result.name] = result;
        ctx.trace.push_back("fold:SEK_FOLD_ACCUMULATE:weighted_tensor_sum");
        return {true, opcode, glyph, result.name,
                had_accumulator ? "weighted contribution accumulated"
                                : "initialized weighted fold accumulator"};
    } catch (const std::exception& error) {
        return {false, opcode, glyph, "", error.what()};
    }
}

} // namespace micronaut::attention
