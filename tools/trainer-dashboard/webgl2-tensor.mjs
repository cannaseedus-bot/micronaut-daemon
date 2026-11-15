// WebGL2 tensor storage: texture + framebuffer + host shape metadata.
// WebGL2 readback is performed with readPixels; getTexImage is not available.

export class WebGL2Tensor {
  constructor(gl, shape, data = null, metadata = {}) {
    if (!Array.isArray(shape) || shape.length < 1) {
      throw new Error('WebGL2Tensor shape must contain at least one dimension');
    }
    this.gl = gl;
    this.shape = [...shape];
    const width = shape.length === 1 ? shape[0] : shape[shape.length - 1];
    const elements = shape.reduce((product, dimension) => product * dimension, 1);
    const height = Math.ceil(elements / width);
    this.packedShape = [width, height];
    this.metadata = { dtype: 'f32', role: 'tensor', fold: 'Wo', ...metadata };
    if (!gl.getExtension('EXT_color_buffer_float')) {
      throw new Error('WebGL2 requires EXT_color_buffer_float for f32 render targets');
    }
    this.texture = gl.createTexture();
    this.framebuffer = gl.createFramebuffer();
    if (!this.texture || !this.framebuffer) throw new Error('Unable to allocate WebGL2 tensor');
    gl.bindTexture(gl.TEXTURE_2D, this.texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.R32F, width, height, 0,
      gl.RED, gl.FLOAT, data);
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.framebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, this.texture, 0);
    if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) !== gl.FRAMEBUFFER_COMPLETE) {
      throw new Error('WebGL2 tensor framebuffer is incomplete');
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.bindTexture(gl.TEXTURE_2D, null);
  }

  read() {
    const gl = this.gl;
    const result = new Float32Array(this.packedShape[0] * this.packedShape[1]);
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.framebuffer);
    gl.readPixels(0, 0, this.packedShape[0], this.packedShape[1], gl.RED, gl.FLOAT, result);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    return result;
  }

  getPackedShape() { return [...this.packedShape]; }

  destroy() {
    this.gl.deleteFramebuffer(this.framebuffer);
    this.gl.deleteTexture(this.texture);
  }
}
