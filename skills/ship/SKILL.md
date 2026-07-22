---
name: ship
description: Ship workflow — run tests, review the diff, update CHANGELOG, commit, push, open a PR. Adapted from garrytan/gstack/ship with agent-agnostic git workflow.
version: 1.0.0
allowed-tools:
  - bash
  - edit
  - glob
  - grep
  - read
  - write
triggers:
  - ship it
  - create a pr
  - push to main
  - ship this
---

# ship

Ship a feature. Adapted from
[garrytan/gstack/ship](https://github.com/garrytan/gstack/tree/main/ship).

## When to use

- Code is ready, want to push + open a PR
- After `review` has cleared the diff
- End of a focused work block

## The steps

1. **Run the test suite.** If it fails, stop. Fix first, ship after.
2. **Review your own diff.** `git diff main...HEAD` — read every line.
   If you can't explain why a line is there, delete it.
3. **Update CHANGELOG.md.** Add an entry under "Unreleased" describing
   the change in user-facing terms. Not "fixed bug" — "VIN decode now
   hard-stops on fake VINs."
4. **Bump VERSION** if the project uses one.
5. **Commit.** One commit per logical change. Message format:
   `<type>(<scope>): <description>` (conventional commits).
6. **Push.** `git push origin <branch>`.
7. **Open PR.** Title = commit message. Body = CHANGELOG entry +
   bullet list of changes + how to test.

## Output

A successful ship leaves:
- A clean main branch (or merge-ready PR)
- Updated CHANGELOG.md
- A test plan that's been executed

## Anti-patterns

- **Skipping the test suite** — "I'll fix that in the next PR" = never
- **Reviewing your own diff optimistically** — read every line
- **Vague CHANGELOG entries** — "improvements" tells no one anything
- **Mega-commits** — split logically separate changes into separate commits
- **"I'll update the PR description later"** — write it now while context is fresh

## Source

Adapted from [garrytan/gstack/ship](https://github.com/garrytan/gstack/tree/main/ship) (MIT).
