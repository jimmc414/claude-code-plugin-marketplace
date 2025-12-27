---
name: compile-once-call-many
description: "For hot loop optimization: repeated formula evaluation, regex patterns, expression compilation. Transform string to callable once, call many times."
---

# compile-once-call-many

## When to Use
- Same expression evaluated millions of times
- eval() or regex in a loop
- Formula/pattern is fixed, only values change
- Profiling shows string parsing as bottleneck

## When NOT to Use
- Expression changes each iteration
- Only called a few times
- Code clarity more important than speed

## The Pattern

Transform string formula to compiled function, then call the function.

```python
# SLOW: eval in loop
for values in million_combinations:
    if eval(f"{values[0]} + {values[1]} == {values[2]}"):
        results.append(values)

# FAST: compile once, call many
formula = "lambda a, b, c: a + b == c"
check = eval(formula)
for values in million_combinations:
    if check(*values):
        results.append(values)
```

## Example (from pytudes Cryptarithmetic.ipynb)

```python
def solve(formula):
    """Slow version: eval in loop."""
    for digits in permutations('1234567890', len(letters)):
        filled = substitute(digits, letters, formula)
        if eval(filled):  # eval called 3.6 million times!
            yield filled

def faster_solve(formula):
    """Fast version: compile once, call many."""
    # Transform "NUM + BER = PLAY" to lambda
    fn_str, letters = translate_formula(formula)
    # fn_str = "lambda A,B,E,L,M,N,P,R,U,Y: (100*N+10*U+M) + (100*B+10*E+R) == ..."

    formula_fn = eval(fn_str)  # Compile once

    for digits in permutations((1,2,3,4,5,6,7,8,9,0), len(letters)):
        try:
            if formula_fn(*digits):  # Call compiled function
                yield format_solution(digits, letters, formula)
        except ArithmeticError:
            pass

def translate_formula(formula):
    """Turn 'NUM + BER = PLAY' into evaluatable lambda."""
    letters = sorted(set(re.findall('[A-Z]', formula)))

    # Convert words to arithmetic: NUM -> (100*N + 10*U + M)
    def word_to_expr(match):
        word = match.group()
        terms = [f"{10**(len(word)-i-1)}*{c}" for i, c in enumerate(word)]
        return f"({' + '.join(terms)})"

    body = re.sub('[A-Z]+', word_to_expr, formula.replace('=', '=='))
    return f"lambda {','.join(letters)}: {body}", letters

# Result: 15x speedup!
```

## Key Principles
1. **Profile first**: Confirm the bottleneck is evaluation
2. **eval once, call many**: Compile to bytecode, execute bytecode
3. **Same for regex**: `re.compile(pattern)` then `pattern.search()`
4. **Lambda strings**: Build lambda expression as string, eval it
5. **Handle errors**: Division by zero, etc. still possible in calls
