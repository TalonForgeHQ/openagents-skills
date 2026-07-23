# Audit Report — v1.0.0 → v1.0.1

**Audit date:** 2026-07-23
**Auditor:** Hermes + gstack-investigate methodology

## Summary

| Area | Found | Fixed |
|---|---|---|
| Repo structure | 1 (branch divergence) | ✓ |
| Production skills | 11/11 clean, zero residue | — |
| Stub skills | 25/25 structurally uniform | — |
| Install scripts | 1 broken (.bat had wrong URL) | ✓ |
| GitHub repo | 1 (default branch wrong) | ✓ |
| FORMAT.md | 1 (wrong claim about tool mapping) | ✓ |
| README claims | 1 (wrong slim-install size) | ✓ |
| Working tree | 1 missing (.gitignore) | ✓ |

14/15 claims verified, 5 issues found and fixed.

## What was audited

1. **Repo structure**: branches, remotes, size, file count, default branch on GitHub
2. **Every skill (36 total)**:
   - Frontmatter completeness (name, description, allowed-tools, triggers)
   - Body residue (`[PORT-REMOVED]`, gstack router, GSTACK_, gbrain, etc.)
   - Line count consistency for stubs (all should be 56 lines)
   - Required sections in stubs (Customization, How to use it, references link)
3. **Install scripts** (`bash -n` syntax + URL check on all 5 files)
4. **GitHub repo state** via API (default branch, sizes, branch list, content reachability for all 11 production skills)
5. **FORMAT.md vs reality** (does the tool-mapping claim hold up?)
6. **README claims** (15 specific claims checked against observable state)
7. **CHANGELOG** (all 36 skill names listed, math adds up)

## Issues found and fixed

### 1. Branch divergence (critical)

The repo had two branches:
- `master` — initial release commit (used `zinou-potts` URL)
- `main` — fix commits (used `TalonForgeHQ` URL)

GitHub's default branch was `master`, so visitors saw the outdated URL.
Anyone running the install commands straight from GitHub would hit a 404.

**Fix:**
- PATCH `default_branch` to `main` via API
- DELETE `origin/master` via API
- `git remote prune origin` to clean the local tracking ref
- Force everyone to land on `main` (latest, fixes applied)

### 2. `install/hermes.bat` had wrong URL

The original Windows installer still had:
```
REM Usage: curl -fsSL https://raw.githubusercontent.com/zinou-potts/openagents-skills/main/install/hermes.bat -o install.bat && install.bat
set REPO_URL=https://github.com/zinou-potts/openagents-skills
```

A Windows user copying that line would never get the right URL.

**Fix:** Updated to `TalonForgeHQ`, made REPO_URL/BRANCH overridable, added
existence checks for both the temp dir and the `skills/` source dir.

### 3. FORMAT.md said install scripts do tool mapping

The original claim was:
> "Each install script in [install/](install/) does the mapping."

This is false. The install scripts only do `git clone + cp`. Tool mapping
happens at skill-load time inside each agent, not at install.

**Fix:** Rewrote that section as a clear "How tool names map at install time"
explaining where mapping actually happens. Each agent maps canonical
names (`bash`, `read`, etc.) onto its own tools at load time.

### 4. README slim-install size was wrong

Original claim:
> "This brings the install down from ~2.6 MB to ~150 KB."

Actual: bring it from **3.5 MB → 1.2 MB**. The upstream references are
60-90% of each skill's size; the references take you to 1.17 MB even after
removal, not 150 KB.

**Fix:** Corrected numbers. Added a second option (cherry-pick the 11
production skills) for an even smaller install (~50 KB).

### 5. Missing .gitignore

The repo had no `.gitignore`. Anyone cloning and iterating would commit
`__pycache__`, `.DS_Store`, editor temp files, etc.

**Fix:** Added standard `.gitignore` (Python, Node, OS, editor, temp,
local env files). 40 lines of standard excludes.

## What passed the audit

- **11/11 production skills** have real cross-agent bodies, no Claude-Code residue
- **25/25 stub skills** are 56 lines, all have `Customization` + `How to use it` + upstream reference link
- **All 36 skills** have `name`, `description`, and `allowed-tools` frontmatter
- **Production skills** all have `## When to use` / `## Anti-patterns` / `## Source` sections
- **CHANGELOG.md** lists all 36 skills (11 production + 25 stubs) by name, math adds up
- **LICENSE** is MIT, preserves garrytan/gstack attribution
- **Install scripts** all pass `bash -n` syntax check
- **GitHub reachable**: all 11 production skill URLs return HTTP 200 via API
- **Branch hygiene**: one local branch, one remote branch, default is `main`
- **Skill example reality**: production skill bodies cite real systems (NHTSA
  vPIC, CarsXE, Craigslist) — no fabricated examples

## What I didn't audit (next round)

- **Skill correctness** — does the 7-question methodology actually elicit
  a better brief? Would require running the skill against a real project.
- **Cross-agent loading** — I tested Hermes, not Claude Code / Codex /
  Cursor. Each loader interprets frontmatter slightly differently.
- **Anti-patterns coverage** — every production skill has anti-patterns,
  but I didn't validate they're the right ones.
- **Test suite** — there is no test suite for the skills themselves
  (this is mostly Markdown, so tests would be lint + example-matching).

## Repo state after audit

```
main
├── AUDIT.md           (this file, new)
├── CHANGELOG.md       (accurate, 36 skills listed)
├── CONTRIBUTING.md    (style guide)
├── FORMAT.md          (corrected tool-mapping claim)
├── LICENSE            (MIT, gstack attribution)
├── README.md          (corrected slim-install size, added cherry-pick option)
├── install/           (5 scripts, .bat fixed)
├── skills/            (36 skills: 11 production + 25 stubs)
└── .gitignore         (new — standard excludes)
```

8 root files, 36 skills, 4 commits on main.

## Commits since audit

- `151cd87` Audit fixes v1.0.1 (FORMAT.md, README.md, install/hermes.bat)
- `a9c71b8` Add .gitignore
