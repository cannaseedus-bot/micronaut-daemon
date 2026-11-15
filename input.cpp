#include "input.h"
#include "output.h"
#include "scxq2_runtime.h"
#include "xcfe_router.h"

namespace micronaut {

MicronautOp parse_request_line(const std::string& line) {
    Json j = parse_json_loose(line);

    MicronautOp op;
    op.raw = line;
    op.kind = j.get("@kind", "micronaut.request.v1");
    op.id = j.get("id", "req-" + now_ms_string());
    op.op = j.get("op", "");
    op.payload = j;

    if (op.op.empty()) {
        // shorthand CLI fallback:
        // --chat hello world
        if (line.rfind("--chat ", 0) == 0) {
            op.op = "chat.generate";
            op.payload.flat["prompt"] = line.substr(7);
        }
    }

    return op;
}

int run_stdin_loop() {
    register_builtin_handlers();

    std::string line;
    while (std::getline(std::cin, line)) {
        if (line.empty()) continue;

        MicronautOp op = parse_request_line(line);
        op.ingress = "stdin";
        if (op.op.empty()) {
            MicronautResult r;
            r.ok = false;
            r.id = op.id;
            r.op = "";
            r.error_code = "INPUT_OP_MISSING";
            r.error_message = "Request missing op field.";
            output().result(r);
            continue;
        }

        MicronautResult r = scxq2_execute(op);
        output().result(r);
    }

    return 0;
}

} // namespace micronaut

