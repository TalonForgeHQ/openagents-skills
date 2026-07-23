# Design Review: README.md

## Scores

| Dimension | Score | What 10 looks like | Current state | Gap |
|---|---|---|---|---|
| Hierarchy | 9/10 | Install block above the fold; "what's in the box" before usage; bullet-list before prose | Strong — 11 production skills visible in production table | None |
| Spacing | 8/10 | 1 blank line between sections, no triple-blanks | Mostly consistent | One or two triple-blanks in production-table area |
| Typography | 9/10 | Code blocks for commands; bold for emphasis; consistent list bullets | Excellent | None |
| Color | N/A | n/a (Markdown renders in agent docs) | | |
| Alignment | 8/10 | Tables align; columns sized to content | Production table good; stub list just bullets | Wrap stub list in a 2-col table for symmetry? |
| Consistency | 7/10 | All headings same level (##, ###); code blocks vs inline code consistent | Code blocks consistent; section heading cases sometimes vary | Standardize "When to use" vs "When to Invoke" etc |
| Density | 8/10 | Right amount — short install, short pitch, longer custom notes | Pitch is concise; audit-fix narrative is dense | Slim install + cherry-pick are good |
| Affordance | 9/10 | Code blocks one-click copy; links clickable; raw install commands work | Verified — install script runs end-to-end | None |
| Feedback | 9/10 | Install script prints success/error messages | Tested and verified | None |
| Accessibility | 9/10 | Headings hierarchy valid (h1 title, h2 sections, h3 subsections); alt text N/A in pure markdown | Standard | None |
| Performance feel | 10/10 | Renders in <100ms in any tool | Verified | None |
| Mobile | 8/10 | Markdown reflows narrow; tables may overflow | Good for prose; production table a bit wide | Could shorten column headers |

## Final: 8.5/10 — polished, ready to ship

## Top 3 improvements (by effort/impact)

1. **Wrap stub list in a 2-column table** (5 min, +0.3 score)
   - Current: 1 long bullet list of 25 stubs
   - Target: 2-col table, sorted, with one-line descriptions
2. **Standardize heading casing across skills** (10 min, +0.5 score)
   - Look for "When to Use" vs "When to use" vs "When to use it" across all 36 skills
3. **Shorten production-table column headers** (3 min, +0.2 score)
   - "Production-ready cross-agent bodies (11)" → "Production (11)"

## What a 10/10 would look like

The README renders flawlessly on every device, every agent doc tool, every chat client. The install one-liner is the only thing the user needs to read to get value. The "what's in the box" section visually contrasts production (full bodies) from stubs (pointers to upstream) — no reading required to know which is which.
