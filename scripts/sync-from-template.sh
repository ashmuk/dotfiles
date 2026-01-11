#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# sync-from-template.sh - Dotfiles-specific template sync
# =============================================================================
# This script is specifically for the dotfiles repository itself.
# It maintains symlinks from dotfiles root to templates/project/.
#
# Usage: ./scripts/sync-from-template.sh [OPTIONS]
#
# Options:
#   --check     Check symlinks without making changes
#   --fix       Create/fix broken symlinks (default)
#   --help      Show this help message
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_PROJECT="${DOTFILES_ROOT}/templates/project"
TEMPLATE_AGENT="${TEMPLATE_PROJECT}/dot.agent"

# Operation mode
MODE="fix"  # fix, check

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
OK=0
FIXED=0
ERRORS=0

# =============================================================================
# Helper Functions
# =============================================================================

show_help() {
    sed -n '4,14p' "$0" | sed 's/^# \?//'
    exit 0
}

log_ok() {
    local source="$1"
    local target="$2"
    echo -e "  ${GREEN}OK${NC}  ${source} -> ${target}"
    OK=$((OK + 1))
    TOTAL=$((TOTAL + 1))
}

log_fixed() {
    local source="$1"
    local target="$2"
    echo -e "  ${GREEN}FIXED${NC}  ${source} -> ${target}"
    FIXED=$((FIXED + 1))
    TOTAL=$((TOTAL + 1))
}

log_error() {
    local source="$1"
    local message="$2"
    echo -e "  ${RED}ERROR${NC}  ${source}: ${message}"
    ERRORS=$((ERRORS + 1))
    TOTAL=$((TOTAL + 1))
}

log_warn() {
    local source="$1"
    local message="$2"
    echo -e "  ${YELLOW}WARN${NC}  ${source}: ${message}"
    TOTAL=$((TOTAL + 1))
}

backup_file() {
    local file="$1"
    local backup_dir="${DOTFILES_ROOT}/.sync-backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "${backup_dir}"
    cp -f "${file}" "${backup_dir}/$(basename "${file}")"
    echo -e "    Backed up to ${backup_dir}/$(basename "${file}")"
}

# =============================================================================
# Symlink Management
# =============================================================================

# Check if a symlink exists and points to the correct target
check_symlink() {
    local source="$1"
    local expected_target="$2"

    if [[ -L "${source}" ]]; then
        local actual_target
        actual_target="$(readlink "${source}")"
        if [[ "${actual_target}" == "${expected_target}" ]]; then
            return 0  # Correct symlink
        else
            return 1  # Wrong target
        fi
    elif [[ -e "${source}" ]]; then
        return 2  # Regular file exists
    else
        return 3  # Nothing exists
    fi
}

# Create or fix a symlink
ensure_symlink() {
    local source="$1"
    local target="$2"
    local display_source="$3"
    local display_target="$4"

    local status
    check_symlink "${source}" "${target}" && status=$? || status=$?

    case ${status} in
        0)
            log_ok "${display_source}" "${display_target}"
            ;;
        1)
            if [[ "${MODE}" == "fix" ]]; then
                rm -f "${source}"
                ln -s "${target}" "${source}"
                log_fixed "${display_source}" "${display_target}"
            else
                log_warn "${display_source}" "wrong target ($(readlink "${source}"))"
            fi
            ;;
        2)
            if [[ "${MODE}" == "fix" ]]; then
                backup_file "${source}"
                rm -f "${source}"
                ln -s "${target}" "${source}"
                log_fixed "${display_source}" "${display_target}"
            else
                log_warn "${display_source}" "regular file exists (needs backup)"
            fi
            ;;
        3)
            if [[ "${MODE}" == "fix" ]]; then
                mkdir -p "$(dirname "${source}")"
                ln -s "${target}" "${source}"
                log_fixed "${display_source}" "${display_target}"
            else
                log_warn "${display_source}" "missing"
            fi
            ;;
    esac
}

