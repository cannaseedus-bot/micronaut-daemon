import { WebGL2Executor } from '/.CSS-C/css-ml-runtime/src/runtime/webgl2.js';
import { buildGemmaForwardGraph, bindGemmaGraphInputs, normalizeGemmaConfig } from '../gemma-graph.mjs';

const status = document.querySelector('#status');
const checkpoint = '/build/gemma3-reasoning-opencl-300m-24h/model.safetensors';
const configUrl = '/build/gemma3-reasoning-opencl-300m-24h/config.json';
const setStatus = (value) => { status.textContent = typeof value === 'string' ? value : JSON.stringify(value, null, 2); };
const range = async (start, end) => {
  const response = await fetch(checkpoint, { headers: { Range: `bytes=${start}-${end - 1}` }, cache: 'no-store' });
  if (response.status !== 206) throw new Error(`Range ${start}-${end} returned HTTP ${response.status}`);
  const bytes = new Uint8Array(await response.arrayBuffer());
  if (bytes.length !== end - start) throw new Error(`Range returned ${bytes.length} bytes; expected ${end - start}`);
  return bytes;
};
const decodeF32 = (bytes) => new Float32Array(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength));

try {
  setStatus('Reading config and Safetensors header…');
  const rawConfig = await (await fetch(configUrl, { cache: 'no-store' })).json();
  const config = normalizeGemmaConfig(rawConfig);
  const prefix = await range(0, 8);
  const headerLength = Number(new DataView(prefix.buffer).getBigUint64(0, true));
  const header = JSON.parse(new TextDecoder().decode(await range(8, 8 + headerLength)));
  const dataStart = 8 + headerLength;
  const gl = document.querySelector('#gpu').getContext('webgl2', { antialias: false });
  if (!gl) throw new Error('WebGL2 context unavailable');
  const executor = new WebGL2Executor(gl);
  const built = buildGemmaForwardGraph({ config, header, layerIndices: [0, 1], seqLen: 45 });
  const inputBytes = new Uint8Array(await (await fetch('./input.f32')).arrayBuffer());
  const expectedBytes = new Uint8Array(await (await fetch('./expected.f32')).arrayBuffer());
  const tensors = {
    hidden_states: { dims: [45, config.hiddenSize], data: decodeF32(inputBytes) },
    rope_cos_sliding_attention: { dims: [45, config.headDim], data: new Float32Array(45 * config.headDim) },
    rope_sin_sliding_attention: { dims: [45, config.headDim], data: new Float32Array(45 * config.headDim) },
    rope_cos_full_attention: { dims: [45, config.headDim], data: new Float32Array(45 * config.headDim) },
    rope_sin_full_attention: { dims: [45, config.headDim], data: new Float32Array(45 * config.headDim) }
  };
  for (const type of ['sliding_attention', 'full_attention']) {
    const theta = config.ropeTheta[type], cos = tensors[`rope_cos_${type}`].data, sin = tensors[`rope_sin_${type}`].data;
    for (let row = 0; row < 45; row++) for (let dim = 0; dim < config.headDim; dim++) {
      const freq = dim % (config.headDim / 2);
      const phase = row * Math.pow(theta, -(2 * freq) / config.headDim);
      cos[row * config.headDim + dim] = Math.cos(phase);
      sin[row * config.headDim + dim] = Math.sin(phase);
    }
  }
  const layerWeights = Object.keys(built.graph.inputs).filter((name) => name.startsWith('model.layers.'));
  const requested = [...layerWeights, 'model.norm.weight'];
  for (const name of requested) {
    const descriptor = header[name];
    if (!descriptor || descriptor.dtype !== 'F32') throw new Error(`Expected F32 checkpoint tensor ${name}`);
    const [begin, end] = descriptor.data_offsets;
    const dims = descriptor.shape;
    tensors[name] = { dims, data: decodeF32(await range(dataStart + begin, dataStart + end)) };
  }
  const graph = bindGemmaGraphInputs(built, tensors);
  setStatus('Executing two checkpoint layers on WebGL2…');
  const result = await executor.executeGraph(graph);
  const actual = executor.readTensor(result.outputs.hidden_states);
  const expected = decodeF32(expectedBytes);
  if (actual.length !== expected.length) throw new Error(`Output length mismatch ${actual.length} vs ${expected.length}`);
  let maxAbsError = 0, squareError = 0, maxExpected = 0;
  for (let i = 0; i < actual.length; i++) {
    const d = Math.abs(actual[i] - expected[i]);
    maxAbsError = Math.max(maxAbsError, d);
    squareError += d * d;
    maxExpected = Math.max(maxExpected, Math.abs(expected[i]));
  }
  const detail = {
    layers: [0, 1], layerTypes: config.layerTypes.slice(0, 2), graphNodes: built.metadata.nodeCount,
    maxAbsError, rmse: Math.sqrt(squareError / actual.length), maxExpected,
    webgl2Nodes: result.telemetry.webgl2Nodes, cpuNodes: result.telemetry.cpuNodes,
    readbacks: result.telemetry.readbacks, peakResidentBytes: result.telemetry.peakResidentBytes,
    renderer: gl.getParameter(gl.RENDERER),
    unmaskedRenderer: (() => { const ext = gl.getExtension('WEBGL_debug_renderer_info'); return ext ? gl.getParameter(ext.UNMASKED_RENDERER_WEBGL) : null; })()
  };
  detail.ok = detail.webgl2Nodes === 45 && detail.cpuNodes === 0 && detail.readbacks === 0 && detail.maxAbsError < 5e-4;
  setStatus({ type: 'PCRE2_STATUS', ...detail });
  window.chrome?.webview?.postMessage(JSON.stringify({ type: 'PCRE2_STATUS', ...detail }));
  result.release();
} catch (error) {
  const payload = { type: 'PCRE2_STATUS', ok: false, error: error?.stack || String(error) };
  setStatus(payload);
  window.chrome?.webview?.postMessage(JSON.stringify(payload));
}
