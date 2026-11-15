#include "../training_phase.h"
#include <cmath>
#include <stdexcept>

static void check(bool value){if(!value)throw std::runtime_error("WCR training phase test failed");}
int main(){
    using namespace micronaut::training_phase;
    auto neutral=score_field({{"neutral"}});
    check(neutral.field.size()==1&&neutral.field[0].base_score==0.125&&
          !neutral.dominant&&neutral.gate==0.5&&!neutral.executed);
    auto cpu=score_field({{"coder",0.8,0.85,0.9},{"other",0.7,0.8,0.8}});
    check(cpu.dominant=="coder"&&std::abs(cpu.field[0].base_score-0.612)<1e-12&&
          !cpu.xcfe_admitted);
    auto tied=score_field({{"zeta",1,1,1},{"alpha",1,1,1}});
    check(tied.dominant=="alpha"&&tied.field[0].name=="alpha");
    Physics p;p.gravity_gate=1.1;p.entropy=0.2;p.attention=0.5;p.pressure=0.3;
    auto gpu=score_field({{"coder",0.8,0.85,0.9}},p);
    check(std::abs(gpu.gate-0.38)<1e-12&&
          std::abs(gpu.field[0].effective_score-(0.8*1.03/1.1*0.85*0.9))<1e-12&&
          gpu.dominant=="coder"&&!gpu.executed);
    bool rejected=false;
    try{(void)score_field({{"bad",1.1,0.5,0.5}});}catch(const std::runtime_error&){rejected=true;}
    check(rejected);
}
