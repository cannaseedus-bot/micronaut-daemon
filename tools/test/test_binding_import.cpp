#include "bindings.hpp"
#include <iostream>
int main(int argc,char**argv) {
    if(argc!=2)return 2;
    kuhul::binding::Environment env;
    std::string error;
    if(!kuhul::binding::bind_vector_candidate(env,argv[1],&error)){
        std::cerr<<error<<"\n";return 1;
    }
    for(const char* name:{"runtime.vector.pattern","runtime.vector.template","runtime.vector.category"}) {
        const auto* binding=env.resolve(name);
        if(!binding||!binding->resolved||!binding->typeValid||binding->writeAllowed||
           binding->executeAllowed||binding->semanticAdmitted||
           kuhul::binding::canExecute(env,name,true))return 3;
    }
    if(kuhul::binding::bind_vector_candidate(env,"missing-record.json",&error))return 4;
    std::cout<<"three data-only vector bindings imported; execution rejected\n";
    return 0;
}
