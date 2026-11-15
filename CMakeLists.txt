cmake_minimum_required(VERSION 3.16)
project(micronaut_runtime LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(gml gml.cpp)
add_executable(ccc4_train ccc4_train.cpp ccc4_learning.cpp trainer.cpp)
target_include_directories(ccc4_train PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(ccc4_infer ccc4_infer.cpp ccc4_learning.cpp trainer.cpp)
target_include_directories(ccc4_infer PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(test_ccc4_learning tools/test_ccc4_learning.cpp ccc4_learning.cpp trainer.cpp)
add_executable(test_ccc4_gradient_opencl tools/test_ccc4_gradient_opencl.cpp ccc4_learning.cpp trainer.cpp opencl.cpp)
target_include_directories(test_ccc4_gradient_opencl PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_custom_command(TARGET test_ccc4_gradient_opencl POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/gradients.cl"
        "$<TARGET_FILE_DIR:test_ccc4_gradient_opencl>/gradients.cl")
add_executable(test_tensor_contract tools/test_tensor_contract.cpp tensor_contract.cpp phase_gate.cpp pop.cpp wo.cpp yax.cpp sek.cpp chen.cpp xul.cpp)
add_executable(test_reasoning_phase tools/test_reasoning_phase.cpp reasoning_phase.cpp common.cpp)
add_executable(test_xcfe_policy tools/test_xcfe_policy.cpp xcfe_policy.cpp)
add_executable(test_training_phase tools/test_training_phase.cpp training_phase.cpp)
target_include_directories(test_xcfe_policy PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
target_include_directories(test_ccc4_learning PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(operator_plan_vector operator_plan_vector.cpp)
add_executable(test_vector_plan tools/test_vector_plan.cpp vector_plan.cpp reduce.cpp)
target_include_directories(test_vector_plan PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(vector_plan_cli vector_plan_cli.cpp vector_plan.cpp vector_store.cpp file_digest.cpp reduce.cpp)
target_include_directories(vector_plan_cli PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(chen_vector_plan_cli chen_vector_plan_cli.cpp chen_vector_plan.cpp vector_plan.cpp vector_store.cpp file_digest.cpp reduce.cpp)
target_include_directories(chen_vector_plan_cli PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(test_semantic_bridge tools/test_semantic_bridge.cpp semantic_bridge.cpp relational_graph.cpp relational_keys.cpp vector_store.cpp file_digest.cpp)
target_include_directories(test_semantic_bridge PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(gemma_bridge_request_cli gemma_bridge_request_cli.cpp semantic_bridge.cpp relational_graph.cpp relational_keys.cpp vector_store.cpp file_digest.cpp)
target_include_directories(gemma_bridge_request_cli PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
target_compile_definitions(gemma_bridge_request_cli PRIVATE MICRONAUT_SOURCE_ROOT="${CMAKE_CURRENT_SOURCE_DIR}")
add_executable(test_domain_bridge tools/test_domain_bridge.cpp vector_store.cpp file_digest.cpp relational_keys.cpp conversation.cpp)
target_include_directories(test_domain_bridge PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(test_micronaut_translation tools/test_micronaut_translation.cpp micronaut_translation.cpp conversation.cpp relational_graph.cpp relational_keys.cpp file_digest.cpp)
target_include_directories(test_micronaut_translation PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(test_gemma_bridge_route tools/test_gemma_bridge_route.cpp gemma_bridge_route.cpp query_attestation.cpp semantic_bridge.cpp vector_store.cpp micronaut_translation.cpp conversation.cpp relational_graph.cpp relational_keys.cpp file_digest.cpp common.cpp)
target_include_directories(test_gemma_bridge_route PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
target_compile_definitions(test_gemma_bridge_route PRIVATE MICRONAUT_SOURCE_ROOT="${CMAKE_CURRENT_SOURCE_DIR}")
add_executable(store_write_cli store_write_cli.cpp store_write.cpp vector_store.cpp file_digest.cpp)
target_include_directories(store_write_cli PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
add_executable(vector_math_probe vector_math_probe.cpp opencl.cpp svml.cpp)
add_executable(vector_lane vector_lane.cpp vector_store.cpp file_digest.cpp kuhul_runtime.cpp opencl.cpp phase_gate.cpp pop.cpp wo.cpp yax.cpp sek.cpp chen.cpp xul.cpp)
target_include_directories(vector_lane PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
foreach(kernel_target vector_math_probe vector_lane)
    add_custom_command(TARGET ${kernel_target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_CURRENT_SOURCE_DIR}/vector_lane.cl"
            "$<TARGET_FILE_DIR:${kernel_target}>/vector_lane.cl"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_CURRENT_SOURCE_DIR}/attention.cl"
            "$<TARGET_FILE_DIR:${kernel_target}>/attention.cl"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_CURRENT_SOURCE_DIR}/micronaut.cl"
            "$<TARGET_FILE_DIR:${kernel_target}>/micronaut.cl")
endforeach()
add_executable(test_kuhul_runtime tools/test_kuhul_runtime.cpp kuhul_runtime.cpp opencl.cpp phase_gate.cpp pop.cpp wo.cpp yax.cpp sek.cpp chen.cpp xul.cpp)
add_executable(test_ccc4_commit tools/test_ccc4_commit.cpp kuhul_runtime.cpp opencl.cpp phase_gate.cpp pop.cpp wo.cpp yax.cpp sek.cpp chen.cpp xul.cpp)
add_custom_command(TARGET test_ccc4_commit POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/vector_lane.cl"
        "$<TARGET_FILE_DIR:test_ccc4_commit>/vector_lane.cl")
add_executable(test_binding_import tools/test_binding_import.cpp bindings.cpp)
target_include_directories(test_binding_import PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/vendor")

add_executable(micronaut
    main.cpp
    http_server.cpp
    common.cpp
    input.cpp
    output.cpp
    process.cpp
    chat.cpp gemma_bridge_route.cpp query_attestation.cpp semantic_bridge.cpp conversation.cpp micronaut_translation.cpp relational_graph.cpp relational_keys.cpp
    aiml_runtime.cpp
    batches.cpp
    threads.cpp
    scheduler.cpp
    canvas.cpp
    frames.cpp
    xcfe_router.cpp
    scxq2_runtime.cpp
    attention_registry.cpp
    matmul.cpp scale.cpp softmax.cpp mask.cpp qkv_split.cpp rotary.cpp
    flash_attn.cpp paged_attn.cpp ring_attn.cpp local_attn.cpp kv_cache.cpp
    sink_attn.cpp sliding.cpp sparse_attn.cpp linear_attn.cpp cross_attn.cpp
    gqa.cpp mqa.cpp mla.cpp head_routing.cpp pi_radius.cpp accumulator.cpp
    phase_gate.cpp pop.cpp wo.cpp yax.cpp sek.cpp chen.cpp xul.cpp
    bindings.cpp vector_store.cpp kuhul_runtime.cpp opencl.cpp file_digest.cpp vector_daemon.cpp vector_plan.cpp reduce.cpp chen_vector_plan.cpp
    reasoning_phase.cpp
)

target_include_directories(micronaut PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/vendor")
target_compile_definitions(micronaut PRIVATE MICRONAUT_SOURCE_ROOT="${CMAKE_CURRENT_SOURCE_DIR}")

set(MICRONAUT_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin" CACHE PATH "Daemon output directory")

set_target_properties(micronaut PROPERTIES
    OUTPUT_NAME "eliza-µ"
    RUNTIME_OUTPUT_DIRECTORY "${MICRONAUT_RUNTIME_OUTPUT_DIRECTORY}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${MICRONAUT_RUNTIME_OUTPUT_DIRECTORY}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${MICRONAUT_RUNTIME_OUTPUT_DIRECTORY}"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${MICRONAUT_RUNTIME_OUTPUT_DIRECTORY}"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${MICRONAUT_RUNTIME_OUTPUT_DIRECTORY}"
)

add_custom_command(TARGET micronaut POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/vector_lane.cl"
        "$<TARGET_FILE_DIR:micronaut>/vector_lane.cl"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/attention.cl"
        "$<TARGET_FILE_DIR:micronaut>/attention.cl")

if (WIN32)
    target_compile_definitions(micronaut PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
    target_link_libraries(micronaut PRIVATE Ws2_32 Bcrypt)
endif()
