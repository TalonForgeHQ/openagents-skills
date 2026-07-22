# Contributing to OpenAgents Skills

Thanks for your interest! This project follows a few simple rules.

## Skill format

Every skill is a `SKILL.md` file in `skills/<name>/SKILL.md`. See
[FORMAT.md](FORMAT.md) for the spec.

## Adding a new skill

1. Create `skills/<your-skill-name>/SKILL.md`
2. Follow the format (YAML frontmatter + body)
3. Add at least one worked example (inline or in `examples/`)
4. Add a `## Source` footer with attribution if ported from elsewhere
5. Open a PR

## Upgrading a stub to a production skill

The 25 stub skills need real cross-agent bodies. To upgrade one:

1. Read `skills/<name>/references/upstream-SKILL.md`
2. Strip Claude-Code-specific runtime (slash commands, `CLAUDE_SKILL_DIR`,
   `$B` browse-binary, gbrain, Conductor)
3. Use canonical tool names (`bash`, `read`, `write`, etc.)
4. Add a worked example
5. Replace the stub body with a real methodology
6. Open a PR

A good production skill:
- Has a clear "When to use" / "When NOT to use" section
- Has numbered steps with rationale
- Has a concrete output format (Markdown template)
- Has an "Anti-patterns" section
- Has at least one worked example
- References the original

## Porting a skill from another source

When porting:
- Strip all agent-runtime-specific bits
- Use canonical tool names
- Document what was removed in a `## Customization` section
- Preserve the original at `references/upstream-SKILL.md`

## Updating an existing skill

- Bump the `version` field
- Keep the body content backwards-compatible — these are reasoning prompts,
  not APIs

## Style guide

- Write in plain English. No marketing copy.
- Use bullet lists for steps. Numbered lists only for ordered sequences.
- "Anti-patterns" section is required for every production skill.
- Voice: terse, evidence-driven, allergic to "platform" pitches.

## Reviewing PRs

We accept:
- ✅ Upgrading stubs to production skills
- ✅ Bug fixes in methodology
- ✅ New worked examples
- ✅ Better anti-patterns sections
- ✅ New skills that fit the role taxonomy
- ✅ Translations

We don't accept:
- ❌ Adding Claude-Code-specific runtime (use your own fork)
- ❌ Adding build steps (Bun, npm, etc.)
- ❌ Skills that require proprietary agents or paid APIs
- ❌ Marketing copy in skill descriptions
