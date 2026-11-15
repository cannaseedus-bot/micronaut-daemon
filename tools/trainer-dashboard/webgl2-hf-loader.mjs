// Browser-native Hugging Face safetensors -> WebGL2 R32F texture loader.
// The loader preserves logical HF shapes and stores a row-major 2D packing.

import { WebGL2Tensor } from './webgl2-tensor.mjs';

const DTYPE_SIZE = { F32: 4, F16: 2, I32: 4 };

function product(shape) { return shape.reduce((a, b) => a * b, 1); }

function halfToFloat(value) {
  const sign = (value & 0x8000) ? -1 : 1;
  const exponent = (value >>> 10) & 0x1f;
  const fraction = value & 0x3ff;
  if (exponent === 0) return sign * Math.pow(2, -14) * (fraction / 1024);
  if (exponent === 0x1f) return fraction ? NaN : sign * Infinity;
  return sign * Math.pow(2, exponent - 15) * (1 + fraction / 1024);
}

function decodeTensor(dtype, bytes) {
  const view = new DataView(bytes);
  if (!(dtype in DTYPE_SIZE)) throw new Error(`Unsupported safetensors dtype: ${dtype}`);
  const count = bytes.byteLength / DTYPE_SIZE[dtype];
  if (dtype === 'F32') return new Float32Array(bytes.slice(0));
  const output = new Float32Array(count);
  for (let i = 0; i < count; i++) {
    if (dtype === 'F16') output[i] = halfToFloat(view.getUint16(i * 2, true));
    else output[i] = view.getInt32(i * 4, true);
  }
  return output;
}

export class HuggingFaceWebGL2Loader {
  constructor(gl, options = {}) {
    this.gl = gl;
    this.baseUrl = options.baseUrl || (typeof location !== 'undefined' ? location.href : 'http://localhost/');
    this.tensors = new Map();
    this.metadata = new Map();
    this.fileHeaders = new Map();
  }

