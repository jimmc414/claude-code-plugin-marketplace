---
name: local-llm
description: "Manage local Ollama LLM models for development and testing. Use when: running local models, configuring Ollama, switching between fast/quality models, optimizing VRAM usage, troubleshooting model performance, creating Modelfiles, or integrating local LLMs with applications via OpenAI-compatible API. Triggers: ollama, local model, local LLM, VRAM, GPU memory, model speed, inference, Modelfile, llama.cpp, quantization."
---

# Local LLM Management

This skill provides comprehensive guidance for managing local LLM models via Ollama for development, testing, and production use.

## Overview

Ollama provides a simple way to run large language models locally with:
- Easy model management (pull, run, stop)
- OpenAI-compatible API at `http://localhost:11434/v1`
- GPU acceleration with automatic VRAM management
- Custom model creation via Modelfiles

## Two-Tier Model Strategy

For efficient development workflows, use a two-tier approach:

| Tier | Purpose | Model Size | Speed | Use Case |
|------|---------|------------|-------|----------|
| **Fast** | Iteration | 3-4B params | 30+ tok/s | Sanity tests, CI/CD, rapid prototyping |
| **Quality** | Validation | 7-14B params | 5-15 tok/s | E2E testing, complex reasoning, final QA |

### Recommended Model Combinations

| GPU VRAM | Fast Model | Quality Model |
|----------|------------|---------------|
| 4 GB | Qwen2.5 3B Q4 | Phi-3 4B Q4 |
| 6 GB | Qwen2.5 4B Q4 | Llama 3.2 8B Q4 |
| 8 GB | Llama 3.2 3B Q8 | DeepSeek-R1 8B Q4 |
| 12+ GB | Qwen2.5 7B Q4 | Llama 3.1 14B Q4 |

*Create custom models using the templates in `templates/` directory.*

## Quick Reference Commands

### Running Models

```bash
# Interactive chat
ollama run <model-name>

# Single prompt (non-interactive)
echo "Your prompt" | ollama run <model-name>

# With verbose output (shows speed metrics)
echo "Your prompt" | ollama run <model-name> --verbose
```

### Model Management

```bash
# List all models
ollama list

# Check currently loaded models (VRAM usage)
ollama ps

# Unload model to free VRAM
ollama stop <model-name>

# View model details
ollama show <model-name>

# View Modelfile configuration
ollama show <model-name> --modelfile

# Delete a model
ollama rm <model-name>

# Pull/update a model
ollama pull <model-name>
```

### Service Management

```bash
# Check Ollama service status
systemctl status ollama

# Restart Ollama service
sudo systemctl restart ollama

# View Ollama logs
journalctl -u ollama -f

# Manual start (if service not running)
ollama serve
```

## OpenAI-Compatible API

Ollama provides an OpenAI-compatible API at `http://localhost:11434/v1`.

### Python Integration

```python
import openai

# Configure client for local Ollama
client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"  # Required but not validated locally
)

# Chat completion
response = client.chat.completions.create(
    model="your-model-name",
    messages=[{"role": "user", "content": "Your prompt"}],
    temperature=0.6
)
print(response.choices[0].message.content)
```

### Environment Variables

```bash
# Standard configuration
export OLLAMA_HOST=http://localhost:11434
export OPENAI_API_BASE=http://localhost:11434/v1
export OPENAI_API_KEY=ollama
export OPENAI_MODEL=your-model-name
```

### cURL Examples

```bash
# Test API availability
curl http://localhost:11434/v1/models

# Chat completion
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "your-model-name",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

## Creating Custom Models

Custom models are created using Modelfiles. See `templates/` for ready-to-use templates.

### Modelfile Structure

```dockerfile
# Base model
FROM model-name:tag

# Parameters
PARAMETER temperature 0.6
PARAMETER top_p 0.95
PARAMETER num_ctx 8192
PARAMETER repeat_penalty 1.1

# System prompt
SYSTEM """Your system prompt here"""

# Stop sequences
PARAMETER stop "<|end|>"
```

### Create Model from Modelfile

```bash
ollama create my-model -f /path/to/Modelfile
```

### Key Parameters

| Parameter | Description | Default | Recommended Range |
|-----------|-------------|---------|-------------------|
| `temperature` | Randomness (0=deterministic) | 0.8 | 0.3-0.7 for code, 0.6-0.8 for chat |
| `top_p` | Nucleus sampling | 0.9 | 0.9-0.95 |
| `top_k` | Token selection pool | 40 | 20-100 |
| `num_ctx` | Context window | 2048 | 4096-8192 (VRAM dependent) |
| `repeat_penalty` | Reduce repetition | 1.1 | 1.0-1.2 |
| `num_gpu` | GPU layers (-1=all) | -1 | -1 for full GPU |

## Performance Optimization

### VRAM Guidelines

| GPU VRAM | Max Model (Q4) | Recommended Context |
|----------|----------------|---------------------|
| 4 GB | 3-4B | 2048-4096 |
| 6 GB | 7-8B | 4096-8192 |
| 8 GB | 13B | 8192 |
| 12 GB | 20-30B | 8192-16384 |
| 24 GB | 70B | 16384-32768 |

### Speed vs Quality Trade-offs

| Adjustment | Speed Impact | Quality Impact |
|------------|--------------|----------------|
| Smaller model (4B vs 8B) | +3-5x faster | Lower reasoning |
| Lower quantization (Q4 vs Q8) | +20% faster | Slight quality loss |
| Smaller context (4K vs 8K) | +15% faster | Less context awareness |
| Disable thinking mode | +40% faster | No chain-of-thought |

## Troubleshooting

### Common Issues

**Model won't load / CUDA out of memory**
```bash
ollama stop --all
sudo systemctl restart ollama
```

**Slow generation speed**
- Check `nvidia-smi` for GPU utilization
- Ensure model fits in VRAM (`ollama ps`)
- Use smaller model or higher quantization

**API connection refused**
```bash
curl http://localhost:11434/api/tags
ollama serve  # Start if needed
```

**Model not found**
```bash
ollama list
ollama pull model-name
```

### Performance Diagnostics

```bash
# Test with verbose output
echo "test" | ollama run model-name --verbose 2>&1 | grep -E "(eval rate|total duration)"

# Monitor GPU during inference
watch -n 1 nvidia-smi
```

## Recommended Workflow

1. **Development**: Use fast model (4B) for rapid iteration
2. **Pre-commit**: Run sanity tests with fast model
3. **CI/CD**: Use fast model for pipeline tests
4. **Validation**: Run full tests with quality model (overnight if needed)
5. **Release**: Final validation with reasoning model

## File Locations

| Item | Path |
|------|------|
| Ollama binary | `/usr/local/bin/ollama` |
| Model storage | `~/.ollama/models/` |
| Service config | `/etc/systemd/system/ollama.service` |
| Custom Modelfiles | `$HOME/` or project directory |

## Available Templates

See the `templates/` directory for ready-to-use Modelfiles:
- `fast-model.Modelfile` - Quick iteration (4B base)
- `reasoning-model.Modelfile` - Quality validation (8B reasoning)
- `code-generation.Modelfile` - Code-focused tasks
- `json-output.Modelfile` - Structured data generation
- `analysis.Modelfile` - Scientific analysis and reasoning
