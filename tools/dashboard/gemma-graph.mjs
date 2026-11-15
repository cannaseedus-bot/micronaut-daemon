// Builds a forward decoder-layer DAG for the verified CSS-ML WebGL2 executor.
// Tensor payloads stay caller-owned: pass loaded CPU tensors or resident handles
// in the graph inputs when calling executeGraph().

const integer = (value, name, minimum = 1) => {
  if (!Number.isInteger(value) || value < minimum) throw new Error(`Invalid Gemma config ${name}: ${value}`);
  return value;
};

function textConfig(config) {
  return config?.text_config && typeof config.text_config === 'object' ? config.text_config : config;
}

export function normalizeGemmaConfig(rawConfig) {
  const c = textConfig(rawConfig);
  if (!c || !['gemma3_text', 'gemma3'].includes(c.model_type) || !c.architectures?.some((name) => name.includes('Gemma3'))) {
    throw new Error('Expected a Gemma 3 text config (model_type gemma3_text/gemma3 and Gemma3 architecture).');
  }
  const hidden = integer(c.hidden_size, 'hidden_size');
  const heads = integer(c.num_attention_heads, 'num_attention_heads');
  const kvHeads = integer(c.num_key_value_heads, 'num_key_value_heads');
  const headDim = integer(c.head_dim ?? hidden / heads, 'head_dim');
  const layers = integer(c.num_hidden_layers, 'num_hidden_layers');
  const intermediate = integer(c.intermediate_size, 'intermediate_size');
  const layerTypes = c.layer_types;
  if (!Array.isArray(layerTypes) || layerTypes.length !== layers || layerTypes.some((type) => !['sliding_attention', 'full_attention'].includes(type))) {
    throw new Error('Gemma config layer_types must list sliding_attention/full_attention for every decoder layer.');
  }
  if (heads % kvHeads !== 0 || heads * headDim !== hidden) throw new Error('Unsupported Gemma attention dimensions or GQA ratio.');
  if (c.hidden_activation !== 'gelu_pytorch_tanh') throw new Error(`Unsupported Gemma MLP activation: ${c.hidden_activation}`);
  if (c.attn_logit_softcapping != null) throw new Error('Attention logit softcapping is configured but not implemented by this graph builder.');
  if (c.use_bidirectional_attention) throw new Error('Bidirectional Gemma attention is not supported by the causal attention kernels.');
  const rope = c.rope_parameters;
  if (!rope?.sliding_attention?.rope_theta || !rope?.full_attention?.rope_theta) throw new Error('Gemma config must define both sliding and full RoPE theta values.');
  return {
    hiddenSize: hidden,
    intermediateSize: intermediate,
    vocabSize: integer(c.vocab_size, 'vocab_size'),
    numLayers: layers,
    numHeads: heads,
    numKvHeads: kvHeads,
    headDim,
    slidingWindow: integer(c.sliding_window, 'sliding_window'),
    attentionScale: 1 / Math.sqrt(Number(c.query_pre_attn_scalar ?? headDim)),
    epsilon: Number(c.rms_norm_eps ?? 1e-6),
    embeddingScale: Math.sqrt(hidden),
    tieWordEmbeddings: c.tie_word_embeddings === true,
    layerTypes: [...layerTypes],
    ropeTheta: {
      sliding_attention: Number(rope.sliding_attention.rope_theta),
      full_attention: Number(rope.full_attention.rope_theta)
    },
    activation: c.hidden_activation
  };
}

const shape = (header, name) => header?.[name]?.shape;
const sameShape = (actual, expected) => Array.isArray(actual) && actual.length === expected.length && actual.every((n, i) => n === expected[i]);

