#include "chat.h"
#include "output.h"
#include "aiml_runtime.h"
#include "gemma_bridge_route.h"
#include <nlohmann/json.hpp>

namespace micronaut {

struct ChatMessage {
    std::string role;
    std::string content;
};

static std::mutex chat_mu;
static std::map<std::string, std::vector<ChatMessage>> sessions;

MicronautResult chat_execute(const MicronautOp& op) {
    auto start = Clock::now();
    MicronautResult r;
    r.id = op.id;
    r.op = op.op;

    if (op.op == "chat.create") {
        std::string session = op.payload.get("sessionId", op.id);
        std::lock_guard<std::mutex> lock(chat_mu);
        sessions[session] = {};
        aiml_runtime_reset_session(session);
        r.ok = true;
        r.result_json = "{\"sessionId\":\"" + json_escape(session) + "\"}";
    } else if (op.op == "chat.history") {
        std::string session = op.payload.get("sessionId", "default");
        std::lock_guard<std::mutex> lock(chat_mu);
        std::ostringstream arr;
        arr << "[";
        bool first = true;
        for (const auto& m : sessions[session]) {
            if (!first) arr << ",";
            first = false;
            arr << "{\"role\":\"" << json_escape(m.role) << "\",\"content\":\"" << json_escape(m.content) << "\"}";
        }
        arr << "]";
        r.ok = true;
        r.result_json = "{\"sessionId\":\"" + json_escape(session) + "\",\"messages\":" + arr.str() + "}";
    } else if (op.op == "chat.generate") {
        std::string session = op.payload.get("sessionId", "default");
        std::string prompt = op.payload.get("prompt", op.payload.get("content", ""));
        bool stream = op.payload.get("stream", "false") == "true";

        if (prompt.empty()) {
            r.ok = false;
            r.error_code = "CHAT_PROMPT_EMPTY";
            r.error_message = "A non-empty prompt is required.";
            r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now() - start).count();
            return r;
        }

        nlohmann::json bridge_selection;
        if (!op.raw.empty()) {
            try {
                auto request=nlohmann::json::parse(op.raw);
                if (request.is_object()&&request.contains("bridge"))
                    bridge_selection=gemma_bridge_route::evaluate(op,prompt);
            } catch (const std::exception& error) {
                r.ok=false;r.error_code="GEMMA_BRIDGE_REJECTED";r.error_message=error.what();
                return r;
            }
        }
        std::optional<std::string> selected_text;
        if (!bridge_selection.is_null()&&
            (bridge_selection.value("selection",std::string{})=="verified_plain_template"||
             bridge_selection.value("selection",std::string{})=="verified_vector_response"))
            selected_text=bridge_selection.at("text").get<std::string>();

        std::string runtime_error;
        if (!aiml_runtime_ensure_loaded(&runtime_error)) {
            r.ok = false;
            r.error_code = "AIML_CORPUS_UNAVAILABLE";
            r.error_message = runtime_error;
            r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now() - start).count();
            return r;
        }
        const auto generated = selected_text ? selected_text : aiml_runtime_generate(session, prompt, &runtime_error);
        if (!generated) {
            r.ok = false;
            r.error_code = "AIML_GENERATION_FAILED";
            r.error_message = runtime_error;
            r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now() - start).count();
            return r;
        }
        const std::string& text = *generated;
        if (selected_text) aiml_runtime_record_response(session,prompt,text);

        {
            std::lock_guard<std::mutex> lock(chat_mu);
            sessions[session].push_back({"user", prompt});
        }

        if (stream) {
            std::istringstream words(text);
            std::string token;
            int idx = 0;
            while (words >> token) {
                output().event(op.id, "token", "{\"token\":\"" + json_escape(token) +
                                               "\",\"index\":" + std::to_string(idx++) + "}");
                std::this_thread::sleep_for(std::chrono::milliseconds(8));
            }
        }

        {
            std::lock_guard<std::mutex> lock(chat_mu);
            sessions[session].push_back({"assistant", text});
        }

        r.ok = true;
        r.result_json = "{\"text\":\"" + json_escape(text) + "\",\"tokens\":" +
                        std::to_string(static_cast<int>(std::count(text.begin(), text.end(), ' ') + 1)) +
                        ",\"sessionId\":\"" + json_escape(session) + "\""+
                        (bridge_selection.is_null()?"":",\"bridge\":"+bridge_selection.dump())+"}";
    } else {
        r.ok = false;
        r.error_code = "CHAT_OP_UNKNOWN";
        r.error_message = "Unknown chat operation: " + op.op;
    }

    auto end = Clock::now();
    r.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    return r;
}

} // namespace micronaut

