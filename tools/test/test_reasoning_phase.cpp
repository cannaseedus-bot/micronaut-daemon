#include "../reasoning_phase.h"
#include <stdexcept>

static void check(bool value) { if(!value)throw std::runtime_error("reasoning phase test failed"); }

int main() {
    using namespace micronaut;
    using namespace micronaut::reasoning_phase;
    Proposal p;p.operator_name="DEFINE";p.entity_a="CCC4";
    auto candidate=prepare(p);
    check(candidate.valid&&!candidate.admitted&&!candidate.executed&&candidate.phases.size()==6);
    p.visited.insert("DEFINE");check(!prepare(p).valid);p.visited.clear();
    p.depth=8;check(!prepare(p).valid);p.depth=0;
    p.operator_name="CAUSE";check(!prepare(p).valid);
    p.entity_b="phase";check(prepare(p).valid);
    MicronautOp op;op.op="reason.propose";op.ingress="stdin";
    op.payload.flat={{"operator","CAUSE"},{"entity_a","CCC4"},{"entity_b","phase"}};
    auto result=propose_execute(op);
    check(result.ok&&result.result_json.find("\"admitted\":false")!=std::string::npos);
    op.payload.flat["depth"]="0";check(!propose_execute(op).ok);
    op.payload.flat.erase("depth");op.ingress="http";check(!propose_execute(op).ok);
}
