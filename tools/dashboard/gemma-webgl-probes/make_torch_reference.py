import json
from pathlib import Path

import torch
import torch.nn.functional as F
from safetensors import safe_open

ROOT = Path(__file__).resolve().parents[3]
CHECKPOINT = ROOT / "build/gemma3-reasoning-opencl-300m-24h"
OUT = Path(__file__).resolve().parent
torch.set_num_threads(1)
config = json.loads((CHECKPOINT / "config.json").read_text(encoding="utf-8"))
seq, hidden = 45, config["hidden_size"]
ids = torch.arange(seq * hidden, dtype=torch.float32).reshape(seq, hidden)
x0 = (torch.sin(ids * 0.013) * 0.1 + torch.cos(ids * 0.007) * 0.05).contiguous()
x0.numpy().tofile(OUT / "input.f32")

def load(name):
    with safe_open(str(CHECKPOINT / "model.safetensors"), framework="pt", device="cpu") as f:
        return f.get_tensor(name).to(torch.float32)

def rms(x, weight):
    x32 = x.float()
    inv = torch.rsqrt(x32.square().mean(dim=-1, keepdim=True) + config["rms_norm_eps"])
    return (x32 * inv * (1.0 + weight.float())).to(x.dtype)

half = config["head_dim"] // 2
positions = torch.arange(seq, dtype=torch.float32)

for layer in range(2):
    p = f"model.layers.{layer}."
    residual = x0
    y = rms(x0, load(p + "input_layernorm.weight"))
    q = F.linear(y, load(p + "self_attn.q_proj.weight"))
    k = F.linear(y, load(p + "self_attn.k_proj.weight"))
    v = F.linear(y, load(p + "self_attn.v_proj.weight"))
    q = q.reshape(seq, config["num_attention_heads"], config["head_dim"])
    k = k.reshape(seq, config["num_key_value_heads"], config["head_dim"])
    v = v.reshape(seq, config["num_key_value_heads"], config["head_dim"])
    q = rms(q, load(p + "self_attn.q_norm.weight"))
    k = rms(k, load(p + "self_attn.k_norm.weight"))

    layer_type = config["layer_types"][layer]
    theta = config["rope_parameters"][layer_type]["rope_theta"]
    inv_freq = 1.0 / (theta ** (torch.arange(0, config["head_dim"], 2, dtype=torch.float32) / config["head_dim"]))
    phase = torch.outer(positions, inv_freq)
    phase = torch.cat((phase, phase), dim=-1)
    cos, sin = phase.cos(), phase.sin()
    q = q * cos[:, None, :] + torch.cat((-q[..., half:], q[..., :half]), dim=-1) * sin[:, None, :]
    k = k * cos[:, None, :] + torch.cat((-k[..., half:], k[..., :half]), dim=-1) * sin[:, None, :]

    result = torch.empty_like(q)
    heads, kv_heads, dim = config["num_attention_heads"], config["num_key_value_heads"], config["head_dim"]
    window = config["sliding_window"] if layer_type == "sliding_attention" else seq
    scale = config["query_pre_attn_scalar"] ** -0.5
    for head in range(heads):
        kv = head // (heads // kv_heads)
        scores = (q[:, head, :] @ k[:, kv, :].T) * scale
        for pos in range(seq):
            scores[pos, :max(0, pos - window + 1)] = -1.0e9
            scores[pos, pos + 1:] = -1.0e9
        probs = torch.softmax(scores, dim=-1)
        result[:, head, :] = probs @ v[:, kv, :]

    y = F.linear(result.reshape(seq, hidden), load(p + "self_attn.o_proj.weight"))
    y = rms(y, load(p + "post_attention_layernorm.weight"))
    x0 = residual + y
    residual = x0
    y = rms(x0, load(p + "pre_feedforward_layernorm.weight"))
    gate = F.linear(y, load(p + "mlp.gate_proj.weight"))
    up = F.linear(y, load(p + "mlp.up_proj.weight"))
    y = F.linear(F.gelu(gate, approximate="tanh") * up, load(p + "mlp.down_proj.weight"))
    y = rms(y, load(p + "post_feedforward_layernorm.weight"))
    x0 = residual + y

expected = rms(x0, load("model.norm.weight")).contiguous()
expected.numpy().tofile(OUT / "expected.f32")
print(json.dumps({"shape": [seq, hidden], "layers": 2, "layerTypes": config["layer_types"][:2], "bytes": expected.numel() * 4}))
