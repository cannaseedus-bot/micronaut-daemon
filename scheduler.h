#pragma once
#include "common.h"

namespace micronaut {

struct ScheduledJob {
    int tick = 0;
    int order = 0;
    MicronautOp op;
};

class Scheduler {
public:
    void push(const ScheduledJob& job);
    std::vector<ScheduledJob> drain_ordered();

private:
    std::mutex mu_;
    std::vector<ScheduledJob> jobs_;
};

Scheduler& scheduler();

} // namespace micronaut
