#!/bin/bash
# Hook Script Template
#
# Input: JSON via stdin
# Output: JSON to stdout
# Exit codes:
#   0 = success
#   2 = blocking error
#   other = non-blocking error

set -e

# Read input JSON
INPUT=$(cat)

# Parse relevant fields
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Your logic here
# ...

# Output response
cat << 'EOF'
{
  "decision": "approve",
  "reason": "Hook executed successfully"
}
EOF
