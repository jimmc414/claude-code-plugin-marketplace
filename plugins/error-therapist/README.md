# error-therapist

Audit and rewrite error messages to be helpful and actionable.

## The Problem

Backend developers write error messages for themselves, not for users:

```
Error: ECONNREFUSED 127.0.0.1:5432
NullReferenceException at line 247
TypeError: Cannot read property 'id' of undefined
```

These messages tell you *what* failed but not *why* it failed or *how to fix it*. Users (and even other developers) see these and have no idea what to do next.

## The Solution

Good error messages are UX content. They should:
1. Explain what happened in plain language
2. Explain why it might have happened
3. Suggest concrete next steps

The `therapist` agent scans your code for error emission patterns, evaluates each message for clarity and actionability, and suggests rewrites.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install error-therapist@community-claude-plugins
```

## Components

| Type | Name | Description |
|------|------|-------------|
| **Agent** | `therapist` | Scans code, evaluates error messages, suggests rewrites |
| **Skill** | `error-ux` | Principles and patterns for writing helpful error messages |

## Usage

### Audit a Specific File

```bash
claude --agent therapist "Audit error messages in src/api/payments.ts"
```

### Audit a Directory

```bash
claude --agent therapist "Review all error handling in src/controllers/"
```

### Focus on User-Facing Errors Only

```bash
claude --agent therapist "Audit only the HTTP response error messages in the API, ignore internal logging"
```

### Apply Fixes

```bash
claude --agent therapist "Rewrite the error messages in the checkout flow to be more user-friendly"
```

## How It Works

### Error Pattern Detection

The agent scans for error emission patterns across languages:

| Language | Patterns |
|----------|----------|
| JavaScript/TypeScript | `throw new Error()`, `res.status(4xx).json()`, `console.error()` |
| Python | `raise Exception()`, `logging.error()`, `abort()` |
| Go | `errors.New()`, `fmt.Errorf()`, `log.Fatal()` |
| Java | `throw new Exception()`, `logger.error()` |

### Evaluation Scoring

Each error message is rated on three criteria (1-5 scale):

| Criterion | What It Measures |
|-----------|------------------|
| **Clarity** | Can a non-expert understand what went wrong? |
| **Actionability** | Does it tell you what to do next? |
| **Specificity** | Does it include relevant context? |

**Scoring Guide:**
- **Critical (< 6/15)**: Needs immediate rewrite
- **Needs Improvement (6-10/15)**: Should be improved
- **Acceptable (> 10/15)**: Good enough

### Output Format

```markdown
## Error Message Audit: src/api/payments.ts

### Critical (Score < 6/15)
| Line | Current Message | Score | Issues | Suggested Rewrite |
|------|-----------------|-------|--------|-------------------|
| 42 | "ECONNREFUSED" | 3 | Jargon, no action | "Cannot connect to database. Is it running?" |

### Needs Improvement (Score 6-10/15)
| Line | Current Message | Score | Issues | Suggested Rewrite |
|------|-----------------|-------|--------|-------------------|
| 78 | "Invalid input" | 7 | Not specific | "Invalid email format: missing @ symbol" |

### Summary
- Total error points: 12
- Critical rewrites: 3
- User impact: High
```

## Transformation Examples

### Jargon to Plain Language

```
Before: ECONNREFUSED 127.0.0.1:5432
After:  Cannot connect to the database. Is PostgreSQL running?
        Try: sudo service postgresql start
```

### Code References to User Context

```
Before: NullReferenceException in UserService.cs:247
After:  User profile could not be loaded. The user may have been
        deleted. Please refresh and try again.
```

### Generic to Specific

```
Before: Validation failed
After:  Email address is invalid: "not-an-email" is missing the @ symbol
```

### Statements to Guidance

```
Before: Payment declined
After:  Payment was declined by your bank. Please try a different
        card or contact your bank. (Error code: card_declined)
```

## Message Structure Template

Every good error message follows this structure:

```
<What happened in plain language>
<Why it might have happened>
<What to do next>
(<Technical code for support reference>)
```

Example:
```
Could not save your document.
The file may be too large or the server may be busy.
Try reducing the file size or waiting a moment before retrying.
(Error: STORAGE_QUOTA_EXCEEDED)
```

## What the Agent Won't Change

### Security-Sensitive Errors

Authentication errors should stay vague for security reasons:

```
SECURITY: This message is intentionally vague to prevent
information disclosure.

Current: "Invalid credentials"
Recommendation: Keep as-is. Ensure detailed logging server-side.
```

### Internal Logging

Debug logs meant only for developers are left alone:

```javascript
// Left unchanged (internal debugging)
logger.debug("User lookup failed", { userId, stack });
```

### Already Good Messages

Messages that already follow best practices get a pass.

## Skill: error-ux

The `error-ux` skill provides comprehensive guidance on:

- **Error Message Framework**: What happened → Why → What to do
- **System-to-User Translations**: `ETIMEDOUT` → "The request took too long"
- **Error Categories**: Validation, auth, network, not found, rate limiting
- **Anti-Patterns**: Blame language, dead ends, ALL CAPS, technical dumps
- **Security Considerations**: When vague errors are appropriate
- **Testing Guidelines**: The Mom Test, 3AM Test, Angry Test, Support Test

## Anti-Patterns Detected

The agent flags these common problems:

| Anti-Pattern | Example | Issue |
|--------------|---------|-------|
| Blame language | "You entered invalid data" | Blames user |
| Dead ends | "Error occurred" | No next steps |
| Technical dumps | Stack traces to users | Confusing |
| ALL CAPS | "FATAL ERROR" | Aggressive |
| Excessive punctuation | "Failed!!!" | Unprofessional |
| Vague errors | "Something went wrong" | Unhelpful |

## Implementation Pattern

When applying fixes, the agent suggests structured error handling:

```javascript
// Before
throw new Error("ECONNREFUSED");

// After
throw new UserFacingError(
  "Cannot connect to the database. Is it running?",
  { code: "ECONNREFUSED", host: "127.0.0.1", port: 5432 }
);
```

This separates the user-facing message from technical details for debugging.

## Testing Your Error Messages

Good error messages should pass these tests:

1. **The Mom Test**: Would your non-technical parent understand it?
2. **The 3AM Test**: Would a tired user at 3AM know what to do?
3. **The Angry Test**: Would this make an already frustrated user more frustrated?
4. **The Support Test**: Does it reduce support tickets or generate them?

## License

MIT
