# Local LLM Cheatsheet

Quick reference for managing local models with Ollama.

---

## Commands

| Action | Command |
|--------|---------|
| Run model (interactive) | `ollama run <model>` |
| Run model (single prompt) | `echo "prompt" \| ollama run <model>` |
| List all models | `ollama list` |
| Check loaded models | `ollama ps` |
| Stop/unload model | `ollama stop <model>` |
| Pull new model | `ollama pull <model>` |
| Delete model | `ollama rm <model>` |
| Show model info | `ollama show <model>` |
| Show Modelfile | `ollama show <model> --modelfile` |
| Create custom model | `ollama create <name> -f Modelfile` |

---

## API Endpoints

**Base URL**: `http://localhost:11434`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/models` | GET | List models |
| `/v1/chat/completions` | POST | Chat (OpenAI-compatible) |
| `/api/generate` | POST | Text completion (native) |
| `/api/tags` | GET | List models (native) |
| `/api/ps` | GET | Running models |

### Quick Test
```bash
curl http://localhost:11434/v1/models
```

### Chat Request
```bash
curl -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"MODEL","messages":[{"role":"user","content":"Hello"}]}'
```

---

## Key Parameters

| Param | Default | Range | Purpose |
|-------|---------|-------|---------|
| `temperature` | 0.8 | 0-2 | Randomness (lower=deterministic) |
| `top_p` | 0.9 | 0-1 | Nucleus sampling threshold |
| `top_k` | 40 | 1-100 | Token selection pool size |
| `num_ctx` | 2048 | 512-128K | Context window (tokens) |
| `repeat_penalty` | 1.1 | 1.0-2.0 | Repetition reduction |
| `num_gpu` | -1 | -1 to N | GPU layers (-1=all) |

### Recommended Settings
- **Code**: `temperature=0.3, top_p=0.9`
- **Chat**: `temperature=0.7, top_p=0.9`
- **Reasoning**: `temperature=0.6, top_p=0.95`
- **JSON output**: `temperature=0.2, repeat_penalty=1.3`

---

## Model Selection Guide

| Need | Model Type | Size | Speed* |
|------|------------|------|--------|
| Fast iteration | Qwen3, Phi-4, Gemma3 | 3-4B | 30-50 tok/s |
| Balanced | Llama3.1, Qwen3 | 7-8B | 10-20 tok/s |
| Complex reasoning | DeepSeek-R1, Qwen3-thinking | 8B+ | 5-10 tok/s |
| Code generation | Qwen3-coder, CodeLlama | 7-14B | 10-15 tok/s |

*Speed varies by GPU. Values shown for mid-range GPU (6-8GB VRAM).

---

## VRAM Requirements (Q4 Quantization)

| Model Size | VRAM Needed | Max Context |
|------------|-------------|-------------|
| 3B | ~2 GB | 8K |
| 7B | ~4 GB | 8K |
| 8B | ~5 GB | 8K |
| 13B | ~8 GB | 8K |
| 14B | ~9 GB | 8K |
| 32B | ~20 GB | 16K |
| 70B | ~40 GB | 16K |

---

## Modelfile Template

```dockerfile
FROM base-model:tag

PARAMETER temperature 0.6
PARAMETER top_p 0.95
PARAMETER num_ctx 8192
PARAMETER repeat_penalty 1.1

SYSTEM """Your system prompt here"""
```

Create: `ollama create my-model -f Modelfile`

---

## Python Quick Start

```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

response = client.chat.completions.create(
    model="your-model",
    messages=[{"role": "user", "content": "Hello"}]
)
print(response.choices[0].message.content)
```

---

## Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `OLLAMA_HOST` | API endpoint | `http://localhost:11434` |
| `OLLAMA_MODELS` | Model storage path | `~/.ollama/models` |
| `OLLAMA_NUM_PARALLEL` | Concurrent requests | `4` |
| `OLLAMA_MAX_LOADED_MODELS` | Models in memory | `1` |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| CUDA out of memory | `ollama stop <model>` → use smaller model |
| Connection refused | `ollama serve` or `sudo systemctl start ollama` |
| Model not found | `ollama pull <model>` |
| Slow generation | Check `nvidia-smi`, reduce `num_ctx` |
| Repetitive output | Increase `repeat_penalty` to 1.2-1.3 |
| Model loading slow | First load caches; subsequent loads faster |

### Quick Diagnostics
```bash
# Check GPU
nvidia-smi

# Check service
systemctl status ollama

# Test connection
curl localhost:11434/api/tags

# Verbose inference
echo "test" | ollama run model --verbose
```

---

## Service Management

```bash
# Start
sudo systemctl start ollama

# Stop
sudo systemctl stop ollama

# Restart
sudo systemctl restart ollama

# Enable on boot
sudo systemctl enable ollama

# View logs
journalctl -u ollama -f
```

---

## Useful Model Sources

| Source | URL | Notes |
|--------|-----|-------|
| Ollama Library | `ollama.com/library` | Official curated models |
| Hugging Face | `hf.co/` prefix | GGUF models via `ollama pull` |
| Unsloth | `unsloth/` on HF | Optimized quantizations |

### Pull from Hugging Face
```bash
ollama pull hf.co/username/model-name-GGUF:Q4_K_M
```

---

*Generated for local-llm skill | See full docs in ~/.claude/skills/local-llm/*
