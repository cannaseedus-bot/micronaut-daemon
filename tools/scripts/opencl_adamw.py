"""PyTorch optimizer-step adapter calling the installed OpenCL DLL directly.

Forward/backward remain on CPU. Parameters and gradients are transferred to
OpenCL for the fused AdamW update, then updated parameters are copied back.
This avoids requiring a separately compiled PyOpenCL extension.
"""
from __future__ import annotations

import ctypes as ct
import math
from pathlib import Path

import numpy as np


class _OpenCL:
    OK = 0
    CPU = 1 << 1
    ALL = 0xFFFFFFFF
    READ_WRITE = 1 << 0
    BUILD_LOG = 0x1183
    DEVICE_NAME = 0x102B
    DEVICE_VERSION = 0x102F

    def __init__(self, kernel_path: Path):
        if not hasattr(ct, "WinDLL"):
            raise RuntimeError("direct OpenCL adapter currently requires Windows OpenCL.dll")
        try:
            self.dll = ct.WinDLL("OpenCL.dll")
        except OSError as exc:
            raise RuntimeError(f"cannot load system OpenCL.dll: {exc}") from exc
        self._declare_api()
        self.platform, self.device = self._find_device()
        self.name = self._device_string(self.DEVICE_NAME)
        self.version = self._device_string(self.DEVICE_VERSION)
        error = ct.c_int()
        devices = (ct.c_void_p * 1)(self.device)
        self.context = self.dll.clCreateContext(None, 1, devices, None, None, ct.byref(error))
        self._check(error.value, "clCreateContext")
        self.queue = self.dll.clCreateCommandQueue(self.context, self.device, 0, ct.byref(error))
        self._check(error.value, "clCreateCommandQueue")
        source = kernel_path.read_bytes()
        source_ptr = ct.c_char_p(source)
        source_len = ct.c_size_t(len(source))
        self.program = self.dll.clCreateProgramWithSource(
            self.context, 1, ct.byref(source_ptr), ct.byref(source_len), ct.byref(error))
        self._check(error.value, "clCreateProgramWithSource")
        status = self.dll.clBuildProgram(self.program, 1, devices,
                                         b"-cl-std=CL1.2 -cl-opt-disable", None, None)
        if status != self.OK:
            log_size = ct.c_size_t()
            self.dll.clGetProgramBuildInfo(self.program, self.device, self.BUILD_LOG,
                                           0, None, ct.byref(log_size))
            log = ct.create_string_buffer(max(1, log_size.value))
            if log_size.value:
                self.dll.clGetProgramBuildInfo(self.program, self.device, self.BUILD_LOG,
                                               log_size.value, log, None)
            raise RuntimeError(f"clBuildProgram failed ({status}): {log.value.decode(errors='replace')}")
        self.kernel = self.dll.clCreateKernel(self.program, b"adamw_update", ct.byref(error))
        self._check(error.value, "clCreateKernel(adamw_update)")

    def _declare_api(self):
        d = self.dll
        ptr = ct.c_void_p
        u = ct.c_uint
        # OpenCL cl_bitfield/cl_device_type are 64-bit even on Windows LLP64.
        ul = ct.c_uint64
        sz = ct.c_size_t
        d.clGetPlatformIDs.argtypes = [u, ct.POINTER(ptr), ct.POINTER(u)]
        d.clGetPlatformIDs.restype = ct.c_int
        d.clGetDeviceIDs.argtypes = [ptr, ul, u, ct.POINTER(ptr), ct.POINTER(u)]
        d.clGetDeviceIDs.restype = ct.c_int
        d.clGetDeviceInfo.argtypes = [ptr, u, sz, ptr, ct.POINTER(sz)]
        d.clGetDeviceInfo.restype = ct.c_int
        d.clCreateContext.argtypes = [ptr, u, ct.POINTER(ptr), ptr, ptr, ct.POINTER(ct.c_int)]
        d.clCreateContext.restype = ptr
        d.clCreateCommandQueue.argtypes = [ptr, ptr, ul, ct.POINTER(ct.c_int)]
        d.clCreateCommandQueue.restype = ptr
        d.clCreateProgramWithSource.argtypes = [ptr, u, ct.POINTER(ct.c_char_p), ct.POINTER(sz), ct.POINTER(ct.c_int)]
        d.clCreateProgramWithSource.restype = ptr
        d.clBuildProgram.argtypes = [ptr, u, ct.POINTER(ptr), ct.c_char_p, ptr, ptr]
        d.clBuildProgram.restype = ct.c_int
        d.clGetProgramBuildInfo.argtypes = [ptr, ptr, u, sz, ptr, ct.POINTER(sz)]
        d.clGetProgramBuildInfo.restype = ct.c_int
        d.clCreateKernel.argtypes = [ptr, ct.c_char_p, ct.POINTER(ct.c_int)]
        d.clCreateKernel.restype = ptr
        d.clCreateBuffer.argtypes = [ptr, ul, sz, ptr, ct.POINTER(ct.c_int)]
        d.clCreateBuffer.restype = ptr
        d.clSetKernelArg.argtypes = [ptr, u, sz, ptr]
        d.clSetKernelArg.restype = ct.c_int
        d.clEnqueueWriteBuffer.argtypes = [ptr, ptr, u, sz, sz, ptr, u, ptr, ptr]
        d.clEnqueueWriteBuffer.restype = ct.c_int
        d.clEnqueueReadBuffer.argtypes = [ptr, ptr, u, sz, sz, ptr, u, ptr, ptr]
        d.clEnqueueReadBuffer.restype = ct.c_int
        d.clEnqueueNDRangeKernel.argtypes = [ptr, ptr, u, ptr, ct.POINTER(sz), ptr, u, ptr, ptr]
        d.clEnqueueNDRangeKernel.restype = ct.c_int
        d.clFinish.argtypes = [ptr]
        d.clFinish.restype = ct.c_int
        for name in ("clReleaseMemObject", "clReleaseKernel", "clReleaseProgram",
                     "clReleaseCommandQueue", "clReleaseContext"):
            fn = getattr(d, name)
            fn.argtypes = [ptr]
            fn.restype = ct.c_int

    @staticmethod
    def _check(status: int, call: str):
        if status != 0:
            raise RuntimeError(f"{call} failed with OpenCL status {status}")

    def _find_device(self):
        count = ct.c_uint()
        self._check(self.dll.clGetPlatformIDs(0, None, ct.byref(count)), "clGetPlatformIDs(count)")
        if count.value == 0:
            raise RuntimeError("OpenCL reports no platforms")
        platforms = (ct.c_void_p * count.value)()
        self._check(self.dll.clGetPlatformIDs(count.value, platforms, None), "clGetPlatformIDs(list)")
        for device_type in (self.CPU, self.ALL):
            for platform in platforms:
                n = ct.c_uint()
                status = self.dll.clGetDeviceIDs(platform, device_type, 0, None, ct.byref(n))
                if status != self.OK or n.value == 0:
                    continue
                devices = (ct.c_void_p * n.value)()
                status = self.dll.clGetDeviceIDs(platform, device_type, n.value, devices, None)
                if status == self.OK and n.value:
                    return platform, devices[0]
        raise RuntimeError("no OpenCL CPU or compute device is available")

    def _device_string(self, key: int) -> str:
        size = ct.c_size_t()
        self._check(self.dll.clGetDeviceInfo(self.device, key, 0, None, ct.byref(size)),
                    "clGetDeviceInfo(size)")
        value = ct.create_string_buffer(size.value)
        self._check(self.dll.clGetDeviceInfo(self.device, key, size.value, value, None),
                    "clGetDeviceInfo(value)")
        return value.value.decode(errors="replace").strip()

    def buffer(self, byte_count: int):
        error = ct.c_int()
        value = self.dll.clCreateBuffer(self.context, self.READ_WRITE, byte_count, None, ct.byref(error))
        self._check(error.value, "clCreateBuffer")
        return value

    def write(self, buffer, array: np.ndarray):
        self._check(self.dll.clEnqueueWriteBuffer(
            self.queue, buffer, 1, 0, array.nbytes, array.ctypes.data_as(ct.c_void_p), 0, None, None),
            "clEnqueueWriteBuffer")

    def read(self, buffer, array: np.ndarray):
        self._check(self.dll.clEnqueueReadBuffer(
            self.queue, buffer, 1, 0, array.nbytes, array.ctypes.data_as(ct.c_void_p), 0, None, None),
            "clEnqueueReadBuffer")

    def arg(self, index: int, value, size=None):
        if size is None:
            size = ct.sizeof(value)
        self._check(self.dll.clSetKernelArg(self.kernel, index, size, ct.byref(value)),
                    f"clSetKernelArg({index})")

    def close(self):
        for name in ("clReleaseMemObject",):
            for buffer in getattr(self, "buffers", []):
                if buffer:
                    getattr(self.dll, name)(buffer)
        for attr, release in (("kernel", "clReleaseKernel"), ("program", "clReleaseProgram"),
                              ("queue", "clReleaseCommandQueue"), ("context", "clReleaseContext")):
            handle = getattr(self, attr, None)
            if handle:
                getattr(self.dll, release)(handle)


