#include "process.h"
#include "output.h"

#ifdef _WIN32
#define POPEN _popen
#define PCLOSE _pclose
#else
#define POPEN popen
#define PCLOSE pclose
#endif

namespace micronaut {

static std::string op_to_command(const MicronautOp& op) {
    if (op.op == "dxsk.run") return op.payload.get("cmd", "dxsk.exe");
    if (op.op == "scx.run") return op.payload.get("cmd", "scx_runtime.exe");
    if (op.op == "node.run") return op.payload.get("cmd", "node");
    if (op.op == "dotnet.run") return op.payload.get("cmd", "dotnet");
    if (op.op == "java.run") return op.payload.get("cmd", "java");
    if (op.op == "gpt2.gguf") return op.payload.get("cmd", "micronaut_gpt2.exe");
    return op.payload.get("cmd", "");
}

MicronautResult process_execute(const MicronautOp& op) {
    auto start = Clock::now();
    MicronautResult r;
    r.id = op.id;
    r.op = op.op;

    std::string cmd = op_to_command(op);
    if (cmd.empty()) {
        r.ok = false;
        r.error_code = "PROCESS_COMMAND_MISSING";
        r.error_message = "No command provided for process operation.";
        return r;
    }

    output().event(op.id, "status", "{\"state\":\"process.start\",\"cmd\":\"" + json_escape(cmd) + "\"}");

    FILE* pipe = POPEN(cmd.c_str(), "r");
    if (!pipe) {
        r.ok = false;
        r.error_code = "PROCESS_SPAWN_FAILED";
        r.error_message = "Failed to launch command: " + cmd;
        return r;
    }

    char buffer[4096];
    std::ostringstream stdout_text;
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        stdout_text << buffer;
    }

    int code = PCLOSE(pipe);
    auto end = Clock::now();
    r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

    r.ok = (code == 0);
    if (r.ok) {
        r.result_json = "{\"exit_code\":" + std::to_string(code) +
                        ",\"stdout\":\"" + json_escape(stdout_text.str()) + "\"}";
    } else {
        r.error_code = "PROCESS_EXIT_NONZERO";
        r.error_message = "Process exited with code " + std::to_string(code);
        r.result_json = "{\"exit_code\":" + std::to_string(code) +
                        ",\"stdout\":\"" + json_escape(stdout_text.str()) + "\"}";
    }
    return r;
}

} // namespace micronaut

