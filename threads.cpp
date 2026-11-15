#include "threads.h"
#include "output.h"

namespace micronaut {

std::string ThreadRegistry::spawn(const std::string& id, std::function<MicronautResult()> fn) {
    std::lock_guard<std::mutex> lock(mu_);
    jobs_[id] = std::async(std::launch::async, [id, fn]() {
        output().event(id, "status", "{\"state\":\"running\"}");
        MicronautResult r = fn();
        output().event(id, "status", "{\"state\":\"done\"}");
        return r;
    });
    return id;
}

std::optional<MicronautResult> ThreadRegistry::poll(const std::string& id) {
    std::lock_guard<std::mutex> lock(mu_);
    auto it = jobs_.find(id);
    if (it == jobs_.end()) return std::nullopt;

    auto status = it->second.wait_for(std::chrono::milliseconds(0));
    if (status != std::future_status::ready) return std::nullopt;

    MicronautResult r = it->second.get();
    jobs_.erase(it);
    return r;
}

ThreadRegistry& thread_registry() {
    static ThreadRegistry reg;
    return reg;
}

} // namespace micronaut

