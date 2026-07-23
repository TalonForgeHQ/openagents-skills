## CEO Review: OpenAgents Skills — Paid Tier ($20/month for premium stub-to-production conversions)

### Posture
**SELECTIVE EXPANSION** — the user's plan is "premium stub-to-production
conversions" at $20/month. Hold that as the baseline. Separately,
surface expansion opportunities.

---

### The 10-star version

The 10-star version of "premium skill conversions" isn't "convert
stubs to production bodies" — that's a 6-star implementation. The
10-star version is **a skill marketplace with reviewer quality scores**:

- Every production-quality skill ships with a `.quality.json` file
  showing: # of distinct agents it's been tested in, regression-test
  pass rate, reviewer rating (1-5), usage telemetry (if user opts in)
- Users can install any agent's skills, and an agent that has high
  cross-agent compatibility gets a "Verified across N agents" badge
- Add a "sponsor a skill upgrade" — anyone can pay $100 to fund the
  production-quality conversion of a stub they care about (e.g.,
  sponsor the `canary` skill; backer gets credit + early access)

Specific 10/10 improvements (one at a time, user opts in):

1. **`skillify-network` skill** — the user says "skillify this" after
   making a successful scrape, and it auto-publishes the codified
   version to a public skill registry (like npm packages).
2. **Cross-agent CI** — GitHub Actions matrix runs each skill against
   Hermes, Claude Code, Codex, Cursor; green badge on the README.
3. **Auto-stub-to-production pipeline** — every stub gets a
   weekly auto-upgrade PR by an LLM that reads the upstream +
   the 11-production-skills-as-few-shot-examples; a human reviewer
   merges.

### Failure modes (top 3)

1. **Nobody pays for stub upgrades.** The free 11 production skills
   are 80% of the value for most users; the marginal value of
   upgrading 25 more stubs is unclear. $20/month × 10 paying users
   = $200/month, which doesn't cover infra costs of a marketplace.
2. **Quality crisis.** One bad production body (e.g., a `qa-only`
   that's actually a security scanner) shipped to paid users poisons
   the brand. The marketplace adds a *delivery* surface, not just a
   *generation* surface.
3. **Maintainer burden.** Convert-the-stubs costs ~2-3 hours per skill.
   25 stubs × 2.5 hrs = 62.5 hrs to clear the backlog. If paid
   subscribers expect "convert within a week", the schedule is
   undeliverable.

### Landmines

- **License laundering.** If the upstream gstack methodology has
  "no commercial derivative works" anywhere (it doesn't, but if so),
  a paid tier would be incompatible. Verify MIT compatibility of
  paid derivatives — they probably are, but a counsel check before
  $20 MRR matters.
- **Stripe webhook is on this machine.** A successful paid product
  needs anywhere-available payments + customer portal + tax
  handling (Stripe Atlas at minimum). The current local-Python infra
  isn't designed for that.
- **No refund policy.** If a user pays $20 and the stub-to-production
  body is mediocre, refund requests become a support burden. Need
  "preview before you pay" — show a diff first, charge only after
  user approves.

### Observability

- **Success metric**: % of paid subscribers who install >=5 production
  skills within their first month. Target: >60%.
- **Failure metric**: refund rate > 10% in any 30-day window OR
  churn rate > 40% after first paid month.
- **Alerts**:
  - Any single skill install fails for >5% of downloads → page on-call
  - Marketplace search latency > 2s → auto-throttle + alert
  - New conversion PR doesn't get reviewer-merge in 7 days → nudge

### Recommended scope changes (opt-in)

1. **Add a `pricing` skill** that auto-generates pricing tier copy from
   a CSV. Effort: 4 hours. Worth it because: paid-tier copy needs
   consistent voice across pricing page, sales email, FAQ. Reduces
   drift between docs.
2. **Defer the marketplace**. Don't ship stub-to-production-as-a-service
   until you have ≥5 paying customers asking for it. Otherwise you're
   shipping infra without product-market fit.
3. **Add a `paid-tier` config file** (`paid-tier.yaml`) listing which
   skills are in the paid tier, why, what conversion cost is, and
   who maintains it. Treats pricing as a first-class artifact, not
   a footnote.
4. **Public roadmap**: `roadmap.md` listing which stubs you'll
   upgrade next, by date. Free users see the queue; subscribers see
   it first. Helps acquisition ("oh I can vote on which to fund") and
   reduces support requests.
5. **Lower the price for first 100 users.** $20/month is a
   "YC-style founder pricing" — but you have <100 customers, not
   100,000. Try $5/month for the first 100 customers; once you
   hit 100, raise. Cheaper to learn from real paid users.

### Critical rule reminder

In ALL modes (including this one), every scope change is an explicit
opt-in. The CEO review does NOT ship anything. The user decides.
