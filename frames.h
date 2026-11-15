#pragma once
#include "common.h"

namespace micronaut {

class FrameScheduler {
public:
    void start(int fps = 30);
    void stop();
    void set_draw(std::function<void()> draw);

private:
    std::atomic<bool> running_{false};
    std::thread thread_;
    std::function<void()> draw_;
    std::mutex mu_;
};

FrameScheduler& frames();

} // namespace micronaut
