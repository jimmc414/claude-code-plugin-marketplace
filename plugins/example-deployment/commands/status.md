---
description: Check deployment status for an environment
argument-hint: [environment]
allowed-tools: Bash, Read, Grep
---

# Status Command

Check the current deployment status for a specified environment.

## Arguments
- `$1` - Environment to check (dev, staging, prod, or "all")

## Steps

1. Identify the deployment infrastructure
2. Query status from appropriate source
3. Report health and version info

## Instructions

When this command is invoked:

1. **Identify Infrastructure**:
   - Check for Docker containers: `docker ps`
   - Check for Kubernetes deployments: `kubectl get deployments`
   - Check for PM2 processes: `pm2 status`
   - Check cloud services if configured

2. **Gather Status**:
   - Current running version
   - Health/readiness status
   - Resource usage if available
   - Last deployment time

3. **Format Report**:
   - Environment name
   - Status (healthy/degraded/down)
   - Version deployed
   - Uptime
   - Any warnings or issues

## Usage

```
/status staging
/status prod
/status all
```

## Example Output

```
Environment: staging
Status: HEALTHY
Version: v1.2.3
Uptime: 3d 14h
Last Deploy: 2025-01-10 14:30 UTC
Resources: CPU 23%, Memory 512MB/1GB
```

## Notes

- Use "all" to see status of all environments
- Red flags are highlighted automatically
- Include container/pod names when relevant
