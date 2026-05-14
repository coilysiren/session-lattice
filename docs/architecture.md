# Architecture

session-lattice is the middle layer of a three-service stack across coilysiren/*.

```
+----------------+        pull          +-----------------+       HTTP        +-------+
|  repo-recall   |  <----------------   | session-lattice |  <------------    | luca  |
|  (Rust)        |    refresh tick      |   (Python)      |   view reads      |  +    |
|                |                      |                 |                   |  CLI  |
|  joins +       |                      |   Feldera SQL   |                   |       |
|  searches +    |                      |   pipelines     |                   |       |
|  per-source    |                      |   (IVM engine)  |                   |       |
|  caches        |                      |                 |                   |       |
+----------------+                      +-----------------+                   +-------+
```

## Each layer's job

### repo-recall (upstream)

Authoritative store of primary data. Parses Claude session JSONL, walks git logs, queries GitHub. Joins and searches across those sources. Each source has its own cache TTL. Exposes a JSON HTTP API on `localhost:7777`.

session-lattice treats repo-recall as read-only. Never writes back.

### session-lattice (this repo)

Pulls row-shaped data from repo-recall on a refresh tick. Pushes rows into Feldera, where SQL pipelines define materialized views. Serves view reads over its own HTTP API.

Each materialized view is an **inverted index** persisted as a Feldera SQL view. The first one is `tool_sessions` (`tool_name -> [session_id]`). The rationale for using inverted indexes as the primary lookup shape is in [decisions.md](decisions.md).

Feldera's value-add is incremental view maintenance: views update as base rows arrive, not on a full rebuild. At session-lattice's data volume this is overkill on paper, but it is the right specialist engine for this workload's shape (the alternative was a general-purpose analytical DB with scheduled `CREATE TABLE AS SELECT` snapshots, which works but is less aligned with the "materialized views as a foundational concept" framing).

### luca (downstream)

Stateless. Queries session-lattice's HTTP API, runs analytical skills against the view results, produces digests. No persistent storage in luca. See `coilysiren/luca` for the consumer side.

## What was retired

- The Claude Code `PostToolUse` hook as an ingest path. The hook captured a strict subset of what the Claude session JSONL files already contain. Repo-recall reads the JSONL directly.
- The `OTel collector to VictoriaMetrics` path. The metric-shaped view of tool activity is replaced by SQL views over rows.
- Grafana as the human-facing view layer. See decisions.md for the future direction.
- `coilysiren/otel-a2a-relay` (the predecessor repo) is archived. Its relay-shaped identity does not survive into session-lattice.

## Caching contract

End-to-end staleness is the sum of repo-recall's per-source TTL and session-lattice's per-view refresh tick. Document the per-view refresh interval next to the view definition. The CLI exposes a `freshness` field on every view-read response so consumers can decide whether to retry.

## Naming rationale

Three services, three naming registers:

- repo-recall: practical action ("the thing that recalls repos")
- session-lattice: theory ("the lattice of materialized views over session data" - see Harinarayan-Rajaraman-Ullman 1996 on the data-cube lattice)
- luca: cute name ("luca" is Italian for light)
