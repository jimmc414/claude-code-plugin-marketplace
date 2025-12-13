---
name: adversarial-analysis
description: Analyze code to identify explicit contracts, implicit usage patterns, and realistic boundary conditions. Contains concrete formulas for calculating input realism limits. Use before generating adversarial tests.
allowed-tools: Read, Grep, Glob
---

# Adversarial Code Analysis

## Purpose

Map the "Surface of Reality" for target code. Your goal is to distinguish:
- **Contract Violations** (invalid inputs the caller shouldn't send) → NOT testable
- **Logic Bugs** (valid inputs the code handles poorly) → TESTABLE

## Analysis Checklist

### 1. Contract Extraction

**Explicit Contracts:**
- Type hints (`int`, `str`, `Optional[T]`, `List[T]`)
- `assert` statements and preconditions
- Docstring `Args`, `Raises`, `Returns` sections
- Validation code at function entry

**Implicit Contracts:**
- Variable names implying limits (`retry_count` → small positive int, `buffer_size` → memory-reasonable)
- Context from call sites (what values are actually passed?)
- Domain knowledge (user IDs are positive, emails contain @)

**External Constraints:**
- Database column limits (VARCHAR(255))
- API rate limits and timeouts
- Filesystem permissions and path length limits

### 2. Realism Baseline (The 3-Sigma Rule)

Use `Grep` to scan existing tests in `tests/` and call sites in `src/`. Calculate boundaries:

**String Inputs:**
```
existing_lengths = [len(s) for each test string argument]
if len(existing_lengths) >= 5:
    Max_Realistic_Length = mean(existing_lengths) + 3 * std(existing_lengths)
elif len(existing_lengths) >= 1:
    Max_Realistic_Length = max(existing_lengths) * 2
else:
    Max_Realistic_Length = 256  # Zero-sample fallback
```

**Numeric Inputs:**
```
existing_values = [v for each numeric argument]
if len(existing_values) >= 5:
    Lower = mean(existing_values) - 3 * std(existing_values)
    Upper = mean(existing_values) + 3 * std(existing_values)
elif len(existing_values) >= 1:
    Lower = min(existing_values) - abs(min(existing_values))
    Upper = max(existing_values) + abs(max(existing_values))
else:
    Lower, Upper = -1000, 1000  # Zero-sample fallback
```

**Special Boundaries (Always Valid):**
- `0`, `-1`, `1` for integers (if type allows)
- Empty string `""` (if not explicitly forbidden)
- `None` only if type is `Optional`

**Complex Objects:**
- Max nesting depth: 3 levels (unless recursive data structure)
- Max fields: 20 (unless schema requires more)
- Zero-sample fallback: depth 2, fields 10

### 3. Vulnerability Surface Identification

**High-Risk Patterns:**
- **Arithmetic**: Division, modulo, floating-point accumulation, currency calculations
- **Boundaries**: Loop limits, array indices, string slicing
- **State**: Multi-step workflows, flag combinations, temporal dependencies
- **Resources**: File handles, connections, locks (cleanup on error paths)
- **Parsing**: User input, external data, format conversions

## Output Format

For each target function, produce:

```
## Analysis: `function_name`

### Contracts
- Parameter X: Type, range [A, B], constraints
- Parameter Y: Type, must not be null/empty

### Realism Bounds (Calculated)
- String inputs: Max N characters (based on M samples, mean=P, std=Q)
- Numeric inputs: Range [X, Y]
- Objects: Max depth D, max fields F

### Realistic Edge Cases (TESTABLE)
1. [Specific input] - [Why it's realistic] - [What might break]
2. ...

### Excluded Scenarios (NOT TESTABLE - Contract Violations)
1. [Input] - [Why it violates contract]
2. ...

### Vulnerability Hypothesis
- Primary risk: [e.g., "off-by-one in loop boundary"]
- Secondary risk: [e.g., "floating point precision in total calculation"]
```
