# stack

Local Feldera pipeline-manager for session-lattice development.

## Run

```sh
coily exec stack-up      # docker compose up -d
coily exec stack-status  # docker compose ps + /healthz probe
coily exec stack-logs    # tail follow
coily exec stack-down    # stop
coily exec stack-wipe    # stop + remove container (ephemeral state goes too)
```

WebConsole at http://127.0.0.1:8080 once `stack-up` reports healthy.

## State

Ephemeral. Restarting the container loses pipelines, views, and ingested rows. Persistence is a follow-up (see [docs/decisions.md](../docs/decisions.md)). For the steel-cable phase, accept the cost and rebuild views on each restart.

## Version

Pinned to Feldera v0.296.0 in [docker-compose.yaml](docker-compose.yaml). Bump deliberately, not via `:latest`.
