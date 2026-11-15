#include "tensor_contract.h"
#include "phase_gate.h"
#include <algorithm>
#include <cmath>
#include <limits>
#include <stdexcept>

namespace micronaut::tensor_contract {
namespace {
void require(bool condition,const char* message) {
    if(!condition)throw std::runtime_error(message);
}
Shape reduced_shape(const Shape& shape,std::optional<std::size_t> axis) {
    if(!axis)return {};
    Shape result=shape;
    result.erase(result.begin()+*axis);
    return result;
}
std::size_t output_index(std::size_t flat,const Shape& input,std::size_t axis) {
    std::size_t out=0,stride=1;
    for(std::size_t reverse=0;reverse<input.size();++reverse) {
        const auto i=input.size()-1-reverse;
        const auto coordinate=flat%input[i];flat/=input[i];
        if(i!=axis){out+=coordinate*stride;stride*=input[i];}
    }
    return out;
}
}
std::size_t elements(const Shape& shape) {
    std::size_t count=1;
    for(const auto dim:shape) {
        require(dim>0 && count<=std::numeric_limits<std::size_t>::max()/dim,
                "tensor shape has zero dimension or overflows");
        count*=dim;
    }
    return count;
}
Resolved resolve(const Contract& c) {
    require(!c.input_shapes.empty(),"operator requires an input shape");
    for(const auto& shape:c.input_shapes)(void)elements(shape);
    (void)elements(c.output_shape);
    Resolved plan;plan.contract=c;
    const auto& input=c.input_shapes.front();
    switch(c.op) {
    case Operator::Map:
        require(c.input_shapes.size()==1 && c.output_shape==input && !c.axis &&
                c.accumulator==AccumulatorStrategy::None && std::isfinite(c.map_factor),
                "MAP must preserve shape and has no accumulator");
        break;
    case Operator::Filter:
        require(c.input_shapes.size()==1 && !input.empty() && !c.axis &&
                c.accumulator==AccumulatorStrategy::None &&
                c.output_shape.size()==input.size() &&
                c.output_shape[0]<=input[0] &&
                std::equal(input.begin()+1,input.end(),c.output_shape.begin()+1),
                "FILTER may select only along axis 0");
        break;
    case Operator::Fold:
        require(c.input_shapes.size()>=2 && !c.axis && c.output_shape==input &&
                std::all_of(c.input_shapes.begin(),c.input_shapes.end(),
                            [&](const Shape& shape){return shape==input;}),
                "FOLD inputs and output must have identical shapes");
        require(c.accumulator==AccumulatorStrategy::FullRank ||
                c.accumulator==AccumulatorStrategy::OutputRank ||
                (c.accumulator==AccumulatorStrategy::Scalar && input.empty()),
                "FOLD accumulator strategy incompatible with shape");
        break;
    case Operator::Reduce:
        require(c.input_shapes.size()==1 && (!c.axis || *c.axis<input.size()) &&
                c.output_shape==reduced_shape(input,c.axis),
                "REDUCE axis does not produce declared output shape");
        require(c.accumulator==AccumulatorStrategy::FullRank ||
                c.accumulator==AccumulatorStrategy::OutputRank ||
                (c.accumulator==AccumulatorStrategy::Scalar && c.output_shape.empty()),
                "REDUCE accumulator strategy incompatible with output rank");
        break;
    case Operator::Stack:
        require(c.input_shapes.size()>=2 && !c.axis &&
                std::all_of(c.input_shapes.begin(),c.input_shapes.end(),
                            [&](const Shape& shape){return shape==input;}) &&
                c.accumulator==AccumulatorStrategy::None,
                "STACK needs equal input shapes and no accumulator");
        {Shape expected=input;expected.insert(expected.begin(),c.input_shapes.size());
         require(c.output_shape==expected,"STACK output shape mismatch");}
        break;
    }
    if(c.accumulator==AccumulatorStrategy::FullRank)plan.accumulator_shape=input;
    else if(c.accumulator==AccumulatorStrategy::OutputRank)plan.accumulator_shape=c.output_shape;
    else if(c.accumulator==AccumulatorStrategy::Scalar)plan.accumulator_shape={};
    plan.accumulator_elements=c.accumulator==AccumulatorStrategy::None ? 0 : elements(plan.accumulator_shape);
    return plan;
}
Candidate execute(const Resolved& plan,const std::vector<Tensor>& inputs,
                  bool host_authorized,const std::vector<bool>& filter_mask) {
    require(host_authorized,"tensor execution requires host admission");
    const auto validated=resolve(plan.contract);
    require(validated.accumulator_shape==plan.accumulator_shape &&
            validated.accumulator_elements==plan.accumulator_elements,
            "resolved accumulator contract changed");
    require(inputs.size()==plan.contract.input_shapes.size(),"tensor input count mismatch");
    for(std::size_t i=0;i<inputs.size();++i) {
        require(inputs[i].shape==plan.contract.input_shapes[i] &&
                inputs[i].values.size()==elements(inputs[i].shape),"tensor input shape mismatch");
        for(const float value:inputs[i].values)
            require(std::isfinite(value),"tensor input contains non-finite value");
    }
    attention::AttentionContext phase;
    require(attention::pop(phase) && attention::wo(phase) && attention::yax(phase) &&
            attention::phase_is(phase,attention::RuntimePhase::Sek),"tensor phase gate rejected Sek");
    const auto& c=plan.contract;
    Candidate candidate;candidate.output.shape=c.output_shape;
    const auto out_count=elements(c.output_shape);
    candidate.output.values.assign(out_count,0.0f);
    if(c.op==Operator::Map) {
        for(std::size_t i=0;i<out_count;++i)
            candidate.output.values[i]=inputs[0].values[i]*c.map_factor;
    } else if(c.op==Operator::Filter) {
        require(filter_mask.size()==inputs[0].shape[0],"FILTER mask length mismatch");
        const auto row_size=elements(Shape(inputs[0].shape.begin()+1,inputs[0].shape.end()));
        std::size_t selected=0;
        for(std::size_t row=0;row<filter_mask.size();++row)if(filter_mask[row]) {
            require(selected<c.output_shape[0],"FILTER selected more rows than declared");
            std::copy_n(inputs[0].values.begin()+row*row_size,row_size,
                        candidate.output.values.begin()+selected*row_size);
            ++selected;
        }
        require(selected==c.output_shape[0],"FILTER selected fewer rows than declared");
    } else if(c.op==Operator::Fold) {
        std::vector<double> accumulator(plan.accumulator_elements,0.0);
        for(const auto& input:inputs)
            for(std::size_t i=0;i<out_count;++i)accumulator[i]+=input.values[i];
        for(std::size_t i=0;i<out_count;++i)candidate.output.values[i]=float(accumulator[i]);
    } else if(c.op==Operator::Reduce) {
        std::vector<double> accumulator(plan.accumulator_elements,0.0);
        const auto& input=inputs[0];
        if(c.accumulator==AccumulatorStrategy::FullRank) {
            for(std::size_t i=0;i<input.values.size();++i)accumulator[i]=input.values[i];
            std::vector<double> reduced(out_count,0.0);
            for(std::size_t i=0;i<input.values.size();++i) {
                const auto target=c.axis?output_index(i,input.shape,*c.axis):0;
                reduced[target]+=accumulator[i];
            }
            for(std::size_t i=0;i<out_count;++i)candidate.output.values[i]=float(reduced[i]);
        } else {
            for(std::size_t i=0;i<input.values.size();++i) {
                const auto target=c.axis?output_index(i,input.shape,*c.axis):0;
                accumulator[target]+=input.values[i];
            }
            for(std::size_t i=0;i<out_count;++i)candidate.output.values[i]=float(accumulator[i]);
        }
    } else if(c.op==Operator::Stack) {
        std::size_t offset=0;
        for(const auto& input:inputs) {
            std::copy(input.values.begin(),input.values.end(),candidate.output.values.begin()+offset);
            offset+=input.values.size();
        }
    }
    require(attention::sek(phase) && attention::phase_is(phase,attention::RuntimePhase::Chen),
            "tensor phase gate rejected Ch'en");
    require(candidate.output.shape==c.output_shape &&
            candidate.output.values.size()==elements(c.output_shape),
            "Ch'en output shape mismatch");
    for(const float value:candidate.output.values)
        require(std::isfinite(value),"Ch'en output contains non-finite value");
    candidate.verified=true;
    require(attention::chen(phase) && attention::xul(phase),"tensor phase gate rejected Xul");
    candidate.trace=std::move(phase.trace);
    return candidate;
}
}
