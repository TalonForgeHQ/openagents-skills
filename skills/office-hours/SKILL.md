---
name: office-hours
description: Reframe a product idea before writing any code. Ask 7 questions in sequence to clarify the user, wedge, why-now, 10x claim, failure mode, cheapest test, and 30-day ship target. Produces a one-page brief.
version: 1.0.0
allowed-tools:
  - ask-user
  - bash
  - glob
  - read
  - write
triggers:
  - office hours
  - is this worth building
  - should I build this
  - reframe this idea
  - help me think through
---

# office-hours

The first stop for any new project. Reframes a vague idea into something
shippable by asking 7 questions in order. Adapted from
[garrytan/gstack/office-hours](https://github.com/garrytan/gstack/tree/main/office-hours).

## When to use

- New project, vague brief ("I want to build X")
- After writing a spec, before starting to code
- Stuck on positioning
- Asked to evaluate whether an idea is worth the next month of work

## When NOT to use

- You're 80% done and just need to ship
- You already have a one-page brief
- The question is "how do I build this", not "should I build this"

## The 7 questions

Ask one at a time using `ask-user` (or equivalent). Do not batch.

1. **Who is the user?**
   "If you had to pick one person to demo this to, who?"

2. **What's the wedge?**
   "What does this do that nothing else does, in one sentence?"

3. **Why now?**
   "Why couldn't this exist two years ago? What changed?"

4. **What's the 10x claim?**
   "In what specific moment does this feel magical to the user?"

5. **What kills this project?**
   "What's the most likely failure mode? Be specific."

6. **What's the cheapest test?**
   "What experiment can you run THIS WEEK for under $100?"

7. **What does 'done' look like in 30 days?**
   "If you ship nothing else, what's the one thing that has to work?"

## Output

After 7 answers, write a one-page brief to
`office-hours/brief-YYYY-MM-DD.md`:

```markdown
# Brief: <one-line title>

## The user
<one sentence>

## The wedge
<one sentence>

## Why now
<2-3 sentences>

## The 10x moment
<2-3 sentences — be specific>

## What kills this
<1-2 sentences — name the failure mode>

## The cheap test
<2-3 sentences — concrete experiment>

## 30-day ship target
<2-3 sentences — the one thing that has to work>
```

## Voice

Terse, evidence-driven, allergic to "platform" pitches. Replace "users" with
a specific person. If you can't name the person, you don't know the user.

## Red flags to flag

- **Vitamin pitch** — "everyone will benefit"
- **Platform pitch** — "we're building infrastructure"
- **Network-effect bait** — "once we have users it gets better"
- **No failure mode** — if the user can't name what kills it, they haven't thought it through
- **"We'll figure out monetization later"** — no unit economics = no business

## Anti-patterns

- Asking all 7 questions at once (overwhelming)
- Skipping the cheap test (that's where ideas get killed)
- Letting the user off the hook with vague answers ("people who want X")
- Writing the brief yourself instead of capturing what they said

## Example

User said: "I want to build a used-car monitoring tool that auto-messages sellers."

After 7 questions, the brief landed here:

```
## The user
Vlad, 35, mechanic, hunting for a 2016-2020 Tacoma TRD for personal use.

## The wedge
Only tool that flags vehicles *under market* (not just listings),
cross-checks against NHTSA recall + open investigation data.

## Why now
NHTSA published a free SafetyRatings API in 2025 with complaint counts
that no consumer-facing tool exposes. Craigslist's HTML search is the
only ToS-friendly source of cross-listed cars.

## The 10x moment
"Alert me once a week with 2-3 candidates that pass safety + history
checks and are 15%+ under comps" — instead of 30 minutes of manual
research per week.

## What kills this
Meta bans my personal account for FB Marketplace automation, or a
paid valuation API quietly starts charging per call.

## The cheap test
Drop 6 listings into a folder. Run a script that scores them. See
how many legit deals surface in 10 minutes.

## 30-day ship target
Daily cron job that surfaces 0-3 alerts to my Telegram, all in-budget
and pre-vetted.
```

## Source

Adapted from [garrytan/gstack/office-hours](https://github.com/garrytan/gstack/tree/main/office-hours) (MIT).
