# Retro: 2026-07-23 (skills-cycle)

## What we shipped

- **11 production skills** in TalonForgeHQ/openagents-skills, each
  tested end-to-end on Hermes against a fresh real task.
- **AUDIT.md**: 5 issues found + fixed, 14 claims verified, all listed
  with severity.
- **v1.0.2 published**: README cherry-pick bug caught by `review`
  skill and fixed in commit 8cbf494.
- **Skill-test artifacts**: brief, SPEC, investigation, review,
  retro, design rating — 6 markdown documents produced by running
  the production skills through their methodology.

## What broke

- **`/tmp` git clone silently fails on Windows MSYS** — install
  scripts appear to succeed but the destination is empty. Not our
  bug, but our tests had to work around it. Documented in
  `INV-2026-07-23-install-script-uses-file-url.md`.
- **`python -m unittest discover` picks up `test_post_flow.py` from
  project root** — integration test gets treated as a unit test,
  fails with `greenlet._greenlet` missing. Cleanly diagnosed using
  the `investigate` skill.
- **README cherry-pick snippet had `cp -r $dir $dir/..`** — would
  have copied each skill into itself. `review` skill caught it before
  the second push shipped.

## What we learned

- **The production skills, when invoked with a real task, produce
  real artifacts that follow the prescribed structure**. Not magic —
  the skills are just well-written reasoning prompts that constrain
  LLM output to a useful shape.
- **The review skill caught a self-introduced bug** in v1.0.1's
  cherry-pick snippet. This is the strongest evidence yet that the
  skills work: they corrected an LLM-introduced defect, not just
  human-written code.
- **Scraping PyPI** is much simpler than scraping Craigslist (HTML
  vs JSON API). The skill's "decision tree" is right: prefer JSON
  APIs when available. Cache, rate-limit, error handling are easy
  to retrofit.
- **The `qa` skill's CAPTCHA finding on PyPI search** is exactly the
  kind of issue that only shows up under automation — real users
  never see it. Worth flagging in CI tools.

## What we'll change next week

- [ ] Upgrade 5 more stubs to production bodies: canary,
      land-and-deploy, document-generate, make-pdf, retro.
- [ ] Add CI workflow: lint YAML frontmatter, `bash -n` install
      scripts, run `skill_view()` on each skill to verify Hermes
      can load it.
- [ ] Cross-agent smoke test: install on Codex / Cursor / Claude
      Code (need access to those tools first), verify each loader
      parses the YAML correctly.
- [ ] Add `tests/manual/` convention for integration tests so
      `unittest discover` doesn't pick them up.
- [ ] Re-install greenlet wheel properly in the hermes-agent venv
      so the test suite reports 12/12 not 11/12.

## Pattern watch list

- **Test discovery pollution**: any file matching `test_*.py` in cwd
  gets picked up by `unittest discover`. Integration tests using
  Playwright / DB drivers should live in `tests/manual/` or be
  prefixed with `_`.
- **Cross-agent skill format**: claims "works in any agent" remain
  unverified for 4 of 5 target agents. Need real loaders to test.
- **Auto-trim residue**: budget time to rewrite N% of bodies rather
  than patching `[PORT-REMOVED]` markers later.
- **README snippets with placeholder ellipsis `...`**: always
  expand or remove. Users will copy-paste literally.
