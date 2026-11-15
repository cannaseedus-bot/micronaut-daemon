#include "aiml_runtime.h"

#include <nlohmann/json.hpp>

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <unordered_map>
#include <utility>
#include <vector>

namespace micronaut {
namespace {
using Json = nlohmann::json;
constexpr const char* kSchema = "micronaut.aiml.corpus.v2";
constexpr const char* kTensor = "aiml.corpus_json";
constexpr const char* kJsonlManifest = "micronaut.aiml.manifest.v1";
constexpr const char* kJsonlSource = "micronaut.aiml.source.v1";
constexpr const char* kJsonlCategory = "micronaut.aiml.category.v1";
constexpr std::uint64_t kMaxCorpusBytes = 512ull * 1024ull * 1024ull;

class GGUFInput {
public:
    explicit GGUFInput(const std::string& path) : in(path, std::ios::binary) {
        if (!in) throw std::runtime_error("cannot open GGUF file: " + path);
        in.seekg(0, std::ios::end);
        const auto end = in.tellg();
        if (end < 0) throw std::runtime_error("cannot determine GGUF file size");
        file_size = static_cast<std::uint64_t>(end);
        in.seekg(0, std::ios::beg);
    }

    template<class T> T little() {
        unsigned char bytes[sizeof(T)]{};
        exact(reinterpret_cast<char*>(bytes), sizeof(bytes));
        T value{};
        auto* dst = reinterpret_cast<unsigned char*>(&value);
        if (host_little_endian()) std::copy(bytes, bytes + sizeof(T), dst);
        else std::reverse_copy(bytes, bytes + sizeof(T), dst);
        return value;
    }

    std::string string() {
        const auto length = little<std::uint64_t>();
        if (length > kMaxCorpusBytes || length > remaining()) throw std::runtime_error("invalid GGUF string length");
        std::string value(static_cast<std::size_t>(length), '\0');
        if (length) exact(value.data(), static_cast<std::size_t>(length));
        return value;
    }

    void skip(std::uint64_t length) {
        if (length > remaining()) throw std::runtime_error("truncated GGUF metadata");
        in.seekg(static_cast<std::streamoff>(length), std::ios::cur);
        if (!in) throw std::runtime_error("failed to seek in GGUF metadata");
    }

    void exact(char* dest, std::size_t length) {
        if (length > remaining()) throw std::runtime_error("truncated GGUF file");
        in.read(dest, static_cast<std::streamsize>(length));
        if (!in) throw std::runtime_error("failed to read GGUF file");
    }

    std::uint64_t tell() {
        const auto pos = in.tellg();
        if (pos < 0) throw std::runtime_error("failed to query GGUF offset");
        return static_cast<std::uint64_t>(pos);
    }

    std::uint64_t remaining() const {
        const auto pos = const_cast<std::ifstream&>(in).tellg();
        if (pos < 0 || static_cast<std::uint64_t>(pos) > file_size) return 0;
        return file_size - static_cast<std::uint64_t>(pos);
    }

