.PHONY: sync lint fmt test stack-up stack-down stack-status stack-logs stack-wipe

sync:
	uv sync

lint:
	uv run ruff check session_lattice
	uv run mypy session_lattice

fmt:
	uv run ruff format session_lattice

test:
	@echo "no tests yet; first view (tool_sessions) will introduce one"

stack-up:
	docker compose -f stack/docker-compose.yaml up -d

stack-down:
	docker compose -f stack/docker-compose.yaml down

stack-status:
	docker compose -f stack/docker-compose.yaml ps
	@curl -fsS http://127.0.0.1:8080/healthz >/dev/null 2>&1 && echo "feldera: healthy" || echo "feldera: not responding on :8080"

stack-logs:
	docker compose -f stack/docker-compose.yaml logs -f --tail=100

stack-wipe:
	docker compose -f stack/docker-compose.yaml down -v --remove-orphans
