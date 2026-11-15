#pragma once
#include "attention_types.h"

namespace micronaut::attention {

inline Tensor matmul_2d(const Tensor& a, const Tensor& b, const std::string& name) {
    if (a.shape.size() != 2 || b.shape.size() != 2) throw std::runtime_error("matmul_2d expects rank-2 tensors");
    const int64_t m = a.shape[0], k = a.shape[1], k2 = b.shape[0], n = b.shape[1];
    if (k != k2) throw std::runtime_error("matmul dimension mismatch");
    Tensor out{name, {m, n}, std::vector<float>(m*n, 0.0f)};
    for (int64_t i=0;i<m;i++) for (int64_t j=0;j<n;j++) {
        float sum = 0.0f;
        for (int64_t p=0;p<k;p++) sum += a.data[i*k+p] * b.data[p*n+j];
        out.data[i*n+j] = sum;
    }
    return out;
}

inline Tensor transpose_2d(const Tensor& t, const std::string& name) {
    if (t.shape.size() != 2) throw std::runtime_error("transpose_2d expects rank-2 tensor");
    const int64_t r=t.shape[0], c=t.shape[1];
    Tensor out{name, {c,r}, std::vector<float>(r*c)};
    for(int64_t i=0;i<r;i++) for(int64_t j=0;j<c;j++) out.data[j*r+i]=t.data[i*c+j];
    return out;
}

inline Tensor row_softmax(const Tensor& x, const std::string& name) {
    if (x.shape.size() != 2) throw std::runtime_error("row_softmax expects rank-2 tensor");
    Tensor out = make_like(x, name);
    const int64_t rows=x.shape[0], cols=x.shape[1];
    for(int64_t r=0;r<rows;r++) {
        float mx = x.data[r*cols];
        for(int64_t c=1;c<cols;c++) mx = std::max(mx, x.data[r*cols+c]);
        float den = 0.0f;
        for(int64_t c=0;c<cols;c++) { out.data[r*cols+c] = std::exp(x.data[r*cols+c]-mx); den += out.data[r*cols+c]; }
        const float inv = den == 0.0f ? 0.0f : 1.0f / den;
        for(int64_t c=0;c<cols;c++) out.data[r*cols+c] *= inv;
    }
    return out;
}

inline Tensor scaled_dot_product_attention(const Tensor& q, const Tensor& k, const Tensor& v, float scale, const std::string& name) {
    Tensor kt = transpose_2d(k, "K_T");
    Tensor scores = matmul_2d(q, kt, "scores");
    for (float& value : scores.data) value *= scale;
    Tensor probs = row_softmax(scores, "probs");
    return matmul_2d(probs, v, name);
}

inline void stamp(AttentionContext& ctx, const std::string& s) { ctx.trace.push_back(s); }

} // namespace micronaut::attention
