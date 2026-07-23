## Review: OpenAgents Skills v1.0.0 → v1.0.1 (audit fixes)

**Reviewer:** Hermes + review skill methodology
**Diff scope:** 5 files, 53 insertions, 9 deletions

### Blocking (must fix before merge — N/A here, this is already merged)

None.

### Non-blocking (nice to have)

- [README.md] **The cherry-pick snippet has a typo / bug**
  - File: README.md:133
  - Issue: The loop does `cp -r ~/.hermes/skills/$dir ~/.hermes/skills/` —
    this re-copies each skill INSIDE its own directory (because DEST
    already exists), then `rm -rf ~/.hermes/skills/canary ...` is meant
    to remove stubs but the example shows literal `...` ellipsis
    without the full list of 25 stub names.
  - Suggested fix: Either (a) show the full rm list, or (b) invert the
    logic — show "start from clean, copy only production":

    ```bash
    # install only the 11 production skills
    DEST=~/.hermes/skills
    for dir in office-hours spec investigate qa scrape retro ship review \
               plan-ceo-review plan-eng-review plan-design-review; do
      curl ... > /tmp/openagents-skills.tar
      tar -xzf /tmp/openagents-skills.tar -C /tmp
      cp -r "/tmp/openagents-skills/skills/$dir" "$DEST/"
    done
    ```

  Severity: **medium** — the snippet is wrong as written, users following
  it will have an inconsistent install.

### Questions

- [README.md] **Was the slim-install number measured or estimated?**
  - The "3.5 MB → 1.2 MB" change — did we measure both before/after on
    disk, or use `du` on the local repo? My own measurement (in the
  audit script) ran `du -sh skills/` which is the same metric, but the
  user-facing claim should be defensible.

### Praise

- The AUDIT.md report is exemplary: it documents 5 issues found + fixed,
  14 claims verified, and explicitly lists what wasn't audited. That's
  the discipline I want from this repo.
- The branch fix (default to `main`, delete `master`) directly addressed
  the symptom someone visiting the repo would have hit. Good catch.
- The `.gitignore` is standard excludes, not over-engineered.

### Checklist summary

- [x] Correctness — every fix matches what the audit claimed
- [x] Security — no secrets added, no URL leaks, .gitignore excludes
  editor temp files
- [x] Performance — no perf changes; README loses 14 lines, gains 25
- [x] Maintainability — clarify "what the install scripts do" vs
  "where mapping happens"
- [x] Operability — hermes.bat now has dir existence checks, will
  fail loud instead of silent
- [x] Documentation — AUDIT.md is the kind of artifact that makes
  this repo credible

### Verdict

**Approve with one nit.** The cherry-pick block in README.md is wrong
as written. Either fix it or remove it. Otherwise the audit fixes
cleanly address every issue found.