    std::ifstream in;
    std::uint64_t file_size = 0;

private:
    static bool host_little_endian() {
        const std::uint16_t one = 1;
        return *reinterpret_cast<const unsigned char*>(&one) == 1;
    }
};

void skip_gguf_value(GGUFInput& in, std::uint32_t type);

void skip_gguf_value(GGUFInput& in, std::uint32_t type) {
    switch (type) {
        case 0: case 1: case 7: in.skip(1); return;
        case 2: case 3: in.skip(2); return;
        case 4: case 5: case 6: in.skip(4); return;
        case 8: (void) in.string(); return;
        case 9: {
            const auto element_type = in.little<std::uint32_t>();
            const auto count = in.little<std::uint64_t>();
            if (count > 100000000ull) throw std::runtime_error("GGUF metadata array exceeds safety limit");
            for (std::uint64_t i = 0; i < count; ++i) skip_gguf_value(in, element_type);
            return;
        }
        case 10: case 11: case 12: in.skip(8); return;
        default: throw std::runtime_error("unknown GGUF metadata value type");
    }
}

struct TensorDescriptor {
    std::string name;
    std::uint64_t bytes = 0;
    std::uint64_t offset = 0;
    std::uint32_t type = 0;
};

Json read_corpus_tensor(const std::string& path) {
    GGUFInput in(path);
    char magic[4]{};
    in.exact(magic, sizeof(magic));
    if (std::string(magic, sizeof(magic)) != "GGUF") throw std::runtime_error("invalid GGUF magic");
    const auto version = in.little<std::uint32_t>();
    if (version < 2 || version > 3) throw std::runtime_error("unsupported GGUF version");
    const auto tensor_count = in.little<std::uint64_t>();
    const auto metadata_count = in.little<std::uint64_t>();
    if (tensor_count == 0 || tensor_count > 100000 || metadata_count > 100000) {
        throw std::runtime_error("invalid GGUF tensor or metadata count");
    }

    std::string schema;
    std::uint32_t alignment = 32;
    for (std::uint64_t i = 0; i < metadata_count; ++i) {
        const auto key = in.string();
        const auto type = in.little<std::uint32_t>();
        if (key == "micronaut.aiml.schema" && type == 8) {
            schema = in.string();
        } else if (key == "general.alignment" && type == 4) {
            alignment = in.little<std::uint32_t>();
        } else {
            skip_gguf_value(in, type);
        }
    }
    if (schema != kSchema) throw std::runtime_error("GGUF is not a supported Micronaut AIML corpus (schema v2 required)");
    if (alignment == 0 || (alignment & (alignment - 1)) != 0 || alignment > 4096) {
        throw std::runtime_error("invalid GGUF alignment");
    }

    TensorDescriptor corpus;
    for (std::uint64_t i = 0; i < tensor_count; ++i) {
        const auto name = in.string();
        const auto dimensions = in.little<std::uint32_t>();
        if (dimensions == 0 || dimensions > 4) throw std::runtime_error("invalid GGUF tensor dimensions");
        std::uint64_t elements = 1;
        for (std::uint32_t d = 0; d < dimensions; ++d) {
            const auto size = in.little<std::uint64_t>();
            if (size == 0 || elements > kMaxCorpusBytes / size) throw std::runtime_error("invalid GGUF tensor shape");
            elements *= size;
        }
        const auto type = in.little<std::uint32_t>();
        const auto offset = in.little<std::uint64_t>();
        if (name == kTensor) {
            if (type != 24 || elements > kMaxCorpusBytes) throw std::runtime_error("corpus tensor must be an I8 byte tensor");
            corpus = {name, elements, offset, type};
        }
    }
    if (corpus.name.empty()) throw std::runtime_error("GGUF corpus tensor is missing");
    const auto header_end = in.tell();
    const auto data_start = ((header_end + alignment - 1) / alignment) * alignment;
    if (corpus.offset > in.file_size || data_start > in.file_size - corpus.offset ||
        corpus.bytes > in.file_size - data_start - corpus.offset) {
        throw std::runtime_error("corpus tensor points outside the GGUF file");
    }
    in.in.seekg(static_cast<std::streamoff>(data_start + corpus.offset), std::ios::beg);
    if (!in.in) throw std::runtime_error("cannot seek to GGUF corpus tensor");
    std::string json_text(static_cast<std::size_t>(corpus.bytes), '\0');
    in.exact(json_text.data(), json_text.size());
    auto corpus_json = Json::parse(json_text);
    if (!corpus_json.is_object() || corpus_json.value("schema", std::string{}) != kSchema ||
        !corpus_json.contains("categories") || !corpus_json["categories"].is_array() ||
        !corpus_json.contains("sources") || !corpus_json["sources"].is_array()) {
        throw std::runtime_error("corpus tensor JSON has invalid shape");
    }
    return corpus_json;
}

Json read_corpus_jsonl(const std::string& path) {
    std::ifstream input(path, std::ios::binary);
    if (!input) throw std::runtime_error("cannot open AIML JSONL corpus: " + path);
    std::string line;
    if (!std::getline(input, line) || line.size() > 64ull * 1024ull * 1024ull) {
        throw std::runtime_error("AIML JSONL corpus is empty or has an invalid manifest line");
    }
    const auto manifest = Json::parse(line);
    if (!manifest.is_object() || manifest.value("@kind", std::string{}) != kJsonlManifest ||
        manifest.value("schema", std::string{}) != kSchema) {
        throw std::runtime_error("AIML JSONL corpus manifest is missing or unsupported");
    }
    const auto source_count = manifest.value("source_count", std::size_t{});
    const auto category_count = manifest.value("category_count", std::size_t{});
    if (source_count > 10000 || category_count > 10000000) throw std::runtime_error("AIML JSONL corpus count exceeds safety limit");
    Json sources = Json::array();
    Json categories = Json::array();
    while (std::getline(input, line)) {
        if (line.empty()) continue;
        if (line.size() > 64ull * 1024ull * 1024ull) throw std::runtime_error("AIML JSONL record exceeds 64 MiB");
        const auto record = Json::parse(line);
        const auto kind = record.value("@kind", std::string{});
        if (kind == kJsonlSource) {
            if (record.value("index", std::numeric_limits<std::size_t>::max()) != sources.size() ||
                !record.contains("path") || !record["path"].is_string() ||
                !record.contains("text") || !record["text"].is_string()) {
                throw std::runtime_error("invalid or out-of-order AIML JSONL source record");
            }
            sources.push_back({{"path", record["path"]}, {"text", record["text"]}});
        } else if (kind == kJsonlCategory) {
            if (record.value("index", std::numeric_limits<std::size_t>::max()) != categories.size() ||
                !record.contains("record") || !record["record"].is_object()) {
                throw std::runtime_error("invalid or out-of-order AIML JSONL category record");
            }
            categories.push_back(record["record"]);
        } else {
            throw std::runtime_error("unexpected AIML JSONL record kind: " + kind);
        }
    }
    if (sources.size() != source_count || categories.size() != category_count) {
        throw std::runtime_error("AIML JSONL record counts do not match manifest");
    }
    return Json{{"schema", kSchema}, {"source_count", source_count},
                {"category_count", category_count}, {"sources", std::move(sources)},
                {"categories", std::move(categories)}};
}

Json read_corpus(const std::string& path) {
    const auto extension = std::filesystem::path(path).extension().string();
    if (extension == ".jsonl" || extension == ".JSONL") return read_corpus_jsonl(path);
    return read_corpus_tensor(path);
}

std::string upper_normalize(const std::string& text) {
    std::string out;
    bool space = true;
    for (unsigned char ch : text) {
        if (std::isalnum(ch) || ch >= 0x80 || ch == '\'' || ch == '_') {
            out.push_back(static_cast<char>(std::toupper(ch)));
            space = false;
        } else if (!space) {
            out.push_back(' ');
            space = true;
        }
    }
    while (!out.empty() && out.back() == ' ') out.pop_back();
    return out;
}

std::string preserve_case_normalize(const std::string& text) {
    std::string out;
    bool space = true;
    for (unsigned char ch : text) {
        if (std::isalnum(ch) || ch >= 0x80 || ch == '\'' || ch == '_') {
            out.push_back(static_cast<char>(ch));
            space = false;
        } else if (!space) {
            out.push_back(' ');
            space = true;
        }
    }
    while (!out.empty() && out.back() == ' ') out.pop_back();
    return out;
}

std::string normalize_pattern(const std::string& text) {
    std::string out;
    bool space = true;
    for (unsigned char ch : text) {
        if (std::isalnum(ch) || ch >= 0x80 || ch == '\'' || ch == '_' || ch == '*') {
            out.push_back(static_cast<char>(std::toupper(ch)));
            space = false;
        } else if (!space) {
            out.push_back(' ');
            space = true;
        }
    }
    while (!out.empty() && out.back() == ' ') out.pop_back();
    return out;
}

std::vector<std::string> words(const std::string& text) {
    std::istringstream stream(text);
    std::vector<std::string> result;
    std::string word;
    while (stream >> word) result.push_back(word);
    return result;
}

std::string join_words(const std::vector<std::string>& tokens, std::size_t start, std::size_t end) {
    std::string result;
    for (std::size_t i = start; i < end; ++i) {
        if (!result.empty()) result += ' ';
        result += tokens[i];
    }
    return result;
}

struct Match {
    bool matched = false;
    std::vector<std::string> captures;
    std::vector<std::string> that_captures;
    std::vector<std::string> topic_captures;
};

bool match_recursive(const std::vector<std::string>& pattern, const std::vector<std::string>& input,
                     const std::vector<std::string>& display_input,
                     std::size_t pi, std::size_t ii, std::vector<std::string>& captures) {
    if (pi == pattern.size()) return ii == input.size();
    const auto& token = pattern[pi];
    if (token == "*" || token == "_") {
        const std::size_t minimum = token == "_" ? 1 : 0;
        if (input.size() - ii < minimum) return false;
        for (std::size_t end = input.size() + 1; end-- > ii + minimum;) {
            captures.push_back(join_words(display_input, ii, end));
            if (match_recursive(pattern, input, display_input, pi + 1, end, captures)) return true;
            captures.pop_back();
        }
        return false;
    }
    return ii < input.size() && token == input[ii] &&
           match_recursive(pattern, input, display_input, pi + 1, ii + 1, captures);
}

Match match_pattern(const std::string& pattern_text, const std::string& input_text) {
    const auto pattern = words(normalize_pattern(pattern_text));
    const auto input = words(upper_normalize(input_text));
    const auto display_input = words(preserve_case_normalize(input_text));
    Match result;
    if (pattern.empty() || input.size() != display_input.size()) return result;
    result.matched = match_recursive(pattern, input, display_input, 0, 0, result.captures);
    return result;
}

int pattern_score(const std::string& pattern_text) {
    int score = 0;
    for (const auto& token : words(normalize_pattern(pattern_text))) {
        if (token == "_") score += 10;
        else if (token == "*") score -= 1;
        else score += 100;
    }
    return score;
}

std::string trim(std::string value) {
    const auto first = value.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return {};
    const auto last = value.find_last_not_of(" \t\r\n");
    return value.substr(first, last - first + 1);
}

std::string substitute_person(std::string value, int mode) {
    static const std::map<std::string, std::string> person = {
        {"I", "YOU"}, {"ME", "YOU"}, {"MY", "YOUR"}, {"MINE", "YOURS"}, {"AM", "ARE"},
        {"YOU", "I"}, {"YOUR", "MY"}, {"YOURS", "MINE"}, {"YOURSELF", "MYSELF"}, {"MYSELF", "YOURSELF"}
    };
    static const std::map<std::string, std::string> gender = {
        {"HE", "SHE"}, {"SHE", "HE"}, {"HIS", "HER"}, {"HER", "HIS"}, {"HIM", "HER"}, {"HERS", "HIS"}
    };
    auto tokens = words(upper_normalize(value));
    std::string result;
    for (const auto& token : tokens) {
        const auto& table = mode == 2 ? gender : person;
        const auto it = table.find(token);
        if (!result.empty()) result += ' ';
        result += it == table.end() ? token : it->second;
    }
    return result;
}

struct Session {
    std::map<std::string, std::string> predicates;
    std::string topic;
    std::string previous_input;
    std::string previous_output;
    std::uint64_t turn = 0;
    std::uint64_t random_choice = 0;
};

class AimlEngine {
public:
    void load(const std::string& path) {
        auto loaded = read_corpus(path);
        if (!loaded.contains("sources") || !loaded["sources"].is_array()) throw std::runtime_error("corpus sources missing");
        if (loaded.value("category_count", std::size_t{}) != loaded["categories"].size()) throw std::runtime_error("category count mismatch");
        corpus = std::move(loaded);
        if (corpus.value("source_count", std::size_t{}) != corpus["sources"].size()) throw std::runtime_error("source count mismatch");
        categories.clear();
        wildcard_categories.clear();
        by_first.clear();
        std::size_t ordinal = 0;
        for (const auto& category : corpus["categories"]) {
            if (!category.is_object() || !category.contains("pattern") || !category["pattern"].is_string() || !category.contains("nodes") || !category["nodes"].is_array()) {
                throw std::runtime_error("category record is malformed");
            }
            const auto normalized = normalize_pattern(category["pattern"].get<std::string>());
            const auto pattern_words = words(normalized);
            const bool has_template = std::any_of(category["nodes"].begin(), category["nodes"].end(),
                [](const Json& node) { return node.is_object() && node.value("tag", std::string{}) == "template"; });
            if (pattern_words.empty() || !has_template) { ++ordinal; continue; }
            const auto* ptr = &category;
            categories.push_back({ptr, ordinal++, pattern_score(normalized)});
        }
        for (const auto& candidate : categories) {
            const auto first = words(normalize_pattern(candidate.category->at("pattern").get<std::string>())).front();
            if (first == "*" || first == "_") wildcard_categories.push_back(&candidate);
            else by_first[first].push_back(&candidate);
        }
        loaded_path = path;
        ready = true;
        sessions.clear();
    }

