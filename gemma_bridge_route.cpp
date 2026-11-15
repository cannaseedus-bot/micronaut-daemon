#include "gemma_bridge_route.h"
#include "conversation.h"
#include "file_digest.h"
#include "micronaut_translation.h"
#include "relational_keys.h"
#include "semantic_bridge.h"
#include "query_attestation.h"
#include <algorithm>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <stdexcept>

namespace micronaut::gemma_bridge_route {
namespace {
using Json=nlohmann::json;
void require(bool good,const char* why){if(!good)throw std::runtime_error(why);}
std::string root(){
#ifdef MICRONAUT_SOURCE_ROOT
    return MICRONAUT_SOURCE_ROOT;
#else
    throw std::runtime_error("source root not configured");
#endif
}
void admission(const MicronautOp& op){
    const char* enabled=std::getenv("MICRONAUT_GEMMA_BRIDGE");
    require(op.ingress=="stdin"&&enabled&&std::string(enabled)=="1",
        "bridge requires host-enabled local stdin ingress");
    const auto path=root()+"/build/gemma-chat-admission.v3.json";
    require(file_sha256(path)=="2e6c5e9952731b2a3260928ca070982bf19069ddc2fffadefbd6264664202ecd",
        "bridge admission contract is not host-pinned");
    require(file_sha256(root()+"/build/ccc4-vector-binding.candidate.json")==
        "c0c2816e5e862fae39307eafd45dfdcec0d6b2b4d37abfc09ff54d2233e65702",
        "vector binding is not host-pinned");
    std::ifstream in(path,std::ios::binary);const auto contract=Json::parse(in);
    require(contract.at("schema")=="gemma.bridge.chat-admission.v3"&&
        contract.at("authority")=="host_selected"&&contract.at("ingress")=="stdin"&&
        contract.at("enable_env")=="MICRONAUT_GEMMA_BRIDGE"&&
        contract.at("attest_key_env")=="MICRONAUT_GEMMA_ATTEST_KEY"&&
        contract.at("attestation")=="hmac_sha256_host_encoder_v1"&&
        contract.at("attestor_sha256")=="95d203147cc27039765dffdd526978c5dc35c412dddff22188f062c28ff621fe"&&
        contract.at("encoder_sha256")=="d3c6311aff7d689e6aba02479353ab8b3a27f2b2d0ab413ab789512cce9bbbd2"&&
        contract.at("manifest_sha256")=="6bce89f103aef62513c2b6f34ce760465b6b5f71085afc721f7bc524ff08a01b"&&
        contract.at("proposal_op")=="gemma.bridge.propose"&&
        contract.at("chat_op")=="chat.generate"&&
        contract.at("policy_id")=="aiml-existing-template.v1"&&
        contract.at("retrieval")=="recompute_pinned_store_exact_v1"&&
        contract.at("query_dimensions")==256&&contract.at("top_k_min")==1&&
        contract.at("top_k_max")==64&&
        contract.at("render")=="verified_plain_text_template"&&
        contract.at("fallback")=="existing_aiml"&&contract.at("mutation")==false,
        "invalid bridge admission contract");
    require(file_sha256(root()+"/tools/attest_gemma_query.py")==contract.at("attestor_sha256"),
        "query attestor script digest mismatch");
    require(file_sha256(root()+"/tools/encode_gemma_query.py")==contract.at("encoder_sha256"),
        "query encoder script digest mismatch");
    require(file_sha256(root()+"/build/io/aiml-embeddinggemma2-vectors/manifest.json")==
        contract.at("manifest_sha256"),"query vector manifest digest mismatch");
}
std::string plain_text(const Json& ast){
    if(ast.at("tag")!="template")return {};
    std::string text;
    for(const auto& node:ast.at("children")){
        if(node.at("tag")!="text")return {};
        text+=node.at("value").get<std::string>();
    }
    auto first=text.find_first_not_of(" \t\r\n");
    if(first==std::string::npos)return {};
    auto last=text.find_last_not_of(" \t\r\n");
    text=text.substr(first,last-first+1);
    if(text.find('&')!=std::string::npos||text.size()>4096)return {};
    return text;
}
void vector_response_admission(){
    const auto path=root()+"/build/vector-response-admission.v1.json";
    require(file_sha256(path)=="d14ec475270e06b3549e195725cb499f29dd80221107fc5c923900dadaa366de",
        "vector response contract is not host-pinned");
    std::ifstream in(path,std::ios::binary);const auto c=Json::parse(in);
    require(c.at("schema")=="micronaut.vector-response-admission.v1"&&
        c.at("track")=="VECTOR-µ"&&c.at("authority")=="host_selected_read_only"&&
        c.at("request_mode")=="vector_extended_v1"&&
        c.at("key_grammar")=="glyph-token-v1"&&c.at("key_prefix")=="⟁AIML_ROW_"&&
        c.at("max_response_chars")==4096&&c.at("fallback")=="existing_aiml"&&
        c.at("mutation")==false&&c.at("requires")==Json::array({
            "host_attestation","recomputed_retrieval","verified_response_policy",
            "validated_pattern_template_edge","plain_text_template"}),
        "invalid vector response contract");
}
}
Json evaluate(const MicronautOp& op,const std::string& prompt){
    admission(op);
    require(op.op=="gemma.bridge.propose"||op.op=="chat.generate","unsupported bridge operation");
    require(!op.raw.empty()&&op.raw.size()<=1048576,"invalid bridge request size");
    const auto request=Json::parse(op.raw);
    require(!request.contains("response_mode")||
        (request.at("response_mode").is_string()&&
         request.at("response_mode")=="vector_extended_v1"),
        "unsupported vector response mode");
    const bool extended=request.contains("response_mode");
    if(extended)vector_response_admission();
    require(request.is_object()&&request.at("op")==op.op&&request.contains("bridge")&&
        request.at("bridge").is_object(),"invalid bridge request");
    const auto& body=request.at("bridge");
    require(body.size()==5&&body.contains("context")&&body.contains("retrieval")&&
        body.contains("query_vector")&&body.contains("top_k")&&body.contains("attestation"),
        "bridge request must contain context, attestation, query_vector, top_k, and retrieval");
    const auto& ctx=body.at("context");
    require(ctx.is_object()&&ctx.size()==3&&ctx.at("utterance").is_string()&&
        ctx.at("that").is_string()&&ctx.at("topic").is_string(),"invalid bridge context");
    conversation::Context context{ctx.at("utterance").get<std::string>(),
        ctx.at("that").get<std::string>(),ctx.at("topic").get<std::string>()};
    require(!context.utterance.empty()&&context.utterance.size()<=4096&&
        context.that.size()<=4096&&context.topic.size()<=4096,"bridge context exceeds bounds");
    if(op.op=="chat.generate")require(context.utterance==prompt&&context.that.empty()&&
        context.topic.empty(),"chat bridge context must match prompt and empty prior context");
    const auto& supplied_query=body.at("query_vector");
    require(supplied_query.is_array()&&supplied_query.size()==256,
        "invalid bridge query dimensions");
    std::vector<float> query;query.reserve(256);
    for(const auto& value:supplied_query){
        require(value.is_number(),"non-numeric query vector value");
        const auto number=value.get<double>();
        require(std::isfinite(number),"nonfinite query vector value");
        const auto scalar=static_cast<float>(number);
        require(std::isfinite(scalar),"query vector value exceeds float32 range");
        query.push_back(scalar);
    }
    const auto& proof=body.at("attestation");
    require(proof.is_object()&&proof.size()==6&&
        proof.at("schema")=="gemma.bridge.query-attestation.v1"&&
        proof.at("model")=="google/embeddinggemma-2"&&
        proof.at("prompt_name")=="Retrieval-query"&&
        proof.at("manifest_sha256")=="6bce89f103aef62513c2b6f34ce760465b6b5f71085afc721f7bc524ff08a01b"&&
        proof.at("vector_sha256").is_string()&&proof.at("mac_sha256").is_string(),
        "invalid query encoder attestation");
    const auto bytes=std::string(reinterpret_cast<const char*>(query.data()),
        query.size()*sizeof(float));
    const auto vector_sha=query_attestation::sha256_hex(bytes);
    require(query_attestation::equal_digest(vector_sha,
        proof.at("vector_sha256").get<std::string>()),
        "query vector differs from encoder attestation");
    const char* secret=std::getenv("MICRONAUT_GEMMA_ATTEST_KEY");
    require(secret&&std::string(secret).size()>=32,"host query attestation key unavailable");
    const auto message="gemma.bridge.query-attestation.v1\n"+context.utterance+"\n"+
        vector_sha+"\n"+proof.at("manifest_sha256").get<std::string>();
    require(query_attestation::equal_digest(
        query_attestation::hmac_sha256_hex(secret,message),
        proof.at("mac_sha256").get<std::string>()),
        "query vector was not attested by host encoder");
    require(body.at("top_k").is_number_unsigned()||body.at("top_k").is_number_integer(),
        "invalid bridge top_k");
    const auto top_k=body.at("top_k").get<int>();
    require(top_k>=1&&top_k<=64,"bridge top_k outside admission bounds");
    const auto& retrieval=body.at("retrieval");
    const auto recomputed=semantic_bridge::retrieve(root(),query,std::size_t(top_k));
    require(retrieval==recomputed,"Ch'en retrieval rows or scores differ from pinned store");
    const auto policy=conversation::load_policy(root()+"/build/gemma-response-policy.v1.json");
    std::ifstream manifest_input(root()+"/build/aiml-relational-pilot/manifest.json",std::ios::binary);
    const auto manifest=Json::parse(manifest_input);
    const auto keys=relational_keys::load_jsonl(root()+"/build/aiml-relational-pilot/keys.jsonl",
        "aiml-embeddinggemma2",manifest.at("vector_rows").get<unsigned>(),
        manifest.at("graph_sha256").get<std::string>(),manifest.at("node_count").get<unsigned>());
    const auto candidate=conversation::propose(context,retrieval,keys,policy);
    const auto verified=micronaut_translation::verify_and_translate(root(),context,retrieval,candidate,policy);
    Json output={{"schema","gemma.bridge.chat-selection.v1"},{"authority","host_selected"},
        {"verified",true},{"attestation_verified",true},{"query_vector_sha256",vector_sha},
        {"retrieval_verified",true},{"top_k",top_k},
        {"proposal",verified},{"selection","existing_aiml"},
        {"admission_sha256","2e6c5e9952731b2a3260928ca070982bf19069ddc2fffadefbd6264664202ecd"}};
    if(verified.contains("template_ast")){
        const auto text=plain_text(verified.at("template_ast"));
        if(!text.empty()){
            output["selection"]="verified_plain_template";
            output["text"]=text;
            output["row_id"]=verified.at("row_id");
            if(extended){
                const auto row=verified.at("row_id").get<unsigned>();
                const auto& bindings=verified.at("graph_bindings");
                bool pattern=false,templ=false;
                for(const auto& binding:bindings){
                    if(binding.at("record_id")!="aiml:"+std::to_string(row))continue;
                    if(binding.at("relation_type")=="pattern"&&
                       binding.at("entity_id")=="pattern:"+std::to_string(row))pattern=true;
                    if(binding.at("relation_type")=="template"&&
                       binding.at("entity_id")=="template:"+std::to_string(row))templ=true;
                }
                if(pattern&&templ){
                    const auto hit=std::find_if(retrieval.at("hits").begin(),
                        retrieval.at("hits").end(),[row](const Json& item){
                            return item.at("row_id")==row;});
                    require(hit!=retrieval.at("hits").end(),"vector response source row missing");
                    const auto source=hit->at("pattern").get<std::string>();
                    const auto key="⟁AIML_ROW_"+std::to_string(row);
                    const auto composed=text+"\n\nVerified AIML pattern: "+source+" ["+key+"]";
                    if(composed.size()<=4096){
                        output["selection"]="verified_vector_response";
                        output["text"]=composed;
                        output["vector_response"]={{"schema","micronaut.vector-response.v1"},
                            {"track","VECTOR-µ"},{"key",key},{"row_id",row},
                            {"pattern",source},{"pattern_score",hit->at("pattern_score")},
                            {"graph_bindings",bindings},{"authority","host_selected_read_only"}};
                    }
                }
            }
        }
    }
    return output;
}
MicronautResult propose_execute(const MicronautOp& op){
    MicronautResult result;result.id=op.id;result.op=op.op;
    try{
        require(op.op=="gemma.bridge.propose","unsupported bridge operation");
        auto output=evaluate(op,"");
        output.erase("text");
        result.ok=true;result.result_json=output.dump();
    }catch(const std::exception& e){
        result.error_code="GEMMA_BRIDGE_REJECTED";result.error_message=e.what();
    }
    return result;
}
}
