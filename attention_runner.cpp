#include "attention_registry.h"
#include <iostream>

using namespace micronaut::attention;

int main() {
    AttentionContext ctx;
    ctx.tensors["Q"] = {"Q", {2, 3}, {1,2,3, 4,5,6}};
    ctx.tensors["K"] = {"K", {3, 2}, {1,0, 0,1, 1,1}};
    ctx.tensors["V"] = {"V", {2, 2}, {1,10, 2,20}};
    for (const std::string op : {"⨀", "◉", "⟐", "✦"}) {
        auto result = execute_attention_glyph(ctx, op);
        std::cout << result.opcode << " ok=" << result.ok << " output=" << result.output << " message=" << result.message << "\n";
    }
    std::cout << "trace:\n";
    for (auto& t : ctx.trace) std::cout << "  " << t << "\n";
    return 0;
}

