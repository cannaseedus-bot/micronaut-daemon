#pragma once
#include <string>

namespace micronaut::query_attestation {
std::string sha256_hex(const std::string& bytes);
std::string hmac_sha256_hex(const std::string& key,const std::string& bytes);
bool equal_digest(const std::string& left,const std::string& right);
}
