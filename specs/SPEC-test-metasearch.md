# SPEC: MetaSearch — local-first semantic search over atlas-store daily vault

## 1. Problem
`atlas-store` runs a daily cron that scrapes 40+ AI-tool vendor sites
and writes one Markdown file per vendor per day. Zinou reads all 40 files
each morning to find signals worth acting on. Of 40 files read
2026-07-23, only 1 ("Make, n8n funding round") drove a downstream
action. Volume is now 2.5× what it was 4 weeks ago; signal-to-noise
ratio dropped below 1%. The user needs a way to query that corpus with
free-text questions and get the 1-3 chunks that actually matter.

## 2. Requirements
1. **MUST** — CLI: `metasearch "query string"` returns top-3 chunks
   ranked by relevance, each with source-file path + date + 1-line summary.
2. **MUST** — All processing local (no data leaves the machine — vault
   content is private).
3. **MUST** — Embedding model pinned to a specific version in
   `requirements.txt`; reinstalling doesn't change behavior.
4. **MUST** — Initial index build time for 42 files <60s; per-query
   latency <5s on a 6-year-old laptop.
5. **SHOULD** — Daily cron rebuilds the index after vault updates.
6. **SHOULD** — Watchpoint: log to stderr if relevant chunk score is
   below 0.5 (means retrieval quality dropped).
7. **SHOULD** — CLI supports `--top N` and `--min-score X` flags.
8. **MAY** — Auto-categorize queries ("pricing / funding / product /
   infra") for routing to different embedding subsets.

## 3. Data model

### chunks

| column | type | notes |
| --- | --- | --- |
| id | int PK | auto |
| chunk_text | str | ≤500 chars per chunk, split on paragraph break |
| source_file | str | absolute path to vault file |
| source_date | date | parsed from filename prefix (YYYY-MM-DD-vendor.md) |
| vendor | str | parsed from filename |
| embedding | list[float] | 384-dim (all-MiniLM-L6-v2) |
| created_at | timestamp | immutable |

### indexes

| column | type | notes |
| --- | --- | --- |
| Primary | PK(id) | btree |
| Source | (source_file, source_date) | btree, supports "what came from vendor X today" |
| Semantic | HNSW over embedding | vector index for cosine similarity |

### queries (audit log)

| column | type | notes |
| --- | --- | --- |
| id | int PK | auto |
| query_text | str | |
| top_chunks | list[int] | FK chunk.id |
| relevance_scores | list[float] | |
| run_at | timestamp | immutable |

## 4. API surface (CLI)

```bash
metasearch "what changed in agent infra this week?"
metasearch --top 5 --min-score 0.6 "any new pricing models?"
metasearch rebuild              # rebuild full index
metasearch rebuild --since 7d  # incremental
metasearch status              # index size, last built time
```

### Output schema

```json
{
  "query": "...",
  "top_k": 3,
  "results": [
    {
      "chunk_id": 42,
      "score": 0.87,
      "source_file": "...",
      "source_date": "2026-07-22",
      "vendor": "n8n",
      "summary": "n8n raises $50M Series B for agent infra expansion",
      "preview": "first 200 chars of chunk_text..."
    }
  ],
  "latency_ms": 187
}
```

### Errors

- empty query → exit 1 + "usage: metasearch <query>"
- no index yet → exit 2 + "run 'metasearch rebuild' first"
- vault dir missing → exit 3 + "VAULT_DIR not set"

## 5. Edge cases

- Empty vault (0 files) → status reports "0 chunks indexed"
- Single large file (1MB) → chunked, not OOM
- Concurrent rebuild + query → query blocks on snapshot at query-start
- Duplicate vendor same-day entries → dedupe by `(vendor, date)`,
  keep newest
- Adversarial query (1MB string) → reject with "query too long"
- Network failure → none (fully local) — but disk full during rebuild
  → graceful exit, log "no space left on device"
- Stale embedding model (newer model released) → bump
  `EMBEDDING_VERSION` constant; rebuild surfaces "embedding upgraded,
  reindex needed"
- Markdown with malformed dates → skip file, log warning
- File changes mid-rebuild → use temp index, atomic swap

## 6. Test plan

| Req # | Test | Pass criteria |
|---|---|---|
| 1 | `metasearch "acquisition"` returns top-3 chunks JSON | exit 0, JSON parses, results non-empty |
| 2 | Curl any cloud LLM endpoint should be netstat-disconnected during build/query | netstat shows no outgoing 443 except local Chroma |
| 3 | Reinstall same model → identical output | byte-equal for top-3 results across installs |
| 4 | Index 42 files on real vault → <60s | wall-clock under 60s |
| 4 | Query against 42-file vault → <5s | wall-clock under 5s |
| 5 | Drop 1 new file in vault → next day's cron rebuilds automatically | chunk count +1 |
| 6 | Force relevance score <0.5 manually → stderr logs the warning | visible in stderr |
| 7 | `--top 5` returns 5 results, `--min-score 0.9` filters low-relevance | count honors flag |
| 8 | Categorize queries via heuristic | output includes "category" field |

## Voice
Write the spec the way you'd want to read it 6 months from now when you
forgot everything. Be specific. No "we will consider" — say what you'll
do or don't.

## Anti-patterns
- Spec-as-fiction ("the system is elegant, scalable, secure")
- Spec-as-todo-list (numbered items without testable requirements)
- Spec-as-vision ("users will love this") — wrong document
- Skipping edge cases ("we'll handle those in implementation")
- Vague test plans ("unit tests", "integration tests")

