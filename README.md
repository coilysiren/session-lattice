# session-lattice

Materialized-view service over Claude session data.

Three-layer architecture across coilysiren/*:

- [coilysiren/repo-recall](https://github.com/coilysiren/repo-recall) - joins, searches, and caches over primary sources (Claude session JSONL, git log, GitHub). Authoritative store.
- **session-lattice** (this repo) - pulls from repo-recall on a tick, maintains a lattice of materialized views via Feldera (DBSP, incremental view maintenance), serves view reads over HTTP.
- [coilysiren/luca](https://github.com/coilysiren/luca) - stateless. Queries session-lattice and turns the views into insights.

See [docs/architecture.md](docs/architecture.md) for the design rationale and [docs/decisions.md](docs/decisions.md) for the recorded choices.

## Status

Pre-cable. Repo scaffolded, no service yet. Replaces the archived `coilysiren/otel-a2a-relay`.
