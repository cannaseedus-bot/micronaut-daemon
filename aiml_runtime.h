#pragma once

#include <optional>
#include <string>

namespace micronaut {

bool aiml_runtime_load(const std::string& path, std::string* error = nullptr);
bool aiml_runtime_ensure_loaded(std::string* error = nullptr);
bool aiml_runtime_ready();
std::string aiml_runtime_path();
void aiml_runtime_reset_session(const std::string& session_id);
void aiml_runtime_record_response(const std::string& session_id,
    const std::string& prompt,const std::string& response);
std::optional<std::string> aiml_runtime_generate(
    const std::string& session_id,
    const std::string& prompt,
    std::string* error = nullptr
);

} // namespace micronaut