export function validateGemmaLayerTensors(config, header, layerIndex) {
  const c = config.hiddenSize ? config : normalizeGemmaConfig(config);
  integer(layerIndex, 'layerIndex', 0);
  if (layerIndex >= c.numLayers) throw new Error(`Layer index ${layerIndex} is outside [0, ${c.numLayers}).`);
  const p = `model.layers.${layerIndex}.`;
  const required = {
    [`${p}input_layernorm.weight`]: [c.hiddenSize],
    [`${p}self_attn.q_proj.weight`]: [c.numHeads * c.headDim, c.hiddenSize],
    [`${p}self_attn.k_proj.weight`]: [c.numKvHeads * c.headDim, c.hiddenSize],
    [`${p}self_attn.v_proj.weight`]: [c.numKvHeads * c.headDim, c.hiddenSize],
    [`${p}self_attn.o_proj.weight`]: [c.hiddenSize, c.numHeads * c.headDim],
    [`${p}self_attn.q_norm.weight`]: [c.headDim],
    [`${p}self_attn.k_norm.weight`]: [c.headDim],
    [`${p}post_attention_layernorm.weight`]: [c.hiddenSize],
    [`${p}pre_feedforward_layernorm.weight`]: [c.hiddenSize],
    [`${p}post_feedforward_layernorm.weight`]: [c.hiddenSize],
    [`${p}mlp.gate_proj.weight`]: [c.intermediateSize, c.hiddenSize],
    [`${p}mlp.up_proj.weight`]: [c.intermediateSize, c.hiddenSize],
    [`${p}mlp.down_proj.weight`]: [c.hiddenSize, c.intermediateSize]
  };
  const mismatches = [];
  for (const [name, expected] of Object.entries(required)) {
    const actual = shape(header, name);
    if (!sameShape(actual, expected)) mismatches.push(`${name}: expected [${expected}], got ${actual ? `[${actual}]` : 'missing'}`);
  }
  if (mismatches.length) throw new Error(`Gemma layer ${layerIndex} Safetensors header mismatch:\n${mismatches.join('\n')}`);
  return { layerIndex, layerType: c.layerTypes[layerIndex], requiredTensors: Object.keys(required) };
}

function addNode(nodes, id, op, inputs, outputDims, params = {}) {
  nodes.push({ id, op, inputs, outputDims, params, device: 'auto' });
  return `$node.${id}`;
}

