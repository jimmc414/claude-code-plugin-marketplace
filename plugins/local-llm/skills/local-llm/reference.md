# Technical Reference: Local LLM Models

## Popular Model Architectures

### DeepSeek-R1 (Reasoning Models)

**Origin**: DeepSeek distilled chain-of-thought reasoning from their flagship R1 model.

**Architecture** (8B variant):
- Parameters: 8.03 billion
- Architecture: Dense Transformer (Qwen3 base)
- Vocabulary: 151,936 tokens
- Hidden size: 4,096
- Layers: 36
- Attention heads: 32
- Key-value heads: 8 (Grouped Query Attention)

**Reasoning Capability**:
- Full chain-of-thought reasoning with "Thinking..." output
- SOTA performance on AIME 2024 among open-source models
- Excellent for complex multi-step problems

**Recommended Settings**:
```dockerfile
PARAMETER temperature 0.6
PARAMETER top_p 0.95
PARAMETER min_p 0.01
```

### Qwen3 (General Purpose)

**Architecture** (4B variant):
- Parameters: 4.02 billion
- Architecture: Dense Transformer
- Vocabulary: 151,936 tokens
- Hidden size: 2,560
- Layers: 36
- Attention heads: 20
- Key-value heads: 4 (Grouped Query Attention)

**Capabilities**:
- Hybrid thinking/non-thinking modes
- 128K context window (native)
- Strong reasoning for size class
- Fast inference on consumer GPUs

## Ollama API Reference

### Base URL
```
http://localhost:11434
```

### OpenAI-Compatible Endpoints (v1)

#### List Models
```http
GET /v1/models
```

Response:
```json
{
  "object": "list",
  "data": [
    {
      "id": "your-model:latest",
      "object": "model",
      "created": 1764135556,
      "owned_by": "library"
    }
  ]
}
```

#### Chat Completions
```http
POST /v1/chat/completions
Content-Type: application/json

{
  "model": "your-model:latest",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"}
  ],
  "temperature": 0.6,
  "top_p": 0.95,
  "max_tokens": 2048,
  "stream": false
}
```

Response:
```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1764135600,
  "model": "your-model:latest",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Hello! How can I help you today?"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 8,
    "total_tokens": 20
  }
}
```

#### Streaming Chat
```http
POST /v1/chat/completions
Content-Type: application/json

{
  "model": "your-model:latest",
  "messages": [{"role": "user", "content": "Hello"}],
  "stream": true
}
```

### Native Ollama Endpoints

#### Generate (Text Completion)
```http
POST /api/generate
Content-Type: application/json

{
  "model": "your-model",
  "prompt": "Why is the sky blue?",
  "stream": false,
  "options": {
    "temperature": 0.6,
    "top_p": 0.95,
    "num_ctx": 8192
  }
}
```

#### Chat (Native Format)
```http
POST /api/chat
Content-Type: application/json

{
  "model": "your-model",
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "stream": false
}
```

#### Pull Model
```http
POST /api/pull
Content-Type: application/json

{
  "name": "qwen3:4b",
  "stream": false
}
```

#### Show Model Info
```http
POST /api/show
Content-Type: application/json

{
  "name": "your-model"
}
```

#### List Running Models
```http
GET /api/ps
```

#### Delete Model
```http
DELETE /api/delete
Content-Type: application/json

{
  "name": "model-name"
}
```

## Modelfile Parameter Reference

### Complete Parameter List

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `temperature` | float | 0.8 | Controls randomness. 0=deterministic, 2=max random |
| `top_p` | float | 0.9 | Nucleus sampling threshold |
| `top_k` | int | 40 | Limits token selection to top K |
| `min_p` | float | 0.0 | Minimum probability threshold |
| `repeat_penalty` | float | 1.1 | Penalty for repeating tokens |
| `repeat_last_n` | int | 64 | Context window for repeat penalty |
| `num_ctx` | int | 2048 | Context window size |
| `num_predict` | int | -1 | Max tokens to generate (-1=infinite) |
| `num_gpu` | int | -1 | GPU layers (-1=all, 0=CPU only) |
| `num_thread` | int | auto | CPU threads for computation |
| `seed` | int | random | Random seed for reproducibility |
| `stop` | string | - | Stop sequence (can have multiple) |
| `tfs_z` | float | 1.0 | Tail free sampling parameter |
| `mirostat` | int | 0 | Mirostat sampling (0=off, 1=v1, 2=v2) |
| `mirostat_tau` | float | 5.0 | Mirostat target entropy |
| `mirostat_eta` | float | 0.1 | Mirostat learning rate |

### Context Window vs VRAM

**Example System (6GB GPU)**:

