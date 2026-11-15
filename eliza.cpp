#include "eliza.h"

#include <algorithm>
#include <atomic>
#include <cctype>
#include <chrono>
#include <random>
#include <sstream>

namespace kuhl::util {

std::string to_lower(const std::string& value) {
	auto out = value;
	std::transform(out.begin(), out.end(), out.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
	return out;
}

std::string trim(const std::string& value) {
	const auto first = value.find_first_not_of(" \t\r\n");
	if (first == std::string::npos) return {};
	return value.substr(first, value.find_last_not_of(" \t\r\n") - first + 1);
}

std::string collapse_whitespace(const std::string& value) {
	std::istringstream in(value);
	std::ostringstream out;
	std::string token;
	while (in >> token) { if (out.tellp() > 0) out << ' '; out << token; }
	return out.str();
}

std::string strip_punctuation(const std::string& value) {
	std::string out;
	for (unsigned char c : value) {
		if (std::ispunct(c) && c != '*' && c != '_' && c != ':' && c != '@' && c != '\'' && c != '-') out += ' ';
		else out += static_cast<char>(c);
	}
	return out;
}

std::vector<std::string> split_whitespace(const std::string& value) {
	std::istringstream in(value);
	std::vector<std::string> out;
	for (std::string token; in >> token;) out.push_back(token);
	return out;
}

bool has_shell_metacharacters(const std::string& value) {
	static const std::string forbidden = ";|&$`(){}[]<>\\\"'\n\r\t";
	return value.find_first_of(forbidden) != std::string::npos;
}

std::string generate_proposal_id() {
	static std::atomic<std::uint64_t> sequence{0};
	const auto stamp = std::chrono::duration_cast<std::chrono::milliseconds>(
		std::chrono::steady_clock::now().time_since_epoch()).count();
	return "prop_" + std::to_string(stamp) + "_" + std::to_string(sequence.fetch_add(1));
}

} // namespace kuhl::util

namespace kuhl {
namespace {

bool wildcard_token(const std::string& token) { return token == "*" || token == "_" || token.rfind("*:", 0) == 0; }

WildcardType wildcard_type(const std::string& token) {
	if (token.rfind("*:", 0) != 0) return WildcardType::Plain;
	const auto type = util::to_lower(token.substr(2));
	if (type == "entity") return WildcardType::Entity;
	if (type == "relation") return WildcardType::Relation;
	if (type == "property") return WildcardType::Property;
	if (type == "question") return WildcardType::Question;
	if (type == "program") return WildcardType::Program;
	return WildcardType::Plain;
}

std::string type_name(WildcardType type) {
	switch (type) {
		case WildcardType::Entity: return "entity";
		case WildcardType::Relation: return "relation";
		case WildcardType::Property: return "property";
		case WildcardType::Question: return "question";
		case WildcardType::Program: return "program";
		default: return "plain";
	}
}

struct Match { bool matched = false; std::vector<std::string> captures; std::vector<WildcardType> types; };

bool match_tokens(const std::vector<std::string>& pattern, const std::vector<std::string>& input,
	std::size_t pi, std::size_t ii, Match& out) {
	if (pi == pattern.size()) return ii == input.size();
	if (!wildcard_token(pattern[pi])) {
		if (ii >= input.size() || util::to_lower(pattern[pi]) != util::to_lower(input[ii])) return false;
		return match_tokens(pattern, input, pi + 1, ii + 1, out);
	}
	const std::size_t min_words = 1;
	for (std::size_t end = input.size(); end >= ii + min_words; --end) {
		std::ostringstream capture;
		for (std::size_t i = ii; i < end; ++i) { if (i > ii) capture << ' '; capture << input[i]; }
		out.captures.push_back(capture.str());
		out.types.push_back(wildcard_type(pattern[pi]));
		if (match_tokens(pattern, input, pi + 1, end, out)) return true;
		out.captures.pop_back(); out.types.pop_back();
		if (end == ii + min_words) break;
	}
	return false;
}

std::string replace_all(std::string value, const std::string& from, const std::string& to) {
	if (from.empty()) return value;
	for (std::size_t pos = 0; (pos = value.find(from, pos)) != std::string::npos; pos += to.size()) value.replace(pos, from.size(), to);
	return value;
}

} // namespace

struct GeneralizedEngine::Impl {
	DomainManifest manifest;
	EngineOptions options;
	std::shared_ptr<IProposalQueue> queue;
	std::deque<std::string> memory;
	std::unordered_map<std::string, std::size_t> cycles;
	mutable std::mutex state_mutex;
	std::mutex transform_mutex;
	Phase phase = Phase::Pop;
	std::size_t transformations = 0, srai_hops = 0, memory_saves = 0, memory_hits = 0, xnone_fallbacks = 0, proposals_queued = 0, proposals_rejected = 0;

