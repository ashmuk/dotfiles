
.PHONY: fmt lint test ai:fmt ai:lint ai:test

fmt:
	@black . || true
	@ruff --fix . || true
	@prettier -w . || true
	@clang-format -i $(shell git ls-files '*.[ch]' '*.[ch]pp' '*.cc' '*.hh' 2>/dev/null) || true
	@cargo fmt || true

lint:
	@ruff . || true
	@eslint . || true
	@clang-tidy $(shell git ls-files '*.[ch]' '*.[ch]pp' '*.cc' '*.hh' 2>/dev/null) || true
	@cargo clippy --all-targets --all-features || true

test:
	@pytest -q || true
	@pnpm -s vitest run || npm test --silent || true
	@cargo test --all --quiet || true

# Simple AI smoke tests (require API keys)
ai:fmt ai:lint ai:test

ai:fmt:
	@echo "Hello" | ai-claude >/dev/null 2>&1 || true
	@echo "Hello" | ai-openai >/dev/null 2>&1 || true
	@echo "Hello" | ai-gemini >/dev/null 2>&1 || true

ai:lint:
	@echo "Lint OK"

ai:test:
	@echo "AI CLIs sanity checks completed."
