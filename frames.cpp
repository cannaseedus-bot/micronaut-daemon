#include "frames.h"

namespace micronaut {

void FrameScheduler::set_draw(std::function<void()> draw) {
    std::lock_guard<std::mutex> lock(mu_);
    draw_ = std::move(draw);
}

void FrameScheduler::start(int fps) {
    if (running_) return;
    running_ = true;
    int delay = std::max(1, 1000 / std::max(1, fps));

    thread_ = std::thread([this, delay]() {
        while (running_) {
            {
                std::lock_guard<std::mutex> lock(mu_);
                if (draw_) draw_();
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(delay));
        }
    });
}

void FrameScheduler::stop() {
    running_ = false;
    if (thread_.joinable()) thread_.join();
}

FrameScheduler& frames() {
    static FrameScheduler f;
    return f;
}

} // namespace micronaut

