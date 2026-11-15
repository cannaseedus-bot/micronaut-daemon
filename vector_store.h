#pragma once
#include <string>
#include <vector>
namespace micronaut::vector_store {
struct Matrix { unsigned rows=0, dim=0; std::vector<float> values; };
struct Header { unsigned rows=0, dim=0; std::size_t payload_offset=0; };
struct DomainStore {
    std::string store_id;
    std::string source_sha256;
    std::string model_snapshot;
    Matrix vectors;
};
Header inspect_npy(const std::string& path);
Matrix load_npy(const std::string& path);
DomainStore load_domain_store(const std::string& manifest_path);
}