    std::string generate(const std::string& session_id, const std::string& prompt) {
        auto& session = sessions[session_id];
        ++session.turn;
        session.previous_input = prompt;
        const auto response = generate_inner(prompt, session, 0);
        session.previous_output = response;
        return response;
    }

    void reset(const std::string& session_id) { sessions.erase(session_id); }
    void record_response(const std::string& session_id,const std::string& prompt,
                         const std::string& response) {
        auto& session=sessions[session_id];++session.turn;
        session.previous_input=prompt;session.previous_output=response;
    }
    bool is_ready() const { return ready; }
    const std::string& path() const { return loaded_path; }

private:
    struct Candidate { const Json* category; std::size_t ordinal; int score; };
    Json corpus;
    std::vector<Candidate> categories;
    std::vector<const Candidate*> wildcard_categories;
    std::unordered_map<std::string, std::vector<const Candidate*>> by_first;
    std::map<std::string, Session> sessions;
    std::string loaded_path;
    bool ready = false;

    const Candidate* select(const std::string& input, const Session& session, Match& selected_match) const {
        const auto input_words = words(upper_normalize(input));
        std::vector<const Candidate*> candidates = wildcard_categories;
        if (!input_words.empty()) {
            const auto it = by_first.find(input_words.front());
            if (it != by_first.end()) candidates.insert(candidates.end(), it->second.begin(), it->second.end());
        }
        const Candidate* best = nullptr;
        int best_score = std::numeric_limits<int>::min();
        for (const auto* candidate : candidates) {
            const auto& category = *candidate->category;
            const auto topic = category.value("topic", std::string{});
            Match topic_match;
            if (!topic.empty()) {
                topic_match = match_pattern(topic, session.topic);
                if (!topic_match.matched) continue;
            }
            const auto that = category.value("that", std::string{});
            Match that_match;
            if (!that.empty()) {
                that_match = match_pattern(that, session.previous_output);
                if (!that_match.matched) continue;
            }
            auto match = match_pattern(category["pattern"].get<std::string>(), input);
            if (!match.matched) continue;
            if (!best || candidate->score > best_score || (candidate->score == best_score && candidate->ordinal < best->ordinal)) {
                best = candidate;
                best_score = candidate->score;
                match.that_captures = std::move(that_match.captures);
                match.topic_captures = std::move(topic_match.captures);
                selected_match = std::move(match);
            }
        }
        return best;
    }

