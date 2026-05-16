# session-lattice

Materialized-view service over Claude session data.

Three-layer architecture across coilysiren/*:

- [coilysiren/repo-recall](https://github.com/coilysiren/repo-recall) - joins, searches, and caches over primary sources (Claude session JSONL, git log, GitHub). Authoritative store.
- **session-lattice** (this repo) - pulls from repo-recall on a tick, maintains a lattice of materialized views via Feldera (DBSP, incremental view maintenance), serves view reads over HTTP.
- [coilysiren/luca](https://github.com/coilysiren/luca) - stateless. Queries session-lattice and turns the views into insights.

See [docs/architecture.md](docs/architecture.md) for the design rationale.

## Status

Pre-cable. Repo scaffolded, no service yet. Replaces the archived `coilysiren/otel-a2a-relay`.

The view-inspection surface is Feldera's built-in web console (ad-hoc SQL against materialized views in a running pipeline). No separate dashboard layer.

## See also

- [AGENTS.md](AGENTS.md) - agent-facing operating rules.
- [docs/FEATURES.md](docs/FEATURES.md) - inventory of what ships today.
- [.coily/coily.yaml](.coily/coily.yaml) - allowlisted commands.

Cross-reference convention from [coilysiren/agentic-os#59](https://github.com/coilysiren/agentic-os/issues/59).