export function buildGemmaLayerForwardGraph({ config: rawConfig, header, layerIndex, seqLen, inputName = 'hidden_states' }) {
  const config = rawConfig?.hiddenSize ? rawConfig : normalizeGemmaConfig(rawConfig);
  integer(seqLen, 'seqLen');
  const validation = header ? validateGemmaLayerTensors(config, header, layerIndex) : { layerIndex, layerType: config.layerTypes[layerIndex] };
  if (layerIndex >= config.numLayers) throw new Error(`Layer index ${layerIndex} is outside [0, ${config.numLayers}).`);
  const { hiddenSize: H, intermediateSize: I, numHeads: QH, numKvHeads: KVH, headDim: D } = config;
  const prefix = `layer${layerIndex}`;
  const w = (suffix) => `model.layers.${layerIndex}.${suffix}`;
  const input = (name) => `$input.${name}`;
  const nodes = [];
  const norm = (id, x, weight, segmentSize, width = segmentSize) => addNode(nodes, id, 'rms_norm', { x, weight: input(weight) }, [seqLen, width], { segment_size: segmentSize, epsilon: config.epsilon, centered_weight: true });
  const linear = (id, x, weight, outCols, inCols) => addNode(nodes, id, 'linear_forward_transposed', { input: x, weight: input(weight) }, [seqLen, outCols], { K: inCols });

  const inputNorm = norm(`${prefix}.input_norm`, input(inputName), w('input_layernorm.weight'), H);
  const q = linear(`${prefix}.q_proj`, inputNorm, w('self_attn.q_proj.weight'), QH * D, H);
  const k = linear(`${prefix}.k_proj`, inputNorm, w('self_attn.k_proj.weight'), KVH * D, H);
  const v = linear(`${prefix}.v_proj`, inputNorm, w('self_attn.v_proj.weight'), KVH * D, H);
  const qNorm = norm(`${prefix}.q_norm`, q, w('self_attn.q_norm.weight'), D, QH * D);
  const kNorm = norm(`${prefix}.k_norm`, k, w('self_attn.k_norm.weight'), D, KVH * D);
  const cosName = `rope_cos_${validation.layerType}`;
  const sinName = `rope_sin_${validation.layerType}`;
  const qRope = addNode(nodes, `${prefix}.q_rope`, 'rope_split_half', { x: qNorm, cos: input(cosName), sin: input(sinName) }, [seqLen, QH * D], { head_dim: D });
  const kRope = addNode(nodes, `${prefix}.k_rope`, 'rope_split_half', { x: kNorm, cos: input(cosName), sin: input(sinName) }, [seqLen, KVH * D], { head_dim: D });
  const window = validation.layerType === 'sliding_attention' ? config.slidingWindow : seqLen;
  const attnParams = { seq_len: seqLen, num_heads: QH, num_kv_heads: KVH, head_dim: D, window };
  const scores = addNode(nodes, `${prefix}.attn_scores`, 'attn_scores_sliding', { q: qRope, k: kRope }, [QH * seqLen, seqLen], { ...attnParams, scale: config.attentionScale });
  const probs = addNode(nodes, `${prefix}.attn_probs`, 'softmax_rows', { scores }, [QH * seqLen, seqLen], { seq_len: seqLen, window });
  const attended = addNode(nodes, `${prefix}.attn_value`, 'attn_weighted_sum', { probabilities: probs, value: v }, [seqLen, QH * D], attnParams);
  const projected = linear(`${prefix}.o_proj`, attended, w('self_attn.o_proj.weight'), H, QH * D);
  const postAttention = norm(`${prefix}.post_attention_norm`, projected, w('post_attention_layernorm.weight'), H);
  const attentionResidual = addNode(nodes, `${prefix}.attention_residual`, 'residual_add', { a: input(inputName), b: postAttention }, [seqLen, H]);
  const preFeedForward = norm(`${prefix}.pre_feedforward_norm`, attentionResidual, w('pre_feedforward_layernorm.weight'), H);
  const gate = linear(`${prefix}.gate_proj`, preFeedForward, w('mlp.gate_proj.weight'), I, H);
  const activatedGate = addNode(nodes, `${prefix}.gate_gelu`, 'activation_gelu_tanh', { x: gate }, [seqLen, I]);
  const up = linear(`${prefix}.up_proj`, preFeedForward, w('mlp.up_proj.weight'), I, H);
  const gated = addNode(nodes, `${prefix}.gate_up_mul`, 'elementwise_mul', { a: activatedGate, b: up }, [seqLen, I]);
  const down = linear(`${prefix}.down_proj`, gated, w('mlp.down_proj.weight'), H, I);
  const postFeedForward = norm(`${prefix}.post_feedforward_norm`, down, w('post_feedforward_layernorm.weight'), H);
  const output = addNode(nodes, `${prefix}.output`, 'residual_add', { a: attentionResidual, b: postFeedForward }, [seqLen, H]);
  const tensorNames = new Set();
  for (const node of nodes) for (const ref of Object.values(node.inputs)) if (typeof ref === 'string' && ref.startsWith('$input.')) tensorNames.add(ref.slice(7));
  const inputs = Object.fromEntries([...tensorNames].map((name) => {
    if (name === inputName) return [name, { dims: [seqLen, H] }];
    if (name.startsWith('rope_cos_') || name.startsWith('rope_sin_')) return [name, { dims: [seqLen, D] }];
    const suffix = name.slice(`model.layers.${layerIndex}.`.length);
    const expectedShapes = {
      'input_layernorm.weight': [H],
      'self_attn.q_proj.weight': [QH * D, H],
      'self_attn.k_proj.weight': [KVH * D, H],
      'self_attn.v_proj.weight': [KVH * D, H],
      'self_attn.o_proj.weight': [H, QH * D],
      'self_attn.q_norm.weight': [D],
      'self_attn.k_norm.weight': [D],
      'post_attention_layernorm.weight': [H],
      'pre_feedforward_layernorm.weight': [H],
      'post_feedforward_layernorm.weight': [H],
      'mlp.gate_proj.weight': [I, H],
      'mlp.up_proj.weight': [I, H],
      'mlp.down_proj.weight': [H, I]
    };
    const tensorShape = shape(header, name) ?? expectedShapes[suffix];
    return [name, { dims: tensorShape }];
  }));
  return {
    graph: { inputs, nodes, outputs: { hidden_states: output } },
    metadata: {
      modelType: 'gemma3_text', layerIndex, layerType: validation.layerType,
      seqLen, hiddenSize: H, intermediateSize: I, attentionScale: config.attentionScale,
      attentionWindow: window, ropeTheta: config.ropeTheta[validation.layerType],
      activation: config.activation, nodeCount: nodes.length,
      trainable: false,
      note: 'Forward-only layer DAG. Backward graph construction, token sampling, and optimizer-step orchestration are separate trainer work.'
    }
  };
}

