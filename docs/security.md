# Security Guidelines

Security best practices for creating and reviewing Claude Code plugins.

## For Plugin Authors

### Hook Script Security

Hooks run arbitrary shell commands. Follow these guidelines:

#### Input Validation

Always validate input from stdin:

```bash
#!/bin/bash
set -e  # Exit on error

INPUT=$(cat)

# Validate required fields exist
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
if [[ -z "$TOOL_NAME" ]]; then
    echo '{"decision": "approve", "reason": "Missing tool name"}'
    exit 0
fi

# Sanitize before using in commands
# NEVER directly interpolate user input into shell commands
```

#### Avoid Command Injection

```bash
# BAD - vulnerable to injection
eval "$USER_INPUT"
bash -c "$USER_INPUT"

# GOOD - use proper quoting and jq
SAFE_VALUE=$(echo "$INPUT" | jq -r '.field // empty')
```

#### Limit File Access

```bash
# Only access files within expected directories
if [[ "$FILE_PATH" != /expected/path/* ]]; then
    echo '{"decision": "block", "reason": "Invalid path"}'
    exit 0
fi
```

#### Handle Errors Gracefully

```bash
#!/bin/bash
set -e

# Trap errors
trap 'echo "{\"decision\": \"approve\", \"reason\": \"Hook error\"}"' ERR

# Your logic here
```

### Credential Handling

**Never include credentials in plugins:**

- No API keys
- No passwords
- No tokens
- No private keys

**Use environment variables:**

```bash
# In hook script
API_KEY="${MY_SERVICE_API_KEY:-}"
if [[ -z "$API_KEY" ]]; then
    echo "Warning: MY_SERVICE_API_KEY not set"
fi
```

**Document required environment variables** in your README.

### File Operations

```bash
# Use absolute paths
SAFE_PATH=$(realpath "$USER_PATH")

# Check path is within allowed directory
if [[ "$SAFE_PATH" != "$ALLOWED_DIR"/* ]]; then
    exit 1
fi

# Don't follow symlinks outside allowed areas
# Use -P flag with cd to avoid symlink traversal
```

### Network Requests

If your plugin makes network requests:

1. Use HTTPS only
2. Validate URLs before requesting
3. Don't expose sensitive data in URLs
4. Handle network errors gracefully
5. Consider timeouts

```bash
# Validate URL
if [[ ! "$URL" =~ ^https:// ]]; then
    echo "Only HTTPS URLs allowed"
    exit 1
fi

# Set timeout
curl --max-time 10 "$URL"
```

### Logging Best Practices

```bash
# DO: Log to a specific file
echo "Action performed" >> "$HOME/.my-plugin/audit.log"

# DON'T: Log sensitive data
echo "API Key: $API_KEY" >> log.txt  # NEVER DO THIS
```

## For Plugin Reviewers

### Review Checklist

Before approving a plugin:

#### 1. Code Review

- [ ] No hardcoded credentials
- [ ] No suspicious network requests
- [ ] Input validation in scripts
- [ ] Proper error handling
- [ ] No command injection vulnerabilities
- [ ] File operations are bounded

#### 2. Permissions Check

- [ ] Plugin requests only necessary permissions
- [ ] Hook scripts don't escalate privileges
- [ ] MCP servers are from trusted sources

#### 3. Behavior Verification

- [ ] Test all commands locally
- [ ] Verify hooks don't block legitimate operations
- [ ] Check scripts exit properly
- [ ] Ensure no infinite loops

#### 4. Documentation Review

- [ ] README accurately describes functionality
- [ ] Required permissions are documented
- [ ] Environment variables are listed
- [ ] Security considerations are noted

### Red Flags

Watch for these warning signs:

```bash
# Dangerous patterns
eval "$var"                    # Command injection risk
curl ... | bash                # Remote code execution
chmod 777                      # Overly permissive
rm -rf /                       # Destructive
base64 -d | bash               # Obfuscated code
```

```json
// Suspicious MCP config
{
  "mcpServers": {
    "unknown": {
      "command": "curl ... | bash"  // Remote execution
    }
  }
}
```

### Verification Process

1. **Automated Validation**
   ```bash
   python tools/validate.py plugin-name --check-conflicts
   ```

2. **Manual Code Review**
   - Read all hook scripts
   - Check plugin.json for unusual settings
   - Review MCP server configurations

3. **Local Testing**
   - Install and test the plugin
   - Monitor network activity
   - Check file system changes

4. **Mark as Verified**
   ```bash
   python tools/validate.py plugin-name --mark-verified --reviewer "Your Name"
   ```

## Reporting Vulnerabilities

If you find a security issue in a plugin:

1. **Don't publish details publicly**
2. Open a private security report
3. Contact the plugin author
4. Allow time for a fix before disclosure

## MCP Server Security

MCP servers have broad system access. Extra caution is needed:

1. Only use MCP servers from trusted sources
2. Review server code before enabling
3. Limit server permissions where possible
4. Monitor server activity

## User Guidance

When using plugins:

1. **Review before installing** - Check the source code
2. **Use verified plugins** - Look for the verified badge
3. **Limit permissions** - Only enable what you need
4. **Monitor activity** - Watch for unexpected behavior
5. **Report issues** - Help maintain marketplace security

## Security Updates

If a security issue is found in your plugin:

1. Fix the vulnerability immediately
2. Bump the version number
3. Document the fix in changelog
4. Submit update via PR
5. Notify users if severe

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Shell Script Security](https://wiki.bash-hackers.org/scripting/security)
- [jq Manual](https://stedolan.github.io/jq/manual/) - Safe JSON parsing
