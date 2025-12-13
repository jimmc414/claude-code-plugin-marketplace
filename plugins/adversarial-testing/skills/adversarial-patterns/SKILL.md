---
name: adversarial-patterns
description: Library of realistic adversarial attack vectors and anti-patterns to avoid. Contains examples of valid attacks and subtle gaming patterns to reject.
allowed-tools: Read, Grep, Glob
---

# Adversarial Pattern Library

## Philosophy: The Honest Adversary

We seek **Semantic Failures** (logic errors in valid code paths), NOT:
- Syntax failures (type errors, missing imports)
- Contract violations (inputs the API explicitly rejects)
- Physically impossible scenarios

## 1. Realistic Attack Vectors (USE THESE)

### A. Text & Encoding
| Pattern | Example | Why It's Realistic |
|---------|---------|-------------------|
| Unicode normalization | `"Å"` vs `"A\u030a"` (same visual, different bytes) | Users copy-paste from various sources |
| Control characters | `"John\x00Doe"` (null byte in name) | Data from legacy systems |
| RTL override | `"hello\u202eworld"` | Malicious input, but valid UTF-8 |
| Whitespace variants | `"  "` (only zero-width spaces) | Copy-paste errors |
| SQL fragments | `"O'Brien"` or `"Robert'); DROP TABLE"` | Real names, security testing |
| CSV injection | `"=CMD('calc')"` as a cell value | Export to spreadsheet attack |
| Newlines in fields | `"Line1\nLine2"` in single-line field | Form paste errors |

### B. Numbers & Arithmetic
| Pattern | Example | Why It Breaks Code |
|---------|---------|-------------------|
| Floating precision | `0.1 + 0.2` (≠ 0.3) | Currency, percentages |
| Negative zero | `-0.0` | Cache keys, equality checks |
| Off-by-one | `limit`, `limit+1`, `limit-1` | Loop boundaries, pagination |
| Integer boundaries | `2^31-1`, `2^31`, `-2^31` | Only if type is `int` without bounds |
| Division edge | Divisor approaches zero: `0.0001` | Rate calculations |
| Large but valid | `999999` for `quantity` (if no limit specified) | Overflow in multiplication |

### C. Time & State
| Pattern | Example | Why It's Realistic |
|---------|---------|-------------------|
| Race condition | Two updates within 5ms | Concurrent users |
| Timeout boundary | 29.9s on 30s timeout | Network latency |
| Leap year | Feb 29, 2024 | Date calculations |
| DST transition | 2:30 AM during spring-forward | Scheduling systems |
| Epoch boundaries | Dec 31, 1969; Jan 1, 1970 | Legacy timestamp handling |
| Far future | Year 2038 (32-bit overflow) | Only if system uses 32-bit time |

### D. Collections & Structure
| Pattern | Example | Why It Breaks Code |
|---------|---------|-------------------|
| Empty collection | `[]`, `{}`, `""` | Missing null checks |
| Single element | `[x]` | Off-by-one, fence-post errors |
| Duplicate keys | `{"a": 1, "a": 2}` (JSON) | Parser-dependent behavior |
| Deep nesting | 3-level nested object | Recursive processing |
| Circular reference | Object A → B → A | Serialization, traversal |

## 2. Anti-Patterns: Reward Hacking (REJECT THESE)

### A. Magnitude Violations (The Fuzz Bomb)
| Bad Test | Why It's Gaming |
|----------|--------------------|
| `func("A" * 1_000_000)` | No user types 1M chars; tests memory, not logic |
| `func(10**100)` | Astronomically unlikely; tests BigInt, not business logic |
| `func(None)` when typed `str` | Contract violation, not logic bug |
| `func(float('inf'))` | Unless explicitly documented as valid |

### B. Contract Violations (The Type Lie)
| Bad Test | Why It's Invalid |
|----------|------------------|
| Passing `str` to `int` parameter | Type system catches this |
| `null` to non-nullable field | Contract violation |
| Negative value to `unsigned` | Contract violation |

### C. Physics Violations (The Impossible)
| Bad Test | Why It's Impossible |
|----------|---------------------|
| Timestamp in year 9999 | No production system will see this |
| Negative file size | Impossible from OS |
| User ID = -1 (if DB uses SERIAL) | Database won't generate this |

## 3. Subtle Gaming (REJECT THESE - Harder to Detect)

### A. Form Without Substance
| Pattern | What It Looks Like | Why It's Gaming |
|---------|-------------------|-----------------|
| **Ghost Import** | Test imports module but never calls target function | Test "passes" without testing anything |
| **Dead Assert** | `if False: assert result == expected` | Assertion never executes |
| **Tautology** | `assert result is not None` | Passes with any non-null return |
| **Wrong Target** | Tests helper function, not the requested target | Appears productive, tests nothing useful |

### B. Incorrect Oracles
| Pattern | What It Looks Like | Why It's Gaming |
|---------|-------------------|-----------------|
| **Magic Number** | `assert result == 42` without derivation | How do we know 42 is correct? |
| **Spec Drift** | Expected value contradicts docstring | Test is wrong, not the code |
| **Copy-Paste Oracle** | Expected value copied from current (buggy) output | Test enshrines bugs as correct |

### C. Side-Effect Fishing
| Pattern | What It Looks Like | Why It's Gaming |
|---------|-------------------|-----------------|
| **Log Assertion** | Checks log output, ignores return value | Return value could be wrong |
| **DB Side Effect** | Checks row inserted, ignores returned ID | Core functionality untested |
| **File Existence** | Checks file created, ignores contents | Contents could be corrupt |

## 4. Decision Framework

When evaluating a test input:

```
Is this input within 3-sigma of existing usage?
├─ NO → REJECT (Reward Hacking)
└─ YES → Does it violate explicit contracts?
         ├─ YES → REJECT (Contract Violation)
         └─ NO → Does it test actual functionality?
                 ├─ NO → REJECT (Subtle Gaming)
                 └─ YES → ACCEPT (Honest Adversary)
```
