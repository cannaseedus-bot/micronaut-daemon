#pragma once

#include <cstdint>
#include <deque>
#include <functional>
#include <memory>
#include <mutex>
#include <optional>
#include <regex>
#include <string>
#include <tuple>
#include <unordered_map>
#include <vector>

namespace kuhl {

enum class WildcardType { Plain, Entity, Relation, Property, Question, Program };
enum class Phase { Pop, Wo, Yax, Sek, Chen, Xul };
enum class RuleKind { Keyword, XNone, XForeign };
enum class ProposalStatus { Queued, RejectedAtValidate };

struct Substitution { std::string from, to; };
struct SynonymGroup { std::string name; std::vector<std::string> words; };
struct Capture { int index = 0; std::string span; WildcardType type = WildcardType::Plain; };
struct TypedBinding {
	WildcardType type = WildcardType::Plain;
	std::string capture_span, provenance;
	std::vector<std::pair<std::string, double>> candidates;
	bool is_fact = false, is_admitted = false;
};
struct Rule {
	std::string key;
	RuleKind kind = RuleKind::Keyword;
	int rank = 0;
	bool cycle = true, wildcard = false, memory_flag = false;
	std::string pattern, typed_pattern, srai_target;
	std::vector<std::string> reassembly, synonym_groups;
};
struct DomainManifest {
	std::string schema = "kuhul.domain-manifest.v1", domain = "unlabeled", authority = "data_only";
	std::vector<std::string> initials, finals, quits;
	std::vector<Substitution> pre, post;
	std::vector<SynonymGroup> synonyms;
	std::vector<Rule> rules;
	std::vector<std::pair<std::string, std::string>> postclean;
};
struct EngineOptions {
	int mem_size = 20, recursion_limit = 8, resolve_k = 5;
	bool cycle_by_default = true;
	double min_edge_score = 0.3;
	std::function<std::vector<std::tuple<std::string, std::string, double>>(const std::string&, int)> nearest;
};
struct KeyProposal {
	std::string schema = "kuhul.key-proposal.v1", proposal_id, session, micronaut;
	std::string token, kind, phase = "Yax", description, rationale, trigger_kind;
	std::vector<std::string> aliases, related_keys;
	bool requires_xcfe_admission = true, creates_fact = false, commit_authority = false;
};
struct ProposalResult { ProposalStatus status = ProposalStatus::RejectedAtValidate; std::string proposal_id, rejection_reason, hard_constraint_failed; };

class IProposalQueue {
public:
	virtual ~IProposalQueue() = default;
	virtual void enqueue(const KeyProposal&) = 0;
	virtual size_t size() const = 0;
};

class GeneralizedEngine {
public:
	struct Diagnostics {
		size_t rules_loaded = 0, transformations = 0, srai_hops = 0, memory_saves = 0;
		size_t memory_hits = 0, xnone_fallbacks = 0, proposals_queued = 0, proposals_rejected = 0;
	};

	GeneralizedEngine(DomainManifest, EngineOptions = {}, std::shared_ptr<IProposalQueue> = {});
	std::optional<std::string> transform(const std::string& input);
	TypedBinding resolve_wildcard(WildcardType, const std::string& span) const;
	ProposalResult propose_key(const KeyProposal&);
	std::optional<std::string> mem_get();
	void mem_set(const std::string&);
	size_t mem_size() const;
	Diagnostics diagnostics() const;
	Phase current_phase() const;

private:
	struct Impl;
	std::unique_ptr<Impl> impl_;
};

namespace util {
std::string to_lower(const std::string&);
std::string trim(const std::string&);
std::string collapse_whitespace(const std::string&);
std::string strip_punctuation(const std::string&);
std::vector<std::string> split_whitespace(const std::string&);
bool has_shell_metacharacters(const std::string&);
std::string generate_proposal_id();
}

} // namespace kuhl
