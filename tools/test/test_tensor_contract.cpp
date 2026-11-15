#include "../tensor_contract.h"
#include <cassert>
#include <stdexcept>

using namespace micronaut::tensor_contract;

template<class F> void rejects(F&& f) {
    bool rejected=false;
    try { f(); } catch(const std::runtime_error&) { rejected=true; }
    assert(rejected);
}

int main() {
    Tensor cube{{2,3,4},{}};
    for(int i=1;i<=24;++i)cube.values.push_back(float(i));
    for(auto strategy:{AccumulatorStrategy::FullRank,AccumulatorStrategy::OutputRank}) {
        Contract c; c.op=Operator::Reduce; c.input_shapes={{2,3,4}};
        c.output_shape={2,3}; c.axis=2; c.accumulator=strategy;
        auto plan=resolve(c);
        assert(plan.accumulator_shape==(strategy==AccumulatorStrategy::FullRank ? Shape{2,3,4}:Shape{2,3}));
        auto result=execute(plan,{cube},true);
        assert(result.output.shape==Shape({2,3}));
        assert(result.output.values==std::vector<float>({10,26,42,58,74,90}));
        assert(result.verified && !result.committed);
        rejects([&]{ execute(plan,{cube},false); });
    }
    Contract bad; bad.op=Operator::Reduce; bad.input_shapes={{2,3,4}};
    bad.output_shape={2,4}; bad.axis=2; bad.accumulator=AccumulatorStrategy::OutputRank;
    rejects([&]{ resolve(bad); });

    Contract all; all.op=Operator::Reduce; all.input_shapes={{2,3,4}};
    all.output_shape={}; all.accumulator=AccumulatorStrategy::Scalar;
    assert(execute(resolve(all),{cube},true).output.values==std::vector<float>({300}));

    Contract fold; fold.op=Operator::Fold; fold.input_shapes={{},{}};
    fold.output_shape={}; fold.accumulator=AccumulatorStrategy::Scalar;
    assert(execute(resolve(fold),{{{}, {2}},{{}, {3}}},true).output.values==std::vector<float>({5}));

    Contract stack; stack.op=Operator::Stack; stack.input_shapes={{2,2},{2,2}};
    stack.output_shape={2,2,2};
    auto stacked=execute(resolve(stack),{{{2,2},{1,2,3,4}},{{2,2},{5,6,7,8}}},true);
    assert(stacked.output.values==std::vector<float>({1,2,3,4,5,6,7,8}));

    Contract filter; filter.op=Operator::Filter; filter.input_shapes={{3,2}};
    filter.output_shape={2,2};
    assert(execute(resolve(filter),{{{3,2},{1,2,3,4,5,6}}},true,{true,false,true}).output.values==
           std::vector<float>({1,2,5,6}));
    rejects([&]{ execute(resolve(filter),{{{3,2},{1,2,3,4,5,6}}},true,{true,false,false}); });
}
