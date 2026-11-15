#include "reasoning_phase.h"
#include <algorithm>
#include <cctype>
#include <stdexcept>

namespace micronaut::reasoning_phase {
namespace {
unsigned arity(const std::string& name) {
    if(name=="DEFINE"||name=="MECHANISM"||name=="COUNTERFACTUAL"||
       name=="EVIDENCE"||name=="SYNTHESIZE")return 1;
    if(name=="DEPENDENCY"||name=="CONTRAST"||name=="CAUSE"||name=="ANALOGY")return 2;
    return 0;
}
bool safe_entity(const std::string& value) {
    return !value.empty() && value.size()<=512 &&
        std::all_of(value.begin(),value.end(),[](unsigned char ch){
            return ch>=32 && ch!=127;
        });
}
}
Candidate prepare(const Proposal& p) {
    Candidate c;c.phases.push_back("Pop:reasoning_proposal");
    const unsigned expected=arity(p.operator_name);
    if(!expected){c.error="unknown reasoning operator";return c;}
    if(p.max_depth==0||p.max_depth>32||p.depth>=p.max_depth){c.error="recursion limit";return c;}
    if(p.visited.count(p.operator_name)){c.error="reasoning operator cycle";return c;}
    if(!safe_entity(p.entity_a)||(expected==2&&!safe_entity(p.entity_b))||
       (expected==1&&!p.entity_b.empty())){c.error="reasoning operator arity or capture invalid";return c;}
    c.phases.push_back("Wo:operator_arity_and_guard_validated");
    c.phases.push_back("Yax:envelope_candidate");
    c.valid=true;
    c.phases.push_back("Sek:XCFE_admission_required");
    c.phases.push_back("Chen:no_execution_claim");
    c.phases.push_back("Xul:candidate_only");
    return c;
}
MicronautResult propose_execute(const MicronautOp& op) {
    MicronautResult r;r.id=op.id;r.op=op.op;
    if(op.op!="reason.propose"||op.ingress!="stdin") {
        r.error_code="XCFE_ADMISSION_DENIED";r.error_message="reasoning proposals require local stdin ingress";return r;
    }
    for(const auto& [key,value]:op.payload.flat)
        if(key!="op"&&key!="id"&&key!="@kind"&&key!="operator"&&key!="entity_a"&&key!="entity_b") {
            r.error_code="REASONING_PROPOSAL_INVALID";r.error_message="unsupported reasoning field";return r;
        }
    Proposal p;p.operator_name=op.payload.get("operator");
    p.entity_a=op.payload.get("entity_a");p.entity_b=op.payload.get("entity_b");
    auto c=prepare(p);
    if(!c.valid){r.error_code="REASONING_PROPOSAL_INVALID";r.error_message=c.error;return r;}
    r.ok=true;
    r.result_json="{\"schema\":\"kuhul.srai.reasoning.v1\",\"status\":\"PROPOSED\",\"operator\":\""+
        json_escape(p.operator_name)+"\",\"entity_a\":\""+json_escape(p.entity_a)+
        "\",\"entity_b\":\""+json_escape(p.entity_b)+
        "\",\"admitted\":false,\"executed\":false}";
    return r;
}
}
