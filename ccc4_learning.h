#pragma once
#include <array>
#include <cstdint>
#include <string>
#include <vector>
#include <nlohmann/json.hpp>

namespace micronaut::ccc4_learning {
constexpr unsigned kNodes=64, kEdges=96, kDirectedWeights=192;
constexpr const char* kTopologyHash="af51f5244ce5ea7fdb352d9fae31ddf511aaca86f442515e81471df5726b1116";
constexpr const char* kNeuronContractHash="37a08263cb88a89cde6408964ce59ec4ea4c463ee35ddce07fabd21658f78dc3";
struct Sample {
    std::array<float,kNodes> input{}, target{};
};
struct Dataset {
    std::string provenance;
    std::vector<Sample> samples;
};
struct Parameters {
    std::array<float,kDirectedWeights> weights{};
    std::array<float,kNodes> biases{};
};
struct AdamState {
    std::array<double,kDirectedWeights+kNodes> m{}, v{};
    std::uint64_t step=0;
};
struct TrainResult { double before=0, after=0; unsigned epochs=0; };
using Gradients=std::array<double,kDirectedWeights+kNodes>;
Gradients compute_gradients(const Parameters& parameters, const Dataset& dataset);
Dataset parse_dataset(const nlohmann::json& document);
Parameters parse_parameters(const nlohmann::json& checkpoint);
std::array<float,kNodes> parse_input(const nlohmann::json& input);
Parameters initial_parameters();
std::array<float,kNodes> infer(const Parameters& parameters,
                               const std::array<float,kNodes>& input);
double loss(const Parameters& parameters, const Dataset& dataset);
TrainResult train(Parameters& parameters, AdamState& optimizer,
                  const Dataset& dataset, unsigned epochs, double learning_rate);
nlohmann::json checkpoint(const Parameters& parameters, const AdamState& optimizer,
                          const Dataset& dataset, const TrainResult& result);
}
