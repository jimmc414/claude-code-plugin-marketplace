---
description: Deploy application to specified environment
argument-hint: [environment] [version]
allowed-tools: Bash, Read, Grep
---

# Deploy Command

Deploy the application to the specified environment.

## Arguments
- `$1` - Environment (dev, staging, prod)
- `$2` - Version tag (optional, defaults to latest)

## Steps

1. Validate the environment argument
2. Check for deployment configuration
3. Run pre-deployment checks
4. Execute deployment
5. Verify deployment success

## Instructions

When this command is invoked:

1. **Validate Environment**: Check that `$1` is one of: dev, staging, prod
2. **Find Configuration**: Look for deployment config in:
   - `deploy.yaml` or `deploy.json` in project root
   - `.deploy/` directory
   - `docker-compose.yml` or `kubernetes/` directory
3. **Pre-deployment Checks**:
   - Verify the target environment is reachable
   - Check for uncommitted changes (warn if present)
   - Validate the version tag if provided
4. **Execute Deployment**:
   - For Docker: Use docker-compose or docker commands
   - For Kubernetes: Use kubectl apply
   - For cloud platforms: Use appropriate CLI tools
5. **Post-deployment Verification**:
   - Check service health
   - Report deployment status

## Usage

```
/deploy staging v1.2.3
/deploy prod
/deploy dev latest
```

## Notes

- Always verify you're deploying to the correct environment
- Production deployments may require additional confirmation
- Check logs if deployment fails
