#pragma once
#include "common.h"

namespace micronaut {

MicronautOp parse_request_line(const std::string& line);
int run_stdin_loop();

} // namespace micronaut