    static std::string attr(const Json& node, const std::string& key, const std::string& fallback = {}) {
        if (!node.contains("attrs") || !node["attrs"].is_object()) return fallback;
        const auto it = node["attrs"].find(key);
        return it == node["attrs"].end() || !it->is_string() ? fallback : it->get<std::string>();
    }

    std::string render_content(const Json& node, Session& session, const Match& match,
                               std::size_t depth, bool suppress) {
        if (!node.contains("content") || !node["content"].is_array()) return {};
        std::string result;
        for (const auto& item : node["content"]) {
            if (item.is_string()) {
                if (!suppress) result += item.get<std::string>();
            } else if (item.is_object()) {
                result += render_node(item, session, match, depth, suppress);
            }
        }
        return result;
    }

    std::string render_node(const Json& node, Session& session, const Match& match,
                            std::size_t depth, bool suppress) {
        const auto tag = node.value("tag", std::string{});
        if (tag == "template" || tag == "li") return render_content(node, session, match, depth, suppress);
        if (tag == "think") { (void) render_content(node, session, match, depth, true); return {}; }
        if (tag == "star" || tag == "thatstar" || tag == "topicstar") {
            std::size_t index = 1;
            try { const auto raw = attr(node, "index", "1"); index = static_cast<std::size_t>(std::stoul(raw)); } catch (...) {}
            const auto& captures = tag == "thatstar" ? match.that_captures :
                                   tag == "topicstar" ? match.topic_captures : match.captures;
            return !suppress && index > 0 && index <= captures.size() ? captures[index - 1] : std::string{};
        }
        if (tag == "get") {
            const auto name = attr(node, "name");
            if (name == "topic") return suppress ? std::string{} : session.topic;
            const auto it = session.predicates.find(name);
            return !suppress && it != session.predicates.end() ? it->second : std::string{};
        }
        if (tag == "set") {
            const auto name = attr(node, "name");
            const auto value = trim(render_content(node, session, match, depth, false));
            if (!name.empty()) {
                session.predicates[name] = value;
                if (name == "topic") session.topic = value;
            }
            return suppress ? std::string{} : value;
        }
        if (tag == "srai") {
            const auto target = trim(render_content(node, session, match, depth, false));
            // Reasoning SRAI is a proposal. The AIML renderer has no XCFE
            // admission record or reasoning handler, so this boundary fails closed.
            if (upper_normalize(target).rfind("XCFE DISPATCH ", 0) == 0)
                return suppress ? std::string{} : "Reasoning dispatch denied: XCFE admission unavailable.";
            return suppress || depth >= 8 ? std::string{} : generate_inner(target, session, depth + 1);
        }
        if (tag == "condition") return render_condition(node, session, match, depth, suppress);
        if (tag == "random") {
            std::vector<const Json*> choices;
            if (node.contains("content") && node["content"].is_array()) {
                for (const auto& item : node["content"]) if (item.is_object() && item.value("tag", std::string{}) == "li") choices.push_back(&item);
            }
            if (choices.empty()) return render_content(node, session, match, depth, suppress);
            const auto choice = static_cast<std::size_t>(session.random_choice++ % choices.size());
            return render_node(*choices[choice], session, match, depth, suppress);
        }
        if (tag == "bot") {
            if (suppress) return {};
            const auto name = attr(node, "name");
            if (name == "name") return "Alice";
            const auto it = session.predicates.find("bot:" + name);
            return it == session.predicates.end() ? std::string{} : it->second;
        }
        if (tag == "input") return suppress ? std::string{} : session.previous_input;
        if (tag == "that") return suppress ? std::string{} : session.previous_output;
        if (tag == "id") return suppress ? std::string{} : "default";
        if (tag == "size") return suppress ? std::string{} : std::to_string(categories.size());
        if (tag == "br" || tag == "p") return suppress ? std::string{} : "\n";
        if (tag == "code") return render_content(node, session, match, depth, suppress);
        if (tag == "person" || tag == "person2" || tag == "gender") {
            const auto content = render_content(node, session, match, depth, false);
            return suppress ? std::string{} : substitute_person(content, tag == "gender" ? 2 : (tag == "person2" ? 1 : 0));
        }
        if (tag == "uppercase" || tag == "lowercase" || tag == "formal" || tag == "sentence") {
            auto content = render_content(node, session, match, depth, suppress);
            if (tag == "uppercase") for (auto& c : content) c = static_cast<char>(std::toupper(static_cast<unsigned char>(c)));
            if (tag == "lowercase") for (auto& c : content) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
            if (tag == "formal" || tag == "sentence") {
                bool next_cap = true;
                for (auto& c : content) {
                    if (tag == "formal" && next_cap && std::isalpha(static_cast<unsigned char>(c))) { c = static_cast<char>(std::toupper(static_cast<unsigned char>(c))); next_cap = false; }
                    else if (tag == "formal" && std::isspace(static_cast<unsigned char>(c))) next_cap = true;
                }
                if (tag == "sentence" && !content.empty()) content[0] = static_cast<char>(std::toupper(static_cast<unsigned char>(content[0])));
            }
            return content;
        }
        if (tag == "learn") return {}; // corpus is immutable; <learn> cannot mutate active rules.
        return render_content(node, session, match, depth, suppress);
    }

