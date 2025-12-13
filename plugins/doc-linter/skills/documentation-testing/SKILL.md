---
name: documentation-testing
description: Provides heuristics for identifying incomplete or broken documentation. Use when validating README setup instructions, testing onboarding flows, or auditing documentation quality. Triggers: docs, readme, onboarding, setup validation, documentation audit.
allowed-tools: Read
---

# Documentation Testing Skill

## Purpose

Provides systematic heuristics for identifying incomplete, outdated, or broken documentation. This skill helps catch the gaps that make onboarding painful for new developers.

## Common Documentation Failures

### Missing Prerequisites

Projects often assume these are installed without documenting them:

| Category | Examples |
|----------|----------|
| **JavaScript** | Node.js, npm, yarn, pnpm (and which version) |
| **Python** | Python, pip, poetry, conda (and which version) |
| **Containers** | Docker, docker-compose, podman |
| **Databases** | PostgreSQL, MySQL, Redis, MongoDB, SQLite |
| **Cloud CLIs** | aws, gcloud, az, terraform |
| **Build tools** | make, cmake, gcc, clang |
| **Version managers** | nvm, pyenv, rbenv, asdf |

### Missing Environment Configuration

Look for these patterns that indicate undocumented environment variables:

| Language | Pattern to detect |
|----------|-------------------|
| JavaScript/TypeScript | `process.env.XXX` |
| Python | `os.environ["XXX"]` or `os.getenv("XXX")` |
| Ruby | `ENV["XXX"]` |
| Go | `os.Getenv("XXX")` |
| Rust | `std::env::var("XXX")` |

**Red flags:**
- References to `.env` files without `.env.example`
- `config.yaml` with placeholder values but no instructions
- Environment variables mentioned in code but not in README

### Incomplete Setup Steps

Common missing steps that break new developer onboarding:

| Step | What's often missing |
|------|---------------------|
| **Database setup** | `createdb`, migrations, seed data |
| **Service dependencies** | Starting Redis, Postgres, etc. before the app |
| **SSL/TLS** | Local HTTPS setup, certificate generation |
| **Host files** | `/etc/hosts` modifications for local domains |
| **Ports** | Required ports and how to check if they're in use |
| **Permissions** | File/directory permissions, sudo requirements |
| **Git hooks** | Pre-commit hooks that need manual setup |
| **IDE setup** | Extensions, settings, debug configurations |

### Platform-Specific Gaps

Documentation often assumes one OS. Check for:

| Issue | Example |
|-------|---------|
| **Shell commands** | `sed -i` (GNU) vs `sed -i ''` (BSD/macOS) |
| **Path separators** | `/` vs `\` |
| **Package managers** | apt vs brew vs choco vs winget |
| **Line endings** | LF vs CRLF issues |
| **Case sensitivity** | Filesystem differences |
| **Docker** | Docker Desktop vs native Docker |

## Validation Sequence

Execute setup validation in this order to catch cascading failures:

```
1. Prerequisites Check
   └─ Are all required tools installed?
   └─ Are versions compatible?

2. Repository Setup
   └─ Clone works?
   └─ Submodules initialized?
   └─ Git LFS files pulled?

3. Dependency Installation
   └─ npm install / pip install / etc.
   └─ Any errors or warnings?
   └─ Postinstall scripts succeed?

4. Environment Configuration
   └─ .env file created from template?
   └─ All required variables filled?
   └─ Config files generated?

5. Build Step (if applicable)
   └─ Compilation succeeds?
   └─ Assets generated?
   └─ No TypeScript/type errors?

6. Database/Service Setup
   └─ Services started (DB, cache, queue)?
   └─ Database created?
   └─ Migrations run?
   └─ Seed data loaded?

7. Application Start
   └─ Dev server starts?
   └─ No port conflicts?
   └─ No missing config errors?

8. Verification
   └─ Health endpoint responds?
   └─ Can log in / perform basic action?
   └─ Tests pass?
```

## Output Standards

Rate each documentation section with these markers:

| Status | Meaning | Action |
|--------|---------|--------|
| PASS | Instructions work exactly as written | None needed |
| AMBIGUOUS | Instructions work but could confuse newcomers | Suggest clarification |
| FAIL | Instructions do not work as written | Document the bug |
| MISSING | Expected section does not exist | Recommend adding |

## Documentation Health Report Format

```markdown
## Documentation Health Report

### Summary
- Total steps tested: N
- Passed: X
- Ambiguous: Y
- Failed: Z
- Missing sections: W

### Detailed Results

#### PASS: [Section Name]
- Step: "Run npm install"
- Result: Completed successfully

#### AMBIGUOUS: [Section Name]
- Step: "Install dependencies"
- Issue: Doesn't specify npm vs yarn
- Suggestion: "Run `npm install` to install dependencies"

#### FAIL: [Section Name]
- Step: "Start the development server"
- Command: `npm run dev`
- Error: `Error: Cannot find module 'dotenv'`
- Documentation Bug: Missing step to create .env file from .env.example

#### MISSING: Database Setup
- Expected: Instructions for database creation and migrations
- Impact: App crashes on start with "relation does not exist"
- Recommendation: Add section with `createdb` and migration commands
```

## Anti-Patterns to Avoid

When testing documentation, do NOT:

1. **Improvise missing steps** - If docs say "install dependencies" without a command, that's a bug
2. **Use domain knowledge** - Pretend you don't know npm from pip
3. **Skip verification** - Always confirm each step actually worked
4. **Assume success** - An empty output might be an error
5. **Fix the code** - Your job is to fix the instructions, not the implementation
