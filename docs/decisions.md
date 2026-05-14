# Decisions

Recorded choices from the design conversation that birthed this repo. Newest at the top.

## Engine: Feldera

Picked over Postgres, DuckDB, Materialize, RisingWave, ReadySet.

Reasons:
- The workload is inverted-index lookups and pivot grids over Claude session rows, expressed as materialized views. Feldera's whole identity is incremental materialized view maintenance over Apache Calcite SQL. Direct fit.
- MIT license. Single-container local run. Has a Python SDK and an HTTP API for ingest and query, so session-lattice can pull from repo-recall and push to Feldera without standing up Kafka or any other streaming source.
- The streaming-MV peer set (Materialize, RisingWave) was built for high-throughput stream maintenance, which is not the volume profile here. Feldera scales down better than the others.
- DuckDB was the pragmatic alternative (general-purpose analytical DB, scheduled `CREATE TABLE AS SELECT` snapshots). Rejected in favor of the specialist engine because the design intent is to treat materialized views as the foundational concept, not as a feature.
- Postgres was rejected as too generalist for this workload. SQLite was rejected on principle (see kai vault `Notes/avoid-list.md`).

## Language: Python

Rust was considered. Repo-recall is Rust because it parses high-volume JSONL streams; session-lattice does not have that workload. Its job is HTTP pull, HTTP push to Feldera, HTTP serve. The DB does the analytical heavy lifting. Python's lower ergonomic friction matters more here than any compute advantage Rust would provide.

## Data direction: pull, not push

session-lattice pulls from repo-recall on a refresh tick. Repo-recall stays ignorant of session-lattice. Future consumers can be added without changing the upstream.

## PostToolUse hook: retired

The hook captured `tool_name`, `tool_input`, `tool_response`, `session_id`, `cwd`. The Claude session JSONL files contain all of these plus more: real timestamps, `gitBranch`, Claude Code `version`, `entrypoint`, `model`, `parentUuid` (conversation lineage), and full `usage` (token counts, cache hits, inference cost signal). The hook was a strict subset. Repo-recall reads the JSONL directly. The hook contributes nothing the JSONL does not already supply, so it is gone.

## Future UI layer: Streamlit (deferred)

Not pursued during cable-laying. CLI + curl + luca digests are the interaction surface for the first weeks.

When the UI question reopens, the top candidate is **Streamlit**:
- Python, matches the session-lattice stack.
- Dashboards-as-code. No separate frontend build.
- Native widgets for tabular and pivot views, which match the inverted-index workload.
- Single container.

Other candidates that were considered:
- **Datasette** - ideologically clean (faceted browsing over SQL), but needs an adapter to talk to Feldera's HTTP API.
- **Phoenix** - kept alive only for LLM-trace-tree views (agent lineage), not as a general view layer. Lives elsewhere in the stack.
- **Grafana** - retired with prejudice. Time-series-on-an-axis is a bad match for the lookup workload. May earn back individual panels later if time-series questions survive.

## CLIguard side-issue (parallel track)

Most current-working-directory values from active Claude Code sessions point at parent directories like `~/projects/coilysiren/` rather than a specific repo, which guts any cwd-keyed view. CLIguard needs to attach actions to a specific repo more aggressively. Heuristics on the table: longest-prefix match against repo-recall's known paths, recent-touch, explicit binding command. Package-manager invocations should additionally require a target repo with a language manifest matching the package manager.

This work happens in `coilysiren/cli-guard` and is a precondition for the `cwd_sessions` view in session-lattice. The other early views do not depend on it.
