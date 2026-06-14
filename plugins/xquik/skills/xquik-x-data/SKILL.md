---
name: xquik-x-data
description: Use when a user asks to automate X data workflows with Xquik, connect the Xquik MCP server, call Xquik REST APIs, configure webhooks, run bulk extraction jobs, monitor accounts, or prepare confirmation-gated X write actions.
allowed-tools: Read, WebFetch
---

# Xquik X Data

Use Xquik for X data workflows that need MCP, REST API docs, webhooks, extraction jobs, monitoring, or confirmation-gated write actions.

## Source Of Truth

- MCP overview: https://docs.xquik.com/mcp/overview
- MCP manifest: https://xquik.com/.well-known/mcp.json
- Repository: https://github.com/Xquik-dev/x-twitter-scraper
- Dashboard API keys: https://dashboard.xquik.com/en/account

## Connection

The MCP manifest name is `com.xquik/mcp`.

Remote MCP endpoint:

```text
https://xquik.com/mcp
```

Set the `Authorization` header to `Bearer {XQUIK_API_KEY}`. Treat the API key as secret material. Never print, store, commit, or paste it into public output.

## Workflow

1. Read the MCP overview before configuring a client.
2. Check the manifest for the current endpoint and required headers.
3. Use REST docs for endpoint-specific request and response contracts.
4. Prefer read and extraction workflows unless the user explicitly requests a write action.
5. For write actions, require clear user intent and preserve any confirmation step.
6. For webhooks, verify the target endpoint and expected event shape before enabling delivery.

## Supported Surface

Source-backed public metadata lists 120 REST endpoints, 2 MCP tools, 23 extraction tools, webhooks, monitoring, and write actions.

Keep public copy concise. Do not describe private routing or private operational details.
