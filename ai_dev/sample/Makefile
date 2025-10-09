.PHONY: setup aider-plan aider-refactor ci-local swe-fix test lint format clean metrics metrics-watch metrics-today metrics-export

setup:
	pip install -U aider-chat swe-agent ruff pytest

aider-plan:
	@if command -v aider-with-metrics >/dev/null 2>&1; then \
		aider-with-metrics --message "未整備テストを列挙し tests/TESTPLAN.md に出力" --yes; \
	else \
		aider --message "未整備テストを列挙し tests/TESTPLAN.md に出力" --yes; \
	fi

aider-refactor:
	@if command -v aider-with-metrics >/dev/null 2>&1; then \
		aider-with-metrics --message "src配下をリファクタし ruff/pytest が通るよう最小修正" --yes; \
	else \
		aider --message "src配下をリファクタし ruff/pytest が通るよう最小修正" --yes; \
	fi

ci-local:
	act pull_request -j check

swe-fix:
	python -m swe_agent --issue-url "$$ISSUE_URL" --model "claude-4-5-sonnet"

test:
	pytest tests/ -v --cov

lint:
	ruff check .

format:
	ruff format .
	black .

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .ruff_cache .coverage htmlcov

# API Usage Metrics
metrics:
	@if command -v aider-metrics >/dev/null 2>&1; then \
		aider-metrics summary; \
	else \
		echo "aider-metrics not found. Ensure ~/dotfiles/bin is in PATH"; \
	fi

metrics-watch:
	@if command -v aider-metrics >/dev/null 2>&1; then \
		aider-metrics watch; \
	else \
		echo "aider-metrics not found. Ensure ~/dotfiles/bin is in PATH"; \
	fi

metrics-today:
	@if command -v aider-metrics >/dev/null 2>&1; then \
		aider-metrics today; \
	else \
		echo "aider-metrics not found. Ensure ~/dotfiles/bin is in PATH"; \
	fi

metrics-export:
	@if command -v aider-metrics >/dev/null 2>&1; then \
		aider-metrics export; \
	else \
		echo "aider-metrics not found. Ensure ~/dotfiles/bin is in PATH"; \
	fi
