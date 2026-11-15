#pragma once
#include "common.h"

namespace micronaut {

Scxq2Frame scxq2_encode(const MicronautOp& op);
MicronautResult scxq2_execute(const MicronautOp& op);

} // namespace micronaut
