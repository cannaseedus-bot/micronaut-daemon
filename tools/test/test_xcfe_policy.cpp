#include "../xcfe_policy.h"
#include <iostream>
#include <stdexcept>

static void check(bool value){if(!value)throw std::runtime_error("XCFE policy test failed");}
int main(){
try {
    using namespace micronaut::xcfe_policy;
    nlohmann::json p={
        {"@ref","xcfe://autonomy/default@1.0.0"},
        {"@evidence",{{"@inputs",{"observations","support","exceptions","validated","failures"}}}},
        {"@weights",{{"@alpha",0.5},{"@beta",0.5},{"@gamma",0.0},{"@delta",0.0},{"@epsilon",0.001}}},
        {"@thresholds",{{"@autonomy",0.8},{"@fallback",0.4},{"@failure_limit",0},{"@hysteresis",0.1}}},
        {"@routes",{{"@autonomous","local"},{"@validated","local-test"},{"@default","fallback"}}}
    };
    Evidence good{10,10,0,10,0};
    auto promoted=evaluate(p,good,"validated","authorize");
    check(promoted.state=="autonomous"&&promoted.route=="local"&&!promoted.execution_authorized);
    auto failed=evaluate(p,good,"autonomous","contract_failed");
    check(failed.state=="learned"&&failed.route=="fallback");
    auto stayed=evaluate(p,good,"autonomous","uncertainty");
    check(stayed.state=="autonomous"&&stayed.route=="local");
    Evidence bad{10,0,10,10,1};
    auto fallback=evaluate(p,bad,"autonomous","uncertainty");
    check(fallback.state=="bound"&&fallback.route=="fallback");
    p["@guard"]=nlohmann::json::array();
    bool rejected=false;try{(void)evaluate(p,good,"validated","authorize");}
    catch(const std::runtime_error&){rejected=true;}
    check(rejected);
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}
}
