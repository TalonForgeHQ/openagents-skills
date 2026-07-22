---
name: qa
description: Headless browser QA in 3 tiers (Quick / Standard / Exhaustive). Find bugs, document with reproducible steps, fix in source, re-verify. Computes a health score 0-100.
version: 1.0.0
allowed-tools:
  - bash
  - browser
  - edit
  - glob
  - grep
  - read
  - write
triggers:
  - qa this
  - qa test this
  - find bugs on site
  - test the app
  - test the site
---

# qa

Headless browser QA. Three depth tiers. Read-only by default — fixing
is a separate phase. Adapted from
[garrytan/gstack/qa](https://github.com/garrytan/gstack/tree/main/qa).

## When to use

- Feature is ready, want to verify it works in a real browser
- Cron job is failing on a deployed URL
- Final sanity check before commit
- User says "does this site even work?"

## The three tiers

### Quick (2-5 minutes)

Critical + high severity only. "Does the page load? Does the form
submit? Does the auth flow not 500?"

1. Navigate to the URL
2. Snapshot the page — verify title and main content render
3. Click the primary CTA — does it work?
4. If anything 4xx/5xx or fails silently, report it

### Standard (15-30 minutes)

Quick + medium severity. Form validation, navigation, console errors.

1. All of Quick
2. Click through every nav link — verify no 404s
3. Submit empty forms — verify validation messages
4. Submit valid forms — verify success state
5. Check browser console for errors
6. Test 5-10 specific user flows end-to-end

### Exhaustive (1-2 hours)

Standard + cosmetic. Layout, copy, performance, mobile, accessibility.

1. All of Standard
2. Visual snapshot at each viewport — does layout break?
3. Copy review — typos, broken links, placeholder text
4. Lighthouse-style checks (load time, total requests, image sizes)
5. Accessibility scan (alt text, color contrast, focus order)
6. Mobile rendering at 375px / 768px / 1024px

## Health Score Rubric

Compute each category (0-100), then weighted average.

| Category | Weight | Start | Deduction per finding |
|---|---|---|---|
| Console | 15% | 100 | -25 critical, -15 high, -8 medium |
| Links | 10% | 100 | -15 per broken |
| Visual | 10% | 100 | -25/-15/-8/-3 by severity |
| Functional | 20% | 100 | same |
| UX | 15% | 100 | same |
| Performance | 10% | 100 | same |
| Content | 5% | 100 | same |
| Accessibility | 15% | 100 | same |

`final_score = Σ (category_score × weight)`

## Hard stops (always fail, any tier)

- 4xx / 5xx on landing page
- JavaScript console errors
- Broken forms (no validation, success state never fires)
- Auth flow broken end-to-end
- 404 on any nav link

## Soft warnings (note but don't fail)

- Console warnings
- Slow load times (> 3s on fast connection)
- Accessibility gaps (no alt text, missing labels)
- Placeholder copy ("Lorem ipsum", "TODO")

## Output

Write to `qa/QA-YYYY-MM-DD-<slug>.md`:

```markdown
# QA Report: <url or feature>

**Tier:** Quick / Standard / Exhaustive
**Date:** YYYY-MM-DD

## Verdict
✅ PASS / ⚠️ PASS-WITH-NOTES / ❌ FAIL

## What works
- [list]

## Bugs found
### Critical (block ship)
1. **<title>** — <one-line repro>
   - Severity: critical
   - Repro: navigate to X, click Y
   - Expected: <expected behavior>
   - Actual: <actual behavior>
   - Screenshot: <path>

### High (block release)
### Medium (next sprint)
### Low (backlog)

## Health score
- Console: 100
- Links: 100
- Functional: 100
- **Final: 100**
```

## Anti-patterns

- **Manual testing on localhost** — test the shipped URL, not dev server
- **Skipping the console** — JS errors hide. Always check.
- **Cosmetic-only QA** — beautiful site with broken forms fails QA
- **Reporting without repro** — every bug needs exact steps
- **Reading source code** — test as a user, not a developer

## Source

Adapted from [garrytan/gstack/qa](https://github.com/garrytan/gstack/tree/main/qa) (MIT).
