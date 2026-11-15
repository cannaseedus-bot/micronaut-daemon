#include "ccc4_learning.h"
#include <algorithm>
#include <cmath>
#include <limits>
#include <set>
#include <stdexcept>

namespace micronaut::ccc4_learning {
namespace {
using Edge=std::pair<unsigned,unsigned>;
const std::vector<Edge>& edges() {
    static const std::vector<Edge> result=[] {
        std::set<Edge> unique;
        auto add=[&](unsigned a,unsigned b){unique.insert({std::min(a,b),std::max(a,b)});};
        for(unsigned x=0;x<16;++x)for(unsigned y=0;y<4;++y) {
            const unsigned id=4*x+y;
            add(id,4*x+((y+1)&3));
            add(id,4*(x^(1u<<y))+y);
        }
        if(unique.size()!=kEdges)throw std::runtime_error("CCC4 edge generation mismatch");
        return std::vector<Edge>(unique.begin(),unique.end());
    }();
    return result;
}
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
template<std::size_t N> std::array<float,N> numeric_array(const nlohmann::json& value) {
    require(value.is_array() && value.size()==N,"dataset vector shape mismatch");
    std::array<float,N> out{};
    for(std::size_t i=0;i<N;++i) {
        require(value[i].is_number(),"dataset vector contains nonnumeric value");
        const double x=value[i].get<double>();
        require(std::isfinite(x) && std::abs(x)<=std::numeric_limits<float>::max(),
                "dataset vector contains nonfinite value");
        out[i]=float(x);
    }
    return out;
}
std::array<double,kNodes> preactivation(const Parameters& p,const std::array<float,kNodes>& input) {
    std::array<double,kNodes> z{};
    for(unsigned i=0;i<kNodes;++i)z[i]=p.biases[i];
    for(std::size_t id=0;id<edges().size();++id) {
        const auto [a,b]=edges()[id];
        z[b]+=double(p.weights[2*id])*input[a];
        z[a]+=double(p.weights[2*id+1])*input[b];
    }
    return z;
}
}
Dataset parse_dataset(const nlohmann::json& document) {
    require(document.is_object() && document.value("schema",std::string())=="ccc4.neuron.dataset.v1",
            "unknown training dataset schema");
    require(document.value("topology_hash",std::string())==kTopologyHash,
            "training dataset topology hash mismatch");
    require(document.value("contract_hash",std::string())==kNeuronContractHash,
            "training dataset neuron contract hash mismatch");
    require(document.value("supervision",std::string())=="external",
            "training dataset must declare external supervision");
    Dataset data;data.provenance=document.value("provenance",std::string());
    require(!data.provenance.empty(),"training provenance missing");
    require(document.contains("samples") && document.at("samples").is_array() &&
            !document.at("samples").empty(),"training samples missing");
    for(const auto& row:document.at("samples")) {
        require(row.is_object() && row.contains("input") && row.contains("target"),
                "training sample missing input or target");
        data.samples.push_back({numeric_array<kNodes>(row.at("input")),
                                numeric_array<kNodes>(row.at("target"))});
    }
    return data;
}
Parameters parse_parameters(const nlohmann::json& document) {
    require(document.is_object() && document.value("schema",std::string())=="ccc4.neuron.checkpoint.v1",
            "unknown neuron checkpoint schema");
    require(document.value("topology_hash",std::string())==kTopologyHash &&
            document.value("contract_hash",std::string())==kNeuronContractHash,
            "neuron checkpoint identity mismatch");
    require(document.value("weight_tying",std::string())=="none" &&
            document.value("dtype",std::string())=="f32" &&
            document.value("direction_convention",std::string())==
                "edge_id*2: min_to_max, edge_id*2+1: max_to_min",
            "neuron checkpoint parameter layout mismatch");
    Parameters p;
    p.weights=numeric_array<kDirectedWeights>(document.at("weights"));
    p.biases=numeric_array<kNodes>(document.at("biases"));
    return p;
}
std::array<float,kNodes> parse_input(const nlohmann::json& input) {
    return numeric_array<kNodes>(input);
}
Parameters initial_parameters() {
    Parameters p;
    p.weights.fill(0.001f);
    p.biases.fill(0.01f);
    return p;
}
std::array<float,kNodes> infer(const Parameters& p,const std::array<float,kNodes>& input) {
    const auto z=preactivation(p,input);
    std::array<float,kNodes> output{};
    for(unsigned i=0;i<kNodes;++i) {
        const double y=std::max(0.0,z[i]);
        require(std::isfinite(y) && y<=std::numeric_limits<float>::max(),
                "neuron inference overflow");
        output[i]=float(y);
    }
    return output;
}
double loss(const Parameters& p,const Dataset& data) {
    require(!data.samples.empty(),"empty training dataset");
    double total=0;
    for(const auto& sample:data.samples) {
        const auto y=infer(p,sample.input);
        for(unsigned i=0;i<kNodes;++i) {
            const double error=double(y[i])-sample.target[i];
            total+=error*error;
        }
    }
    return total/(double(data.samples.size())*kNodes);
}
TrainResult train(Parameters& p,AdamState& state,const Dataset& data,
                  unsigned epochs,double learning_rate) {
    require(!data.samples.empty() && epochs>0,"training requires samples and epochs");
    require(std::isfinite(learning_rate) && learning_rate>0 && learning_rate<=1,
            "invalid learning rate");
    TrainResult result;result.before=loss(p,data);result.epochs=epochs;
    constexpr double beta1=0.9,beta2=0.999,epsilon=1e-8;
    for(unsigned epoch=0;epoch<epochs;++epoch) {
        const auto grad=compute_gradients(p,data);
        ++state.step;
        const double correct1=1.0-std::pow(beta1,double(state.step));
        const double correct2=1.0-std::pow(beta2,double(state.step));
        for(unsigned i=0;i<grad.size();++i) {
            require(std::isfinite(grad[i]),"training gradient is nonfinite");
            state.m[i]=beta1*state.m[i]+(1-beta1)*grad[i];
            state.v[i]=beta2*state.v[i]+(1-beta2)*grad[i]*grad[i];
            const double update=learning_rate*(state.m[i]/correct1)/
                (std::sqrt(state.v[i]/correct2)+epsilon);
            const double old=i<kDirectedWeights ? p.weights[i] : p.biases[i-kDirectedWeights];
            const double next=old-update;
            require(std::isfinite(next) && std::abs(next)<=std::numeric_limits<float>::max(),
                    "training parameter overflow");
            if(i<kDirectedWeights)p.weights[i]=float(next);
            else p.biases[i-kDirectedWeights]=float(next);
        }
    }
    result.after=loss(p,data);
    return result;
}
nlohmann::json checkpoint(const Parameters& p,const AdamState& state,
                          const Dataset& data,const TrainResult& result) {
    return {
        {"schema","ccc4.neuron.checkpoint.v1"},
        {"topology_hash",kTopologyHash},
        {"contract_hash",kNeuronContractHash},
        {"direction_convention","edge_id*2: min_to_max, edge_id*2+1: max_to_min"},
        {"weight_tying","none"},
        {"dtype","f32"},
        {"weights",p.weights},
        {"biases",p.biases},
        {"optimizer",{{"kind","adam"},{"step",state.step},{"m",state.m},{"v",state.v}}},
        {"training",{{"provenance",data.provenance},{"samples",data.samples.size()},
                     {"epochs",result.epochs},{"loss_before",result.before},
                     {"loss_after",result.after}}},
        {"execution_authorized",false},
        {"persistent_state_committed",false}
    };
}
}
