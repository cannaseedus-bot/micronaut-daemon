#include "../ccc4_learning.h"
#include <cmath>
#include <iostream>

int main() {
    using namespace micronaut::ccc4_learning;
    nlohmann::json document={
        {"schema","ccc4.neuron.dataset.v1"},{"topology_hash",kTopologyHash},
        {"contract_hash",kNeuronContractHash},
        {"supervision","external"},{"provenance","synthetic.unit_test"},
        {"samples",nlohmann::json::array()}
    };
    document["samples"].push_back({{"input",std::vector<float>(64,1.0f)},
                                     {"target",std::vector<float>(64,2.0f)}});
    auto dataset=parse_dataset(document);
    auto parameters=initial_parameters();AdamState optimizer;
    const auto gradient=compute_gradients(parameters,dataset);
    const float original=parameters.weights[0],epsilon=0.001f;
    parameters.weights[0]=original+epsilon;
    const double plus=loss(parameters,dataset);
    parameters.weights[0]=original-epsilon;
    const double minus=loss(parameters,dataset);
    parameters.weights[0]=original;
    if(std::abs(gradient[0]-(plus-minus)/(2.0*epsilon))>1e-5)return 3;
    const auto before=loss(parameters,dataset);
    const auto result=train(parameters,optimizer,dataset,100,0.03);
    const auto saved=checkpoint(parameters,optimizer,dataset,result);
    if(result.before!=before || result.after>=before*0.01 || optimizer.step!=100 ||
       saved["weights"].size()!=192 || saved["biases"].size()!=64 ||
       saved["optimizer"]["m"].size()!=256 || saved["persistent_state_committed"]!=false ||
       parse_parameters(saved).weights[0]!=parameters.weights[0])return 1;
    document["topology_hash"]="wrong";
    try {(void)parse_dataset(document);return 2;}catch(const std::exception&) {}
    std::cerr<<"CCC4 neuron learning: directed weights, biases, Adam and topology rejection passed\n";
}
