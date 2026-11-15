#include "ccc4_learning.h"
#include <algorithm>
#include <cmath>
#include <set>
#include <stdexcept>

namespace micronaut::ccc4_learning {
Gradients compute_gradients(const Parameters& p,const Dataset& data) {
    if(data.samples.empty())throw std::runtime_error("training requires samples");
    static const std::vector<std::pair<unsigned,unsigned>> edges=[] {
        std::set<std::pair<unsigned,unsigned>> unique;
        for(unsigned x=0;x<16;++x)for(unsigned y=0;y<4;++y) {
            unsigned a=4*x+y;
            auto add=[&](unsigned b){unique.insert({std::min(a,b),std::max(a,b)});};
            add(4*x+((y+1)&3));
            add(4*(x^(1u<<y))+y);
        }
        if(unique.size()!=kEdges)throw std::runtime_error("CCC4 gradient edge count mismatch");
        return std::vector<std::pair<unsigned,unsigned>>(unique.begin(),unique.end());
    }();
    Gradients grad{};
    const double factor=2.0/(double(data.samples.size())*kNodes);
    for(const auto& sample:data.samples) {
        std::array<double,kNodes> z{},delta{};
        for(unsigned i=0;i<kNodes;++i)z[i]=p.biases[i];
        for(unsigned id=0;id<kEdges;++id) {
            const auto [a,b]=edges[id];
            z[b]+=double(p.weights[2*id])*sample.input[a];
            z[a]+=double(p.weights[2*id+1])*sample.input[b];
        }
        for(unsigned i=0;i<kNodes;++i) {
            const double y=std::max(0.0,z[i]);
            delta[i]=z[i]>0 ? factor*(y-sample.target[i]) : 0.0;
            grad[kDirectedWeights+i]+=delta[i];
        }
        for(unsigned id=0;id<kEdges;++id) {
            const auto [a,b]=edges[id];
            grad[2*id]+=delta[b]*sample.input[a];
            grad[2*id+1]+=delta[a]*sample.input[b];
        }
    }
    for(double v:grad)if(!std::isfinite(v))throw std::runtime_error("training gradient is nonfinite");
    return grad;
}
}