export function buildGemmaForwardGraph({ config: rawConfig, header, layerIndices, seqLen, inputName = 'hidden_states', includeFinalNorm = true }) {
  const config = rawConfig?.hiddenSize ? rawConfig : normalizeGemmaConfig(rawConfig);
  const selected = layerIndices ?? Array.from({ length: config.numLayers }, (_, i) => i);
  if (!Array.isArray(selected) || selected.length === 0 || selected.some((index, i) => !Number.isInteger(index) || index < 0 || index >= config.numLayers || (i > 0 && index !== selected[i - 1] + 1))) {
    throw new Error('layerIndices must be a non-empty, in-range contiguous ascending layer slice.');
  }
  const graphs = selected.map((layerIndex) => buildGemmaLayerForwardGraph({ config, header, layerIndex, seqLen, inputName }));
  const nodes = [];
  const inputs = { [inputName]: { dims: [seqLen, config.hiddenSize] } };
  let hiddenRef = `$input.${inputName}`;
  for (let i = 0; i < graphs.length; i++) {
    const { graph } = graphs[i];
    for (const [name, tensor] of Object.entries(graph.inputs)) {
      if (name !== inputName) {
        const previous = inputs[name];
        if (previous && previous.dims.join('x') !== tensor.dims.join('x')) throw new Error(`Inconsistent graph input shape for ${name}.`);
        inputs[name] = tensor;
      }
    }
    const outputRef = graph.outputs.hidden_states;
    for (const node of graph.nodes) {
      const copied = { ...node, inputs: { ...node.inputs } };
      for (const [key, ref] of Object.entries(copied.inputs)) {
        if (ref === `$input.${inputName}`) copied.inputs[key] = hiddenRef;
      }
      nodes.push(copied);
    }
    hiddenRef = outputRef;
  }
  if (includeFinalNorm) {
    const finalWeight = 'model.norm.weight';
    const expected = [config.hiddenSize];
    if (header && !sameShape(shape(header, finalWeight), expected)) throw new Error(`Safetensors header mismatch for ${finalWeight}: expected [${expected}].`);
    inputs[finalWeight] = { dims: expected };
    const finalId = 'model.final_norm';
    addNode(nodes, finalId, 'rms_norm', { x: hiddenRef, weight: `$input.${finalWeight}` }, [seqLen, config.hiddenSize], { segment_size: config.hiddenSize, epsilon: config.epsilon, centered_weight: true });
    hiddenRef = `$node.${finalId}`;
  }
  return {
    graph: { inputs, nodes, outputs: { hidden_states: hiddenRef } },
    metadata: {
      modelType: 'gemma3_text', layers: selected, seqLen,
      nodeCount: nodes.length, includeFinalNorm,
      activation: config.activation, tieWordEmbeddings: config.tieWordEmbeddings,
      trainable: false,
      note: 'Forward-only graph builder. Input embedding/tokenizer, chunked vocabulary loss, backward DAG, optimizer loop, activation checkpointing, and checkpoint writing are not included.'
    }
  };
}

export function bindGemmaGraphInputs(graph, tensors) {
  if (!graph?.graph?.inputs || !tensors || typeof tensors !== 'object') throw new Error('Expected a built Gemma graph and a tensor map.');
  const missing = Object.keys(graph.graph.inputs).filter((name) => !Object.hasOwn(tensors, name));
  if (missing.length) throw new Error(`Missing Gemma graph inputs: ${missing.join(', ')}`);
  const inputs = {};
  for (const [name, expected] of Object.entries(graph.graph.inputs)) {
    const actual = tensors[name];
    if (!sameShape(actual?.dims, expected.dims)) throw new Error(`Gemma graph input ${name} must have shape [${expected.dims.join(',')}].`);
    if (!actual.data && !(actual.texture && actual.framebuffer && !actual.released)) throw new Error(`Gemma graph input ${name} must contain CPU data or a live resident tensor.`);
    inputs[name] = actual;
  }
  return { ...graph.graph, inputs };
}
