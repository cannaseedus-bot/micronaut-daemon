graph [
  comment "CSS-GEMM execution contract for the CSS-ML runtime. This graph declares tensor shapes, operation bindings, and backend authority; it is not itself executable code. The CSS-ML graph remains the executable operation DAG. WebGL2 uses GLSL ES 3.00 render-target passes and host-side tensor metadata. Unsupported kernels fall back to the CPU reference executor. Backpropagation and AdamW updates remain CPU-authoritative until GPU gradient and optimizer kernels are implemented and validated."
  directed 1
  id 1701
  label "CSS_GEMM_WebGL2_Contract"

  node [
    id 1
    label "TensorContract"
    x 0.0 y 0.0 z 0.0
    backend "webgl2"
    dtype "f32"
    layout "row_major"
    shape_authority "host_metadata"
    shape_rule "matmul: A[-1] == B[-2]; C = broadcast(A[:-1],B[:-2]) + [A[-2],B[-1]]"
    validation "reject_shape_dtype_or_stride_mismatch"
  ]

  node [
    id 2
    label "WebGL2Dispatcher"
    x 1.0 y 0.0 z 0.0
    module ".CSS-C/css-ml-runtime/src/runner/dispatcher.js"
    executor ".CSS-C/css-ml-runtime/src/runtime/webgl2.js"
    context "WebGL2RenderingContext"
    shader_version "#version 300 es"
    compute_model "fragment_render_target_passes"
    tensor_transport "host_float32_to_r32f_texture_and_readback"
  ]

  node [
    id 3
    label "ForwardKernels"
    x 2.0 y 0.0 z 0.0
    kernels "gemm,linear_forward,activation_relu"
    matmul_binding "gemm -> css_gemm_matmul_fragment"
    linear_binding "linear_forward -> css_gemm_linear_fragment"
    relu_binding "activation_relu -> css_gemm_relu_fragment"
    output_commit "readPixels_to_RuntimeTensor_data"
  ]

  node [
    id 4
    label "CPUReferenceFallback"
    x 2.0 y 1.0 z 0.0
    module ".CSS-C/css-ml-runtime/src/runtime/cpu.js"
    kernels "all_registered_cpu_kernels"
    fallback_rule "unsupported_webgl2_kernel_uses_cpu_reference"
  ]

  node [
    id 5
    label "GradientAndOptimizerAuthority"
    x 3.0 y 1.0 z 0.0
    gradient_module ".CSS-C/css-ml-runtime/src/runner/autograd.js"
    optimizer_kernel "adamw_update"
    authority "cpu"
    gpu_status "not_implemented"
    invariant "WebGL2_forward_does_not_claim_GPU_gradients_or_AdamW"
  ]

  node [
    id 6
    label "MicronautBrowserHost"
    x 4.0 y 0.0 z 0.0
    server_module "shell/Server.psm1"
    shell "Micronaut.ps1"
    demo_route "GET /css-gemm/demo"
    runtime_routes "GET /css-gemm/runtime/webgl2.js, GET /css-gemm/runtime/cpu.js"
    status_binding "css-gemm.driver.status"
    origin "http://127.0.0.1:9880"
    webview2_origin "https://cssml.local"
    virtual_host_root ".CSS-C"
  ]

  node [
    id 7
    label "ChatInfographicCard"
    x 4.0 y 1.0 z 0.0
    preview "data/apps/css-gemm-infographic.svg"
    interactive_target "http://127.0.0.1:9880/css-gemm/demo"
    display_modes "in_chat_svg,browser_html"
  ]

  node [
    id 8
    label "WebGL2JavaScriptModelTrainer"
    x 5.0 y 0.0 z 0.0
    entrypoint ".CSS-C/css-ml-runtime/src/runner/webgl2-model-trainer.js"
    graph ".CSS-C/css-ml-runtime/build/mnist/graph.json"
    forward_backend "WebGL2RenderingContext"
    backward_backend "CPU reference autograd"
    optimizer_backend "CPU reference AdamW"
    training_source "deterministic synthetic 28x28 samples"
    declaration "data/programs/css-gemm.trainer.json"
  ]

  edge [
    source 1 target 2
    label "validates_host_tensor_contract"
    verb "@requires"
    weight 1.0
  ]
  edge [
    source 2 target 3
    label "dispatches_webgl2_forward_kernels"
    verb "@uses"
    weight 1.0
  ]
  edge [
    source 2 target 4
    label "routes_unsupported_kernels"
    verb "@delegates_to"
    weight 1.0
  ]
  edge [
    source 3 target 5
    label "keeps_training_authority_explicit"
    verb "@requires"
    weight 1.0
  ]
  edge [
    source 6 target 2
    label "serves_runtime_modules_to_same_origin_browser"
    verb "@uses"
    weight 1.0
  ]
  edge [
    source 6 target 7
    label "hosts_interactive_infographic_route"
    verb "@exposes"
    weight 1.0
  ]
  edge [
    source 6 target 8
    label "serves_declared_browser_trainer_module_and_graph"
    verb "@exposes"
    weight 1.0
  ]
  edge [
    source 8 target 3
    label "runs_declared_forward_graph_kernels"
    verb "@uses"
    weight 1.0
  ]
  edge [
    source 8 target 5
    label "retains_cpu_gradient_and_optimizer_authority"
    verb "@requires"
    weight 1.0
  ]
]
