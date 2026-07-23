# Design Review: README.md install section

## Scores

| Dimension | Score | What 10 looks like | Current state | Gap |
|---|---|---|---|---|
| Hierarchy | 9/10 | One install command visible without scrolling on a 1080p monitor | Pass — 5 install commands, one per agent, each copy-pasteable | None |
| Spacing | 7/10 | 1 blank between sections, no triple-blanks | Triple-blanks appear after a few blocks (around `## What's in the box`) | Single sed pass to normalize |
| Typography | 9/10 | Code blocks for commands; bold for emphasis; bullets for list | Mostly good — the install one-liners use fenced ```bash``` correctly | Wrap install commands in language-tagged fenced blocks |
| Color | N/A | n/a (Markdown) | | |
| Alignment | 9/10 | Tables align, columns sized to content | Production table uses `\| description \|` with descriptions truncated to ~50 chars | Production column widths look fine |
| Consistency | 6/10 | Same heading levels (h2, h3) used throughout | Install commands across 5 agents use slightly different phrasings ("Hermes Agent on Windows / Mac / Linux" vs "Claude Code" without OS note) | Normalize all 5 to same structural pattern |
| Density | 8/10 | Right amount — short pitch, short install, longer custom notes | Good | None |
| Affordance | 9/10 | Code blocks one-click copy; links clickable | Verified earlier (curl returns 200) | None |
| Feedback | 8/10 | Install script prints success/error messages | Yes, verified earlier | None |
| Accessibility | 9/10 | Headings hierarchy valid (h1 → h2 → h3) | Standard | Code-block lang tags would help screen readers (`bash`, `sh`) |
| Performance feel | 10/10 | Renders <100ms in any tool | Markdown is light | None |
| Mobile | 7/10 | Markdown reflows narrow; tables may overflow | Production table is ~80 chars wide — overflows on phone-sized viewports | Add a `<details>` collapsible summary for production skill list |

## Final: 8.3/10 — polished, ready to ship

## Top 3 improvements (by effort/impact)

1. **Normalize install command phrasing across all 5 agents**
   (10 min, +1.0 score)
   - Current: 5 different phrasings ("on Windows / Mac / Linux"
     for Hermes, no OS note for Claude Code/Codex/Cursor, "cd
     your-project &&" for Cursor)
   - Target: same structure for each — `### <agent name>\n\n\`\`\`bash\ncurl ... | bash\n\`\`\`\n`
2. **Add language tags to code blocks** (3 min, +0.5 score)
   - Current: most ```bash``` already tagged; some bare ``` ``` remain
   - Verify all install commands are tagged with `bash`
3. **Collapse production-skill list on mobile** (15 min, +0.5 score)
   - Current: 11-row table for production skills
   - Target: keep table on desktop, `<details><summary>Show all production skills</summary>` on mobile

## What a 10/10 would look like

The README renders in a way that a user who has never seen the
project can:
1. Within 3 seconds of landing, know the project's value prop
2. Within 5 seconds, copy the install command for their agent
3. Within 10 seconds, see what skills are included
4. Without scrolling, see the install + what's in the box sections

Currently, on a 1080p monitor, all 4 fit above the fold. On a
phone, points 3-4 require scrolling, which is acceptable.

## Anti-patterns to verify (no instances)

- No "marketing copy" — the pitch is one sentence, plain English ✓
- No fake stats ("10,000+ installs") — claims are verifiable ✓
- No emoji as the only emphasis ✓
- No "click here" link text — every link is descriptive ✓
- No "LGTM" / "looks good" vibe in any section ✓

## What the v1.0.x changelog says about design

The CHANGELOG.md has 1 release note (v1.0.0). It does not call out
design improvements. Consider: link from CHANGELOG to design review
artifacts at `plan-design-review/README-rating.md` so future audits
can see "was this section reviewed?".
