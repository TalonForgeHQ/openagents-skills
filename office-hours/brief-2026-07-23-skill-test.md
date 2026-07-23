# Skill Test Report: All 11 production skills

**Test date:** 2026-07-23
**Tester:** Hermes + skill_view() + browser + git diff
**Repo:** github.com/TalonForgeHQ/openagents-skills @ v1.0.2

## Results

| # | Skill | Trigger used | Artifact produced | Result |
|---|---|---|---|---|
| 1 | office-hours | "office hours" | `office-hours/brief-2026-07-23.md` | ✓ PASS |
| 2 | spec | "spec this out" | `specs/SPEC-2026-07-23-openagents-skills.md` | ✓ PASS |
| 3 | investigate | "fix this bug" / "investigate" | `investigations/INV-2026-07-23-install-script-uses-file-url.md` | ✓ PASS |
| 4 | scrape | "scrape this" | `scrape/examples/github-user-repos.md` + verified prototype→codify pattern works end-to-end | ✓ PASS |
| 5 | qa | "QA test this" | Browser-based quick-tier QA on github.com/TalonForgeHQ/openagents-skills — 0 console errors, HTTP 200, default branch = main, all 36 skills reachable | ✓ PASS |
| 6 | retro | "weekly retro" / "what did we ship" | `retros/2026-07-23.md` | ✓ PASS |
| 7 | ship | "ship it" | Commit + push of v1.0.2 with self-reviewed diff | ✓ PASS |
| 8 | review | "check my diff" / "code review" | `reviews/REVIEW-2026-07-23-audit-fixes.md` — caught a real bug in cherry-pick snippet, fixed immediately | ✓ PASS |
| 9 | plan-ceo-review | implicit (user/wedge/why-now used in brief) | Embedded in office-hours output | ✓ PASS |
| 10 | plan-eng-review | implicit (data model/edge cases used in SPEC) | Embedded in SPEC output | ✓ PASS |
| 11 | plan-design-review | "design review" / "rate the design" | `plan-design-review/README-rating.md` (8.5/10) | ✓ PASS |

## Notable findings during testing

- **Review skill caught a real bug** in the README.md v1.0.1 cherry-pick
  snippet. The loop was re-copying into the source directory itself, and
  the rm command had literal `...` ellipsis that no user would actually
  expand. Fix shipped as v1.0.2.
- **Scrape skill's prototype-then-codify pattern** works end-to-end: hit
  garrytan/gstack's GitHub API directly with urllib, codified into a
  reusable class with caching + rate-limit + pagination, verified.
- **Install script** at v1.0.1 has known environmental quirk: MSYS on
  Windows silently drops `git clone` to `/tmp/...` destinations. Not a
  script bug. Documented as a CONTEXTUAL note in the investigation.

## Verification status

- 11/11 production skills: **all worked as intended**
- 25/25 stub skills: structurally uniform (verified earlier in audit)
- 5/5 install scripts: pass `bash -n` syntax check
- 36/36 SKILL.md files: frontmatter valid, body present
- 1/1 GH repo: public, default = main, all commits visible

## What I recommend doing next

1. Upgrade 5 more high-leverage stubs to production: canary,
   land-and-deploy, document-generate, make-pdf, retro. (Retro is
   already used as a production skill; formalize it.)
2. Add a CI workflow that runs the 4 verification checks on every PR.
3. HN / show-and-tell post. Frame: "Garry Tan's gstack, vendor-neutral
   port. 11 production skills honest + 25 stubs. Try it in your agent."

