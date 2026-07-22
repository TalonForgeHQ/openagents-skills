---
name: plan-eng-review
description: Engineering manager review of a plan. Lock the architecture, data flow, edge cases, and tests. Flag risks before code is written.
version: 1.0.0
allowed-tools:
  - ask-user
  - bash
  - glob
  - grep
  - read
triggers:
  - eng review
  - architecture review
  - lock the plan
  - what's the data flow
---

# plan-eng-review

Eng-manager review. Lock architecture before code is written. Adapted from
[garrytan/gstack/plan-eng-review](https://github.com/garrytan/gstack/tree/main/plan-eng-review).

## When to use

- Plan is approved at CEO level, now needs to be buildable
- Before writing a spec
- Before starting any project > 1 day of work

## The review

### 1. Architecture

For each component:
- What is its responsibility (one sentence)?
- What does it depend on?
- What depends on it?
- What's its failure mode?

Draw or describe the data flow:
- Where does data come from?
- Where does it go?
- Where does it get transformed?

### 2. Data model

- What entities exist?
- What are their fields?
- What's mutable vs immutable?
- What indexes are needed?
- What's the cardinality of relationships (1:1, 1:N, N:M)?

### 3. Edge cases

For each input, name:
- Empty case (no records)
- Maximum case (records at limit)
- Concurrent case (two users editing same row)
- Adversarial case (1KB string in name field)
- Failure case (network down, API 500, disk full)
- Stale data case (caller sees 5-second-old snapshot)

### 4. Tests

For each requirement:
- What unit test proves it?
- What integration test proves it?
- What manual test verifies it works?

### 5. Risks

Name the top 3 risks:
- What could go wrong?
- How likely?
- What's the mitigation?

### 6. Build/Deploy

- How does this get built?
- How does this get deployed?
- How does this get rolled back?
- What's the rollback time target?

## Output

```
## Eng Review: <plan title>

### Architecture
- <component>: <responsibility>. Depends on <X>. Failure mode: <Y>.

### Data flow
[diagram or step-by-step description]

### Data model
| entity | field | type | mutable | notes |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

### Edge cases
- Empty: ...
- Max: ...
- Concurrent: ...
- Adversarial: ...
- Failure: ...
- Stale: ...

### Tests
- Unit: <list>
- Integration: <list>
- Manual: <list>

### Risks (top 3)
1. <risk> — <likelihood>. Mitigation: <mitigation>.

### Build / Deploy
- Build: <command>
- Deploy: <process>
- Rollback: <process>, target <time>
```

## Anti-patterns

- Architecture without failure modes
- Data model without cardinality
- Edge cases without the actual values
- Tests that just say "unit tests"
- Risks without mitigation

## Source

Adapted from [garrytan/gstack/plan-eng-review](https://github.com/garrytan/gstack/tree/main/plan-eng-review) (MIT).
