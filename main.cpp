#include "input.h"
#include "output.h"
#include "scxq2_runtime.h"
#include "xcfe_router.h"
#include "http_server.h"
#include "aiml_runtime.h"
#include <iostream>
#include <cstdio>
#ifdef _WIN32
#include <io.h>
#else
#include <unistd.h>
#endif

namespace {
bool stdin_is_interactive() {
#ifdef _WIN32
    return _isatty(_fileno(stdin)) != 0;
#else
    return isatty(fileno(stdin)) != 0;
#endif
}

void print_usage() {
    std::cout << "ELIZA Micronaut daemon\n"
              << "  eliza-µ.exe --http [port]  Start the loopback HTTP API (default 9879)\n"
              << "  eliza-µ.exe --aiml-corpus PATH  Load AIML JSONL (or GGUF) corpus\n"
              << "  eliza-µ.exe --chat TEXT    Run one chat request\n"
              << "  eliza-µ.exe                Read JSONL requests from piped stdin\n"
              << "  vector.candidate           Local stdin route; host must set MICRONAUT_VECTOR_CANDIDATE=1\n"
              << "  vector.plan.v2.candidate   Fixed v2 plan; host must set MICRONAUT_VECTOR_PLAN_V2_DAEMON=1\n"
              << "  gemma.bridge.propose       Attested retrieval proposal; local stdin, bridge gate, and host attestation key\n";
}
}

int main(int argc, char** argv) {
    using namespace micronaut;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--help" || arg == "-h") { print_usage(); return 0; }
        if (arg == "--pretty") output().set_mode(OutputMode::Pretty);
        if ((arg == "--aiml-corpus" || arg == "--aiml-jsonl" || arg == "--aiml-gguf") && i + 1 < argc) {
            std::string error;
            if (!aiml_runtime_load(argv[++i], &error)) {
                std::cerr << "Failed to load AIML corpus: " << error << '\n';
                return 2;
            }
            continue;
        }
        if (arg == "--http") {
            unsigned short port = 9879;
            if (i + 1 < argc) {
                try { port = static_cast<unsigned short>(std::stoul(argv[++i])); } catch (...) { return 2; }
            }
            return run_http_server(port);
        }
        if (arg == "--chat" && i + 1 < argc) {
            std::string prompt = argv[++i];
            MicronautOp op;
            op.kind = "micronaut.request.v1";
            op.id = "cli-" + now_ms_string();
            op.op = "chat.generate";
            op.payload.raw = prompt;
            op.payload.flat["prompt"] = prompt;
            register_builtin_handlers();
            output().result(scxq2_execute(op));
            return 0;
        }
    }

    if (argc == 1 && stdin_is_interactive()) { print_usage(); return 0; }
    return run_stdin_loop();
}