class OpenCLAdamW:
    def __init__(self, parameters, learning_rate: float, *, weight_decay: float = 0.01,
                 beta1: float = 0.9, beta2: float = 0.999, epsilon: float = 1e-8,
                 chunk_elements: int = 4_194_304):
        import torch
        self.parameters = [p for p in parameters if p.requires_grad]
        if not self.parameters or any(p.device.type != "cpu" or p.dtype != torch.float32
                                      for p in self.parameters):
            raise ValueError("OpenCL AdamW currently requires nonempty CPU float32 parameters")
        self.learning_rate = np.float32(learning_rate)
        self.weight_decay = np.float32(weight_decay)
        self.beta1, self.beta2 = np.float32(beta1), np.float32(beta2)
        self.epsilon = np.float32(epsilon)
        if chunk_elements < 1:
            raise ValueError("OpenCL AdamW chunk_elements must be positive")
        self.chunk_elements = int(chunk_elements)
        self.states = {id(p): [np.zeros(p.numel(), np.float32),
                               np.zeros(p.numel(), np.float32)] for p in self.parameters}
        self.step_count = 0
        self.count = sum(p.numel() for p in self.parameters)
        self.runtime = _OpenCL(Path(__file__).with_name("opencl_adamw.cl"))
        self.runtime.buffers = [self.runtime.buffer(min(self.count, self.chunk_elements) * 4)
                                for _ in range(4)]

    def zero_grad(self, set_to_none: bool = True):
        for parameter in self.parameters:
            if parameter.grad is not None:
                if set_to_none:
                    parameter.grad = None
                else:
                    parameter.grad.zero_()

    def step(self):
        import torch
        if any(p.grad is None for p in self.parameters):
            raise RuntimeError("compact OpenCL AdamW path expects a gradient for every model parameter")
        self.step_count += 1
        rt = self.runtime
        scalars = (ct.c_uint(self.count), ct.c_float(self.learning_rate),
                   ct.c_float(self.beta1), ct.c_float(self.beta2), ct.c_float(self.epsilon),
                   ct.c_float(self.weight_decay),
                   ct.c_float(1.0 - math.pow(float(self.beta1), self.step_count)),
                   ct.c_float(1.0 - math.pow(float(self.beta2), self.step_count)))
        for i, scalar in enumerate(scalars[1:], start=5):
            rt.arg(i, scalar)
        for i, buffer in enumerate(rt.buffers):
            rt.arg(i, ct.c_void_p(buffer), ct.sizeof(ct.c_void_p))

        for parameter in self.parameters:
            params = parameter.detach().numpy().reshape(-1)
            grads = parameter.grad.detach().numpy().reshape(-1)
            first, second = self.states[id(parameter)]
            for offset in range(0, parameter.numel(), self.chunk_elements):
                end = min(offset + self.chunk_elements, parameter.numel())
                p_chunk, g_chunk = params[offset:end], grads[offset:end]
                m_chunk, v_chunk = first[offset:end], second[offset:end]
                if not np.isfinite(p_chunk).all() or not np.isfinite(g_chunk).all():
                    raise RuntimeError("OpenCL AdamW received non-finite parameters or gradients")
                for buffer, array in zip(rt.buffers, (p_chunk, g_chunk, m_chunk, v_chunk)):
                    rt.write(buffer, array)
                chunk_count = ct.c_uint(end - offset)
                rt.arg(4, chunk_count)
                global_size = ct.c_size_t(end - offset)
                self._check_status(rt.dll.clEnqueueNDRangeKernel(
                    rt.queue, rt.kernel, 1, None, ct.byref(global_size), None, 0, None, None),
                    "clEnqueueNDRangeKernel(adamw_update)")
                for buffer, array in zip((rt.buffers[0], rt.buffers[2], rt.buffers[3]),
                                         (p_chunk, m_chunk, v_chunk)):
                    rt.read(buffer, array)

    @staticmethod
    def _check_status(status: int, call: str):
        if status != 0:
            raise RuntimeError(f"{call} failed with OpenCL status {status}")

    def metadata(self):
        return {"optimizer_backend": "OpenCL AdamW update; CPU forward/backward",
                "opencl_device": self.runtime.name, "opencl_version": self.runtime.version,
                "optimizer_steps": self.step_count, "parameter_count": self.count,
                "chunk_elements": self.chunk_elements}

    def state_dict(self):
        """Copy the host-side Adam moments into a serializable checkpoint."""
        return {
            "step_count": self.step_count,
            "states": [(self.states[id(p)][0], self.states[id(p)][1])
                       for p in self.parameters],
        }

    def load_state_dict(self, state):
        entries = state.get("states")
        if not isinstance(entries, list) or len(entries) != len(self.parameters):
            raise ValueError("OpenCL AdamW checkpoint parameter count does not match model")
        restored = {}
        for parameter, pair in zip(self.parameters, entries):
            if not isinstance(pair, (list, tuple)) or len(pair) != 2:
                raise ValueError("OpenCL AdamW checkpoint has malformed moment state")
            first, second = (np.asarray(value, dtype=np.float32) for value in pair)
            if first.size != parameter.numel() or second.size != parameter.numel():
                raise ValueError("OpenCL AdamW checkpoint moment shape does not match model")
            restored[id(parameter)] = [first.copy(), second.copy()]
        self.states = restored
        self.step_count = int(state.get("step_count", 0))
        if self.step_count < 0:
            raise ValueError("OpenCL AdamW checkpoint step count is invalid")

    def close(self):
        self.runtime.close()
