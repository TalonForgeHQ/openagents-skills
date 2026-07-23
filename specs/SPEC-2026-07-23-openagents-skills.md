# SPEC: OpenAgents Skills — vendor-neutral skill format

## 1. Problem
Indie devs running multiple AI agents (Hermes, Claude Code, Codex, Cursor,
Aider) want to install Garry Tan's gstack but it only works in Claude Code.
The reasoning plays are portable; the runtime isn't. Every user either (a)
picks one agent and surrenders portability or (b) maintains per-agent forks.
We want to fork the methodology once, ship it as Markdown, and let any
agent load it.

## 2. Requirements
1. **MUST** — Single `SKILL.md` format loads in Hermes Agent, Claude Code,
   Codex CLI, Cursor, Aider, and any LLM that reads Markdown.
2. **MUST** — Canonical tool-name vocabulary (`bash`, `read`, `write`,
   `edit`, `glob`, `grep`, `web-search`, `ask-user`, `agent-task`,
   `browser`). Each agent maps canonical names onto its own tools.
3. **MUST** — YAML frontmatter (name / description / allowed-tools /
   version) with optional triggers list.
4. **SHOULD** — Production skills have real cross-agent bodies (no
   Claude-Code residue). Stub skills point at upstream with explicit
   "what to replace" hints.
5. **SHOULD** — Upstream reference preserved at `references/upstream-SKILL.md`
   per stub (so reviewers can diff).
6. **SHOULD** — One-line `curl | bash` install per target agent.
7. **MAY** — Per-agent name-table adapter for canonical-name mapping.

## 3. Data model

### skill_version

| column | type | notes |
|---|---|---|
| name | str | kebab-case, matches dir name |
| description | str | one sentence, agents match this |
| version | semver | bumped on body changes |
| allowed_tools | list[str] | canonical names |
| triggers | list[str] | phrases the agent matches |
| is_production | bool | true = full body, false = stub |

### install_adapter

| column | type | notes |
|---|---|---|
| agent_name | str | "hermes" / "claude-code" / "codex" / "cursor" / "aider" |
| skills_dir | str | absolute path the agent scans |
| canonical_to_native | map[str,str] | `bash` → `terminal`, etc. |

### upstream_ref

| column | type | notes |
|---|---|---|
| skill_name | str | FK |
| upstream_path | str | garrytan/gstack/<name>/SKILL.md |
| sha | str | git commit of upstream |
| fetched_at | timestamp | immutable |

## 4. API surface

### CLI (no HTTP API — this is a content distribution)

```bash
# install.sh (per agent)
mkdir -p "${DEST:-$HOME/.hermes/skills}"
git clone --depth=1 --branch main \
  https://github.com/TalonForgeHQ/openagents-skills \
  /tmp/openagents-install
cp -r /tmp/openagents-install/skills/. "${DEST}/"
rm -rf /tmp/openagents-install
```

### Loader contract

When agent scans `${skills_dir}/<name>/SKILL.md`:
1. Parse YAML frontmatter
2. Strip frontmatter, load body as Markdown
3. Match user prompt against `description` and `triggers[]`
4. If match, inject body as system-prompt prefix
5. Filter `allowed_tools` through canonical→native mapping

## 5. Edge cases

- **Malformed YAML frontmatter** → loader skips skill, logs warning
- **Empty `triggers`** → skill only matches on `description` text
- **Canonical tool has no native equivalent** → loader emits warning,
  strips from `allowed_tools` (skill runs with reduced tool set)
- **Network failure during `git clone`** → exit 1, user retries manually
- **Slim install (`rm references/`)** → production skills unaffected;
  stubs lose their reference but stay functionally complete
- **Skill body uses Claude-specific shorthand (`$B` for browse binary,
  etc.)** → user sees stub-style warning in body Customization section
- **Two skills with same name across nested dirs** → loader refuses
  to guess, requires full categorized path
- **Skill content drift from upstream** → out of scope for v1; noted
  in CONTRIBUTING.md

## 6. Test plan

| Req # | Test | Success criteria |
|---|---|---|
| 1 | `bash -n install/*.sh` | exit 0 |
| 1 | Run `hermes.sh` with `DEST=/tmp/x` | 36 skills in `/tmp/x` |
| 2 | Grep skill frontmatter for tool names | all names in canonical set |
| 3 | `python -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1]))"` | no parse error |
| 4 | Grep production skills for `[PORT-REMOVED]` | 0 hits |
| 4 | `wc -l skills/*/SKILL.md` for production | 60-200 lines each |
| 5 | `ls skills/*/references/upstream-SKILL.md` | 36 files |
| 6 | Manually run curl-to-bash | succeeds |
| 7 | Hermes loads `office-hours` skill | `skill_view` returns full body |

## Voice
Write the spec the way you'd want to read it 6 months from now when you
forgot everything. Be specific. No "we will consider" — say what you'll
do or don't.

## Anti-patterns
- **Spec-as-fiction** ("the system is elegant, scalable, secure")
- **Spec-as-todo-list** (numbered items without testable requirements)
- **Spec-as-vision** ("users will love this") — wrong document
- **Skipping edge cases** ("we'll handle those in implementation")
- **Vague test plans** ("unit tests", "integration tests")
