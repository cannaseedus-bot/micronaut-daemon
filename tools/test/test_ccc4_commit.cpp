#include "../kuhul_runtime.h"
#include <vector>
#include <iostream>

int main() {
    using namespace micronaut::kuhul_runtime;
    std::vector<float> rows(std::size_t(99524)*256, 1.0f);
    Ccc4StateStore store;
    CommitRequest unauthorized{&store,0,false};
    auto denied=run_row_index_mod64(rows.data(),99524,256,{true,true},&unauthorized);
    if(denied.ok || store.snapshot().generation!=0)return 1;
    CommitRequest request{&store,0,true};
    auto committed=run_row_index_mod64(rows.data(),99524,256,{true,true},&request);
    auto state=store.snapshot();
    if(!committed.ok || !committed.verified || !committed.committed ||
       state.generation!=1 || state.values.size()!=64*256 || state.values[0]!=1.0f)return 2;
    auto stale=run_row_index_mod64(rows.data(),99524,256,{true,true},&request);
    if(stale.ok || stale.committed || store.snapshot().generation!=1)return 3;
    std::vector<float> small(std::size_t(65)*3);
    for(unsigned row=0;row<65;++row)for(unsigned col=0;col<3;++col)
        small[std::size_t(row)*3+col]=float(row+col);
    auto generalized=run_row_index_mod_mean(small.data(),{65,3,64},{true,true});
    if(!generalized.ok || !generalized.verified || generalized.committed ||
       generalized.values.size()!=64*3 || generalized.values[0]!=32.0f ||
       generalized.values[3]!=1.0f)return 4;
    std::cerr<<"CCC4 commit authorization, verified swap, and stale generation passed\n";
}
