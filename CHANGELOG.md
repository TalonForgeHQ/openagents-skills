# Changelog

## 1.0.0 — 2026-07-22

Initial port from garrytan/gstack. 36 skills total.

### Production-ready cross-agent bodies (11)

These have full vendor-neutral bodies written from scratch:

- office-hours, spec, investigate, qa, scrape, retro, ship, review,
  plan-ceo-review, plan-eng-review, plan-design-review

### Stubs (25)

Honest pointers to the upstream reference at
`references/upstream-SKILL.md`. The `Customization` section tells you
what to replace for your agent.

- autoplan, canary, context-save, context-restore, design-consultation,
  design-html, design-review, design-shotgun, devex-review, diagram,
  document-generate, document-release, gstack-openclaw-{ceo-review,
  investigate, office-hours, retro}, land-and-deploy, landing-report,
  learn, make-pdf, pair-agent, plan-devex-review, plan-tune, qa-only,
  skillify

### Format

- Vendor-neutral Markdown with canonical tool names (`bash`, `read`,
  `write`, `edit`, `glob`, `grep`, `web-search`, `ask-user`,
  `agent-task`, `browser`)
- Install scripts for Hermes Agent, Claude Code, Codex CLI, Cursor
- Each skill preserves its upstream original at
  `references/upstream-SKILL.md` for diffing
