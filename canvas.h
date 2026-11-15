#pragma once
#include "common.h"

namespace micronaut {

class Canvas {
public:
    void set_enabled(bool enabled);
    bool enabled() const;
    void render_status(const std::string& status);
    void render_token(const std::string& token);

private:
    bool enabled_ = false;
    mutable std::mutex mu_;
};

Canvas& canvas();

} // namespace micronaut
