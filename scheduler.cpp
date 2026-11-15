#include "scheduler.h"

namespace micronaut {

void Scheduler::push(const ScheduledJob& job) {
    std::lock_guard<std::mutex> lock(mu_);
    jobs_.push_back(job);
}

std::vector<ScheduledJob> Scheduler::drain_ordered() {
    std::lock_guard<std::mutex> lock(mu_);
    std::sort(jobs_.begin(), jobs_.end(), [](const ScheduledJob& a, const ScheduledJob& b) {
        if (a.tick != b.tick) return a.tick < b.tick;
        return a.order < b.order;
    });
    auto out = jobs_;
    jobs_.clear();
    return out;
}

Scheduler& scheduler() {
    static Scheduler s;
    return s;
}

} // namespace micronaut

