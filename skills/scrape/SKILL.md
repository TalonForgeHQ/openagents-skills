---
name: scrape
description: Pull structured data from a web page. Two-call pattern: prototype interactively to find selectors, then codify into a fast headless script. Includes decision tree for common site types (HTML, JSON API, SPA, bot-blocked).
version: 1.0.0
allowed-tools:
  - bash
  - browser
  - glob
  - grep
  - read
  - write
triggers:
  - scrape this
  - scrape this page
  - extract data from
  - get listings from
  - pull from page
---

# scrape

Web → structured data. Two-call pattern: prototype first, codify second.
Adapted from
[garrytan/gstack/scrape](https://github.com/garrytan/gstack/tree/main/scrape).

## When to use

- Extract structured data from a web page
- Monitor a page for changes (price drop, new listing)
- Build a discovery adapter (used-car monitor, news feed, etc.)
- Have a URL and want JSON back

## Ask the user first

- **URL + what they want extracted** — don't guess fields
- **Refresh cadence** — every call? hourly? daily?
- **Volume** — 10 records? 10k? 100k? Drives pagination
- **Failure behavior** — alert on empty? alert on change? alert on schema drift?

## The two-call pattern

### Call 1: Prototype (interactive, 5-30 minutes)

Use the browser to:

1. Load the page
2. Inspect the HTML — find the repeating element (`.result`, `li.cl-search-result`)
3. Identify the fields and their selectors / regex
4. Pull a sample of 5-10 records
5. **Validate the sample** — does it match reality?

Output: a working Python function `def prototype_scrape(url) -> list[dict]`
that pulls from the live page. Slow but correct.

### Call 2: Codify (fast, headless)

Take the prototype and turn it into a deterministic script:

1. **No browser required** — `urllib.request` + regex / BeautifulSoup
2. **Cache the request** — save HTML to disk on first call, replay in tests
3. **Handle pagination** — usually `?page=N` or `?offset=N`
4. **Handle rate limiting** — sleep between calls, respect `Retry-After`
5. **Handle schema drift** — empty result + warning, alert on cron

**Speed target:** < 500ms per page, < 5s for 10 pages.

## Decision tree: which approach?

| Site type | Pattern | Example |
|---|---|---|
| HTML search results | Regex on repeating `<li class="...">` blocks | Craigslist, eBay listings |
| JSON API | `urllib.request` + `json.loads` | NHTSA, CarsXE |
| Server-rendered SPA | Look for `<script id="__NEXT_DATA__">` block | Next.js sites |
| Client-rendered SPA | Headless browser required (slow path) | React, Vue apps |
| Bot-blocked site | **STOP.** Find an alternative API or accept it can't be done. | CarGurus, KBB |

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Skipping the prototype | Always prototype first. You'll get the regex wrong 3x. |
| Hardcoded selectors | Test against the live page, not your saved HTML |
| Trusting rendered text | Look at raw HTML — sometimes post-JS |
| No rate limiting | Even legal sites ban you for hammering |
| One regex per field | Grab the whole block, regex inside |

## Output

Two files in the project:

```
scrape/
  prototype_<slug>.py     # the 5-30 min interactive version
  codify_<slug>.py        # the <500ms headless version
```

The codified version is what goes into the cron job.

## Anti-patterns

- "I'll just write the regex from the HTML." — you'll get it wrong 3 times.
- Reading rendered text instead of raw HTML.
- No cache for the first run.
- One big function that does everything.
- Ignoring rate limiting even on legal sites.

## Example: Craigslist listings

**Prototype** (interactive):
```python
import re, urllib.request
body = urllib.request.urlopen(url).read().decode()
# Find <li class="cl-static-search-result">...</li>
for m in re.finditer(r'<li class="cl-static-search-result.*?>(.*?)</li>', body, re.S):
    block = m.group(1)
    title = re.search(r'<div class="title">(.*?)</div>', block).group(1)
    price = re.search(r'<div class="price">\$(.*?)</div>', block).group(1)
    url = re.search(r'<a href="(.*?)"', block).group(1)
    # ... returns dict
```

**Codify** (fast, with pagination + caching + rate limit):
```python
import re, urllib.request, json, time, hashlib

CACHE = Path("scrape/cache")
CACHE.mkdir(exist_ok=True)

def fetch_page(url: str) -> str:
    cache_key = hashlib.md5(url.encode()).hexdigest() + ".html"
    cached = CACHE / cache_key
    if cached.exists():
        return cached.read_text()
    body = urllib.request.urlopen(url, timeout=20).read().decode()
    cached.write_text(body)
    time.sleep(2)  # rate limit
    return body

def scrape_all(base_url: str) -> list[dict]:
    out = []
    page = 0
    while True:
        html = fetch_page(f"{base_url}&page={page}")
        items = parse_page(html)
        if not items:
            break
        out.extend(items)
        page += 1
    return out
```

## Source

Adapted from [garrytan/gstack/scrape](https://github.com/garrytan/gstack/tree/main/scrape) (MIT).
