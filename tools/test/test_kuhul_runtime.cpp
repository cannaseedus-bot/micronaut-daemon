#include "../kuhul_runtime.h"
#include <iostream>
int main(){
    auto denied=micronaut::kuhul_runtime::run_row_index_mod64(nullptr,99524,256,{false,true});
    auto unvalidated=micronaut::kuhul_runtime::run_row_index_mod64(nullptr,99524,256,{true,false});
    if(denied.ok||denied.verified||denied.committed||!denied.values.empty())return 1;
    if(unvalidated.ok||unvalidated.verified||unvalidated.committed||!unvalidated.values.empty())return 2;
    std::cout<<"unadmitted and unvalidated execution rejected\n";
    return 0;
}
