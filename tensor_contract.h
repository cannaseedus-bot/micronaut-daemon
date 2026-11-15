#pragma once
#include <cstddef>
#include <optional>
#include <string>
#include <vector>

namespace micronaut::tensor_contract {
using Shape=std::vector<std::size_t>;
enum class Operator { Map, Filter, Fold, Reduce, Stack };
enum class AccumulatorStrategy { None, FullRank, OutputRank, Scalar };
struct Contract {
    Operator op=Operator::Map;
    std::vector<Shape> input_shapes;
    Shape output_shape;
    AccumulatorStrategy accumulator=AccumulatorStrategy::None;
    std::optional<std::size_t> axis;
    float map_factor=1.0f;
};
struct Tensor {
    Shape shape;
    std::vector<float> values;
};
struct Resolved {
    Contract contract;
    Shape accumulator_shape;
    std::size_t accumulator_elements=0;
};
struct Candidate {
    Tensor output;
    bool verified=false;
    bool committed=false;
    std::vector<std::string> trace;
};
std::size_t elements(const Shape& shape);
Resolved resolve(const Contract& contract);
Candidate execute(const Resolved& plan,const std::vector<Tensor>& inputs,
                  bool host_authorized,const std::vector<bool>& filter_mask={});
}
