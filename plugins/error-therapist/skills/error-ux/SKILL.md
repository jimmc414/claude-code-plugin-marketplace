---
name: error-ux
description: Principles and patterns for writing error messages that help users recover. Use when auditing, writing, or improving error messages in code. Triggers: error messages, user experience, error handling, exception messages, validation errors.
allowed-tools: Read, Grep
---

# Error UX Skill

## Purpose

Provides principles and patterns for writing error messages that help users recover instead of leaving them stuck.

## The Error Message Framework

Every error message should answer three questions:

### 1. What Happened (Symptom)

State the problem in user terms, not system terms.

| System Speak | User Speak |
|--------------|------------|
| `ETIMEDOUT` | The request took too long |
| `ECONNREFUSED` | Cannot connect to the service |
| `403 Forbidden` | You don't have permission |
| `ENOMEM` | The system is overloaded |
| `Deadlock detected` | Please try again in a moment |
| `ENOENT` | File or resource not found |
| `EPERM` | Permission denied |
| `EEXIST` | Already exists |

### 2. Why It Happened (Cause)

Give the most likely explanation without requiring technical knowledge.

**Common causes to surface:**
- Network connectivity issues
- Invalid input (be specific about which field)
- Missing permissions
- Resource not found (was it deleted?)
- Rate limiting
- Service temporarily unavailable
- Session expired
- Configuration missing

### 3. What To Do (Resolution)

Provide concrete next steps. Prioritize:
1. **Self-service fixes** ("Check your internet connection")
2. **Retry suggestions** ("Try again in a few minutes")
3. **Alternative paths** ("Use X instead")
4. **Support escalation** (last resort, with context to provide)

## Error Categories and Patterns

### Input Validation Errors

Always specify:
- Which field failed
- What was wrong with it
- What format is expected

```
Bad:  "Validation error"
Good: "Phone number must be 10 digits. You entered: 555-123 (7 digits)"

Bad:  "Invalid input"
Good: "Email address is invalid: 'not-an-email' is missing the @ symbol"

Bad:  "Field required"
Good: "Please enter your last name"
```

### Authentication/Authorization Errors

Be vague enough for security, helpful enough for legitimate users:

```
Bad:  "Invalid password for user john@example.com"  // Confirms email exists
Good: "Email or password is incorrect. [Forgot password?]"

Bad:  "You don't have admin role"  // Leaks role information
Good: "You don't have permission to access this page. Contact your administrator if you need access."

Bad:  "Token expired at 2024-01-15T10:30:00"  // Leaks timing info
Good: "Your session has expired. Please log in again."
```

### Network/Service Errors

Distinguish between user-fixable and system issues:

```
Bad:  "ECONNREFUSED"
Good: "Cannot reach the payment service. This is likely temporary—please try again in a few minutes. If this persists, check status.example.com"

Bad:  "503 Service Unavailable"
Good: "Our servers are temporarily busy. Please try again in a moment."

Bad:  "Request timeout"
Good: "This is taking longer than expected. Please check your internet connection and try again."
```

### Not Found Errors

Help users understand if it's their mistake or something changed:

```
Bad:  "404 Not Found"
Good: "This page doesn't exist. It may have been moved or deleted. [Return to homepage] [Search for what you need]"

Bad:  "Resource not found"
Good: "We couldn't find the document you're looking for. It may have been deleted or you may not have access."
```

### Rate Limiting

Tell them how long to wait:

```
Bad:  "Too many requests"
Good: "You've made too many requests. Please wait 30 seconds before trying again."

Bad:  "Rate limit exceeded"
Good: "Slow down! You can try again in 2 minutes. (Limit: 100 requests per minute)"
```

### Database/Data Errors

Translate constraint violations:

```
Bad:  "UNIQUE constraint failed: users.email"
Good: "This email address is already registered. [Log in instead?] [Reset password?]"

Bad:  "Foreign key constraint violation"
Good: "Cannot delete this item because other items depend on it. Remove those first."
```

## Technical Detail Handling

Include technical info for debugging, but separate it from the user message:

```javascript
// Pattern 1: Separate user and technical messages
throw new UserFacingError(
  "Could not save your changes. Please try again.",
  { code: "DB_WRITE_FAILED", table: "users", constraint: "unique_email" }
);

// Pattern 2: Support reference codes
const supportCode = generateSupportCode(technicalDetail);
// User sees: "...Please try again. (Reference: ABC123)"
// Support can look up ABC123 to see full technical details

// Pattern 3: Log detailed, show simple
logger.error("Database write failed", { table, constraint, stack });
throw new Error("Could not save your changes");
```

## Anti-Patterns to Flag

### 1. Blame Language
```
Bad:  "You entered an invalid email"
Good: "This email address isn't valid"

Bad:  "You don't have permission"
Good: "Access denied for this resource"
```

### 2. Dead Ends
```
Bad:  "Error occurred"  // Now what?
Good: "Error occurred. [Try again] [Contact support]"

Bad:  "Operation failed"
Good: "Could not complete the operation. Here's what you can try: ..."
```

### 3. Technical Dumps
```
Bad:  Stack traces shown to users
Good: Logged server-side, user sees friendly message

Bad:  "NullReferenceException at UserService.cs:247"
Good: "Something went wrong loading your profile. Please refresh the page."
```

### 4. ALL CAPS
```
Bad:  "FATAL ERROR: OPERATION FAILED"
Good: "Something went wrong. We're looking into it."
```

### 5. Excessive Punctuation
```
Bad:  "Payment failed!!!"
Good: "Payment could not be processed."
```

### 6. Humor in Error States
```
Bad:  "Oopsie woopsie! We made a fucky wucky!"
Good: "Something went wrong. Please try again."
```
(Users are frustrated; humor makes it worse)

### 7. Vague Errors for Non-Security Reasons
```
Bad:  "Something went wrong"  // When you know exactly what
Good: "Your file is too large. Maximum size is 10MB."
```

## Language and Tone Guidelines

- Use contractions (don't, can't) for friendlier tone
- Avoid jargon (say "internet connection" not "network connectivity")
- Be concise but complete
- Don't apologize excessively ("Sorry! We're so sorry!")—one "sorry" max
- Match the brand voice of the application
- Use sentence case, not Title Case
- End statements with periods, not exclamation marks

## Security Considerations

### Errors That Should Stay Vague

For security reasons, these errors should NOT be specific:

| Scenario | Why vague | Good message |
|----------|-----------|--------------|
| Login failure | Don't reveal if email exists | "Email or password incorrect" |
| Resource access | Don't confirm resource exists | "Not found or access denied" |
| Admin actions | Don't reveal admin exists | Generic "permission denied" |
| API keys | Don't reveal key format | "Invalid authentication" |

### Pattern for Security-Sensitive Code

```javascript
// Log the real reason server-side
logger.warn("Login failed: invalid password", { email, ip });

// Return generic message to user
throw new AuthError("Email or password is incorrect");
```

## Testing Error Messages

Good error messages should pass these tests:

1. **The Mom Test**: Would your non-technical parent understand it?
2. **The 3AM Test**: Would a tired user at 3AM know what to do?
3. **The Angry Test**: Would this make an already frustrated user more frustrated?
4. **The Support Test**: Does it reduce support tickets or generate them?

## Internationalization Notes

If the codebase uses i18n, error messages should be keys, not hardcoded:

```javascript
// Bad: Hardcoded
throw new Error("Email is invalid");

// Good: i18n key
throw new Error(t('errors.validation.email_invalid'));

// Good: With interpolation
throw new Error(t('errors.validation.field_required', { field: 'email' }));
```
