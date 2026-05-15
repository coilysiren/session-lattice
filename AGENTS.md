# Agent instructions

See `../AGENTS.md` for workspace-level conventions (git workflow, test/lint autonomy, readonly ops, writing voice, deploy knowledge). This file covers only what's specific to this repo.

## What this is

Materialized-view service. Pulls Claude-session row data from `coilysiren/repo-recall` on a refresh tick, maintains a lattice of views inside Feldera (DBSP, incremental view maintenance), exposes the views via HTTP for `coilysiren/luca` and other consumers.

## What this is not

- Not an OTel relay. The archived predecessor `coilysiren/otel-a2a-relay` was. This repo replaces it with a different architectural identity.
- Not an ingest endpoint for the Claude Code `PostToolUse` hook. The hook is retired. Repo-recall reads session JSONL directly.
- Not a UI. Feldera's built-in web console covers the inspect / debug surface. CLI + curl + luca digests cover the rest.

## Layering rules

- Upstream: repo-recall. Pull only. Never push.
- Downstream: luca, plus any future consumer of HTTP view reads.
- Side-stream: Feldera. Embedded engine. Treat its SQL pipeline definitions as part of this repo's source.

## Caching

Two caches stack here: repo-recall's per-source TTLs and session-lattice's per-view refresh tick. End-to-end staleness is the sum. Document the per-view refresh interval in the view definition, never inline.
