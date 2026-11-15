#include "canvas.h"

namespace micronaut {

void Canvas::set_enabled(bool enabled) {
    std::lock_guard<std::mutex> lock(mu_);
    enabled_ = enabled;
}

bool Canvas::enabled() const {
    std::lock_guard<std::mutex> lock(mu_);
    return enabled_;
}

void Canvas::render_status(const std::string& status) {
    std::lock_guard<std::mutex> lock(mu_);
    if (!enabled_) return;
    std::cerr << "\r[Micronaut] " << status << "                    " << std::flush;
}

void Canvas::render_token(const std::string& token) {
    std::lock_guard<std::mutex> lock(mu_);
    if (!enabled_) return;
    std::cerr << token << " " << std::flush;
}

Canvas& canvas() {
    static Canvas c;
    return c;
}

} // namespace micronaut

