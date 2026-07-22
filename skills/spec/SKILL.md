---
name: spec
description: Turn vague intent into a precise, executable spec in 5 phases. Produces a Markdown spec with problem statement, requirements, data model, API surface, edge cases, and test plan.
version: 1.0.0
allowed-tools:
  - ask-user
  - bash
  - glob
  - grep
  - read
  - write
triggers:
  - spec this
  - write the spec
  - what are we actually building
  - turn this into a ticket
  - spec this out
---

# spec

5-phase spec authoring. Adapted from
[garrytan/gstack/spec](https://github.com/garrytan/gstack/tree/main/spec).

## When to use

- Before any project > 1 day of work
- When the user has written a paragraph and you need a one-page spec
- When the codebase has been growing without an authoritative design doc
- When you need to communicate the plan to another engineer / future-you

## The 5 phases

### Phase 1: Problem statement

One paragraph. Who has the problem, what is it, what do they do today,
why is that bad. No solution yet.

### Phase 2: Requirements (numbered)

Each requirement is testable. Number them so you can refer to them in
code review.

Bad: "the system should be fast."
Good: "search returns in <300ms for 10k listings."

Mark each as:
- **MUST** — blocks ship
- **SHOULD** — blocks ship-quality rating
- **MAY** — nice to have

### Phase 3: Data model

Tables, columns, types, indexes. Don't write SQL — write the shape.
Show relationships. Call out immutable (audit log) vs mutable
(user-edited fields).

### Phase 4: API surface

For each endpoint:
- Method + path
- Auth requirement
- Request schema (types, not just shape)
- Response schema
- Error cases (each one)

For non-API projects: each user flow, step by step, with the screen/state
transition at each step.

### Phase 5: Edge cases + test plan

**Edge cases section:** every weird input you can think of.
- Empty input (no listings, no users, empty cart)
- Massive input (1M listings, 100k users)
- Concurrent input (two users edit same row)
- Adversarial input (1KB string in name, negative price, future date)
- Network failure (API down, timeout)
- Stale data (caller sees 5-second-old snapshot)

**Test plan section:** for each requirement in Phase 2, name the test
that proves it. If you can't name the test, the requirement is vague.

## Output

Save to `specs/SPEC-YYYY-MM-DD-<slug>.md`:

```markdown
# SPEC: <one-line title>

## 1. Problem
<one paragraph>

## 2. Requirements
1. **MUST** — system does X
2. **SHOULD** — system does Y in < 300ms
3. **MAY** — system supports Z

## 3. Data model
### table_a
| column | type | notes |
| --- | --- | --- |
| id | int PK | auto |
| created_at | timestamp | immutable |

## 4. API surface
### POST /things
- Request: `{ name: str, ... }`
- Response: `201 { id: int, ... }`
- Errors: `400` (validation), `409` (conflict)

## 5. Edge cases
- Empty listing: returns 404 with structured error
- 1M listings: paginated, no full-table scans
- Concurrent edit: row-level lock prevents lost update

## 6. Test plan
- Req #1: `test_post_thing_creates_row`
- Req #2: `test_get_thing_returns_within_300ms`
```

## Voice

Write the spec the way you'd want to read it 6 months from now when you
forgot everything. Be specific. No "we will consider" — say what you'll
do or don't.

## Anti-patterns

- Spec-as-fiction ("the system is elegant, scalable, secure")
- Spec-as-todo-list (numbered items without testable requirements)
- Spec-as-vision ("users will love this") — wrong document
- Skipping edge cases ("we'll handle those in implementation")
- Vague test plans ("unit tests", "integration tests")

## Example

Spec for `used-car-monitor`:

```
## 1. Problem
Used-car buyers in Texas can't tell when a Facebook Marketplace listing
is a real deal vs a scam. They manually cross-check 5-10 sites, miss
NHTSA recall data, and overpay by 10-30%.

## 2. Requirements
1. MUST — Ingest listings from Craigslist (file feed + opt-in MCP)
2. MUST — Cross-check VIN against NHTSA vPIC
3. MUST — Flag open recalls before alerting
4. MUST — All alerts human-approved before outbound contact
5. SHOULD — Return discount % vs local comps
6. SHOULD — Run as daily cron, output to Telegram

## 3. Data model
### listings
| column | type | notes |
| --- | --- | --- |
| id | int PK | |
| listing_id | str | source-provided, deduped via fingerprint |
| source | str | "craigslist:austin" |
| ask_price | float | |
| year/make/model | str | parsed from title |

## 4. API surface (CLI)
### used-car-monitor run --brief N
- Runs pipeline for brief N
- Output: JSON summary

### used-car-monitor approve --listing-id N --max-offer X
- Records approval, sets status = contacted
- Does NOT send any messages

## 5. Edge cases
- Fake VIN: NHTSA returns error code 1 → hard stop
- No VIN in listing: skip NHTSA check, warn
- Same listing seen twice: dedupe by fingerprint, no duplicate alerts
- Cron job killed mid-run: idempotent on next run

## 6. Test plan
- Req #1: `test_craigslist_adapter_parses_real_listings`
- Req #2: `test_nhtsa_decode_hard_stops_on_fake_vin`
- Req #3: `test_recall_count_in_alert_payload`
- Req #4: `test_approve_does_not_send_message`
```

## Source

Adapted from [garrytan/gstack/spec](https://github.com/garrytan/gstack/tree/main/spec) (MIT).
