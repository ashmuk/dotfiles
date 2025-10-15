#!/usr/bin/env bash

# bootstrap_agent.sh
# Copies agent configuration files and directories to a new project root
# Usage: Run from the agent/ directory or provide path to project root
#   ./bootstrap_agent.sh [target_directory]

set -euo pipefail

# Colors for output (use $'\033' for proper escape sequence interpretation)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
NC=$'\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine target directory
if [ $# -eq 0 ]; then
    TARGET_DIR="$(pwd)"
    echo -e "${YELLOW}No target directory specified, using current directory: ${TARGET_DIR}${NC}"
else
    TARGET_DIR="$1"
fi

# Verify target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory does not exist: ${TARGET_DIR}${NC}"
    exit 1
fi

# Prevent copying to the agent directory itself
if [ "$(realpath "$TARGET_DIR")" = "$(realpath "$SCRIPT_DIR")" ]; then
    echo -e "${RED}Error: Cannot bootstrap to the agent directory itself${NC}"
    exit 1
fi

echo -e "${GREEN}Bootstrapping agent files to: ${TARGET_DIR}${NC}"

# Files to copy to root
FILES=(
    "CLAUDE.md"
    "AGENTS.md"
)

# Directories to copy
DOT_DIRECTORIES=(
    "cursor"
    "codex"
)
OTHER_DIRS=(
    "mcp"
)

# Copy files
echo -e "\n${GREEN}Copying configuration files...${NC}"
for file in "${FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        if [ -f "$TARGET_DIR/$file" ]; then
            echo -e "${YELLOW}  ⚠ Skipping $file (already exists)${NC}"
        else
            cp "$SCRIPT_DIR/$file" "$TARGET_DIR/$file"
            echo -e "  ✓ Copied $file"
        fi
    else
        echo -e "${YELLOW}  ⚠ Skipping $file (not found in source)${NC}"
    fi
done

# Copy dot directories
echo -e "\n${GREEN}Copying directories...${NC}"
for dir in "${DOT_DIRECTORIES[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        if [ -d "$TARGET_DIR/.$dir" ]; then
            echo -e "${YELLOW}  ⚠ Skipping .$dir/ (already exists)${NC}"
        else
            cp -r "$SCRIPT_DIR/$dir" "$TARGET_DIR/.$dir"
            echo -e "  ✓ Copied .$dir/"
        fi
    else
        echo -e "${YELLOW}  ⚠ Skipping $dir/ (not found in source)${NC}"
    fi
done

# Copy directories (simple copy if not present)
echo -e "\n${GREEN}Copying directories...${NC}"
for dir in "${OTHER_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        if [ -d "$TARGET_DIR/$dir" ]; then
            echo -e "${YELLOW}  ⚠ Skipping $dir/ (already exists)${NC}"
        else
            cp -r "$SCRIPT_DIR/$dir" "$TARGET_DIR/$dir"
            echo -e "  ✓ Copied $dir/"
        fi
    else
        echo -e "${YELLOW}  ⚠ Skipping $dir/ (not found in source)${NC}"
    fi
done

# Merge-copy prompts directory: copy only missing files
SRC_PROMPTS_DIR="$SCRIPT_DIR/prompts"
DST_PROMPTS_DIR="$TARGET_DIR/prompts"
if [ -d "$SRC_PROMPTS_DIR" ]; then
    echo -e "\n${GREEN}Syncing prompts directory (copy missing files)...${NC}"
    if [ ! -d "$DST_PROMPTS_DIR" ]; then
        cp -r "$SRC_PROMPTS_DIR" "$DST_PROMPTS_DIR"
        echo -e "  ✓ Copied prompts/"
    else
        while IFS= read -r -d '' src_file; do
            rel_path="${src_file#"$SRC_PROMPTS_DIR/"}"
            dst_file="$DST_PROMPTS_DIR/$rel_path"
            dst_dir="$(dirname "$dst_file")"
            if [ ! -e "$dst_file" ]; then
                mkdir -p "$dst_dir"
                cp "$src_file" "$dst_file"
                echo -e "  ✓ Copied prompts/$rel_path"
            else
                echo -e "${YELLOW}  ⚠ Skipping prompts/$rel_path (already exists)${NC}"
            fi
        done < <(find "$SRC_PROMPTS_DIR" -type f -print0)
    fi
else
    echo -e "${YELLOW}  ⚠ Skipping prompts/ (not found in source)${NC}"
fi

echo -e "\n${GREEN}✓ Bootstrap complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. Review and customize CLAUDE.md for your project"
echo -e "  2. Configure .cursor/rules if using Cursor"
echo -e "  3. Update prompts/ directory with project-specific prompts"
echo -e "  4. Check mcp/ for MCP server configurations"
