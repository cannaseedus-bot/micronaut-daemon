#pragma once
#include "common.h"

namespace micronaut {

class XcfeRouter {
public:
    void register_handler(const std::string& op_prefix, Handler handler);
    MicronautResult route(const MicronautOp& op) const;
    std::string route_name(const std::string& op) const;

private:
    std::map<std::string, Handler> handlers_;
};

XcfeRouter& xcfe_router();
void register_builtin_handlers();

} // namespace micronaut
