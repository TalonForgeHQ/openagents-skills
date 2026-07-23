# OpenAgents Skill Format

## Goal

One SKILL.md works in Hermes Agent, Claude Code, Codex, Cursor, Aider, and any
LLM that can read a file. No build step. No proprietary runtime.

## The format

```markdown
---
name: kebab-case-skill-name
description: One sentence — when to invoke this skill. Use this exact phrasing when adding to a skill directory because some agents (Hermes) match on description text.
version: 1.0.0
allowed-tools:
  - bash
  - read
  - write
  - edit
  - glob
  - grep
  - web-search
  - ask-user
  - agent-task
  - browser
triggers:
  - phrase 1
  - phrase 2
  - phrase 3
references:        # optional, replaces gbrain
  - references/prior-learnings.md
examples:          # optional
  - examples/spec-for-tacoma-monitor.md
---

# Skill Title

Body of the skill — the actual reasoning prompt, methodology, output format.

## When to use
...

## Methodology
...

## Output format
...

## Anti-patterns
...

## Examples
See [examples/](examples/) for worked examples.

## Source
Where this came from (link to original, attribution).
```

## Canonical tool names

| Canonical | Hermes Agent | Claude Code | Codex CLI | Cursor | Aider |
|---|---|---|---|---|---|
| `bash` | `terminal` | `Bash` | `shell` | `terminal` | `bash` |
| `read` | `read_file` | `Read` | `read_file` | `read_file` | `read` |
| `write` | `write_file` | `Write` | `write_file` | `write_file` | `write` |
| `edit` | `patch` | `Edit` | `edit_file` | `edit_file` | `edit` |
| `glob` | `search_files` | `Glob` | `glob_files` | `glob_files` | `glob` |
| `grep` | `search_files` | `Grep` | `grep_files` | `grep_files` | `grep` |
| `web-search` | `web_search` | `WebSearch` | `web_search` | `web_search` | `web_search` |
| `ask-user` | `clarify` | `AskUserQuestion` | `ask_user` | `ask_user` | `ask` |
| `agent-task` | `delegate_task` | `Agent` | `codex-subagent` | `composer` | (none) |
| `browser` | `browser_*` | `WebFetch`/`WebSearch`/`mcp:*browser*` | `browser` | `browser` | `browser` |

## How tool names map at install time

Skill frontmatter uses canonical names (`bash`, `read`, etc.). Each agent
loads skills by reading the SKILL.md file and matching its own loader:

- **Hermes Agent**: canonical names match native tool names directly
  (`read` → `read_file`, `grep` → `search_files`, etc. — Hermes has a
  name aliasing layer that maps the canonical name onto its internal
  tool identifier)
- **Claude Code / Codex / Cursor**: each agent's loader maps canonical
  names onto its own tools via lookup tables. If a canonical name has
  no equivalent in the target agent, the loader issues a warning and
  drops the tool from `allowed-tools` for that agent.
- **Aider / bare LLM**: no tool layer — the agent must interpret the
  canonical names literally and translate them to its own tools.

The install scripts in [install/](install/) only clone + copy. The
mapping happens at skill-load time inside each agent. To customize,
override one agent's name table — see the per-skill
`Customization` section.

## File layout

A skill can be a single SKILL.md or a directory:

```
skill-name/
├── SKILL.md              # required
├── references/           # optional, agent loads on demand
│   └── ...
├── examples/             # optional
│   └── ...
└── scripts/              # optional, portable shell scripts
    └── ...
```

Single-file layout for small skills:
```
skill-name.md
```

## Naming

- Directory: `kebab-case-skill-name/`
- Single file: `kebab-case-skill-name.md`
- `name` frontmatter must match the file/directory name

## Description

The `description` field is the trigger. Be specific. Agents match on this text
when the user says something like "office hours" or "reframe this idea".

Bad:
```
description: Helps with products
```

Good:
```
description: Reframe a product idea before code is written. Use when the user says "office hours", "is this worth building", "reframe this idea", or wants Garry-Tan-style structured product thinking.
```

## Triggers

List common phrases the user might say. Each agent matches on these.

## Anti-patterns

Every skill should have an "Anti-patterns" section. The whole point of using
a skill over a free-form prompt is to encode the failure modes.

## Examples

Every skill should have at least one worked example. Either inline at the
bottom of SKILL.md, or in an `examples/` directory.

## Versioning

Bump version on any change to SKILL.md body. Keep semver. Agents can use
this to detect updates.
