# Sample design — first-run grill target

> **Purpose:** Packaged fixture for no-arg `:grill`. Intentional gaps for adversarial review.
> No secrets. No host-absolute paths. Not production advice.

## Problem

A CLI tool runs background jobs and writes status to a local state file. Operators want a single command that reports whether the tool is ready to accept work.

## Proposed design

### Components

1. **Binary resolve** — find the tool on `PATH`.
2. **Auth soft probe** — call a lightweight remote command once.
3. **Config load** — read optional custom profiles from a user config file.
4. **Ready line** — print `Ready: yes` or `Ready: no` and exit 0/1.

### Happy path

1. Binary present.
2. Auth probe returns success.
3. Custom profile loads → use profile name `custom_ro`.
4. Print Ready and mode; exit 0.

### Fallback

If custom profiles are missing, fall back to a built-in restricted mode and set `STAGING=1` so inputs are copied into a run directory before invocation.

## Claims (grill targets)

- **Claim A:** Auth probe failure always maps to Ready:no with a clear reason.
- **Claim B:** Fallback mode is always available whenever the binary is present.
- **Claim C:** Ready:yes means the next grill/verify run can start without refuse-to-start.

## Intentional weaknesses

1. **Missing error handling:** Claim A does not specify timeout, network partition, or non-zero exit without stderr — no recovery policy.
2. **No concurrency model:** Two simultaneous check runs writing the same state file are undefined.
3. **No schema version** on the state file — future keys may break older readers silently.
4. **Staging path lifecycle** (cleanup, disk full) is unspecified.

## Non-goals

- Implementing the background job runner itself.
- Network sandbox policy beyond the named profiles.
- Automatic merge of concurrent state updates.
