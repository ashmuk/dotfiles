.PHONY: setup aider-plan aider-refactor ci-local swe-fix test lint format clean

setup:
	pip install -U aider-chat swe-agent ruff pytest

aider-plan:
	aider --message "未整備テストを列挙し tests/TESTPLAN.md に出力" --yes

aider-refactor:
	aider --message "src配下をリファクタし ruff/pytest が通るよう最小修正" --yes

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