	Impl(DomainManifest m, EngineOptions o, std::shared_ptr<IProposalQueue> q) : manifest(std::move(m)), options(std::move(o)), queue(std::move(q)) {
		if (options.mem_size < 1) options.mem_size = 20;
		if (options.recursion_limit < 1) options.recursion_limit = 8;
	}

	std::string apply_substitutions(std::string value, const std::vector<Substitution>& substitutions) const {
		for (const auto& sub : substitutions) {
			if (sub.from.empty()) continue;
			const std::regex word("\\b" + sub.from + "\\b", std::regex::icase);
			value = std::regex_replace(value, word, sub.to);
		}
		return value;
	}

	std::string expand_input_synonyms(std::string value) const {
		for (const auto& group : manifest.synonyms) {
			for (const auto& word : group.words) {
				if (word.empty()) continue;
				const std::regex re("\\b" + word + "\\b", std::regex::icase);
				value = std::regex_replace(value, re, "@" + group.name);
			}
		}
		return value;
	}

	Match match_rule(const Rule& rule, const std::string& input) const {
		const auto pattern = util::split_whitespace(rule.typed_pattern.empty() ? rule.pattern : rule.typed_pattern);
		const auto words = util::split_whitespace(input);
		Match m;
		m.matched = match_tokens(pattern, words, 0, 0, m);
		if (!m.matched) return {};
		for (std::size_t i = 0; i < m.types.size(); ++i) {
			if (m.types[i] == WildcardType::Plain) continue;
			const auto bindings = resolve(m.types[i], m.captures[i]);
			if (bindings.candidates.empty()) return {};
		}
		return m;
	}

	TypedBinding resolve(WildcardType type, const std::string& span) const {
		TypedBinding binding; binding.type = type; binding.capture_span = span; binding.is_fact = false; binding.is_admitted = false;
		if (type == WildcardType::Plain) { binding.provenance = "plain_wildcard"; return binding; }
		if (!options.nearest) return binding;
		for (const auto& [key, candidate_type, score] : options.nearest(span, options.resolve_k)) {
			if (candidate_type == type_name(type) && score >= options.min_edge_score) binding.candidates.emplace_back(key, score);
		}
		if (!binding.candidates.empty()) binding.provenance = "typed-nearest-k";
		return binding;
	}

	std::vector<const Rule*> sorted_rules(bool include_fallback = false) const {
		std::vector<const Rule*> out;
		for (const auto& rule : manifest.rules) {
			if (!include_fallback && (rule.kind == RuleKind::XNone || rule.kind == RuleKind::XForeign)) continue;
			out.push_back(&rule);
		}
		std::stable_sort(out.begin(), out.end(), [](const Rule* a, const Rule* b) { return a->rank < b->rank; });
		return out;
	}

	std::size_t select(const Rule& rule) {
		if (rule.reassembly.empty()) return 0;
		if (!(rule.cycle || options.cycle_by_default)) return static_cast<std::size_t>(std::rand()) % rule.reassembly.size();
		std::lock_guard<std::mutex> lock(state_mutex);
		auto& index = cycles[rule.key];
		return index++ % rule.reassembly.size();
	}

	std::string render(const Rule& rule, const Match& match, const std::string& input) {
		const auto idx = select(rule);
		std::string response = rule.reassembly[idx];
		for (std::size_t i = 0; i < match.captures.size(); ++i) {
			response = replace_all(response, "{" + std::to_string(i + 1) + "}", match.captures[i]);
			response = replace_all(response, "(" + std::to_string(i + 1) + ")", match.captures[i]);
		}
		if (rule.memory_flag || (!response.empty() && response.front() == '$')) {
			if (!response.empty() && response.front() == '$') response.erase(response.begin());
			mem_set(response); ++memory_saves; return {};
		}
		std::string target = rule.srai_target;
		if (target.empty() && response.rfind("goto ", 0) == 0) target = response.substr(5);
		if (!target.empty()) { ++srai_hops; return transform_inner(target, 1); }
		// Post substitutions apply to captured spans before template rendering in ELIZA.
		std::string result = apply_substitutions(response, manifest.post);
		for (const auto& [pattern, replacement] : manifest.postclean) {
			try { result = std::regex_replace(result, std::regex(pattern), replacement); } catch (...) { /* invalid optional postclean entry */ }
		}
		(void)input;
		return util::collapse_whitespace(result);
	}

