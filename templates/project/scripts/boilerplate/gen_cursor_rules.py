#!/usr/bin/env python3
"""Generate Cursor rules by symlinking RULES.md and 4 core agents to .cursor/rules/project/"""
from __future__ import annotations

import os
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC_RULES = ROOT / "RULES.md"
SRC_AGENTS = ROOT / ".agent" / "subagents"
DST = ROOT / ".cursor" / "rules" / "project"

AGENTS = ["analyst.md", "architect.md", "builder.md", "reviewer.md"]


def clear_directory(path: Path) -> None:
    """Remove all files and subdirectories in path."""
    if path.exists():
        shutil.rmtree(path)
        print(f"[gen] cleared: {path.relative_to(ROOT)}")


def create_symlink(src: Path, dst: Path, link_name: str) -> None:
    """Create a relative symlink from dst/link_name -> src."""
    link_path = dst / link_name
    # Calculate relative path from link location to source
    rel_path = os.path.relpath(src, dst)
    link_path.symlink_to(rel_path)
    print(f"[gen] {link_path.relative_to(ROOT)} -> {rel_path}")


def main() -> None:
    # Check sources exist
    if not SRC_RULES.exists():
        print(f"[gen] RULES.md not found: {SRC_RULES}")
        return

    if not SRC_AGENTS.exists():
        print(f"[gen] agents dir not found: {SRC_AGENTS}")
        return

    # Clear and recreate destination
    clear_directory(DST)
    DST.mkdir(parents=True, exist_ok=True)
    print(f"[gen] created: {DST.relative_to(ROOT)}")

    # Symlink RULES.md as RULE.md (Cursor convention)
    create_symlink(SRC_RULES, DST, "RULE.md")

    # Symlink 4 core agents
    for agent in AGENTS:
        agent_src = SRC_AGENTS / agent
        if agent_src.exists():
            create_symlink(agent_src, DST, agent)
        else:
            print(f"[gen] warning: agent not found: {agent_src}")

    print("[gen] done")


if __name__ == "__main__":
    main()
