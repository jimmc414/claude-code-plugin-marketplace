# cocoindex-code

AST/tree-sitter code search MCP server that indexes a codebase and returns compact, relevant snippets so coding agents retrieve just what they need instead of loading whole files, reducing context/token usage.

- Upstream: https://github.com/cocoindex-io/cocoindex-code
- License: Apache-2.0
- Package: [`cocoindex-code`](https://pypi.org/project/cocoindex-code/) (PyPI)

## What it provides

An MCP server (stdio) exposing AST-based code search over your repository.

## Requirements

[`uv`](https://docs.astral.sh/uv/) on PATH. The bundled `.mcp.json` launches the server with:

```
uvx --from cocoindex-code ccc mcp
```

which installs and runs the `ccc mcp` entry point on first use, no separate install step.