	std::optional<std::string> transform_inner(const std::string& original, int depth) {
		if (depth > options.recursion_limit) return std::nullopt;
		++transformations;
		phase = Phase::Wo;
		std::string normalized = util::collapse_whitespace(util::strip_punctuation(util::to_lower(original)));
		for (const auto& quit : manifest.quits) if (normalized == util::to_lower(quit)) { phase = Phase::Xul; return manifest.finals.empty() ? std::optional<std::string>("Goodbye.") : std::optional<std::string>(manifest.finals.front()); }
		normalized = apply_substitutions(normalized, manifest.pre);
		phase = Phase::Yax; normalized = expand_input_synonyms(normalized);
		phase = Phase::Sek;
		for (const Rule* rule : sorted_rules()) {
			const auto match = match_rule(*rule, normalized);
			if (!match.matched) continue;
			const auto result = render(*rule, match, original);
			if (!result.empty()) { phase = Phase::Chen; phase = Phase::Xul; return result; }
		}
		phase = Phase::Chen;
		if (auto remembered = mem_get()) { ++memory_hits; phase = Phase::Xul; return apply_substitutions(*remembered, manifest.post); }
		for (const auto& rule : manifest.rules) {
			if (rule.kind != RuleKind::XNone && rule.kind != RuleKind::XForeign) continue;
			Match fallback; fallback.matched = true; fallback.captures = {original}; fallback.types = {WildcardType::Plain};
			++xnone_fallbacks; phase = Phase::Xul; return render(rule, fallback, original);
		}
		phase = Phase::Xul; return std::nullopt;
	}

	void mem_set(const std::string& value) {
		std::lock_guard<std::mutex> lock(state_mutex);
		memory.push_back(value);
		while (memory.size() > static_cast<std::size_t>(options.mem_size)) memory.pop_front();
	}
	std::optional<std::string> mem_get() {
		std::lock_guard<std::mutex> lock(state_mutex);
		if (memory.empty()) return std::nullopt;
		auto value = memory.back(); memory.pop_back(); return value;
	}
};

GeneralizedEngine::GeneralizedEngine(DomainManifest m, EngineOptions o, std::shared_ptr<IProposalQueue> q)
	: impl_(std::make_unique<Impl>(std::move(m), std::move(o), std::move(q))) {}
std::optional<std::string> GeneralizedEngine::transform(const std::string& input) {
	std::lock_guard<std::mutex> lock(impl_->transform_mutex);
	return impl_->transform_inner(input, 0);
}
TypedBinding GeneralizedEngine::resolve_wildcard(WildcardType type, const std::string& span) const { return impl_->resolve(type, span); }
std::optional<std::string> GeneralizedEngine::mem_get() { return impl_->mem_get(); }
void GeneralizedEngine::mem_set(const std::string& value) { impl_->mem_set(value); }
std::size_t GeneralizedEngine::mem_size() const { std::lock_guard<std::mutex> lock(impl_->state_mutex); return impl_->memory.size(); }
Phase GeneralizedEngine::current_phase() const { return impl_->phase; }
GeneralizedEngine::Diagnostics GeneralizedEngine::diagnostics() const {
	return {impl_->manifest.rules.size(), impl_->transformations, impl_->srai_hops, impl_->memory_saves,
		impl_->memory_hits, impl_->xnone_fallbacks, impl_->proposals_queued, impl_->proposals_rejected};
}

ProposalResult GeneralizedEngine::propose_key(const KeyProposal& proposal) {
	ProposalResult result;
	const bool invalid_token = proposal.token.empty() || proposal.token.find_first_not_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789⟁:_-*.") != std::string::npos;
	if (invalid_token || util::has_shell_metacharacters(proposal.token)) { result.hard_constraint_failed = "no_shell_metacharacters"; result.rejection_reason = "key token failed safe-token validation"; }
	else if (proposal.kind.rfind("@ports.", 0) == 0 || proposal.token.rfind("@ports.", 0) == 0) { result.hard_constraint_failed = "@ports_reject"; result.rejection_reason = "@ports.* fields are prohibited"; }
	else if (proposal.commit_authority) { result.hard_constraint_failed = "host_only_commit"; result.rejection_reason = "commit_authority must remain false"; }
	else if (proposal.kind.empty() || proposal.phase.empty()) { result.hard_constraint_failed = "required_fields"; result.rejection_reason = "kind and phase are required"; }
	else if (std::find(proposal.aliases.begin(), proposal.aliases.end(), proposal.token) != proposal.aliases.end() || std::find(proposal.related_keys.begin(), proposal.related_keys.end(), proposal.token) != proposal.related_keys.end()) { result.hard_constraint_failed = "no_invented_keys"; result.rejection_reason = "proposal token duplicates one of its own aliases or related keys"; }
	else {
		KeyProposal queued = proposal;
		if (queued.proposal_id.empty()) queued.proposal_id = util::generate_proposal_id();
		if (impl_->queue) impl_->queue->enqueue(queued);
		++impl_->proposals_queued;
		result.status = ProposalStatus::Queued; result.proposal_id = queued.proposal_id; return result;
	}
	++impl_->proposals_rejected;
	return result;
}

} // namespace kuhl

