import { WebGL2Executor } from '/.CSS-C/css-ml-runtime/src/runtime/webgl2.js';

const values = [-100, -20, -10, -5, -2, -1, -0.1, 0, 0.1, 1, 2, 5, 10, 20, 100];
const expected = [0, 0, 0, -2.980232238769531e-7, -0.04540228843688965,
  -0.15880799293518066, -0.046017248183488846, 0, 0.053982753306627274,
  0.8411920070648193, 1.9545977115631104, 4.999999523162842, 10, 20, 100];
const grads = [-0.75, -0.6428571343421936, -0.5357142686843872, -0.4285714328289032,
  -0.3214285671710968, -0.2142857313156128, -0.1071428656578064, 0,
  0.1071428656578064, 0.2142857313156128, 0.3214285671710968,
  0.4285714328289032, 0.5357142686843872, 0.6428571343421936, 0.75];
const expectedGrad = [0, 0, 0, 8.618039828434121e-7, 0.027674749493598938,
  0.017778020352125168, -0.04505123943090439, 0, 0.06209162250161171,
  0.23206374049186707, 0.34910333156585693, 0.42857229709625244,
  0.5357142686843872, 0.6428571343421936, 0.75];
const gl = document.querySelector('#gpu').getContext('webgl2', { antialias: false });
if (!gl) throw new Error('WebGL2 context unavailable');
const executor = new WebGL2Executor(gl), x = Float32Array.from(values), grad = Float32Array.from(grads);
const result = await executor.executeGraph({
  inputs: { x: { dims: [1, x.length], data: x }, grad: { dims: [1, grad.length], data: grad } },
  nodes: [
    { id: 'gelu', op: 'activation_gelu_tanh', inputs: { x: '$input.x' }, outputDims: [1, x.length], device: 'webgl2' },
    { id: 'gelu_backward', op: 'activation_gelu_tanh_backward', inputs: { x: '$input.x', grad: '$input.grad' }, outputDims: [1, x.length], device: 'webgl2' }
  ],
  outputs: { y: '$node.gelu', dy: '$node.gelu_backward' }
});
const actual = Array.from(executor.readTensor(result.outputs.y));
const actualGrad = Array.from(executor.readTensor(result.outputs.dy));
const maxAbsError = Math.max(...actual.map((value, i) => Math.abs(value - expected[i])));
const maxGradAbsError = Math.max(...actualGrad.map((value, i) => Math.abs(value - expectedGrad[i])));
const finite = actual.every(Number.isFinite) && actualGrad.every(Number.isFinite);
const ext = gl.getExtension('WEBGL_debug_renderer_info');
const payload = {
  type: 'PCRE2_STATUS', ok: finite && maxAbsError < 1e-6 && maxGradAbsError < 1e-6,
  detail: { ops: ['activation_gelu_tanh', 'activation_gelu_tanh_backward'], inputCount: x.length,
    maxAbsError, maxGradAbsError, finite, renderer: gl.getParameter(gl.RENDERER),
    unmaskedRenderer: ext ? gl.getParameter(ext.UNMASKED_RENDERER_WEBGL) : null }
};
document.querySelector('#status').textContent = JSON.stringify(payload, null, 2);
window.chrome?.webview?.postMessage(JSON.stringify(payload));
result.release();
