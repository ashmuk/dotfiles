#!/bin/bash
# Git Skip-Worktree Helper Script
# Manage files ignored from git status using skip-worktree flag

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

usage() {
    cat <<EOF
Git Skip-Worktree Helper

Usage: $0 <command> [files...]

Commands:
  add <file>...      Mark files to skip in worktree
  remove <file>...   Unmark files (show in git status again)
  list               Show all files marked skip-worktree
  status             Show status of tracked files
  reset              Remove all skip-worktree flags

Examples:
  $0 add config/claude/settings.json
  $0 list
  $0 remove git/gitignore.common
  $0 status

Currently marked files:
$(git ls-files -v | grep '^S' | sed 's/^S /  ✓ /' || echo "  (none)")
EOF
}

list_skip_worktree() {
    echo "Files marked skip-worktree:"
    git ls-files -v | grep '^S' | sed 's/^S /  /' || echo "  (none)"
}

add_skip_worktree() {
    if [ $# -eq 0 ]; then
        echo "Error: No files specified"
        usage
        exit 1
    fi

    for file in "$@"; do
        if git ls-files --error-unmatch "$file" &>/dev/null; then
            git update-index --skip-worktree "$file"
            echo "✓ Marked skip-worktree: $file"
        else
            echo "✗ Not tracked: $file (skipping)"
        fi
    done
}

remove_skip_worktree() {
    if [ $# -eq 0 ]; then
        echo "Error: No files specified"
        usage
        exit 1
    fi

    for file in "$@"; do
        git update-index --no-skip-worktree "$file"
        echo "✓ Removed skip-worktree: $file"
    done
}

reset_all() {
    echo "Removing skip-worktree from all files..."
    git ls-files -v | grep '^S' | cut -c3- | while read file; do
        git update-index --no-skip-worktree "$file"
        echo "  ✓ $file"
    done
    echo "Done!"
}

show_status() {
    echo "Modified tracked files (would show in git status):"
    git ls-files -v | grep '^H' | cut -c3- | while read file; do
        if [ -f "$file" ] && git diff --quiet "$file" 2>/dev/null; then
            : # File unchanged
        else
            echo "  M $file"
        fi
    done

    echo ""
    echo "Skip-worktree files (hidden from git status):"
    git ls-files -v | grep '^S' | sed 's/^S /  S /' || echo "  (none)"
}

# Main
case "${1:-help}" in
    add)
        shift
        add_skip_worktree "$@"
        ;;
    remove)
        shift
        remove_skip_worktree "$@"
        ;;
    list)
        list_skip_worktree
        ;;
    status)
        show_status
        ;;
    reset)
        reset_all
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        usage
        exit 1
        ;;
esac
