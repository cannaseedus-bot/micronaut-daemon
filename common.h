#pragma once
#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <cstdlib>
#include <deque>
#include <exception>
#include <functional>
#include <future>
#include <iostream>
#include <map>
#include <mutex>
#include <optional>
#include <queue>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

namespace micronaut {

using Clock = std::chrono::steady_clock;

struct Json {
    std::string raw;
    std::map<std::string, std::string> flat;

    bool has(const std::string& key) const { return flat.find(key) != flat.end(); }
    std::string get(const std::string& key, const std::string& fallback = "") const {
        auto it = flat.find(key);
        return it == flat.end() ? fallback : it->second;
    }
};

// Minimal JSON helper for runtime protocol.
// Handles normal JSONL request shapes used by micronaut.exe.
// This is intentionally small; replace with nlohmann/json later if desired.
Json parse_json_loose(const std::string& line);
std::string json_escape(const std::string& s);
std::string now_ms_string();

struct MicronautOp {
    std::string id;
    std::string kind;
    std::string op;
    Json payload;
    std::string raw;
    std::string ingress; // set by host input path, never copied from payload
};

struct MicronautResult {
    bool ok = false;
    std::string id;
    std::string op;
    std::string result_json = "{}";
    std::string error_code;
    std::string error_message;
    long long duration_ms = 0;
};

struct Scxq2Frame {
    std::map<std::string, std::string> dict; // metadata: op/id/kind/route
    std::map<std::string, std::string> field; // payload fields
    std::vector<std::pair<std::string, std::string>> edge; // route edges
    std::vector<std::string> lane; // execution schedule
};

using Handler = std::function<MicronautResult(const MicronautOp&)>;

} // namespace micronaut
