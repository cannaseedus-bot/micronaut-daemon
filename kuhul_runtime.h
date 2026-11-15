#pragma once
#include <string>
#include <vector>
#include <cstdint>
#include <mutex>

namespace micronaut::kuhul_runtime {
// Admission is supplied by the caller. This local record is not an XCFE token.
struct Admission {
    bool local_execution_requested = false;
    bool artifact_shape_validated = false;
};
struct CandidateResult {
    bool ok = false;
    bool verified = false;
    bool committed = false;
    std::string error;
    std::vector<float> values;
    std::vector<std::string> trace;
};
struct RowIndexModPlan;
// Host-owned, process-local CCC4 activation state. Persistence is a separate
// operation; a verified candidate is not a committed state by itself.
class Ccc4StateStore {
public:
    struct Snapshot { std::uint64_t generation; std::vector<float> values; };
    Snapshot snapshot() const;
private:
    friend CandidateResult run_row_index_mod_mean(const float*, const RowIndexModPlan&,
                                                 const Admission&, const struct CommitRequest*);
    mutable std::mutex mutex_;
    std::uint64_t generation_ = 0;
    std::vector<float> values_;
};
struct CommitRequest {
    Ccc4StateStore* store = nullptr;
    std::uint64_t expected_generation = 0;
    bool host_authorized = false;
};
struct RowIndexModPlan {
    unsigned source_rows = 0;
    unsigned dimension = 0;
    unsigned groups = 0;
};
CandidateResult run_row_index_mod_mean(const float* rows, const RowIndexModPlan& plan,
                                       const Admission& admission,
                                       const CommitRequest* commit = nullptr);
CandidateResult run_row_index_mod64(const float* rows, unsigned row_count,
                                    unsigned dimension, const Admission& admission,
                                    const CommitRequest* commit = nullptr);
}
