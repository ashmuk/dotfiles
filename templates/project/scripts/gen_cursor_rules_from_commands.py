#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / ".agent" / "commands"
DST = ROOT / ".agent" / "cursor" / "rules" / "010-commands"  # single source for cursor rules

CODE_BLOCK_RE = re.compile(r"```bash\s*(.*?)```", re.DOTALL)

def slugify(name: str) -> str:
    s = name.strip().lower()
    s = re.sub(r"[^a-z0-9._-]+", "-", s)
    s = re.sub(r"-{2,}", "-", s).strip("-")
    return s or "command"

def extract_bash_blocks(md: str) -> list[str]:
    blocks = []
    for m in CODE_BLOCK_RE.finditer(md):
        block = m.group(1).strip()
        if block:
            blocks.append(block)
    return blocks

def render_rule(command_md_path: Path, title: str, bash_blocks: list[str]) -> str:
    rel = command_md_path.relative_to(ROOT)
    parts = []
    parts.append(f"# {title}")
    parts.append("")
    parts.append("## Scope")
    parts.append("This rule is auto-generated from the single source of truth:")
    parts.append(f"- `{rel.as_posix()}`")
    parts.append("")
    parts.append("## Instruction")
    parts.append("- Follow the command procedure exactly.")
    parts.append("- Do not invent alternative commands unless explicitly requested.")
    parts.append("- If the command fails, follow the Failure Handling section in the source file.")
    parts.append("")
    parts.append("## Canonical command(s)")
    if bash_blocks:
        for i, b in enumerate(bash_blocks, start=1):
            parts.append(f"### Bash block {i}")
            parts.append("```bash")
            parts.append(b)
            parts.append("```")
            parts.append("")
    else:
        parts.append("_No `bash` code blocks found in the source._")
        parts.append("")
    parts.append("## Notes")
    parts.append("- This file is generated. Edit the source command file instead.")
    parts.append("")
    return "\n".join(parts)

def main() -> None:
    if not SRC.exists():
        print(f"[gen] no source dir: {SRC}")
        return

    # clear existing generated command rules
    if DST.exists():
        for p in DST.glob("*"):
            if p.is_dir():
                for q in p.rglob("*"):
                    if q.is_file():
                        q.unlink()
                p.rmdir()
            elif p.is_file():
                p.unlink()
    DST.mkdir(parents=True, exist_ok=True)

    for cmd_path in sorted(SRC.glob("*.md")):
        md = cmd_path.read_text(encoding="utf-8")
        # title: prefer first H1, else file name
        title = cmd_path.stem
        for line in md.splitlines():
            if line.startswith("# "):
                title = line[2:].strip()
                break
        bash_blocks = extract_bash_blocks(md)

        rule_dir = DST / slugify(cmd_path.stem)
        rule_dir.mkdir(parents=True, exist_ok=True)
        rule_path = rule_dir / "RULE.md"
        rule_path.write_text(render_rule(cmd_path, title, bash_blocks), encoding="utf-8")
        print(f"[gen] {rule_path.relative_to(ROOT)} <= {cmd_path.relative_to(ROOT)}")

if __name__ == "__main__":
    main()
