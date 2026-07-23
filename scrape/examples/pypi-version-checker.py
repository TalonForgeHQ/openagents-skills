"""Scrape skill test 4: PyPI simple API → prototype-then-codify.

Different target than the GitHub-user-repos example in the skill doc.
Tests the skill's prescription on a different real source.

Pattern (from the skill):
  1. PROTOTYPE: 5-min interactive, gets the response shape right
  2. CODIFY: production version with cache + rate-limit + pagination
"""

import urllib.request, json, time
from pathlib import Path

CACHE = Path("/tmp/scrape-cache-pypi")
CACHE.mkdir(exist_ok=True)

# === PHASE 1: PROTOTYPE (5-min interactive) ===
print("=== PROTOTYPE phase: PyPI for 'requests' ===")
url = "https://pypi.org/pypi/requests/json"
body = urllib.request.urlopen(url, timeout=10).read().decode()
data = json.loads(body)
print(f"  Latest version: {data['info']['version']}")
print(f"  Author:          {data['info'].get('author', '?')}")
print(f"  Summary:         {data['info']['summary'][:80]}")
print(f"  Releases count:  {len(data['releases'])}")
print()

# Probe for a different package to validate the pattern is generic
print("=== PROTOTYPE phase: PyPI for 'chromadb' ===")
body2 = urllib.request.urlopen("https://pypi.org/pypi/chromadb/json", timeout=10).read().decode()
data2 = json.loads(body2)
print(f"  Latest version: {data2['info']['version']}")
print(f"  Summary: {data2['info']['summary'][:80]}")
print()

# === PHASE 2: CODIFY (production version) ===
print("=== CODIFY phase: PyPiVersionChecker class ===")

class PyPiVersionChecker:
    """Codified: cache + rate-limit + error handling."""

    def __init__(self, cache_dir="/tmp/scrape-cache-pypi",
                 rate_limit_seconds=1.0, max_retries=2):
        self.cache = Path(cache_dir); self.cache.mkdir(exist_ok=True)
        self.rate_limit = rate_limit_seconds; self._last = 0.0
        self.max_retries = max_retries

    def _throttle(self):
        elapsed = time.time() - self._last
        if elapsed < self.rate_limit:
            time.sleep(self.rate_limit - elapsed)
        self._last = time.time()

    def fetch(self, package: str) -> dict:
        """Fetch latest version of `package` from PyPI. Returns {} on miss."""
        key = self.cache / f"{package}.json"
        if key.exists():
            data = json.loads(key.read_text())
            return {"name": data["info"]["name"],
                    "version": data["info"]["version"],
                    "summary": data["info"]["summary"],
                    "cached": True}
        url = f"https://pypi.org/pypi/{package}/json"
        for attempt in range(self.max_retries + 1):
            self._throttle()
            try:
                body = urllib.request.urlopen(url, timeout=10).read().decode()
                data = json.loads(body)
                key.write_text(body)
                return {"name": data["info"]["name"],
                        "version": data["info"]["version"],
                        "summary": data["info"]["summary"],
                        "cached": False}
            except urllib.error.HTTPError as e:
                if e.code == 404:
                    return {}
                if attempt == self.max_retries:
                    raise
                time.sleep(2 ** attempt)  # exponential backoff
        return {}

checker = PyPiVersionChecker()
for pkg in ["requests", "chromadb", "playwright", "openai", "anthropic",
            "fake-package-name-xyzzy", "rich"]:
    r = checker.fetch(pkg)
    if r:
        print(f"  {r['name']:25s} {r['version']:12s}  cached={r['cached']}  {r['summary'][:50]}")
    else:
        print(f"  {pkg:25s} NOT FOUND")

# Validate cache hit on re-run
print()
print("=== Cache hit validation ===")
for pkg in ["requests", "rich"]:
    r = checker.fetch(pkg)
    if r.get("cached"):
        print(f"  ✓ {pkg}: cache hit confirmed")
    else:
        print(f"  ✗ {pkg}: cache miss (unexpected)")

print()
print(f"Cache files on disk: {len(list(CACHE.glob('*.json')))}")
