# local-llm

Manage local Ollama LLM models for development and testing. Includes comprehensive guidance for running models, optimizing VRAM usage, creating custom Modelfiles, and integrating with applications via the OpenAI-compatible API.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install local-llm@community-claude-plugins
```

## Components

### Skills (Auto-triggered)

| Skill | Triggers |
|-------|----------|
| `local-llm` | "ollama", "local model", "VRAM", "GPU memory", "Modelfile", "quantization" |

### Agents

| Agent | Use Case |
|-------|----------|
| `llm-setup` | "Use the llm-setup agent to configure Ollama for my GPU" |

### Included Templates

Ready-to-use Modelfiles in `skills/local-llm/templates/`:
- `fast-model.Modelfile` - Quick iteration (3-4B models)
- `reasoning-model.Modelfile` - Quality validation with chain-of-thought
- `code-generation.Modelfile` - Code-focused tasks
- `json-output.Modelfile` - Structured data generation
- `analysis.Modelfile` - Analysis and reasoning

## Features

### Two-Tier Model Strategy

| Tier | Purpose | Model Size | Speed | Use Case |
|------|---------|------------|-------|----------|
| **Fast** | Iteration | 3-4B params | 30+ tok/s | Rapid prototyping, CI/CD |
| **Quality** | Validation | 7-14B params | 5-15 tok/s | E2E testing, final QA |

### VRAM Guidelines

| GPU VRAM | Fast Model | Quality Model |
|----------|------------|---------------|
| 4 GB | Qwen2.5 3B Q4 | Phi-3 4B Q4 |
| 6 GB | Qwen2.5 4B Q4 | Llama 3.2 8B Q4 |
| 8 GB | Llama 3.2 3B Q8 | DeepSeek-R1 8B Q4 |
| 12+ GB | Qwen2.5 7B Q4 | Llama 3.1 14B Q4 |

### OpenAI-Compatible API

```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

response = client.chat.completions.create(
    model="your-model-name",
    messages=[{"role": "user", "content": "Hello"}]
)
```

## Quick Commands

```bash
# List models
ollama list

# Run interactively
ollama run model-name

# Check VRAM usage
ollama ps

# Create custom model
ollama create my-model -f Modelfile
```

## Usage Examples

### Set Up Environment
```
Use the llm-setup agent to help me configure Ollama
for my 8GB GPU focused on code generation
```

### Get Help with Ollama
```
How do I create a custom Modelfile for fast code completion?
```

### Troubleshooting
```
My Ollama model is running slowly, help me diagnose the issue
```

## Requirements

- [Ollama](https://ollama.com) installed
- NVIDIA GPU with CUDA (recommended) or CPU-only mode
- Linux, macOS, or Windows with WSL

## License

MIT
