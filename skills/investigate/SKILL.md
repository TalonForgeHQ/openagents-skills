---
name: investigate
description: Systematic root-cause debugging in 6 steps: reproduce, isolate, hypothesize, root cause, fix, verify. Refuses to "just try stuff" or fix symptoms without understanding causes.
version: 1.0.0
allowed-tools:
  - bash
  - edit
  - glob
  - grep
  - read
  - write
triggers:
  - debug this
  - fix this bug
  - why is this broken
  - investigate this error
  - root cause analysis
---

# investigate

Systematic debugging with one rule: **no fixes without root cause first.**
Adapted from [garrytan/gstack/investigate](https://github.com/garrytan/gstack/tree/main/investigate).

## When to use

- A test is failing and you don't know why
- A cron job died silently
- A real-world user reports a bug you can't reproduce
- An external API changed behavior
- "It worked yesterday"

## The Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Fixing symptoms creates whack-a-mole debugging. Every fix that doesn't
address root cause makes the next bug harder to find.

## The 6 steps

### Step 1: Reproduce

Prove you can make it fail on demand. If you can't, document what you
tried — the bug may be intermittent, which is data not failure.

Capture three things:
- **Exact trigger** (URL, request, command, input)
- **Exact observed behavior** (error message, log line, output)
- **Exact environment** (Python version, OS, env vars, git SHA)

Save the reproducer as `tests/repro_<bug>.py`.

### Step 2: Isolate

Bisect. Cut the system in half until the failure lives in one half.

- Comment out half the code. Does it still fail?
- Remove dependencies. Does it still fail?
- Swap the data. Does it still fail?

Goal: smallest possible reproducer. If the bug is in `adapter X`, prove
it with a 5-line script.

### Step 3: Hypothesize

Generate 3-5 candidate causes. For each:
- Why it would explain the observed behavior
- What test would confirm or refute it
- How confident you are (high/medium/low)

Write them down. If you can't generate 3, you don't understand the bug.

### Step 4: Root cause

The actual WHY. Not "the API returned 500" but "the API returned 500
because the request body schema changed on July 14 and we never updated
our client." Symptoms vs causes — keep going until you can answer "but
WHY did THAT happen?" three levels deep.

### Step 5: Fix

Only now do you write code. The fix should be:
- **Minimal** — change as few lines as possible
- **Reversible** — one commit, easy to revert
- **Tested** — add a regression test that fails on the bug, passes on the fix

### Step 6: Verify the fix didn't break anything

Run the full test suite. The fix that breaks two other things is worse
than the bug.

## Output

Write the investigation to `investigations/INV-YYYY-MM-DD-<slug>.md`:

```markdown
# Investigation: <one-line title>

## 1. Reproducer
- Trigger: ...
- Observed: ...
- Environment: ...
- Saved to: tests/repro_<bug>.py

## 2. Isolation
- Bisected to: <module/function>
- Confirmed: 5-line repro fails every time

## 3. Hypotheses
| # | Hypothesis | Test | Result |
|---|---|---|---|
| 1 | API schema changed | call API with old schema | CONFIRMED |
| 2 | Local cache stale | clear cache | refuted |
| 3 | Network | try different network | refuted |

## 4. Root cause
The API changed on YYYY-MM-DD. Our client was using the old schema.

## 5. Fix
- Commit: <sha>
- Changed: <file:line>
- Regression test: tests/test_<thing>.py::test_<bug>
- All tests: pass

## 6. What we learned
- Pattern to watch for: API schema changes mid-quarter
- Gap: no automated schema drift detection
```

## Anti-patterns

- **Shotgun debugging** — "let me just try changing X." Stop. Go back to Step 1.
- **Fixing the symptom** — making the error message go away without addressing why
- **Skipping the reproducer** — "I can see the bug in the logs." It's not enough.
- **"It works on my machine"** — that's the next reproducer attempt, not a fix

## Example

Real case: "CarsXE /specs pricing — is it free or paid?"

```
## 1. Reproducer
curl 'https://api.carsxe.com/specs?vin=5TFCZ5AN8KX171001'
→ HTTP 402: {"success":false,"message":"Payment required","price":"$0.15"}

## 3. Hypotheses
1. /specs is paid ($0.15/call)        → CONFIRMED (price in payload)
2. /market-value is free              → refuted (also 402)
3. No free endpoints at all           → refuted (sandbox = free)
4. Sandbox key unlocks free calls     → CONFIRMED

## 4. Root cause
CarsXE exposes 12+ endpoints with per-call pricing.
The README's claim of "free tier" was wrong for /specs.

## 5. Fix
README: corrected pricing table to say "NHTSA vPIC is free,
CarsXE /specs is $0.15/call". No code change.

## 6. What we learned
- Vendor pricing pages say "free tier" without specifying which endpoints
- Action: add cost_per_call to each adapter's metadata
```

## Source

Adapted from [garrytan/gstack/investigate](https://github.com/garrytan/gstack/tree/main/investigate) (MIT).
