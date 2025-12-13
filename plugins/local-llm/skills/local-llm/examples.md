# Usage Examples: Local LLM

Practical code examples for working with local Ollama models.

## Configuration

Set these environment variables for the examples (or modify inline):

```bash
export FAST_MODEL="qwen3:4b"           # Your fast model
export QUALITY_MODEL="deepseek-r1:8b"  # Your quality/reasoning model
export OLLAMA_HOST="http://localhost:11434"
```

---

## Example 1: Quick Sanity Test

Verify your local model setup is working.

```bash
# Check Ollama is running
curl -s http://localhost:11434/api/tags | python3 -m json.tool

# Quick test with your fast model
echo "What is 2+2? Answer with just the number." | ollama run $FAST_MODEL

# Quick test with your quality model
echo "What is 2+2? Answer with just the number." | ollama run $QUALITY_MODEL
```

---

## Example 2: Python Client Setup

Basic Python integration with environment-based model selection.

```python
import os
import openai

# Configuration from environment
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
FAST_MODEL = os.getenv("FAST_MODEL", "qwen3:4b")
QUALITY_MODEL = os.getenv("QUALITY_MODEL", "deepseek-r1:8b")

def get_client():
    """Get configured OpenAI client for Ollama."""
    return openai.OpenAI(
        base_url=f"{OLLAMA_HOST}/v1",
        api_key="ollama"
    )

def complete(prompt: str, model: str = None, temperature: float = 0.7) -> str:
    """Get completion from local model."""
    client = get_client()
    model = model or FAST_MODEL

    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=temperature
    )
    return response.choices[0].message.content

# Usage
result = complete("Explain quantum computing in one sentence.")
print(result)
```

---

## Example 3: Two-Tier Testing

Use fast model for iteration, quality model for validation.

```python
import os
import time
import openai

FAST_MODEL = os.getenv("FAST_MODEL", "qwen3:4b")
QUALITY_MODEL = os.getenv("QUALITY_MODEL", "deepseek-r1:8b")

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

def run_with_model(prompt: str, model: str):
    """Run prompt with specified model and return result with timing."""
    start = time.time()
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.6
    )
    elapsed = time.time() - start
    return {
        "model": model,
        "content": response.choices[0].message.content,
        "time": elapsed,
        "tokens": response.usage.completion_tokens
    }

# Test prompt
prompt = "Write a Python function to check if a string is a palindrome."

# Fast iteration
print("Fast model:")
fast_result = run_with_model(prompt, FAST_MODEL)
print(f"  Time: {fast_result['time']:.1f}s")
print(f"  Tokens: {fast_result['tokens']}")

# Quality validation
print("\nQuality model:")
quality_result = run_with_model(prompt, QUALITY_MODEL)
print(f"  Time: {quality_result['time']:.1f}s")
print(f"  Tokens: {quality_result['tokens']}")
```

---

## Example 4: Batch Processing

Process multiple prompts efficiently.

```python
import os
import openai
from typing import List, Dict

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

def batch_process(prompts: List[str], model: str) -> List[Dict]:
    """Process a batch of prompts sequentially."""
    results = []
    for i, prompt in enumerate(prompts):
        print(f"Processing {i+1}/{len(prompts)}...")
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.6
        )
        results.append({
            "prompt": prompt[:50] + "...",
            "response": response.choices[0].message.content,
            "tokens": response.usage.total_tokens
        })
    return results

# Example usage
prompts = [
    "What is machine learning?",
    "Explain neural networks briefly.",
    "What is gradient descent?",
]

results = batch_process(prompts, os.getenv("FAST_MODEL", "qwen3:4b"))
for r in results:
    print(f"\n{r['prompt']}")
    print(f"Tokens: {r['tokens']}")
```

---

## Example 5: Streaming Responses

Handle long-running generation with streaming.

```python
import os
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

def stream_response(prompt: str, model: str = None):
    """Stream response for real-time output."""
    model = model or os.getenv("QUALITY_MODEL", "deepseek-r1:8b")

    print(f"Generating with {model}...\n")
    print("-" * 50)

    stream = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.6,
        stream=True
    )

    full_response = ""
    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            print(content, end="", flush=True)
            full_response += content

    print("\n" + "-" * 50)
    return full_response

# Usage
response = stream_response("Write a short poem about programming.")
```

---

## Example 6: Custom Modelfile Creation

Create a specialized model programmatically.

```python
import subprocess
import tempfile
import os

def create_custom_model(
    name: str,
    base_model: str,
    system_prompt: str,
    temperature: float = 0.7,
    num_ctx: int = 8192
):
    """Create a custom Ollama model from parameters."""

    modelfile_content = f'''FROM {base_model}

PARAMETER temperature {temperature}
PARAMETER top_p 0.9
PARAMETER num_ctx {num_ctx}
PARAMETER repeat_penalty 1.1

SYSTEM """{system_prompt}"""
'''

    # Write temporary Modelfile
    with tempfile.NamedTemporaryFile(mode='w', suffix='.Modelfile', delete=False) as f:
        f.write(modelfile_content)
        modelfile_path = f.name

    try:
        # Create model
        result = subprocess.run(
            ['ollama', 'create', name, '-f', modelfile_path],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print(f"Created model: {name}")
        else:
            print(f"Error: {result.stderr}")
    finally:
        os.unlink(modelfile_path)

# Example: Create a code review model
create_custom_model(
    name="code-reviewer",
    base_model="qwen3:4b",
    system_prompt="""You are an expert code reviewer. When reviewing code:
1. Identify bugs and security issues first
2. Suggest performance improvements
3. Check for best practices
4. Be concise but thorough""",
    temperature=0.3
)
```

