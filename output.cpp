#include "output.h"

namespace micronaut {

Output::Output(OutputMode mode) : mode_(mode) {}

void Output::set_mode(OutputMode mode) {
    std::lock_guard<std::mutex> lock(mu_);
    mode_ = mode;
}

void Output::event(const std::string& id, const std::string& type, const std::string& data_json) {
    std::lock_guard<std::mutex> lock(mu_);
    if (mode_ == OutputMode::Jsonl) {
        std::cout
            << "{\"@kind\":\"micronaut.event.v1\","
            << "\"id\":\"" << json_escape(id) << "\","
            << "\"type\":\"" << json_escape(type) << "\","
            << "\"ts\":\"" << now_ms_string() << "\","
            << "\"data\":" << data_json
            << "}" << std::endl;
    } else {
        std::cout << "[event:" << type << "] " << data_json << std::endl;
    }
}

void Output::result(const MicronautResult& r) {
    std::lock_guard<std::mutex> lock(mu_);
    if (mode_ == OutputMode::Jsonl) {
        if (r.ok) {
            std::cout
                << "{\"@kind\":\"micronaut.result.v1\","
                << "\"ok\":true,"
                << "\"id\":\"" << json_escape(r.id) << "\","
                << "\"op\":\"" << json_escape(r.op) << "\","
                << "\"duration_ms\":" << r.duration_ms << ","
                << "\"result\":" << r.result_json
                << "}" << std::endl;
        } else {
            std::cout
                << "{\"@kind\":\"micronaut.result.v1\","
                << "\"ok\":false,"
                << "\"id\":\"" << json_escape(r.id) << "\","
                << "\"op\":\"" << json_escape(r.op) << "\","
                << "\"duration_ms\":" << r.duration_ms << ","
                << "\"error\":{\"code\":\"" << json_escape(r.error_code) << "\","
                << "\"message\":\"" << json_escape(r.error_message) << "\"}"
                << "}" << std::endl;
        }
    } else {
        if (r.ok) {
            std::cout << "[ok] " << r.id << " " << r.op << " " << r.result_json << std::endl;
        } else {
            std::cout << "[error] " << r.id << " " << r.error_code << ": " << r.error_message << std::endl;
        }
    }
}

void Output::log(const std::string& level, const std::string& message) {
    std::lock_guard<std::mutex> lock(mu_);
    if (mode_ == OutputMode::Jsonl) {
        std::cerr << "{\"@kind\":\"micronaut.log.v1\",\"level\":\""
                  << json_escape(level) << "\",\"message\":\""
                  << json_escape(message) << "\",\"ts\":\"" << now_ms_string() << "\"}"
                  << std::endl;
    } else {
        std::cerr << "[" << level << "] " << message << std::endl;
    }
}

Output& output() {
    static Output instance;
    return instance;
}

} // namespace micronaut

