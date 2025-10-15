.PHONY: setup run test lint format clean aider-plan aider-refactor ci-local health-check

# Setup - Install dependencies in virtual environment
setup:
	@if [ -d "/home/vscode/.venv" ]; then \
		/home/vscode/.venv/bin/pip install -U pip; \
		/home/vscode/.venv/bin/pip install -U fastapi uvicorn pytest ruff httpx aider-chat coverage pre-commit; \
	else \
		echo "Virtual environment not found. Run postCreateCommand first."; \
		exit 1; \
	fi

# Run the application
run:
	uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Test
test:
	pytest -v --cov

# Linting
lint:
	ruff check .

# Format code
format:
	ruff format .

# Clean build artifacts
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .ruff_cache .coverage htmlcov

# AI Development Tasks
aider-plan:
	aider --message "Scan the repo and create a test plan at tests/TESTPLAN.md focusing on API health and CRUD coverage" --yes

aider-refactor:
	aider --message "Refactor app/main.py to add /todos endpoints with in-memory store and make tests pass; keep style with ruff and add missing tests." --yes

# Local CI with act
ci-local:
	act pull_request -j check

# Health check
health-check:
	./.devcontainer/health-check.sh

# Pre-commit hooks
pre-commit-install:
	pre-commit install

pre-commit-run:
	pre-commit run --all-files