| Context Size | VRAM (8B model) | VRAM (4B model) |
|--------------|-----------------|-----------------|
| 2048 | ~4.8 GB | ~2.4 GB |
| 4096 | ~5.2 GB | ~2.6 GB |
| 8192 | ~5.8 GB | ~3.0 GB |
| 16384 | OOM | ~3.8 GB |

**Formula**: VRAM ≈ Model Size + (Context × 2MB per 1K tokens)

## Quantization Reference

### GGUF Quantization Types

| Type | Bits/Weight | Quality | Speed | Size (8B) |
|------|-------------|---------|-------|-----------|
| Q2_K | 2.5 | Poor | Fastest | ~2.5 GB |
| Q3_K_S | 3.0 | Low | Fast | ~3.0 GB |
| Q3_K_M | 3.5 | Fair | Fast | ~3.5 GB |
| Q4_K_S | 4.0 | Good | Medium | ~4.2 GB |
| **Q4_K_M** | **4.5** | **Good** | **Medium** | **~5.0 GB** |
| Q5_K_S | 5.0 | Better | Slower | ~5.5 GB |
| Q5_K_M | 5.5 | Better | Slower | ~6.0 GB |
| Q6_K | 6.0 | Best | Slow | ~6.5 GB |
| Q8_0 | 8.0 | Near-FP16 | Slowest | ~8.5 GB |

**Recommendation**: Q4_K_M provides the best balance of quality and size.

### Quantization Size Formula

```
Size (GB) ≈ Parameters (B) × Bits / 8
Example: 8B model at Q4 ≈ 8 × 4.5 / 8 ≈ 4.5 GB
```

## GPU Memory Management

### NVIDIA Commands

```bash
# Check GPU status
nvidia-smi

# Continuous monitoring
watch -n 1 nvidia-smi

# Check CUDA version
nvcc --version

# List GPU processes
nvidia-smi --query-compute-apps=pid,name,used_memory --format=csv
```

### Ollama Memory Behavior

- Models are loaded on first use
- Stay resident until explicitly unloaded or timeout
- Default keepalive: 5 minutes of inactivity
- VRAM-constrained systems: only one model active at a time

### Force Unload

```bash
# Unload specific model
ollama stop model-name

# Restart service (clears all)
sudo systemctl restart ollama
```

## Benchmark Reference

### Example System (GTX 1660 Ti 6GB, i7-10700, 62GB RAM)

| Model | Prompt Eval | Generation | Total (500 tok) |
|-------|-------------|------------|-----------------|
| Qwen3 4B (Q4) | 184 tok/s | 34 tok/s | ~17 sec |
| DeepSeek-R1 8B (Q4) | 102 tok/s | 6.4 tok/s | ~83 sec |

### Expected Ranges by Hardware

| GPU | VRAM | 4B Model | 8B Model |
|-----|------|----------|----------|
| RTX 4090 | 24GB | ~120 tok/s | ~80 tok/s |
| RTX 3080 | 10GB | ~60 tok/s | ~40 tok/s |
| RTX 3060 | 12GB | ~45 tok/s | ~30 tok/s |
| GTX 1660 Ti | 6GB | ~34 tok/s | ~6-7 tok/s |
| M2 MacBook | 16GB | ~40 tok/s | ~25 tok/s |
| M3 Max | 36GB | ~60 tok/s | ~45 tok/s |

*Note: Reasoning models (R1, thinking mode) are slower due to chain-of-thought generation.*

## Error Codes

| Error | Cause | Solution |
|-------|-------|----------|
| `model not found` | Model not downloaded | `ollama pull model-name` |
| `CUDA out of memory` | Model too large | Use smaller model or unload others |
| `context length exceeded` | Input too long | Reduce input or increase num_ctx |
| `connection refused` | Ollama not running | `ollama serve` or restart service |
| `rate limit exceeded` | Too many requests | Add delays between requests |

## Useful Model Sources

| Source | Format | Pull Command |
|--------|--------|--------------|
| Ollama Library | Native | `ollama pull model:tag` |
| Hugging Face | GGUF | `ollama pull hf.co/user/model-GGUF:quant` |
| Unsloth | GGUF | `ollama pull hf.co/unsloth/model-GGUF:quant` |

### Popular Models for Local Use

| Model | Size | Best For |
|-------|------|----------|
| `qwen3:4b` | 2.5 GB | Fast iteration |
| `qwen3:8b` | 5.2 GB | Balanced |
| `llama3.1:8b` | 4.9 GB | General purpose |
| `deepseek-r1:8b` | 5.0 GB | Complex reasoning |
| `codestral:22b` | 13 GB | Code generation |
| `phi4:14b` | 9 GB | Reasoning (small) |