# Check if files are hardlinked (same inode)
check_hardlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "${source}" ]]; then
        return 3  # Nothing exists
    fi

    if [[ -L "${source}" ]]; then
        return 2  # Is a symlink (needs to be hardlink)
    fi

    if [[ ! -e "${target}" ]]; then
        return 1  # Target doesn't exist
    fi

    # Compare inodes
    local source_inode target_inode
    source_inode=$(stat -f "%i" "${source}" 2>/dev/null || stat -c "%i" "${source}" 2>/dev/null)
    target_inode=$(stat -f "%i" "${target}" 2>/dev/null || stat -c "%i" "${target}" 2>/dev/null)

    if [[ "${source_inode}" == "${target_inode}" ]]; then
        return 0  # Same inode = hardlinked
    else
        return 1  # Different files
    fi
}

# Create or fix a hardlink (for .gitignore which doesn't work as symlink with git)
ensure_hardlink() {
    local source="$1"
    local target="$2"
    local display_source="$3"
    local display_target="$4"

    local status
    check_hardlink "${source}" "${target}" && status=$? || status=$?

    case ${status} in
        0)
            log_ok "${display_source}" "${display_target} (hardlink)"
            ;;
        1|2)
            if [[ "${MODE}" == "fix" ]]; then
                backup_file "${source}" 2>/dev/null || true
                rm -f "${source}"
                ln "${target}" "${source}"
                log_fixed "${display_source}" "${display_target} (hardlink)"
            else
                if [[ ${status} -eq 2 ]]; then
                    log_warn "${display_source}" "is symlink (needs hardlink for git compatibility)"
                else
                    log_warn "${display_source}" "not hardlinked"
                fi
            fi
            ;;
        3)
            if [[ "${MODE}" == "fix" ]]; then
                ln "${target}" "${source}"
                log_fixed "${display_source}" "${display_target} (hardlink)"
            else
                log_warn "${display_source}" "missing"
            fi
            ;;
    esac
}

# =============================================================================
# Sync Functions
# =============================================================================

sync_root_files() {
    echo -e "\n${BLUE}Root Files${NC}"
    echo -e "${BLUE}----------${NC}"

    # .gitignore uses hardlink (symlinks cause git warnings)
    ensure_hardlink \
        "${DOTFILES_ROOT}/.gitignore" \
        "${DOTFILES_ROOT}/templates/project/dot.gitignore" \
        ".gitignore" \
        "templates/project/dot.gitignore"

    # AGENTS.md -> templates/project/AGENTS_project.md
    ensure_symlink \
        "${DOTFILES_ROOT}/AGENTS.md" \
        "./templates/project/AGENTS_project.md" \
        "AGENTS.md" \
        "templates/project/AGENTS_project.md"

    # CLAUDE.md -> templates/project/CLAUDE_project.md
    ensure_symlink \
        "${DOTFILES_ROOT}/CLAUDE.md" \
        "./templates/project/CLAUDE_project.md" \
        "CLAUDE.md" \
        "templates/project/CLAUDE_project.md"

    # RULES.md -> templates/project/RULES.md
    ensure_symlink \
        "${DOTFILES_ROOT}/RULES.md" \
        "./templates/project/RULES.md" \
        "RULES.md" \
        "templates/project/RULES.md"
}

