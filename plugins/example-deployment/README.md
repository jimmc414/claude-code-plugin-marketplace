# example-deployment

Deployment automation tools for common platforms including Docker, Kubernetes, and cloud services.

## Installation

```bash
/plugin marketplace add yourname/claude-code-marketplace
/plugin install example-deployment@community-claude-plugins
```

## Components

### Commands

- `/deploy [environment] [version]` - Deploy application to specified environment
- `/status [environment]` - Check deployment status for an environment

### Agents

- `deployer` - Autonomous deployment agent for complex multi-step deployments

### Skills

- `docker-deploy` - Docker deployment automation skill

### Hooks

- **PostToolUse**: Logs deployment-related commands for audit trail

## Usage Examples

### Quick Deploy
```
/deploy staging v1.2.3
```

### Check Status
```
/status prod
```

### Complex Deployment (via agent)
```
Use the deployer agent to deploy the new version to staging,
run the integration tests, and if they pass, deploy to production.
```

## Configuration

The plugin looks for deployment configuration in:
- `deploy.yaml` or `deploy.json`
- `.deploy/` directory
- `docker-compose.yml`
- `kubernetes/` directory

## Audit Logging

All deployment-related commands are automatically logged to:
`~/.claude-deployment-logs/deployment-YYYY-MM-DD.log`

## Requirements

- Docker (for docker-deploy skill)
- kubectl (for Kubernetes deployments)
- jq (for hook scripts)

## License

MIT
