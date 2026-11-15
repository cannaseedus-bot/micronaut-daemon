// WebGL2 KUHUL glyph/opcode dispatcher.
// The registry is the semantic authority; shader files are backend artifacts.

import { WebGL2Tensor } from './webgl2-tensor.mjs';

const HEX = /^0x[0-9a-f]+$/i;

function normalizeOpcode(value) {
  if (typeof value === 'number' && Number.isInteger(value)) return `0x${value.toString(16)}`;
  if (typeof value === 'string' && HEX.test(value)) return value.toLowerCase();
  throw new Error(`Invalid KUHUL opcode: ${String(value)}`);
}

export class WebGL2GlyphDispatcher {
  constructor(gl, registry, options = {}) {
    this.gl = gl;
    this.registry = registry;
    this.entries = registry.glyph_opcodes || {};
    this.baseUrl = options.baseUrl || (typeof location !== 'undefined' ? location.href : 'http://localhost/');
    this.programs = new Map();
    this.vao = gl.createVertexArray();
    if (!this.vao) throw new Error('Unable to allocate WebGL2 vertex array');
  }

  decodeGlyph(record) {
    const raw = typeof record === 'number' || typeof record === 'string' ? { opcode: record } : record;
    if (!raw || typeof raw !== 'object') throw new Error('Glyph record must be an object, number, or hex opcode');
    let key = raw.opcode ?? raw.op ?? raw.id;
    if (key === undefined && raw.glyph) {
      const found = Object.entries(this.entries).find(([, entry]) => entry.glyph === raw.glyph);
      if (!found) throw new Error(`Unknown KUHUL glyph: ${raw.glyph}`);
      key = found[0];
    }
    const opcode = normalizeOpcode(key);
    const entry = this.entries[opcode];
    if (!entry) throw new Error(`WebGL2 opcode is not registered: ${opcode}`);
    const args = raw.args || raw.inputs || [];
    const expected = entry.arity;
    if (expected !== undefined && args.length !== expected) {
      throw new Error(`${entry.glyph} expects ${expected} arguments, received ${args.length}`);
    }
    return { opcode, entry, args, payload: raw.payload ?? null };
  }

  async compile(opcode) {
    const decoded = this.decodeGlyph(opcode);
    if (this.programs.has(decoded.opcode)) return this.programs.get(decoded.opcode);
    if (decoded.entry.status !== 'implemented') throw new Error(`${decoded.opcode} is ${decoded.entry.status}`);
    const [vertexSource, fragmentSource] = await Promise.all([
      fetch(new URL(decoded.entry.vertex, this.baseUrl)).then(r => r.text()),
      fetch(new URL(decoded.entry.fragment, this.baseUrl)).then(r => r.text()),
    ]);
    const gl = this.gl;
    const compile = (type, source) => {
      const shader = gl.createShader(type);
      gl.shaderSource(shader, source); gl.compileShader(shader);
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        throw new Error(`${decoded.opcode} shader error: ${gl.getShaderInfoLog(shader)}`);
      }
      return shader;
    };
    const program = gl.createProgram();
    const vs = compile(gl.VERTEX_SHADER, vertexSource);
    const fs = compile(gl.FRAGMENT_SHADER, fragmentSource);
    gl.attachShader(program, vs); gl.attachShader(program, fs); gl.linkProgram(program);
    gl.deleteShader(vs); gl.deleteShader(fs);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error(`WebGL2 link error: ${gl.getProgramInfoLog(program)}`);
    this.programs.set(decoded.opcode, program);
    return program;
  }

  async dispatch(record, inputs, output, uniforms = {}) {
    const decoded = this.decodeGlyph(record);
    if (!Array.isArray(inputs) || !output) throw new Error('dispatch requires input tensors and an output tensor');
    const program = await this.compile(decoded.opcode);
    const gl = this.gl;
    gl.bindVertexArray(this.vao);
    gl.useProgram(program);
    inputs.forEach((tensor, index) => {
      gl.activeTexture(gl.TEXTURE0 + index);
      gl.bindTexture(gl.TEXTURE_2D, tensor.texture);
      const location = gl.getUniformLocation(program, `u_input_${index}`);
      if (location) gl.uniform1i(location, index);
    });
    const shape = output.getPackedShape ? output.getPackedShape() : output.shape;
    for (const [name, value] of Object.entries({ u_shape: shape, ...uniforms })) {
      const location = gl.getUniformLocation(program, name);
      if (!location) continue;
      if (Array.isArray(value) && value.length === 2) gl.uniform2i(location, value[0], value[1]);
      else if (Number.isInteger(value)) gl.uniform1i(location, value);
      else gl.uniform1f(location, value);
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, output.framebuffer);
    gl.viewport(0, 0, shape[0], shape[1]);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    if (gl.getError() !== gl.NO_ERROR) throw new Error(`WebGL2 dispatch failed for ${decoded.opcode}`);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.bindVertexArray(null); gl.useProgram(null);
    return output;
  }

  dispose() {
    for (const program of this.programs.values()) this.gl.deleteProgram(program);
    this.gl.deleteVertexArray(this.vao);
  }
}

export { WebGL2Tensor };
