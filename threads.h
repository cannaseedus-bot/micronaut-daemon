#pragma once
#include "common.h"

namespace micronaut {

class ThreadRegistry {
public:
    std::string spawn(const std::string& id, std::function<MicronautResult()> fn);
    std::optional<MicronautResult> poll(const std::string& id);

private:
    std::mutex mu_;
    std::map<std::string, std::future<MicronautResult>> jobs_;
};

ThreadRegistry& thread_registry();

} // namespace micronaut
