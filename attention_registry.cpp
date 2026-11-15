#include "attention_ops.h"
#include <unordered_map>

namespace micronaut::attention {

const std::vector<Binding>& attention_registry() {
    static const std::vector<Binding> table = {
        {"⨀","WO_MATMUL","attention/matmul.cpp",Fold::TENSOR,900,907,&matmul,"attention_matmul"},
        {"◉","WO_SCALE","attention/scale.cpp",Fold::TENSOR,908,915,&scale,"attention_scale"},
        {"⟐","WO_SOFTMAX","attention/softmax.cpp",Fold::TENSOR,916,923,&softmax,"attention_softmax"},
        {"◈","WO_MASK","attention/mask.cpp",Fold::TENSOR,924,931,&mask,"attention_additive_mask"},
        {"◬","WO_QKV_SPLIT","attention/qkv_split.cpp",Fold::TENSOR,932,939,&qkv_split,"attention_qkv_split"},
        {"⌬","WO_ROTARY","attention/rotary.cpp",Fold::TENSOR,940,947,&rotary,"attention_rotary"},
        {"✦","WO_FLASH_ATTN","attention/flash_attn.cpp",Fold::KERNEL,948,955,&flash_attn},
        {"✧","WO_PAGED_ATTN","attention/paged_attn.cpp",Fold::KERNEL,956,963,&paged_attn},
        {"◉","WO_RING_ATTN","attention/ring_attn.cpp",Fold::KERNEL,964,971,&ring_attn},
        {"◯","WO_LOCAL_ATTN","attention/local_attn.cpp",Fold::KERNEL,972,979,&local_attn},
        {"◈","WO_KV_CACHE","attention/kv_cache.cpp",Fold::MEMORY,980,987,&kv_cache},
        {"◍","WO_SINK_ATTN","attention/sink_attn.cpp",Fold::KERNEL,988,995,&sink_attn},
        {"◐","WO_SLIDING","attention/sliding.cpp",Fold::KERNEL,996,1003,&sliding},
        {"◑","WO_SPARSE_ATTN","attention/sparse_attn.cpp",Fold::KERNEL,1004,1011,&sparse_attn},
        {"◒","WO_LINEAR_ATTN","attention/linear_attn.cpp",Fold::KERNEL,1012,1019,&linear_attn},
        {"◓","WO_CROSS_ATTN","attention/cross_attn.cpp",Fold::KERNEL,1020,1027,&cross_attn},
        {"◔","WO_GQA","attention/gqa.cpp",Fold::TENSOR,1028,1035,&gqa},
        {"◕","WO_MQA","attention/mqa.cpp",Fold::TENSOR,1036,1043,&mqa},
        {"◖","WO_MLA","attention/mla.cpp",Fold::TENSOR,1044,1051,&mla},
        {"◗","WO_HEAD_ROUTE","attention/head_routing.cpp",Fold::CONTROL,1052,1059,&head_routing},
        {"⊙","SEK_PI_RADIUS","pi_radius.cpp",Fold::KERNEL,1060,1067,&pi_radius},
        {"⊗","SEK_FOLD_ACCUMULATE","accumulator.cpp",Fold::TENSOR,1068,1075,&accumulator},
    };
    return table;
}

const Binding* find_attention_binding(const std::string& glyph_or_opcode) {
    for (const auto& b : attention_registry()) {
        if (b.glyph == glyph_or_opcode || b.opcode == glyph_or_opcode) return &b;
    }
    return nullptr;
}

OpResult execute_attention_glyph(AttentionContext& ctx, const std::string& glyph_or_opcode) {
    const Binding* b = find_attention_binding(glyph_or_opcode);
    if (!b) return {false,"UNKNOWN",glyph_or_opcode,"","unknown attention glyph/opcode"};
    return b->execute(ctx);
}

} // namespace micronaut::attention