  async #readRange(url, start, endExclusive, rangeReader) {
    if (typeof rangeReader === 'function') {
      const bytes = await rangeReader(url, start, endExclusive);
      const view = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
      if (view.byteLength !== endExclusive - start) throw new Error(`Range reader returned ${view.byteLength} bytes; expected ${endExclusive - start}`);
      return view.buffer.slice(view.byteOffset, view.byteOffset + view.byteLength);
    }
    const response = await fetch(url, { headers: { Range: `bytes=${start}-${endExclusive - 1}` }, cache: 'no-store' });
    if (response.status !== 206) {
      await response.body?.cancel();
      throw new Error(`Safetensors source must support byte ranges (received HTTP ${response.status} for bytes ${start}-${endExclusive - 1})`);
    }
    const contentRange = response.headers.get('content-range');
    if (contentRange && !contentRange.startsWith(`bytes ${start}-${endExclusive - 1}/`)) {
      await response.body?.cancel();
      throw new Error(`Safetensors server returned unexpected Content-Range: ${contentRange}`);
    }
    const buffer = await response.arrayBuffer();
    if (buffer.byteLength !== endExclusive - start) throw new Error(`Safetensors range returned ${buffer.byteLength} bytes; expected ${endExclusive - start}`);
    return buffer;
  }

  async openSafetensors(url, options = {}) {
    const resolvedUrl = new URL(url, this.baseUrl).href;
    if (this.fileHeaders.has(resolvedUrl)) return this.fileHeaders.get(resolvedUrl);
    const pending = (async () => {
      const prefix = await this.#readRange(resolvedUrl, 0, 8, options.rangeReader);
      const headerLength = Number(new DataView(prefix).getBigUint64(0, true));
      if (!Number.isSafeInteger(headerLength) || headerLength < 2 || headerLength > (options.maxHeaderBytes ?? 16 * 1024 * 1024)) {
        throw new Error(`Invalid safetensors header length: ${headerLength}`);
      }
      const headerBuffer = await this.#readRange(resolvedUrl, 8, 8 + headerLength, options.rangeReader);
      const header = JSON.parse(new TextDecoder().decode(headerBuffer));
      return { url: resolvedUrl, dataStart: 8 + headerLength, header };
    })();
    this.fileHeaders.set(resolvedUrl, pending);
    try { return await pending; }
    catch (error) { this.fileHeaders.delete(resolvedUrl); throw error; }
  }

  async readTensorRows(url, name, rowStart, rowCount, options = {}) {
    const file = await this.openSafetensors(url, options);
    const descriptor = file.header[name];
    if (!descriptor) throw new Error(`Safetensors tensor not found: ${name}`);
    if (descriptor.shape.length !== 2 || !Number.isInteger(rowStart) || rowStart < 0 || !Number.isInteger(rowCount) || rowCount < 1 || rowStart + rowCount > descriptor.shape[0]) {
      throw new Error(`Invalid row slice ${rowStart}+${rowCount} for ${name} shape [${descriptor.shape.join(',')}]`);
    }
    const dtypeBytes = DTYPE_SIZE[descriptor.dtype];
    if (!dtypeBytes) throw new Error(`Unsupported safetensors dtype: ${descriptor.dtype}`);
    const rowElements = product(descriptor.shape.slice(1));
    const rowBytes = rowElements * dtypeBytes;
    const start = file.dataStart + descriptor.data_offsets[0] + rowStart * rowBytes;
    const buffer = await this.#readRange(file.url, start, start + rowCount * rowBytes, options.rangeReader);
    const data = decodeTensor(descriptor.dtype, buffer);
    return { dims: [rowCount, ...descriptor.shape.slice(1)], data, rowStart, totalRows: descriptor.shape[0], dtype: descriptor.dtype };
  }

  async loadTensorRows(url, name, rowStart, rowCount, options = {}) {
    const slice = await this.readTensorRows(url, name, rowStart, rowCount, options);
    const maxTextureSize = this.gl.getParameter(this.gl.MAX_TEXTURE_SIZE);
    if (slice.dims.some((dimension) => dimension > maxTextureSize)) {
      throw new Error(`Safetensors row slice ${name}[${rowStart}:${rowStart + rowCount}] exceeds MAX_TEXTURE_SIZE ${maxTextureSize}; lower the chunk row count.`);
    }
    const tensor = new WebGL2Tensor(this.gl, slice.dims, slice.data, {
      dtype: slice.dtype.toLowerCase(), role: options.role || 'weight',
      name, rowStart: slice.rowStart, totalRows: slice.totalRows, fold: options.fold || 'Wo'
    });
    return tensor;
  }

  async * iterateTensorRows(url, name, options = {}) {
    const file = await this.openSafetensors(url, options);
    const descriptor = file.header[name];
    if (!descriptor || descriptor.shape.length !== 2) throw new Error(`A rank-2 safetensors tensor is required: ${name}`);
    const maxRows = this.gl.getParameter(this.gl.MAX_TEXTURE_SIZE);
    const chunkRows = options.chunkRows ?? Math.min(4096, maxRows);
    if (!Number.isInteger(chunkRows) || chunkRows < 1 || chunkRows > maxRows) throw new Error(`chunkRows must be between 1 and MAX_TEXTURE_SIZE (${maxRows})`);
    for (let rowStart = 0; rowStart < descriptor.shape[0]; rowStart += chunkRows) {
      yield await this.loadTensorRows(url, name, rowStart, Math.min(chunkRows, descriptor.shape[0] - rowStart), options);
    }
  }

  async loadSafetensors(url, options = {}) {
    const response = await fetch(new URL(url, this.baseUrl));
    if (!response.ok) throw new Error(`Unable to fetch safetensors: ${response.status} ${url}`);
    const buffer = await response.arrayBuffer();
    if (buffer.byteLength < 8) throw new Error('Safetensors file is truncated');
    const view = new DataView(buffer);
    const headerLength = Number(view.getBigUint64(0, true));
    const headerStart = 8, dataStart = headerStart + headerLength;
    if (dataStart > buffer.byteLength) throw new Error('Safetensors header exceeds file size');
    const header = JSON.parse(new TextDecoder().decode(buffer.slice(headerStart, dataStart)));
    for (const [name, descriptor] of Object.entries(header)) {
      if (name === '__metadata__') continue;
      const [start, end] = descriptor.data_offsets;
      const bytes = buffer.slice(dataStart + start, dataStart + end);
      const values = decodeTensor(descriptor.dtype, bytes);
      const expected = product(descriptor.shape);
      if (values.length !== expected) throw new Error(`Tensor size mismatch: ${name}`);
      if (values.length > this.gl.getParameter(this.gl.MAX_TEXTURE_SIZE) ** 2) {
        throw new Error(`Tensor exceeds one WebGL2 texture: ${name}`);
      }
      const tensor = new WebGL2Tensor(this.gl, descriptor.shape, values, {
        dtype: descriptor.dtype.toLowerCase(), role: options.role || 'weight',
        name, fold: options.fold || 'Wo'
      });
      this.tensors.set(name, tensor);
      this.metadata.set(name, descriptor);
    }
    return this.tensors;
  }

  get(name) {
    const tensor = this.tensors.get(name);
    if (!tensor) throw new Error(`HF tensor is not loaded: ${name}`);
    return tensor;
  }

  alias(source, target) {
    this.tensors.set(target, this.get(source));
    this.metadata.set(target, this.metadata.get(source));
  }

  mapModelAliases(modelType) {
    const aliases = {
      llama: {
        'model.embed_tokens.weight': 'embed_tokens',
        'model.layers.0.self_attn.q_proj.weight': 'q_proj',
        'model.layers.0.self_attn.k_proj.weight': 'k_proj',
        'model.layers.0.self_attn.v_proj.weight': 'v_proj',
        'model.layers.0.self_attn.o_proj.weight': 'o_proj',
        'model.layers.0.mlp.gate_proj.weight': 'gate_proj',
        'model.layers.0.mlp.up_proj.weight': 'up_proj',
        'model.layers.0.mlp.down_proj.weight': 'down_proj'
      },
      gpt2: { 'transformer.wte.weight': 'wte', 'transformer.wpe.weight': 'wpe' },
      bert: { 'bert.embeddings.word_embeddings.weight': 'word_embeddings' }
    }[modelType] || {};
    for (const [source, target] of Object.entries(aliases)) {
      if (this.tensors.has(source)) this.alias(source, target);
    }
  }
}
