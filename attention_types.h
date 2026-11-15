#pragma once
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>
#include "phase.hpp"

namespace micronaut::attention {

enum class Fold { TENSOR, KERNEL, MEMORY, CONTROL };
using RuntimePhase = kuhul::phase::Name;

struct Tensor {
    std::string name;
    std::vector<int64_t> shape;
    std::vector<float> data;

    int64_t size() const {
        int64_t n = 1;
        for (auto d : shape) n *= d;
        return n;
    }

    void require_size() const {
        if (size() != static_cast<int64_t>(data.size())) {
            throw std::runtime_error("tensor size mismatch: " + name);
        }
    }
};

struct AttentionContext {
    std::unordered_map<std::string, Tensor> tensors;
    std::unordered_map<std::string, float> scalars;
    std::unordered_map<std::string, int64_t> ints;
    std::vector<std::string> trace;
    RuntimePhase phase = RuntimePhase::Pop;

    Tensor& tensor(const std::string& key) {
        auto it = tensors.find(key);
        if (it == tensors.end()) throw std::runtime_error("missing tensor: " + key);
        return it->second;
    }
    const Tensor& tensor(const std::string& key) const {
        auto it = tensors.find(key);
        if (it == tensors.end()) throw std::runtime_error("missing tensor: " + key);
        return it->second;
    }
    float scalar(const std::string& key, float fallback) const {
        auto it = scalars.find(key);
        return it == scalars.end() ? fallback : it->second;
    }
    int64_t integer(const std::string& key, int64_t fallback) const {
        auto it = ints.find(key);
        return it == ints.end() ? fallback : it->second;
    }
};

inline const char* phase_name(RuntimePhase phase) {
    switch (phase) {
        case RuntimePhase::Pop: return "Pop";
        case RuntimePhase::Wo: return "Wo";
        case RuntimePhase::Yax: return "Yax";
        case RuntimePhase::Sek: return "Sek";
        case RuntimePhase::Chen: return "Ch'en";
        case RuntimePhase::Xul: return "Xul";
    }
    return "Unknown";
}

struct OpResult {
    bool ok = true;
    std::string opcode;
    std::string glyph;
    std::string output;
    std::string message;
};

using OpFn = OpResult(*)(AttentionContext&);

struct Binding {
    std::string glyph;
    std::string opcode;
    std::string cpp_file;
    Fold fold;
    int node_first;
    int node_last;
    OpFn execute;
    // Tested OpenCL primitive available for a future admitted host dispatch.
    // The registered execute function remains the CPU implementation.
    const char* opencl_primitive = nullptr;
};

inline const char* fold_name(Fold fold) {
    switch (fold) {
        case Fold::TENSOR: return "TENSOR";
        case Fold::KERNEL: return "KERNEL";
        case Fold::MEMORY: return "MEMORY";
        case Fold::CONTROL: return "CONTROL";
    }
    return "UNKNOWN";
}

inline Tensor make_like(const Tensor& t, std::string name) {
    Tensor out;
    out.name = std::move(name);
    out.shape = t.shape;
    out.data.assign(t.data.size(), 0.0f);
    return out;
}

} // namespace micronaut::attention
