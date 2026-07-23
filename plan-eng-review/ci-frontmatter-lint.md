# Plan Eng Review: CI workflow — validate skill frontmatter + run install scripts on every PR

## Context

OpenAgents Skills has 36 SKILL.md files but zero automated validation.
A recent user introduced an invalid SKILL.md (pair-agent's name field
got replaced by a literal string after the auto-cleanup pass), which
was caught only by a manual audit. We need CI to catch this at PR time,
not after merge.

## Architecture

```
.github/workflows/validate-skills.yml
    └─ on: pull_request, push to main
        └─ jobs:
            ├─ lint-frontmatter (Python)
            │   └─ parses every skills/*/SKILL.md
            │      ├─ YAML frontmatter valid
            │      ├─ name matches dir name
            │      ├─ description < 200 chars
            │      ├─ allowed-tools only contains canonical names
            │      └─ no [PORT-REMOVED] markers in body
            ├─ install-syntax
            │   └─ bash -n install/*.sh
            └─ smoke-load
                └─ python smoke.py
                    └─ for each production skill (production flag):
                        emulate skill_view() parse
```

Components:
- **validate_skills.py** (~120 lines): walks skills/, parses YAML,
  reports failures as GitHub Actions annotations
- **install-syntax** job (~5 lines): `bash -n` per install script
- **smoke-load** job (~30 lines): parses each SKILL.md as if it were
  Hermes loading it — verifies frontmatter structure matches what
  the docs claim

Dependencies:
- PyYAML (already in hermes-agent venv)
- GitHub Actions runner (already free for public repos)
- Python 3.12+ (the runner has it)

Failure modes:
- YAML parse error → fail CI
- Invalid tool name (e.g., `bashful` instead of `bash`) → warn
- Mismatched name/dir → fail CI
- `[PORT-REMOVED]` residue → warn (we have <current count>, should be 0)

## Data model

### skills (filesystem-only)
```
skills/<name>/
├── SKILL.md              # required, the only validated file
└── references/
    └── upstream-SKILL.md # optional, ignored by CI
```

### CI-side reporting
Each PR adds 1 annotation per failure via:
```
::error file=skills/canary/SKILL.md::description='$name' must equal '$dirname'
```

## API surface (CI workflow)

```yaml
name: validate-skills
on:
  pull_request:
  push:
    branches: [main]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.12"}
      - run: pip install pyyaml
      - run: python scripts/validate_skills.py
        # exits non-zero on any failure
  install-syntax:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          for f in install/*.sh; do
            bash -n "$f" || exit 1
          done
```

Errors:
- Bad YAML → exit 1, GitHub annotations
- Mismatched name → exit 1, annotation
- Tool name not in canonical set → non-fatal warning
- `[PORT-REMOVED]` residue → non-fatal warning

## Edge cases

- **SKILL.md is empty** → fail ("no body")
- **SKILL.md has Windows line endings** → warn (we've hit CRLF warnings)
- **Frontmatter delimiters wrong** (`---` instead of `---`) → fail
- **`allowed-tools` is missing entirely** → warn (we have stubs without it)
- **`triggers` is empty** → warn, not fail (some skills are documentation-only)
- **Multiple skills in same dir** → fail ("skill collision")
- **Skill dir exists but no SKILL.md** → fail ("orphaned dir")
- **Upstream reference missing** → warn (stubs without upstream = confused user)
- **CI runner timeout** → fail at 60s; the validate script should be <10s
- **Concurrent PRs** → jobs run in parallel matrix, no state conflicts
- **Action version pinned to @vN** → if pinned to a major that breaks,
  we're stuck. Pin to commit SHA instead.

## Build / Deploy / Rollback

- **Build**: CI workflow file is plain YAML, no build step
- **Deploy**: merged-to-main auto-activates the workflow
- **Rollback**: revert the workflow commit; runs against next push
- **Rollback time target**: < 1 minute (revert PR + merge)

## Risks (top 3)

1. **CI runner false positives**. The validate_skills.py logic may be
   wrong (e.g., a legitimate `name` with emoji should match). Mitigation:
   start with warn-only, escalate to fail after 1 week of clean runs.
2. **Bundled PyYAML version drift**. PyYAML changes its API rarely but
   uses C extensions that could break on a new runner image. Pin to
   `PyYAML==6.0.1` in the workflow.
3. **CI minutes cost**. Free for public repos, but if the repo gets
   private it's $0.008/minute. Current workflow will be <2min total.
   Likely <2% of free quota.

## Tests (per requirement)

- Req "every skill has valid frontmatter":
  - `tests/test_validate_skills.py` — passes when every SKILL.md parses
- Req "name matches dir":
  - `tests/test_name_match.py` — verifies the rule
- Req "tool names canonical":
  - `tests/test_canonical_tools.py` — fails on `bashful`
- Req "no [PORT-REMOVED] in production bodies":
  - `tests/test_no_residue.py` — fails on any match

CI itself proves the build is good. Unit tests prove the linter
is good. Together: any future bad PR is caught at PR time.

## Effort estimate

- `validate_skills.py`: 4 hours (120 lines + 4 unit tests)
- Workflow YAML: 1 hour
- First real PR with workflow enabled: 30 min to debug any issues
- Total: ~6 hours, single PR

## Anti-patterns (for this plan)

- ❌ Auto-fixing YAML in a commit (CI shouldn't mutate; should report)
- ❌ Locking install scripts to a specific shell version (use `bash` not `/bin/bash`)
- ❌ One mega-job that runs everything (each job should be independent
      so partial failures are visible)
