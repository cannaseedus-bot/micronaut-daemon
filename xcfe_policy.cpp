#include "xcfe_policy.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <limits>
#include <regex>
#include <stdexcept>
#include <vector>

namespace micronaut::xcfe_policy {
namespace {
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
bool state_valid(const std::string& s){
    return s=="unbound"||s=="observed"||s=="learned"||
           s=="bound"||s=="validated"||s=="autonomous";
}
double number(const nlohmann::json& o,const char* key){
    require(o.contains(key)&&o.at(key).is_number(),"policy numeric field missing");
    const double v=o.at(key).get<double>();
    require(std::isfinite(v),"policy numeric field must be finite");
    return v;
}
unsigned count(const nlohmann::json& o,const char* key){
    require(o.contains(key)&&o.at(key).is_number_integer(),"policy count must be integer");
    const auto value=o.at(key).get<std::int64_t>();
    require(value>=0&&value<=std::numeric_limits<unsigned>::max(),"policy count out of range");
    return static_cast<unsigned>(value);
}
void exact_keys(const nlohmann::json& o,std::initializer_list<const char*> keys){
    require(o.is_object(),"policy section must be object");
    require(o.size()==keys.size(),"policy section has missing or unsupported fields");
    for(const char* key:keys)require(o.contains(key),"policy section missing field");
}
}
Decision evaluate(const nlohmann::json& p,const Evidence& e,
                  const std::string& previous_state,const std::string& event){
    require(p.is_object(),"XCFE policy must be object");
    exact_keys(p,{"@ref","@evidence","@weights","@thresholds","@routes"});
    require(p.at("@ref").is_string(),"policy ref must be string");
    const std::regex ref(R"(^xcfe://[A-Za-z0-9._:-]+/[A-Za-z0-9._:-]+(@[A-Za-z0-9._:+-]+)?$)");
    require(std::regex_match(p.at("@ref").get<std::string>(),ref),"invalid XCFE policy ref");
    require(state_valid(previous_state),"invalid prior Fold Kernel state");
    require(event=="authorize"||event=="uncertainty"||event=="contract_failed",
            "unsupported XCFE event");
    require(e.observations==std::uint64_t(e.support)+e.exceptions,
            "evidence observation count mismatch");
    require(e.validated>=e.failures,"evidence validated count below failures");
    const auto& spec=p.at("@evidence");
    exact_keys(spec,{"@inputs"}); // custom derive expressions are not yet evaluated
    require(spec.at("@inputs").is_array()&&spec.at("@inputs").size()==5,
            "default confidence requires five evidence inputs");
    std::vector<std::string> inputs;
    for(const auto& item:spec.at("@inputs")) {
        require(item.is_string(),"evidence input must be string");
        inputs.push_back(item.get<std::string>());
    }
    std::sort(inputs.begin(),inputs.end());
    require(inputs==std::vector<std::string>({"exceptions","failures","observations","support","validated"}),
            "default confidence requires exact evidence input set");
    const auto& w=p.at("@weights");
    exact_keys(w,{"@alpha","@beta","@gamma","@delta","@epsilon"});
    const double a=number(w,"@alpha"),b=number(w,"@beta"),g=number(w,"@gamma"),
                 d=number(w,"@delta"),eps=number(w,"@epsilon");
    require(a>=0&&b>=0&&g>=0&&d>=0&&eps>0,"invalid XCFE weights");
    require(std::abs((a+b+g+d)-1.0)<=1e-9,"XCFE weights must sum to one");
    const auto& t=p.at("@thresholds");
    exact_keys(t,{"@autonomy","@fallback","@failure_limit","@hysteresis"});
    const double autonomy=number(t,"@autonomy"),fallback=number(t,"@fallback"),
                 hysteresis=number(t,"@hysteresis");
    const unsigned failure_limit=count(t,"@failure_limit");
    require(autonomy>=0&&autonomy<=1&&fallback>=0&&fallback<=autonomy&&
            hysteresis>=0&&hysteresis<=autonomy-fallback,"invalid XCFE threshold ordering");
    const auto& routes=p.at("@routes");
    exact_keys(routes,{"@autonomous","@validated","@default"});
    for(const char* key:{"@autonomous","@validated","@default"}) {
        require(routes.at(key).is_string(),"XCFE route must be string");
        const auto target=routes.at(key).get<std::string>();
        require(target=="local"||target=="local-test"||target=="fallback",
                "unknown XCFE route target");
    }
    const double raw=a*e.support/(e.observations+eps)+
                     b*e.validated/(double(e.validated)+e.failures+eps)-
                     g*e.exceptions/(e.observations+eps)-
                     d*e.failures/(e.validated+eps);
    Decision result;result.confidence=std::clamp(raw,0.0,1.0);
    result.state=previous_state;
    result.route=routes.at("@default").get<std::string>();
    if(event=="contract_failed")result.state="learned";
    else if(previous_state=="validated") {
        if(result.confidence>=autonomy&&e.failures<=failure_limit) {
            result.state="autonomous";result.route=routes.at("@autonomous").get<std::string>();
        } else if(result.confidence>=fallback) {
            result.route=routes.at("@validated").get<std::string>();
        }
    } else if(previous_state=="autonomous") {
        if(result.confidence<fallback||e.failures>failure_limit)result.state="bound";
        else result.route=routes.at("@autonomous").get<std::string>();
    }
    return result;
}
}