    std::string render_condition(const Json& node, Session& session, const Match& match,
                                 std::size_t depth, bool suppress) {
        const auto name = attr(node, "name");
        const auto value = attr(node, "value");
        const auto pred = session.predicates.find(name);
        const std::string actual = pred == session.predicates.end() ? std::string{} : pred->second;
        bool has_li = false;
        if (node.contains("content") && node["content"].is_array()) {
            for (const auto& item : node["content"]) {
                if (!item.is_object() || item.value("tag", std::string{}) != "li") continue;
                has_li = true;
                const auto li_name = attr(item, "name", name);
                const auto li_value = attr(item, "value");
                const auto it = session.predicates.find(li_name);
                const auto candidate = it == session.predicates.end() ? std::string{} : it->second;
                if (li_value.empty() || candidate == li_value) return render_node(item, session, match, depth, suppress);
            }
        }
        if (has_li) return {};
        if (!name.empty() && actual == value) return render_content(node, session, match, depth, suppress);
        return {};
    }

    std::string generate_inner(const std::string& input, Session& session, std::size_t depth) {
        if (depth > 8) return {};
        if (upper_normalize(input).rfind("XCFE DISPATCH ", 0) == 0)
            return "Reasoning dispatch denied: XCFE admission unavailable.";
        Match match;
        const auto* candidate = select(input, session, match);
        if (std::getenv("MICRONAUT_AIML_TRACE")) {
            std::cerr << "[aiml] depth=" << depth << " input=" << input
                      << " pattern=" << (candidate ? candidate->category->at("pattern").get<std::string>() : "<miss>") << '\n';
        }
        if (!candidate) return "I don't know.";
        const Json* templ = nullptr;
        for (const auto& node : candidate->category->at("nodes")) {
            if (node.is_object() && node.value("tag", std::string{}) == "template") { templ = &node; break; }
        }
        if (!templ) return {};
        auto response = trim(render_node(*templ, session, match, depth, false));
        return response;
    }
};

AimlEngine& engine() { static AimlEngine value; return value; }
std::mutex& engine_mutex() { static std::mutex value; return value; }
std::string& engine_load_error() { static std::string value; return value; }
}

bool aiml_runtime_load(const std::string& path, std::string* error) {
    std::lock_guard<std::mutex> lock(engine_mutex());
    try {
        engine().load(path);
        engine_load_error().clear();
        return true;
    } catch (const std::exception& ex) {
        engine_load_error() = ex.what();
        if (error) *error = engine_load_error();
        return false;
    }
}

bool aiml_runtime_ensure_loaded(std::string* error) {
    std::lock_guard<std::mutex> lock(engine_mutex());
    if (engine().is_ready()) return true;
    std::vector<std::string> candidates;
    if (const char* env = std::getenv("MICRONAUT_AIML_CORPUS")) if (*env) candidates.emplace_back(env);
    if (const char* env = std::getenv("MICRONAUT_AIML_GGUF")) if (*env) candidates.emplace_back(env);
    candidates.emplace_back("micronaut_daemon/build/alice.aiml.jsonl");
    candidates.emplace_back("build/alice.aiml.jsonl");
    candidates.emplace_back("micronaut_daemon/build/alice.aiml.gguf");
    candidates.emplace_back("build/alice.aiml.gguf");
    for (const auto& path : candidates) {
        if (!std::filesystem::exists(path)) continue;
        try {
            engine().load(path);
            engine_load_error().clear();
            return true;
        } catch (const std::exception& ex) {
            engine_load_error() = ex.what();
            if (error) *error = engine_load_error();
            return false;
        }
    }
    engine_load_error() = "AIML corpus not found; set MICRONAUT_AIML_CORPUS or pass --aiml-corpus <path>";
    if (error) *error = engine_load_error();
    return false;
}

bool aiml_runtime_ready() {
    std::lock_guard<std::mutex> lock(engine_mutex());
    return engine().is_ready();
}

std::string aiml_runtime_path() {
    std::lock_guard<std::mutex> lock(engine_mutex());
    return engine().path();
}

void aiml_runtime_reset_session(const std::string& session_id) {
    std::lock_guard<std::mutex> lock(engine_mutex());
    engine().reset(session_id);
}

void aiml_runtime_record_response(const std::string& session_id,
                                  const std::string& prompt,const std::string& response) {
    std::lock_guard<std::mutex> lock(engine_mutex());
    engine().record_response(session_id,prompt,response);
}

std::optional<std::string> aiml_runtime_generate(const std::string& session_id,
                                                 const std::string& prompt,
                                                 std::string* error) {
    std::lock_guard<std::mutex> lock(engine_mutex());
    if (!engine().is_ready()) {
        if (error) *error = engine_load_error().empty() ? "AIML runtime is not loaded" : engine_load_error();
        return std::nullopt;
    }
    try {
        return engine().generate(session_id, prompt);
    } catch (const std::exception& ex) {
        if (error) *error = ex.what();
        return std::nullopt;
    }
}

} // namespace micronaut
