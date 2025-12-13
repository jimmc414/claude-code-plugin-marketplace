# adversarial-testing

Adversarial test generation that finds real bugs by inverting the reward structure. Instead of rewarding tests that pass, this system rewards tests that fail—because a failing test means a potential bug was found.

## Installation

```bash
/plugin marketplace add jimmc414/claude-code-plugin-marketplace
/plugin install adversarial-testing@community-claude-plugins
```

## The Problem

Traditional test generation optimizes for the wrong thing. Tests that pass tell you nothing useful—either the code is correct, or the test is too weak. This creates perverse incentives where models generate:
- Permissive assertions (`assert result is not None`)
- Unrealistic inputs that exercise paths without testing logic
- Inputs so extreme they test memory allocation, not business rules

## The Inversion

This system inverts the reward structure:

| Test Result | Traditional | Adversarial |
|-------------|-------------|-------------|
| **Passes** | Success ✓ | Suspicious—verify with mutation testing |
| **Fails** | Failure ✗ | Potential success—verify oracle is correct |

## Components

### Skills (Knowledge Layer)

| Skill | Purpose |
|-------|---------|
| `adversarial-analysis` | Calculate realism bounds (3-sigma), extract contracts, identify vulnerability surfaces |
| `adversarial-patterns` | Library of attack vectors + anti-patterns to reject (gaming detection) |

### Agents (Execution Layer)

| Agent | Purpose |
|-------|---------|
| `adversarial-orchestrator` | Coordinates workflow, max 3 iterations, parses results |
| `adversarial-generator` | Creates candidate tests with documented hypotheses |
| `adversarial-validator` | 4-phase quality gate: static → dynamic → oracle → mutation |

## Architecture

```
User Request
     │
     ▼
┌─────────────────────────────────┐
│   adversarial-orchestrator      │  Coordinates workflow, max 3 iterations
└─────────────────────────────────┘
     │                    │
     ▼                    ▼
┌─────────────┐    ┌─────────────────┐
│  Generator  │───▶│    Validator    │
│             │◀───│                 │
└─────────────┘    └─────────────────┘
     │                    │
     ▼                    ▼
┌─────────────┐    ┌─────────────────┐
│ Skills:     │    │ 4-Phase Pipeline│
│ - analysis  │    │ 1. Static       │
│ - patterns  │    │ 2. Dynamic      │
└─────────────┘    │ 3. Oracle       │
                   │ 4. Mutation     │
                   └─────────────────┘
```

## Usage

```
Use the adversarial-orchestrator to generate tests for src/utils.py
```

The orchestrator will:
1. Task generator to analyze target code
2. Generate candidate test with hypothesis
3. Validate through 4-phase pipeline
4. Accept or reject with feedback
5. Loop up to 3 times if rejected

## Key Concepts

### 3-Sigma Constraint

Inputs must be within realistic bounds based on existing usage:

```
existing_lengths = [len(s) for test strings in codebase]
Max_Realistic = mean + 3 * std
```

Inputs beyond this are rejected as "reward hacking."

### Oracle Verification

A failing test isn't automatically valuable. The validator checks that the expected value can be derived from documented behavior (docstrings, type hints, comments).

### Mutation Testing

When a test passes, we introduce a deliberate bug:
- Change `>` to `>=`
- Delete a boundary check
- Return `None` instead of computed value

If the test still passes, it's too weak. Rejected.

### Subtle Gaming Detection

Catches sophisticated gaming:
- **Ghost Import**: Imports module but never calls target
- **Dead Assert**: Assertion inside `if False:`
- **Tautology**: `assert result is not None` when specific value needed
- **Side-Effect Fishing**: Checking logs while ignoring wrong return values

## Output Statuses

| Status | Meaning |
|--------|---------|
| `ACCEPTED_BUG_FOUND` | Test fails, oracle verified. Real bug discovered. |
| `ACCEPTED_STRONG_TEST` | Test passes, killed mutation. Good regression test. |
| `REJECTED` | Failed validation. Feedback provided for retry. |
| `NEEDS_VERIFICATION` | Spec ambiguous. Human review required. |

## Example Output

```
## Adversarial Test Result

**Status:** BUG_FOUND
**Target:** `src/calculator.py::divide`
**Iterations:** 2

### Test Code
def test_divide_by_near_zero():
    result = divide(1.0, 1e-308)
    assert result == float('inf')  # Should handle near-zero

### Bug Description
- **What:** Division by very small float returns incorrect result
- **Impact:** Financial calculations could overflow silently
- **Fix:** Add check for denormalized floats
```

## Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| Mutation Score | >70% | Passing tests should catch obvious bugs |
| False Discovery Rate | <5% | "Bugs" should be real, not bad oracles |
| Rejection Rate | <30% | Generator should learn from feedback |
| Realism Score | >95% | Inputs should be production-plausible |

## Limitations

1. **Spec quality dependent**: Undocumented code produces `NEEDS_VERIFICATION`
2. **Mutation strategy is basic**: Equivalent mutants can cause false rejections
3. **3 iteration cap**: Complex bugs may not be found
4. **Framework detection**: Assumes pytest or unittest

## License

MIT
