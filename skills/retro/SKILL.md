---
name: retro
description: Weekly engineering retrospective. Captures what shipped, what broke, what we learned, what we'll change next week. Produces a Markdown file with the four sections.
version: 1.0.0
allowed-tools:
  - bash
  - glob
  - grep
  - read
  - write
triggers:
  - weekly retro
  - what did we ship
  - engineering retrospective
  - end of week review
---

# retro

Weekly engineering retrospective. Four sections. Adapted from
[garrytan/gstack/retro](https://github.com/garrytan/gstack/tree/main/retro).

## When to use

- End of week, want to capture what happened
- After a launch, want to write up the post-mortem
- Quarterly review prep
- Onboarding new team members (they read the last 4 retros)

## The four sections

### 1. What we shipped

Bullet list of completed work. Link to PRs, commits, deployed URLs.
Be specific — "improved onboarding" is useless; "added VIN decoder to
listing import (PR #42)" is good.

### 2. What broke

Bullet list of incidents. For each:
- Date + duration
- What users saw
- Root cause (one sentence)
- Fix (one sentence)
- Prevention (what we'll do differently)

### 3. What we learned

Bullet list of insights. Each should be reusable — something that
saves time in a future session. Examples:
- "CarsXE /specs is paid ($0.15/call) — use NHTSA vPIC instead"
- "Craigslist returns 200 with empty body when rate-limited — sleep 2s between calls"

### 4. What we'll change next week

Bullet list of commitments. Each should be testable. Examples:
- "Add cost_per_call to all adapter metadata"
- "Switch CarsXE history calls to the cheapest endpoint"

## Output

Write to `retros/YYYY-MM-DD.md`:

```markdown
# Retro: YYYY-MM-DD

## What we shipped
- <bullet with link>

## What broke
- **<date> — <title>**
  - Users saw: ...
  - Root cause: ...
  - Fix: ...
  - Prevention: ...

## What we learned
- <insight that saves time in future>

## What we'll change next week
- [ ] <testable commitment>
```

## Anti-patterns

- Generic accomplishments ("shipped a lot") — useless
- "Learned a lot" without specifics
- Vague next-week commitments ("do better") — unfailable, so unmotivating
- Skipping the "what broke" section out of embarrassment
- Writing the retro yourself instead of capturing the team's actual week

## Source

Adapted from [garrytan/gstack/retro](https://github.com/garrytan/gstack/tree/main/retro) (MIT).
