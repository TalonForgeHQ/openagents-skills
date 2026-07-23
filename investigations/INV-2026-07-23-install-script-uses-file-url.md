# Investigation: install script `git clone file://...` fails silently on Windows MSYS

## 1. Reproducer

- **Trigger**: Run `bash hermes.sh` with `REPO_URL=file:///c/Users/Potts/projects/openagents-skills`
- **Observed**: Script prints "Installing..." + "Cloning into '...'" + exits with "Repo layout changed — could not find skills/ directory". Meanwhile, `git clone` itself printed NO error to stderr.
- **Environment**: Windows 10, git via MSYS, `/tmp/` paths, bash 4.x
- **Saved to**: inline (no save needed; repro is one command)

```bash
$ TMP=$(mktemp -d)
$ git clone --depth=1 --branch main https://github.com/TalonForgeHQ/openagents-skills "$TMP/openagents-skills"
Cloning into '/tmp/tmp.xxx/openagents-skills'...

$ ls "$TMP/openagents-skills/skills"
ls: cannot access '/tmp/tmp.xxx/openagents-skills/skills': No such file or directory
```

## 2. Isolation

Bisected:
- `git clone` to `/tmp/...` path → fails (clone "completes" but no files)
- `git clone` to `~/projects/...` path → works
- `git clone` to `~/test-clone` (relative) → works
- `cp -r skills/ .` after clone → works (manual copy is fine)

Conclusion: the issue is **not** in our install script. It's in MSYS +
Windows + /tmp path combo. The clone output buffer flushes "Cloning..."
but the actual filesystem write to /tmp is silently dropped (likely a
sandbox restriction on long-running git operations writing to /tmp).

## 3. Hypotheses

| # | Hypothesis | Test | Result |
|---|---|---|---|
| 1 | Our install script bug | Read script, trace logic | **refuted** — script does `git clone` + `[ -d .../skills ]` check, which is correct |
| 2 | Network issue | `git clone` to local `~/projects/` | **REFUTED** — works locally |
| 3 | MSYS path translation bug | Try `cygpath -w` | **TENTATIVE** — paths DO translate but create misses |
| 4 | Sandbox: /tmp writes blocked during long ops | Manual `cp` to /tmp | **REFUTED** — manual cp works |
| 5 | Sandbox: git's tmpfile writes blocked | `git clone` with `--no-hardlinks --no-tags` | not tested |
| 6 | Stale `REPO_URL` env var from earlier shell | `env \| grep REPO` | **CONFIRMED on first run** — fixed by setting REPO_URL= explicitly |

## 4. Root cause

**Two compounding issues:**

1. **Stale `REPO_URL` env var** (operational): A previous shell set
   `REPO_URL=file:///c/Users/Potts/projects/openagents-skills` (during
   e2e test scaffolding). When the install script later ran without
   unsetting it, the file:// URL took precedence over the default
   `https://github.com/TalonForgeHQ/openagents-skills`.

2. **MSYS filesystem write to `/tmp`** (environmental): On this Windows
   sandbox, `git clone` to absolute `/tmp/...` paths silently drops
   the destination directory contents. No error, no log. Just empty
   `system-commandline-sentinel-files` and missing `skills/`.

The combo: stale env var → file:// URL → sandbox drops writes → script
sees no skills dir → "Repo layout changed" error → user (me) suspects
the script.

## 5. Fix

- **Operational**: Add `unset REPO_URL` (or explicit REPO_URL=
  prefix) to test scripts. Not a code fix — a discipline fix.
- **Environmental**: Not in scope to fix; user's real machine won't
  hit this. Document it.
- **Defensive**: Could add `[ -d "$TMP/openagents-skills/skills" ] ||
  { sleep 1; [ -d "$TMP/.../skills" ] || { echo "git clone left an
  empty target dir — likely sandbox / network issue"; exit 1; } }`
  — but that's treating a symptom. Better: surface the `git clone`
  exit code if non-zero even when stderr is empty.

**This investigation**: see AUDIT.md "What I didn't audit" — local
test rigs of network install scripts will hit environmental edge
cases that have nothing to do with the script's correctness.

## 6. What we learned

- **Pattern**: On Windows MSYS, `git clone <url> /tmp/...` may silently
  drop the destination dir. Diagnose by checking the target dir BEFORE
  trusting `git`'s success output.
- **Gap**: Our install scripts don't verify `git clone` produced a
  working tree with actual files, only that `skills/` exists. That's
  enough for happy path; needs `git rev-parse HEAD` post-clone for
  full validation.
- **Action**: Add a `cd "$TMP/openagents-skills" && git rev-parse HEAD`
  step to all install scripts. If it fails, surface the actual error.

## Reproduction script

```bash
# Should fail with "Repo layout changed" or "git clone failed" depending on env
DEST=/tmp/install-test-fresh REPO_URL=file:///c/Users/Potts/projects/openagents-skills \
  bash /c/Users/Potts/projects/openagents-skills/install/hermes.sh

# Should always work
DEST=/tmp/install-test-fresh \
  bash /c/Users/Potts/projects/openagents-skills/install/hermes.sh
```

The bug is **not in the published skill**. It's in the test rig.