---

## Example 7: Error Handling and Retry

Robust error handling for production use.

```python
import os
import time
import openai
from typing import Optional

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

def robust_completion(
    prompt: str,
    model: str = None,
    max_retries: int = 3,
    retry_delay: float = 2.0,
    timeout: int = 120
) -> Optional[str]:
    """Get completion with retry logic and error handling."""

    model = model or os.getenv("FAST_MODEL", "qwen3:4b")

    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(
                model=model,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.6,
                timeout=timeout
            )
            return response.choices[0].message.content

        except openai.APIConnectionError as e:
            print(f"Connection error (attempt {attempt + 1}): {e}")
            if attempt < max_retries - 1:
                time.sleep(retry_delay)

        except openai.APITimeoutError as e:
            print(f"Timeout (attempt {attempt + 1}): {e}")
            if attempt < max_retries - 1:
                time.sleep(retry_delay)

        except openai.APIError as e:
            print(f"API error: {e}")
            if "loading" in str(e).lower():
                print("Model is loading, waiting...")
                time.sleep(10)
            else:
                raise

    return None

# Usage
result = robust_completion("What is the meaning of life?")
if result:
    print(result)
else:
    print("Failed after all retries")
```

---

## Example 8: Model Benchmarking

Compare performance across models.

```python
import os
import time
import statistics
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

def benchmark_model(model: str, prompts: list, runs: int = 2) -> dict:
    """Benchmark a model on a set of prompts."""
    times = []
    tokens = []

    for prompt in prompts:
        for _ in range(runs):
            start = time.time()
            response = client.chat.completions.create(
                model=model,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.6
            )
            elapsed = time.time() - start
            times.append(elapsed)
            tokens.append(response.usage.completion_tokens)

    avg_time = statistics.mean(times)
    avg_tokens = statistics.mean(tokens)

    return {
        "model": model,
        "avg_time": avg_time,
        "avg_tokens": avg_tokens,
        "tok_per_sec": avg_tokens / avg_time
    }

# Test prompts
test_prompts = [
    "Explain photosynthesis briefly.",
    "Write a haiku about coding.",
    "What is 15 * 23?",
]

# Benchmark
models = [
    os.getenv("FAST_MODEL", "qwen3:4b"),
    os.getenv("QUALITY_MODEL", "deepseek-r1:8b"),
]

print("Benchmarking models...\n")
for model in models:
    result = benchmark_model(model, test_prompts, runs=2)
    print(f"{result['model']}:")
    print(f"  Avg time: {result['avg_time']:.2f}s")
    print(f"  Avg tokens: {result['avg_tokens']:.0f}")
    print(f"  Speed: {result['tok_per_sec']:.1f} tok/s\n")
```

---

## Example 9: Health Check Script

Verify local LLM setup is working.

```bash
#!/bin/bash
# health_check.sh - Verify local LLM setup

echo "=== Local LLM Health Check ==="
echo ""

# Check Ollama service
echo "1. Checking Ollama service..."
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "   [OK] Ollama is running"
else
    echo "   [FAIL] Ollama is not responding"
    echo "   Try: sudo systemctl start ollama"
    exit 1
fi

# List models
echo ""
echo "2. Installed models:"
curl -s http://localhost:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('models', []):
    size = m.get('size', 0) / 1e9
    print(f\"   - {m['name']} ({size:.1f} GB)\")
"

# Check GPU
echo ""
echo "3. GPU Status:"
if nvidia-smi > /dev/null 2>&1; then
    GPU_MEM=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | head -1)
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    echo "   [OK] $GPU_NAME (${GPU_MEM}MB free)"
else
    echo "   [INFO] No NVIDIA GPU detected (CPU mode)"
fi

# Quick inference test
echo ""
echo "4. Testing inference..."
MODEL=${FAST_MODEL:-qwen3:4b}
START=$(date +%s.%N)
RESULT=$(echo "Say OK" | ollama run $MODEL 2>/dev/null | head -1)
END=$(date +%s.%N)
DURATION=$(echo "$END - $START" | bc)

if [ -n "$RESULT" ]; then
    echo "   [OK] Inference working (${DURATION}s)"
else
    echo "   [FAIL] Inference failed"
fi

echo ""
echo "=== Health check complete ==="
```

Usage:
```bash
chmod +x health_check.sh
./health_check.sh
```

---

## Example 10: JSON Output Parsing

Get structured JSON responses.

```python
import os
import json
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"
)

def get_json_response(prompt: str, model: str = None) -> dict:
    """Get JSON response from model."""
    model = model or os.getenv("FAST_MODEL", "qwen3:4b")

    system_prompt = """You are a JSON generator. Always respond with valid JSON only.
No markdown, no explanations, just the JSON object."""

    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        temperature=0.2  # Lower for consistent structured output
    )

    content = response.choices[0].message.content

    # Clean up common issues
    content = content.strip()
    if content.startswith("```"):
        content = content.split("```")[1]
        if content.startswith("json"):
            content = content[4:]
        content = content.strip()

    return json.loads(content)

# Usage
result = get_json_response("""
Extract entities from this text and return as JSON:
"Apple Inc. CEO Tim Cook announced the new iPhone in Cupertino, California."

Format: {"entities": [{"text": "...", "type": "..."}]}
""")

print(json.dumps(result, indent=2))
```

---

*See SKILL.md for full documentation and CHEATSHEET.md for quick reference.*
