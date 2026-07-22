---
name: autoplan
description: Run CEO + design + eng + DX reviews in sequence on a plan.
version: 1.0.0
allowed-tools:
  - bash
  - read
  - write
---

## When to invoke this skill

Run CEO + design + eng + DX reviews in sequence on a plan.

This skill is a vendor-neutral port of
[garrytan/gstack/autoplan](https://github.com/garrytan/gstack/tree/main/autoplan)
(MIT). The full Claude-Code-specific methodology is preserved at
[`references/upstream-SKILL.md`](references/upstream-SKILL.md).

## How to use it

Read the upstream reference, then adapt the methodology to your agent:

- Replace any Claude-Code-specific runtime bits (`CLAUDE_SKILL_DIR`,
  `$B` browse-binary shorthand, Conductor workspace awareness, gbrain
  memory) with your agent's equivalents.
- Keep the methodology body (the actual reasoning prompts, output formats,
  anti-patterns).
- Add a worked example in `examples/` to make the skill useful without
  reading the upstream.

## Why not a full body?

Some skills in the original gstack are deeply tied to the Claude-Code
runtime (telemetry collection, gbrain cross-project memory, Conductor
workspaces). Stripping those leaves a thin shell — better to acknowledge
that and point you at the upstream than to ship a half-functional
imitation.

## Customization

The upstream methodology is well-tested. The port's job is to make it
work in your agent. Typical adaptations:

- Replace `$B` (browse binary shorthand) with `browser_navigate` /
  `browser_snapshot` / `browser_console` (or your agent's equivalent)
- Replace `CLAUDE_SKILL_DIR` lookups with `$YOUR_AGENT_SKILLS_DIR`
- Replace Conductor workspace awareness with plain git worktree
  awareness
- Replace gbrain memory with your agent's filesystem-based notes

## Source

Adapted from
[garrytan/gstack/autoplan](https://github.com/garrytan/gstack/tree/main/autoplan)
(MIT).
