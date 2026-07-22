---
name: review
description: Pre-landing PR review. Catches bugs that pass CI but break in prod. Reviews the diff against requirements, checks for security, performance, and edge cases.
version: 1.0.0
allowed-tools:
  - bash
  - glob
  - grep
  - read
triggers:
  - review this pr
  - code review
  - check my diff
  - pre-landing review
---

# review

Pre-landing code review. Adapted from
[garrytan/gstack/review](https://github.com/garrytan/gstack/tree/main/review).

## When to use

- PR is open, you (or someone) needs to review before merge
- Self-review before pushing
- Want a second pass to catch what tests missed

## The review checklist

### Correctness

- Does the code do what the PR description says?
- Are edge cases handled? (empty input, max size, concurrent access)
- Are error paths real? (no `except: pass`)
- Are types right? (no `Any` where it matters)

### Security

- User input validated?
- SQL injection / shell injection / path traversal possible?
- Secrets hardcoded? (look for API keys, tokens, passwords in diff)
- Auth checks present where required?
- XSS / CSRF concerns?

### Performance

- N+1 queries?
- Full table scans?
- O(n²) where O(n) works?
- Unbounded loops / memory growth?

### Maintainability

- Names tell you what something is?
- Magic numbers extracted to constants?
- Comments explain WHY, not WHAT?
- Tests cover the new behavior?

### Operability

- Logs at the right level (info vs debug vs error)?
- Metrics / traces for new endpoints?
- Errors actionable (not "Something went wrong")?
- Rollback plan obvious?

## Output

Post a PR review comment with this structure:

```markdown
## Review: <PR title>

### Blocking (must fix before merge)
- [ ] **<file:line>** — <issue>. <suggested fix>

### Non-blocking (nice to have)
- <file:line> — <issue>

### Questions
- <question about intent>

### Praise
- <what's particularly good — engineers need positive feedback too>
```

## Anti-patterns

- "LGTM" with no actual reading
- Nitpicking style while missing real bugs
- Reviewing only the diff, not the surrounding code
- Bikeshedding on naming
- Not blocking on real issues because the PR author is your friend

## Source

Adapted from [garrytan/gstack/review](https://github.com/garrytan/gstack/tree/main/review) (MIT).
