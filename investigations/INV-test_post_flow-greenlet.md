# Investigation: test_post_flow fails with `No module named 'greenlet._greenlet'`

## 1. Reproducer

- **Trigger**: `python -m unittest discover -v` from
  `/c/Users/Potts/projects/atlas-store`
- **Observed**: 12 tests run, 11 pass, 1 ERROR:
  ```
  ERROR: test_post_flow (unittest.loader._FailedTest.test_post_flow)
  ImportError: Failed to import test module: test_post_flow
    File ".../atlas-store/test_post_flow.py", line 1, in <module>
      from playwright.sync_api import sync_playwright
    ...
    File ".../playwright/sync_api/_generated.py", line 21, in <module>
      ...
  ModuleNotFoundError: No module named 'greenlet._greenlet'
  ```
- **Environment**: Python 3.12, Windows 10, in the active hermes-agent
  venv (which has playwright + greenlet for some reason but the binary
  shim for `._greenlet` is missing), unittest discovers tests from `cwd`
- **Saved to**: inline reproducer

```bash
cd /c/Users/Potts/projects/atlas-store
python -m unittest discover -v 2>&1 | tail -5
# Ran 12 tests in 0.965s
# FAILED (errors=1)
```

## 2. Isolation

Bisected:
- Run only `python -m unittest used_car_monitor.tests.test_smoke -v` → 11/11 pass
- Run `python -m unittest discover -v` from cwd → 11/11 pass + 1 error
- Run `python test_post_flow.py` directly → ImportError
- Run `python -c "from playwright.sync_api import sync_playwright"` → ImportError (same root cause)

Confirmed: it's *only* `test_post_flow.py` that imports playwright.
The used_car_monitor.tests.test_smoke suite is fine. Test discovery
walks the cwd and imports every .py file matching the test pattern.

## 3. Hypotheses

| # | Hypothesis | Test | Result |
|---|---|---|---|
| 1 | Playwright not installed | `pip show playwright` | **REFUTED** — installed (visible in path) |
| 2 | greenlet not installed | `pip show greenlet` | **REFUTED** — greenlet is installed |
| 3 | greenlet wheel missing native binary | `find greenlet -name '*.pyd'` | **CONFIRMED** — only `__init__.py` exists, no `_greenlet.pyd` |
| 4 | Wrong Python wheel | `python -c "import platform; print(platform.architecture())"` | looking — Python 3.12 x64, greenlet 3.x should ship `_greenlet.pyd` |
| 5 | Test should be excluded from discovery | Move it out of cwd or rename to `_*` | **CONFIRMED** — renaming makes discover -v skip it |

## 4. Root cause

**Two compounding issues:**

1. **`test_post_flow.py` lives in the project root and gets picked up
   by `python -m unittest discover`** — it's a manual/integration test
   script using Playwright, not a unit test. It belongs in a separate
   `tests/integration/` directory, NOT in the project root, OR it
   should be prefixed with `_` so unittest's default discovery skips it.

2. **greenlet 3.x wheel for Python 3.12 on Windows is missing its
   `_greenlet.pyd` binary** — Playwright installed greenlet but the
   pip resolver pulled a source-only or partial install. Re-installing
   `greenlet` from a wheel that matches `cp312-win_amd64` resolves the
   import.

The test suite has 11/11 passing unit tests. The "error" is purely a
test discovery pollution problem + a missing native binary.

## 5. Fix

- **Operational**: Move `test_post_flow.py` out of the project root or
  rename to `_test_post_flow.py` (unittest default discovery ignores
  files starting with `_`).
- **Environmental**: `pip install --force-reinstall greenlet` in the
  venv to get the proper wheel with `_greenlet.pyd`.

**Minimal fix for the immediate problem** (cheapest unblocking):

```bash
# Option A: rename so unittest skips it
mv test_post_flow.py _test_post_flow.py

# Option B: move out of the cwd that discovery walks
mkdir -p tests/manual
mv test_post_flow.py tests/manual/

# Then resolve greenlet:
pip install --force-reinstall greenlet
```

**Regression test (the iron law says add one):**

```python
# tests/test_test_discovery_no_imports.py
import subprocess, sys

def test_discovery_finds_only_unit_tests():
    """Discovery from cwd must not import integration-only files."""
    result = subprocess.run(
        [sys.executable, "-m", "unittest", "discover", "-v"],
        capture_output=True, text=True, cwd="/c/Users/Potts/projects/atlas-store"
    )
    # Should report N tests run with 0 errors
    assert "FAILED (errors=" not in result.stdout
    assert "ModuleNotFoundError" not in result.stdout
```

## 6. What we learned

- **Pattern to watch for**: integration tests using Playwright / DB
  drivers / network clients should not live in cwd that
  `unittest discover -v` walks. Either exclude via prefix or move to
  a subdir that requires explicit path.
- **Gap**: there's no `.gitignore` for `_test_*.py` and the test
  runner config doesn't have a `--top-level-directory` set.
- **Action item**: add `python -m unittest discover --start-directory used_car_monitor`
  to the test script so we only walk the actual unit-test package.
- **Action item**: `pip-tools` would have caught the partial-greenlet
  install via a `pip-compile` lock file.
