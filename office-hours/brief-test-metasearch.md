# Brief: MetaSearch — cross-AI-tool relevance engine

## The user
Zinou (zinou potts), who runs `atlas-store`'s daily cron against 40+ AI
tools (Companies, Products, People, Pricing, Tech Stack, Integrations).
Each morning he skims 40 markdown files looking for "does anything
genuinely change today?" Then the relevant signals get folded into a
weekly Learnings brief.

## The wedge
A search index that ranks every signal in the 40-file daily collection
by relevance to Zinou's actual goals (revenue for atlas-store, audience
for OpenAgents Skills, infrastructure for used-car-monitor), not by
recency or by vendor priority. Right now he reads 40 files. He'd need to
read 1.

## Why now
The cron has been running 4 weeks (since 2026-06-26). The volume
crossed the threshold where reading 40 files daily is no longer
sustainable, and the signals worth acting on are now diluted below
1% of total content. Three concrete data points:
- File count grew from 17 (week 1) to 42 (today) — 2.5× in 4 weeks
- Of 42 files read on 2026-07-23, only 1 ("Make, n8n funding round")
  drove a downstream action (a tweet draft the next day)
- "What changed since yesterday" is now the dominant time sink — not
  the value extraction itself

## The 10x moment
"Type a question, get the 1-3 signals from this week's data that
actually matter — with the source file, the date, and the action to
take." Specifically: queries like "what changed in agent infrastructure
this week?" return 2-3 chunks of text (not full files) with provenance
metadata. Reading goes from 30 min/day to 2 min/day.

## What kills this
- The 40-file collection is private vault content; uploading to a
  public LLM endpoint (OpenAI, Anthropic) leaks them. Local embedding
  model + local vector store is the only safe path, and that's a lot
  of plumbing for one person's daily read.
- Zinou's relevance heuristics aren't stable — they shift as
  atlas-store priorities shift. A fixed query embedding model won't
  match his evolving "what matters". Needs a feedback loop.

## The cheap test
Pick 5 representative queries ("who acquired who in agent infra this
week?", "what new pricing models dropped?", "any unblock on the
Facebook Marketplace automation problem?"). Drop the 42 files into
Chroma with `all-MiniLM-L6-v2` local embeddings (free, no network).
Run the queries. For each, check the top-3 results by hand: do they
match what Zinou already noted in his daily skim? If 4/5 queries
return relevant signals in top-3, ship. If <3/5, change the
embedding or chunking.

## The 30-day ship target
A CLI `metasearch "what changed in agent infra today?"` that returns 3
context chunks with source-file-path + date + 1-line summary. Runs
locally. No cloud calls. Inserts into daily Hermes cron as the first
step before Zinou reads anything. Each query takes <5s.
