#pragma once
#include "common.h"

namespace micronaut {

enum class OutputMode {
    Jsonl,
    Pretty
};

class Output {
public:
    explicit Output(OutputMode mode = OutputMode::Jsonl);
    void event(const std::string& id, const std::string& type, const std::string& data_json);
    void result(const MicronautResult& r);
    void log(const std::string& level, const std::string& message);
    void set_mode(OutputMode mode);

private:
    std::mutex mu_;
    OutputMode mode_;
};

Output& output();

} // namespace micronaut
