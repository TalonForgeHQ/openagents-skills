---
name: plan-design-review
description: Design review. Rate each design dimension 0-10. Explain what a 10 looks like. Find the gap and the next improvement.
version: 1.0.0
allowed-tools:
  - ask-user
  - bash
  - glob
  - read
triggers:
  - design review
  - rate the design
  - what would 10 look like
  - visual review
---

# plan-design-review

Rate each design dimension 0-10. Find the gap and the next improvement.
Adapted from
[garrytan/gstack/plan-design-review](https://github.com/garrytan/gstack/tree/main/plan-design-review).

## The dimensions

Rate each on 0-10:

| Dimension | What it measures |
|---|---|
| **Hierarchy** | Is the visual weight right? Most important thing most prominent? |
| **Spacing** | Is whitespace intentional or accidental? |
| **Typography** | Are type sizes/scale ratios harmonious? |
| **Color** | Is the palette restrained or chaotic? Does it serve the content? |
| **Alignment** | Is everything on a grid or are there floaters? |
| **Consistency** | Are similar things treated similarly? |
| **Density** | Is the right amount of info per screen? Too much? Too little? |
| **Affordance** | Do interactive elements look interactive? |
| **Feedback** | Do actions have visible responses? |
| **Accessibility** | Color contrast, focus states, alt text, screen reader? |
| **Performance feel** | Does it feel fast? Are loading states handled? |
| **Mobile** | Does the mobile layout work? Or is it the desktop squished? |

## For each dimension

- **Score (0-10)**
- **What a 10 looks like** — concrete description
- **Current state** — what's actually there
- **Gap** — the specific improvement that would close it
- **Effort** — rough cost (hours / days / weeks)

## The overall

```
score = sum of dimensions / 12

0-3:   rough sketch
4-6:   functional but unrefined
7-8:   polished, ready to ship
9-10:  extraordinary
```

## Output

```
## Design Review: <feature or page>

### Scores
| Dimension | Score | What 10 looks like | Gap |
|---|---|---|---|
| Hierarchy | 7/10 | clear focal point, scannable | reduce secondary text by 30% |
| Spacing | 6/10 | 8/16/24 rhythm | standardize to 8px base |
| ... | ... | ... | ... |

### Final: 6.8/10 — functional but unrefined

### Top 3 improvements (by effort/impact)
1. **Standardize spacing** — 4h, +1.5 overall
2. **Improve hierarchy** — 2h, +0.8 overall
3. **Mobile breakpoint** — 8h, +1.0 overall

### What a 10/10 would look like
<paragraph describing the platonic ideal>
```

## Anti-patterns

- Scoring without explaining what a 10 looks like
- Skipping dimensions because they're "fine"
- Recommending changes that don't move the needle
- Generic praise ("the design is good") without naming specifics

## Source

Adapted from [garrytan/gstack/plan-design-review](https://github.com/garrytan/gstack/tree/main/plan-design-review) (MIT).