sync_agents() {
    echo -e "\n${BLUE}Agents (.claude/agents/)${NC}"
    echo -e "${BLUE}------------------------${NC}"

    local agent_source="${TEMPLATE_AGENT}/subagents"
    local agent_dest="${DOTFILES_ROOT}/.claude/agents"

    # Ensure destination directory exists
    mkdir -p "${agent_dest}"

    # Auto-discover agents from template
    for agent_file in "${agent_source}"/*.md; do
        if [[ -f "${agent_file}" ]]; then
            local filename
            filename="$(basename "${agent_file}")"
            local relative_target="../../templates/project/dot.agent/subagents/${filename}"

            ensure_symlink \
                "${agent_dest}/${filename}" \
                "${relative_target}" \
                "${filename}" \
                "...subagents/${filename}"
        fi
    done
}

sync_commands() {
    echo -e "\n${BLUE}Commands (.claude/commands/)${NC}"
    echo -e "${BLUE}----------------------------${NC}"

    local cmd_source="${TEMPLATE_AGENT}/commands"
    local cmd_dest="${DOTFILES_ROOT}/.claude/commands"

    # Ensure destination directory exists
    mkdir -p "${cmd_dest}"

    # Auto-discover commands from template
    for cmd_file in "${cmd_source}"/*.md; do
        if [[ -f "${cmd_file}" ]]; then
            local filename
            filename="$(basename "${cmd_file}")"
            local relative_target="../../templates/project/dot.agent/commands/${filename}"

            ensure_symlink \
                "${cmd_dest}/${filename}" \
                "${relative_target}" \
                "${filename}" \
                "...commands/${filename}"
        fi
    done
}

sync_skills() {
    echo -e "\n${BLUE}Skills (.claude/skills/)${NC}"
    echo -e "${BLUE}------------------------${NC}"

    local skill_source="${TEMPLATE_AGENT}/skills"
    local skill_dest="${DOTFILES_ROOT}/.claude/skills"

    # Ensure destination directory exists
    mkdir -p "${skill_dest}"

    # Auto-discover skills from template
    for skill_file in "${skill_source}"/*.md; do
        if [[ -f "${skill_file}" ]]; then
            local skill_name
            skill_name="$(basename "${skill_file}" .md)"
            local skill_dir="${skill_dest}/${skill_name}"
            local relative_target="../../../templates/project/dot.agent/skills/${skill_name}.md"

            # Create skill directory
            mkdir -p "${skill_dir}"

            ensure_symlink \
                "${skill_dir}/SKILL.md" \
                "${relative_target}" \
                "${skill_name}/SKILL.md" \
                "...skills/${skill_name}.md"
        fi
    done
}

# =============================================================================
# Main
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                ;;
            --check)
                MODE="check"
                shift
                ;;
            --fix)
                MODE="fix"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Run with --help for usage information"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    echo ""
    echo -e "${BLUE}Dotfiles Template Sync${NC}"
    echo -e "${BLUE}======================${NC}"
    echo -e "Mode: ${MODE}"

    # Verify we're in the dotfiles repo
    if [[ ! -d "${TEMPLATE_PROJECT}" ]]; then
        echo -e "${RED}ERROR${NC}: templates/project/ not found"
        echo "This script must be run from the dotfiles repository"
        exit 1
    fi

    # Run sync functions
    sync_root_files
    sync_agents
    sync_commands
    sync_skills

    # Summary
    echo ""
    echo -e "${BLUE}Summary${NC}"
    echo -e "${BLUE}-------${NC}"
    echo -e "  Total: ${TOTAL}"
    echo -e "  ${GREEN}OK${NC}: ${OK}"
    if [[ ${FIXED} -gt 0 ]]; then
        echo -e "  ${GREEN}Fixed${NC}: ${FIXED}"
    fi
    if [[ ${ERRORS} -gt 0 ]]; then
        echo -e "  ${RED}Errors${NC}: ${ERRORS}"
    fi

    if [[ "${MODE}" == "check" && ${FIXED} -eq 0 && ${ERRORS} -eq 0 && ${OK} -eq ${TOTAL} ]]; then
        echo ""
        echo -e "${GREEN}All symlinks verified.${NC}"
    elif [[ "${MODE}" == "fix" && ${ERRORS} -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}All symlinks configured.${NC}"
    fi

    # Exit with error if there were problems
    if [[ ${ERRORS} -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
