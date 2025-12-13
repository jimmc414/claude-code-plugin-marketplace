#!/bin/bash
# Log deployment-related commands for audit trail
#
# This hook logs any bash commands that contain deployment-related keywords
# to help maintain an audit trail of deployment actions.

set -e

# Read input JSON from stdin
INPUT=$(cat)

# Extract the command that was run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check if this is a deployment-related command
if [[ "$COMMAND" == *"deploy"* ]] || \
   [[ "$COMMAND" == *"docker"* ]] || \
   [[ "$COMMAND" == *"kubectl"* ]] || \
   [[ "$COMMAND" == *"docker-compose"* ]] || \
   [[ "$COMMAND" == *"pm2"* ]]; then

    # Create log directory if it doesn't exist
    LOG_DIR="${HOME}/.claude-deployment-logs"
    mkdir -p "$LOG_DIR"

    # Log the command with timestamp
    LOG_FILE="$LOG_DIR/deployment-$(date +%Y-%m-%d).log"
    echo "[$(date -Iseconds)] $COMMAND" >> "$LOG_FILE"
fi

# Always approve - this is just logging
cat << 'EOF'
{
  "decision": "approve",
  "reason": "Command logged for audit trail"
}
EOF
