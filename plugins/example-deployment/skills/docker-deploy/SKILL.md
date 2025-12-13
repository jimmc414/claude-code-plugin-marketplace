---
name: docker-deploy
description: Deploy applications using Docker. Use when deploying containerized applications, building images, or managing Docker Compose stacks.
allowed-tools: Bash, Read, Grep
---

# Docker Deployment Skill

## Overview

This skill enables Claude to deploy and manage Docker-based applications. Use this when working with containerized applications, Docker Compose stacks, or container orchestration.

## Instructions

### Step 1: Identify Docker Setup

Look for Docker configuration files:
- `Dockerfile` - Container build instructions
- `docker-compose.yml` - Multi-container orchestration
- `.dockerignore` - Build exclusions
- `.env` or `.env.example` - Environment variables

### Step 2: Common Operations

#### Building Images

```bash
# Build with tag
docker build -t app:version .

# Build with build args
docker build --build-arg ENV=production -t app:prod .

# Build for specific platform
docker build --platform linux/amd64 -t app:latest .
```

#### Deploying with Compose

```bash
# Start services
docker-compose up -d

# Start specific service
docker-compose up -d web

# Rebuild and start
docker-compose up -d --build

# With specific compose file
docker-compose -f docker-compose.prod.yml up -d
```

#### Managing Containers

```bash
# List running containers
docker ps

# View logs
docker logs -f container-name

# Execute command in container
docker exec -it container-name /bin/sh

# Stop containers
docker-compose down
```

### Step 3: Verify Deployment

```bash
# Check container status
docker ps

# Check container health
docker inspect --format='{{.State.Health.Status}}' container-name

# View recent logs
docker logs --tail 100 container-name

# Check resource usage
docker stats --no-stream
```

## Examples

### Example 1: Deploy New Version
```
User: "Deploy the new version of the app"
Claude:
1. Build new image: docker build -t myapp:v1.2.3 .
2. Stop old containers: docker-compose down
3. Update version in compose file
4. Start new version: docker-compose up -d
5. Verify: docker ps && docker logs myapp
```

### Example 2: Rollback
```
User: "The deployment failed, rollback"
Claude:
1. Stop current: docker-compose down
2. Update to previous version tag
3. Start previous: docker-compose up -d
4. Verify rollback successful
```

## Capabilities

- Build Docker images with proper tagging
- Deploy multi-container applications
- Manage environment variables
- Handle volume mounts
- Configure networking
- Scale services
- View and analyze logs
- Health checking

## Limitations

- Cannot access remote Docker hosts without proper setup
- Requires Docker to be installed and running
- Limited to Docker's capabilities on the host system
- Cannot manage Kubernetes directly (use kubectl for that)

## Best Practices

1. Always tag images with specific versions, not just `latest`
2. Use `.dockerignore` to keep images small
3. Check logs after deployment
4. Use health checks in Dockerfile
5. Keep secrets out of images - use environment variables
