#include "common.h"

namespace micronaut {

Json parse_json_loose(const std::string& line) {
    Json j;
    j.raw = line;

    // Captures shallow string fields: "key":"value"
    std::regex kv_string(R"json("([^"]+)"\s*:\s*"([^"]*)")json");
    for (std::sregex_iterator it(line.begin(), line.end(), kv_string), end; it != end; ++it) {
        j.flat[(*it)[1].str()] = (*it)[2].str();
    }

    // Captures shallow bool fields: "key":true|false
    std::regex kv_bool(R"json("([^"]+)"\s*:\s*(true|false))json");
    for (std::sregex_iterator it(line.begin(), line.end(), kv_bool), end; it != end; ++it) {
        j.flat[(*it)[1].str()] = (*it)[2].str();
    }

    // Captures shallow numeric fields: "key":123
    std::regex kv_num(R"json("([^"]+)"\s*:\s*(-?[0-9]+(?:\.[0-9]+)?))json");
    for (std::sregex_iterator it(line.begin(), line.end(), kv_num), end; it != end; ++it) {
        j.flat[(*it)[1].str()] = (*it)[2].str();
    }

    return j;
}

std::string json_escape(const std::string& s) {
    std::ostringstream out;
    for (char c : s) {
        switch (c) {
            case '"': out << "\\\""; break;
            case '\\': out << "\\\\"; break;
            case '\b': out << "\\b"; break;
            case '\f': out << "\\f"; break;
            case '\n': out << "\\n"; break;
            case '\r': out << "\\r"; break;
            case '\t': out << "\\t"; break;
            default:
                if (static_cast<unsigned char>(c) < 0x20) {
                    out << "\\u" << std::hex << static_cast<int>(c);
                } else {
                    out << c;
                }
        }
    }
    return out.str();
}

std::string now_ms_string() {
    auto now = std::chrono::system_clock::now().time_since_epoch();
    auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(now).count();
    return std::to_string(ms);
}

} // namespace micronaut

