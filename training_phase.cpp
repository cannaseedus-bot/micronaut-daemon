#include "training_phase.h"
#include <algorithm>
#include <cmath>
#include <set>
#include <stdexcept>

namespace micronaut::training_phase {
namespace {
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
bool probability(double value){return std::isfinite(value)&&value>=0.0&&value<=1.0;}
}
Selection score_field(const std::vector<MuScore>& field,const std::optional<Physics>& physics) {
    Selection result;
    if(physics) {
        const auto& p=*physics;
        require(std::isfinite(p.gravity_gate)&&p.gravity_gate>=0.0&&
                std::isfinite(p.entropy)&&p.entropy>=0.0&&
                probability(p.attention)&&std::isfinite(p.pressure)&&p.pressure>=0.0,
                "invalid WCR physics scalar");
        result.gate=0.5*(1.0-p.attention*0.1)*(p.gravity_gate>1.0 ? 0.8 : 1.0);
    }
    std::set<std::string> names;
    double best=-1.0;
    std::vector<MuScore> canonical=field;
    std::sort(canonical.begin(),canonical.end(),[](const MuScore& a,const MuScore& b){return a.name<b.name;});
    for(const auto& mu:canonical) {
        require(!mu.name.empty()&&names.insert(mu.name).second,"WCR candidate name missing or duplicate");
        require(probability(mu.W)&&probability(mu.C)&&probability(mu.R),"WCR component out of range");
        Entry entry;entry.name=mu.name;entry.base_score=mu.W*mu.C*mu.R;
        const double effective_W=physics ? mu.W*(1.0+physics->pressure*0.1)/
                                        (1.0+physics->entropy*0.5) : mu.W;
        entry.effective_score=effective_W*mu.C*mu.R;
        require(std::isfinite(entry.effective_score),"WCR effective score overflow");
        entry.passes_gate=entry.effective_score>=result.gate;
        if(entry.passes_gate&&entry.effective_score>best) {
            best=entry.effective_score;result.dominant=entry.name;
        }
        result.field.push_back(entry);
    }
    return result;
}
}
