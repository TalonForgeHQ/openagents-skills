# OpenAgents Skills

**A vendor-neutral skill suite for AI coding agents.**

11 production-ready skills + 25 honest stubs that work the same way in
Hermes Agent, Claude Code, Codex, Cursor, Aider, and any LLM that can
read a file.

> Forked from [garrytan/gstack](https://github.com/garrytan/gstack) (123k★)
> and stripped of Claude-Code-specific runtime. Every skill here is plain
> Markdown with YAML frontmatter. No build step, no Bun, no proprietary
> hooks.

## Why

Garry Tan's gstack is one of the best structured engineering workflows
published in 2026. The problem: it's tied to Claude Code's slash-command
runtime, Bun build step, gbrain memory system, and Conductor workspaces.
The reasoning plays (7 questions to reframe a product idea, 6-step
debugging, etc.) are agent-agnostic and valuable to anyone shipping
software with AI assistance.

This repo takes the 36 reasoning skills and ships them as a portable skill
format. The same SKILL.md works in any agent that supports the conventions
documented in [FORMAT.md](FORMAT.md).

## What's in the box

### Production-ready cross-agent skills (11)

These have full vendor-neutral bodies, written from scratch using the
upstream methodology as reference:

| Skill | What it does |
|---|---|
| [office-hours](skills/office-hours/) | 7 questions to reframe a product idea before code |
| [spec](skills/spec/) | 5-phase spec from vague intent |
| [investigate](skills/investigate/) | 6-step root-cause debugging |
| [qa](skills/qa/) | Headless browser QA, 3 tiers, health score 0-100 |
| [scrape](skills/scrape/) | Prototype-then-codify web scraper pattern |
| [retro](skills/retro/) | Weekly engineering retrospective |
| [ship](skills/ship/) | Test, review, changelog, commit, push, PR |
| [review](skills/review/) | Pre-landing code review checklist |
| [plan-ceo-review](skills/plan-ceo-review/) | 4-posture CEO review, 10-star product |
| [plan-eng-review](skills/plan-eng-review/) | Lock architecture, data flow, edge cases |
| [plan-design-review](skills/plan-design-review/) | Rate each design dimension 0-10 |

### Stubs (25)

These have a clean frontmatter + a pointer to the upstream reference at
`references/upstream-SKILL.md`. They're honest: read the upstream,
adapt the methodology to your agent's runtime.

The 25 stubs cover: `autoplan`, `canary`, `context-save`,
`context-restore`, `design-consultation`, `design-html`, `design-review`,
`design-shotgun`, `devex-review`, `diagram`, `document-generate`,
`document-release`, `gstack-openclaw-ceo-review`,
`gstack-openclaw-investigate`, `gstack-openclaw-office-hours`,
`gstack-openclaw-retro`, `land-and-deploy`, `landing-report`, `learn`,
`make-pdf`, `pair-agent`, `plan-devex-review`, `plan-tune`, `qa-only`,
`skillify`.

## Install

```bash
# Hermes Agent (Windows / Mac / Linux)
curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/hermes.sh | bash
# or Windows:
curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/hermes.bat -o install.bat && install.bat

# Claude Code
curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/claude-code.sh | bash

# Codex CLI
curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/codex.sh | bash

# Cursor (project-scoped)
cd your-project && curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/cursor.sh | bash

# Manual / generic — point your agent at this repo
git clone https://github.com/TalonForgeHQ/openagents-skills
# then say "load the skills from openagents-skills/skills/"
```

## Format

Every skill is a Markdown file with YAML frontmatter. See [FORMAT.md](FORMAT.md)
for the spec. Tools required are named using canonical identifiers
(`bash`, `read`, `write`, `edit`, `glob`, `grep`, `web-search`, `ask-user`,
`agent-task`, `browser`). Each agent's installer maps those to the
agent's own tool names.

## What we kept vs what we cut

**Kept** (the reasoning plays and templates):
- 11 production skills with full cross-agent bodies
- 25 stub skills with clean frontmatter + upstream reference
- The role taxonomy (CEO / Eng Manager / Designer / QA / Release /
  Debugger / Docs)
- The methodology bodies (7 questions, 5 phases, 6 steps)

**Cut** (Claude Code runtime dependencies):
- Bun build pipeline (`bun.lock`, `bunfig.toml`, `SKILL.md.tmpl` auto-generation)
- `gbrain` cross-project memory system (replaced with `references/upstream-SKILL.md` files)
- `Conductor` workspace awareness (replaced with plain git worktree awareness)
- `CLAUDE_SKILL_DIR` env vars and shell hooks
- `~/.claude/` directory hard-codes
- Conductor-specific binaries and YAML configs
- iOS / Swift design review skills (Claude-Code-only asset pipeline)
- `gstack-upgrade`, `setup-gbrain`, `sync-gbrain`, `setup-deploy` (Claude runtime management)

## Why some skills are stubs

The 11 production-ready skills are the highest-leverage ones. The
remaining 25 from the original gstack are deeply tied to the Claude-Code
runtime (telemetry collection, gbrain cross-project memory, Conductor
workspaces, the `$B` browse-binary shorthand). Stripping those would
leave a half-functional imitation that's worse than no skill at all.

Each stub is honest about this — it has a clean frontmatter so your
agent can find it by trigger phrase, and a `references/upstream-SKILL.md`
that points at the full original methodology. The `Customization`
section tells you what to replace when you port it.

## Slim install

If you don't need the upstream references (each is 50-100KB), delete
them after install:

```bash
rm -rf ~/.hermes/skills/*/references/
```

This brings the install down from ~2.6 MB to ~150 KB without affecting
any skill functionality.

## Contributing

1. Pick a skill to customize (or write a new one)
2. Follow [FORMAT.md](FORMAT.md)
3. Add a `## Examples` section with at least one real-world example
4. Open a PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for the style guide.

## License

MIT — same as the original gstack.

## Credits

- Original gstack by [Garry Tan](https://x.com/garrytan), President & CEO of Y Combinator
- Port + cross-agent refactor by [TalonForgeHQ](https://github.com/TalonForgeHQ)
- Inspired by the broader movement toward vendor-neutral AI tooling
