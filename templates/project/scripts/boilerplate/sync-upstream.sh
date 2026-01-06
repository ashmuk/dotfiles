#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Template Sync Script - Fetch updates from upstream dotfiles template
# ============================================================================
# Usage: sync-upstream.sh [OPTIONS] [FILES...]
#
# Options:
#   --check           Check for differences without syncing
#   --dry-run         Show what would be synced without making changes
#   --status          Show last sync info and current state
#   --force           Skip prompts for Tier 1 files (still ask for Tier 2)
#   --help            Show this help message
#
# Files (optional):
#   AGENTS_global     Sync only AGENTS_global.md
#   CLAUDE_global     Sync only CLAUDE_global.md
#   AGENTS            Sync only AGENTS.md
#   CLAUDE            Sync only CLAUDE.md
#   RULES             Sync only RULES.md
#   agent             Sync only .agent/ directory
#   boilerplate       Sync only scripts/boilerplate/ directory
#   all               Sync all files (default)
# ============================================================================

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMPLATE_ROOT="${TEMPLATE_ROOT:-${HOME}/dotfiles/templates}"
TEMPLATE_GLOBAL="${TEMPLATE_ROOT}/global"
TEMPLATE_PROJECT="${TEMPLATE_ROOT}/project"
BACKUP_DIR="${PROJECT_ROOT}/.template-backups/$(date +%Y%m%d-%H%M%S)"
SYNC_LOG="${PROJECT_ROOT}/.template-sync.log"
SYNC_METADATA="${PROJECT_ROOT}/.template-sync-metadata"

# Operation modes
MODE="sync"  # sync, check, dry-run, status
FORCE_MODE=false
SELECTED_FILES=()

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[${timestamp}] [${level}] ${message}" >> "${SYNC_LOG}"

  case "${level}" in
    INFO)  echo -e "${BLUE}ℹ${NC} ${message}" ;;
    OK)    echo -e "${GREEN}✓${NC} ${message}" ;;
    WARN)  echo -e "${YELLOW}⚠${NC} ${message}" ;;
    ERROR) echo -e "${RED}✗${NC} ${message}" ;;
    *)     echo "${message}" ;;
  esac
}

show_help() {
  sed -n '3,23p' "$0" | sed 's/^# \?//'
  exit 0
}

check_upstream_exists() {
  if [[ ! -d "${TEMPLATE_GLOBAL}" ]]; then
    log ERROR "Template global directory not found: ${TEMPLATE_GLOBAL}"
    log INFO "Set TEMPLATE_ROOT environment variable if your dotfiles are elsewhere"
    return 1
  fi

  if [[ ! -d "${TEMPLATE_PROJECT}" ]]; then
    log ERROR "Template project directory not found: ${TEMPLATE_PROJECT}"
    log INFO "Set TEMPLATE_ROOT environment variable if your dotfiles are elsewhere"
    return 1
  fi

  log INFO "Using template: ${TEMPLATE_ROOT}"
  return 0
}

has_local_modifications() {
  local file="$1"

  # Check if file exists and is tracked by git
  if [[ ! -f "${PROJECT_ROOT}/${file}" ]]; then
    return 1  # No file means no modifications
  fi

  if ! git -C "${PROJECT_ROOT}" ls-files --error-unmatch "${file}" &>/dev/null; then
    return 1  # Untracked file means no modifications (will be created)
  fi

  # Check for modifications (staged or unstaged)
  if ! git -C "${PROJECT_ROOT}" diff --quiet HEAD -- "${file}" 2>/dev/null; then
    return 0  # Has modifications
  fi

  return 1  # No modifications
}

files_differ() {
  local upstream="$1"
  local local="$2"

  if [[ ! -f "${upstream}" ]]; then
    return 1  # Upstream doesn't exist
  fi

  if [[ ! -f "${local}" ]]; then
    return 0  # Local doesn't exist, so they differ
  fi

  if ! diff -q "${upstream}" "${local}" &>/dev/null; then
    return 0  # Files differ
  fi

  return 1  # Files are identical
}

show_diff() {
  local upstream="$1"
  local local="$2"
  local label="$3"

  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}Diff for: ${label}${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  if [[ ! -f "${local}" ]]; then
    echo -e "${GREEN}File will be created (doesn't exist locally)${NC}"
    echo ""
    echo -e "${GREEN}Preview of new content:${NC}"
    head -20 "${upstream}"
    if [[ $(wc -l < "${upstream}") -gt 20 ]]; then
      echo "... ($(wc -l < "${upstream}") lines total)"
    fi
  else
    diff -u "${local}" "${upstream}" || true
  fi

  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

create_backup() {
  local file="$1"
  local filepath="${PROJECT_ROOT}/${file}"

  if [[ ! -f "${filepath}" ]]; then
    return 0  # No file to backup
  fi

  mkdir -p "${BACKUP_DIR}/$(dirname "${file}")"
  cp -f "${filepath}" "${BACKUP_DIR}/${file}"
  log INFO "Backed up: ${file} → .template-backups/$(basename "${BACKUP_DIR}")/${file}"
}

create_backup_dir() {
  local dir="$1"
  local dirpath="${PROJECT_ROOT}/${dir}"

  if [[ ! -d "${dirpath}" ]]; then
    return 0  # No directory to backup
  fi

  # Create parent directory structure in backup location
  mkdir -p "${BACKUP_DIR}/$(dirname "${dir}")"
  cp -R "${dirpath}" "${BACKUP_DIR}/${dir}"
  log INFO "Backed up: ${dir}/ → .template-backups/$(basename "${BACKUP_DIR}")/${dir}/"
}

prompt_user() {
  local message="$1"
  local options="$2"  # e.g., "y/n/d/s"

  while true; do
    echo -ne "${YELLOW}?${NC} ${message} [${options}]: "
    read -r response

    case "${response}" in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      d|D) return 2 ;;  # Show diff
      s|S) return 3 ;;  # Skip
      *) echo "Invalid option. Please choose from: ${options}" ;;
    esac
  done
}

get_file_hash() {
  local file="$1"
  if [[ -f "${file}" ]]; then
    shasum -a 256 "${file}" | cut -d' ' -f1
  else
    echo "none"
  fi
}

update_metadata() {
  local file="$1"
  local upstream_file="$2"
  local status="$3"  # synced, modified, diverged, skipped

  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local upstream_hash
  upstream_hash="$(get_file_hash "${upstream_file}")"
  local local_hash
  local_hash="$(get_file_hash "${PROJECT_ROOT}/${file}")"

  # Create or update metadata file (simple JSON)
  if [[ ! -f "${SYNC_METADATA}" ]]; then
    echo "{" > "${SYNC_METADATA}"
    echo "  \"last_sync\": \"${timestamp}\"," >> "${SYNC_METADATA}"
    echo "  \"template_root\": \"${TEMPLATE_ROOT}\"," >> "${SYNC_METADATA}"
    echo "  \"files\": {}" >> "${SYNC_METADATA}"
    echo "}" >> "${SYNC_METADATA}"
  fi

  # Update last_sync timestamp
  if command -v jq &>/dev/null; then
    local temp_file
    temp_file="$(mktemp)"
    jq --arg ts "${timestamp}" \
       --arg file "${file}" \
       --arg status "${status}" \
       --arg upstream_hash "${upstream_hash}" \
       --arg local_hash "${local_hash}" \
       '.last_sync = $ts | .files[$file] = {last_sync: $ts, status: $status, upstream_hash: $upstream_hash, local_hash: $local_hash}' \
       "${SYNC_METADATA}" > "${temp_file}"
    mv "${temp_file}" "${SYNC_METADATA}"
  else
    # Fallback: just update timestamp
    sed -i.bak "s/\"last_sync\": \".*\"/\"last_sync\": \"${timestamp}\"/" "${SYNC_METADATA}"
    rm -f "${SYNC_METADATA}.bak"
  fi
}

# ============================================================================
# Sync Functions
# ============================================================================

sync_tier1_file() {
  local upstream_file="$1"
  local local_file="$2"
  local label="$3"

  local upstream_path="${upstream_file}"
  local local_path="${PROJECT_ROOT}/${local_file}"

  # Check if files differ
  if ! files_differ "${upstream_path}" "${local_path}"; then
    log OK "${label}: unchanged"
    update_metadata "${local_file}" "${upstream_path}" "synced"
    return 0
  fi

  # Files differ
  case "${MODE}" in
    check)
      log WARN "${label}: differs from upstream"
      return 0
      ;;
    dry-run)
      log INFO "${label}: would be updated"
      return 0
      ;;
    status)
      return 0
      ;;
    sync)
      if [[ "${FORCE_MODE}" == "false" ]]; then
        echo ""
        log INFO "${label}: differs from upstream"
        show_diff "${upstream_path}" "${local_path}" "${label}"

        if prompt_user "Apply changes to ${label}?" "y/n/d"; then
          local result=$?
          if [[ ${result} -eq 2 ]]; then
            # Show diff again
            show_diff "${upstream_path}" "${local_path}" "${label}"
            if prompt_user "Apply changes to ${label}?" "y/n"; then
              return 1  # User said no
            fi
          elif [[ ${result} -ne 0 ]]; then
            log INFO "${label}: skipped by user"
            update_metadata "${local_file}" "${upstream_path}" "skipped"
            return 0
          fi
        else
          log INFO "${label}: skipped by user"
          update_metadata "${local_file}" "${upstream_path}" "skipped"
          return 0
        fi
      fi

      # Apply changes
      create_backup "${local_file}"
      mkdir -p "$(dirname "${local_path}")"
      cp -f "${upstream_path}" "${local_path}"
      log OK "${label}: synced from upstream"
      update_metadata "${local_file}" "${upstream_path}" "synced"
      ;;
  esac
}

sync_tier2_file() {
  local upstream_file="$1"
  local local_file="$2"
  local label="$3"

  local upstream_path="${upstream_file}"
  local local_path="${PROJECT_ROOT}/${local_file}"

  # Check if files differ
  if ! files_differ "${upstream_path}" "${local_path}"; then
    log OK "${label}: unchanged"
    update_metadata "${local_file}" "${upstream_path}" "synced"
    return 0
  fi

  # Check for local modifications
  local has_mods=false
  if has_local_modifications "${local_file}"; then
    has_mods=true
  fi

  # Files differ
  case "${MODE}" in
    check)
      if [[ "${has_mods}" == "true" ]]; then
        log WARN "${label}: differs from upstream (has local modifications)"
      else
        log WARN "${label}: differs from upstream"
      fi
      return 0
      ;;
    dry-run)
      if [[ "${has_mods}" == "true" ]]; then
        log INFO "${label}: would prompt (has local modifications)"
      else
        log INFO "${label}: would be updated"
      fi
      return 0
      ;;
    status)
      return 0
      ;;
    sync)
      echo ""
      if [[ "${has_mods}" == "true" ]]; then
        log WARN "${label}: differs from upstream and has local modifications"
      else
        log INFO "${label}: differs from upstream"
      fi

      show_diff "${upstream_path}" "${local_path}" "${label}"

      local prompt_opts="y/n/d/s"
      while true; do
        if prompt_user "Apply changes to ${label}?" "${prompt_opts}"; then
          local result=$?
          case ${result} in
            0)  # Yes
              create_backup "${local_file}"
              mkdir -p "$(dirname "${local_path}")"
              cp -f "${upstream_path}" "${local_path}"
              log OK "${label}: synced from upstream"
              update_metadata "${local_file}" "${upstream_path}" "synced"
              break
              ;;
            2)  # Diff
              show_diff "${upstream_path}" "${local_path}" "${label}"
              ;;
            *)  # No or Skip
              log INFO "${label}: skipped by user"
              update_metadata "${local_file}" "${upstream_path}" "skipped"
              break
              ;;
          esac
        else
          log INFO "${label}: skipped by user"
          update_metadata "${local_file}" "${upstream_path}" "skipped"
          break
        fi
      done
      ;;
  esac
}

sync_agent_directory() {
  local upstream_dir="${TEMPLATE_PROJECT}/dot.agent"
  local local_dir="${PROJECT_ROOT}/.agent"
  local label=".agent/"

  # Check if upstream directory exists
  if [[ ! -d "${upstream_dir}" ]]; then
    log WARN "${label}: upstream directory not found"
    return 0
  fi

  # Simple directory comparison (check if any files differ)
  local dirs_differ=false
  if [[ ! -d "${local_dir}" ]]; then
    dirs_differ=true
  else
    # Compare directory trees (excluding system files)
    if ! diff -qr \
      -x ".DS_Store" \
      -x ".AppleDouble" \
      -x ".LSOverride" \
      -x "Thumbs.db" \
      -x "Desktop.ini" \
      -x ".git" \
      "${upstream_dir}" "${local_dir}" &>/dev/null; then
      dirs_differ=true
    fi
  fi

  if [[ "${dirs_differ}" == "false" ]]; then
    log OK "${label}: unchanged"
    return 0
  fi

  # Directories differ
  case "${MODE}" in
    check)
      log WARN "${label}: differs from upstream"
      return 0
      ;;
    dry-run)
      log INFO "${label}: would be replaced"
      return 0
      ;;
    status)
      return 0
      ;;
    sync)
      echo ""
      log INFO "${label}: differs from upstream"

      if [[ "${FORCE_MODE}" == "false" ]]; then
        preview_directory_changes "${upstream_dir}" "${local_dir}" "${label}"

        echo -e "${YELLOW}Warning:${NC} .agent/ directory will be completely replaced"
        echo "Current .agent/ will be backed up to .template-backups/"
        echo ""

        if ! prompt_user "Replace .agent/ directory?" "y/n"; then
          log INFO "${label}: skipped by user"
          return 0
        fi
      fi

      # Replace directory
      create_backup_dir ".agent"
      rm -rf "${local_dir}"
      cp -R "${upstream_dir}" "${local_dir}"
      log OK "${label}: synced from upstream"

      # Run local sync to propagate changes
      if [[ -f "${PROJECT_ROOT}/scripts/boilerplate/sync-agents.sh" ]]; then
        log INFO "Running local sync to propagate .agent/ changes..."
        "${PROJECT_ROOT}/scripts/boilerplate/sync-agents.sh"
      fi
      ;;
  esac
}

preview_directory_changes() {
  local upstream_dir="$1"
  local local_dir="$2"
  local label="$3"

  echo ""
  echo -e "${BLUE}Preview of changes for ${label}:${NC}"
  echo ""

  # Files only in upstream (will be added)
  local to_add=$(diff -qr \
    -x ".DS_Store" -x ".AppleDouble" -x ".LSOverride" \
    -x "Thumbs.db" -x "Desktop.ini" -x ".git" \
    "${upstream_dir}" "${local_dir}" 2>/dev/null | \
    grep "Only in ${upstream_dir}" | \
    sed "s|Only in ${upstream_dir}[:/] *||")

  if [[ -n "$to_add" ]]; then
    echo -e "${GREEN}Files to be added:${NC}"
    echo "$to_add" | while read -r file; do
      echo "  + $file"
    done
    echo ""
  fi

  # Files only in local (will be removed)
  local to_remove=$(diff -qr \
    -x ".DS_Store" -x ".AppleDouble" -x ".LSOverride" \
    -x "Thumbs.db" -x "Desktop.ini" -x ".git" \
    "${upstream_dir}" "${local_dir}" 2>/dev/null | \
    grep "Only in ${local_dir}" | \
    sed "s|Only in ${local_dir}[:/] *||")

  if [[ -n "$to_remove" ]]; then
    echo -e "${RED}Files to be removed:${NC}"
    echo "$to_remove" | while read -r file; do
      echo "  - $file"
    done
    echo ""
  fi

  # Files that differ (will be modified)
  local to_modify=$(diff -qr \
    -x ".DS_Store" -x ".AppleDouble" -x ".LSOverride" \
    -x "Thumbs.db" -x "Desktop.ini" -x ".git" \
    "${upstream_dir}" "${local_dir}" 2>/dev/null | \
    grep "^Files " | \
    sed "s|Files ${upstream_dir}/\(.*\) and ${local_dir}/\(.*\) differ|\1|")

  if [[ -n "$to_modify" ]]; then
    echo -e "${YELLOW}Files to be modified:${NC}"
    echo "$to_modify" | while read -r file; do
      echo "  ~ $file"
    done
    echo ""
  fi
}

sync_boilerplate_directory() {
  local upstream_dir="${TEMPLATE_PROJECT}/scripts/boilerplate"
  local local_dir="${PROJECT_ROOT}/scripts/boilerplate"
  local label="scripts/boilerplate/"

  # Check if upstream directory exists
  if [[ ! -d "${upstream_dir}" ]]; then
    log WARN "${label}: upstream directory not found"
    return 0
  fi

  # Simple directory comparison
  local dirs_differ=false
  if [[ ! -d "${local_dir}" ]]; then
    dirs_differ=true
  else
    # Compare directory trees (excluding system files)
    if ! diff -qr \
      -x ".DS_Store" \
      -x ".AppleDouble" \
      -x ".LSOverride" \
      -x "Thumbs.db" \
      -x "Desktop.ini" \
      -x ".git" \
      "${upstream_dir}" "${local_dir}" &>/dev/null; then
      dirs_differ=true
    fi
  fi

  if [[ "${dirs_differ}" == "false" ]]; then
    log OK "${label}: unchanged"
    return 0
  fi

  # Directories differ
  case "${MODE}" in
    check)
      log WARN "${label}: differs from upstream"
      return 0
      ;;
    dry-run)
      log INFO "${label}: would be replaced"
      return 0
      ;;
    status)
      return 0
      ;;
    sync)
      echo ""
      log INFO "${label}: differs from upstream"

      if [[ "${FORCE_MODE}" == "false" ]]; then
        preview_directory_changes "${upstream_dir}" "${local_dir}" "${label}"

        echo -e "${YELLOW}Warning:${NC} scripts/boilerplate/ directory will be completely replaced"
        echo "Current scripts/boilerplate/ will be backed up to .template-backups/"
        echo ""

        if ! prompt_user "Replace scripts/boilerplate/ directory?" "y/n"; then
          log INFO "${label}: skipped by user"
          return 0
        fi
      fi

      # Replace directory
      create_backup_dir "scripts/boilerplate"
      rm -rf "${local_dir}"
      cp -R "${upstream_dir}" "${local_dir}"

      # Ensure scripts are executable
      chmod +x "${local_dir}"/*.sh "${local_dir}"/*.py 2>/dev/null || true

      log OK "${label}: synced from upstream"
      ;;
  esac
}

# ============================================================================
# Main Sync Logic
# ============================================================================

sync_all_files() {
  log INFO "Starting template sync (mode: ${MODE})"
  log INFO "Project: ${PROJECT_ROOT}"
  log INFO "Template: ${TEMPLATE_ROOT}"
  echo ""

  # Determine which files to sync
  local sync_agents_global=false
  local sync_claude_global=false
  local sync_agents=false
  local sync_claude=false
  local sync_rules=false
  local sync_agent_dir=false
  local sync_boilerplate_dir=false

  if [[ ${#SELECTED_FILES[@]} -eq 0 ]] || [[ " ${SELECTED_FILES[*]} " =~ " all " ]]; then
    sync_agents_global=true
    sync_claude_global=true
    sync_agents=true
    sync_claude=true
    sync_rules=true
    sync_agent_dir=true
    sync_boilerplate_dir=true
  else
    for file in "${SELECTED_FILES[@]}"; do
      case "${file}" in
        AGENTS_global) sync_agents_global=true ;;
        CLAUDE_global) sync_claude_global=true ;;
        AGENTS) sync_agents=true ;;
        CLAUDE) sync_claude=true ;;
        RULES) sync_rules=true ;;
        agent) sync_agent_dir=true ;;
        boilerplate) sync_boilerplate_dir=true ;;
        *) log WARN "Unknown file: ${file}" ;;
      esac
    done
  fi

  # Tier 1: Pure template files (auto-sync with backup)
  echo -e "${BLUE}Tier 1: Pure Template Files${NC}"
  if [[ "${sync_agents_global}" == "true" ]]; then
    sync_tier1_file "${TEMPLATE_GLOBAL}/AGENTS_global.md" "AGENTS_global.md" "AGENTS_global.md"
  fi

  if [[ "${sync_claude_global}" == "true" ]]; then
    sync_tier1_file "${TEMPLATE_GLOBAL}/CLAUDE_global.md" "CLAUDE_global.md" "CLAUDE_global.md"
  fi

  if [[ "${sync_agent_dir}" == "true" ]]; then
    sync_agent_directory
  fi

  if [[ "${sync_boilerplate_dir}" == "true" ]]; then
    sync_boilerplate_directory
  fi

  echo ""

  # Tier 2: Customizable project files (interactive)
  echo -e "${BLUE}Tier 2: Customizable Project Files${NC}"
  if [[ "${sync_agents}" == "true" ]]; then
    sync_tier2_file "${TEMPLATE_PROJECT}/AGENTS_project.md" "AGENTS.md" "AGENTS.md"
  fi

  if [[ "${sync_claude}" == "true" ]]; then
    sync_tier2_file "${TEMPLATE_PROJECT}/CLAUDE_project.md" "CLAUDE.md" "CLAUDE.md"
  fi

  if [[ "${sync_rules}" == "true" ]]; then
    sync_tier2_file "${TEMPLATE_PROJECT}/RULES.md" "RULES.md" "RULES.md"
  fi

  echo ""
  log OK "Sync complete"
}

show_status() {
  if [[ ! -f "${SYNC_METADATA}" ]]; then
    log INFO "No sync history found"
    log INFO "Run 'make sync-upstream' to sync from template"
    return 0
  fi

  echo -e "${BLUE}Template Sync Status${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  if command -v jq &>/dev/null; then
    local last_sync
    last_sync="$(jq -r '.last_sync' "${SYNC_METADATA}")"
    echo -e "Last sync: ${GREEN}${last_sync}${NC}"
    echo ""

    echo -e "${BLUE}Files:${NC}"
    jq -r '.files | to_entries[] | "\(.key): \(.value.status)"' "${SYNC_METADATA}" | while read -r line; do
      local file="${line%%:*}"
      local status="${line#*: }"

      case "${status}" in
        synced)   echo -e "  ${GREEN}✓${NC} ${file} (synced)" ;;
        modified) echo -e "  ${YELLOW}⚠${NC} ${file} (local modifications)" ;;
        diverged) echo -e "  ${RED}✗${NC} ${file} (diverged)" ;;
        skipped)  echo -e "  ${BLUE}○${NC} ${file} (skipped)" ;;
        *)        echo -e "  ${BLUE}?${NC} ${file} (${status})" ;;
      esac
    done
  else
    cat "${SYNC_METADATA}"
  fi

  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================================================
# Argument Parsing
# ============================================================================

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
      --dry-run)
        MODE="dry-run"
        shift
        ;;
      --status)
        MODE="status"
        shift
        ;;
      --force)
        FORCE_MODE=true
        shift
        ;;
      AGENTS_global|CLAUDE_global|AGENTS|CLAUDE|RULES|agent|boilerplate|all)
        SELECTED_FILES+=("$1")
        shift
        ;;
      *)
        log ERROR "Unknown option: $1"
        echo "Run with --help for usage information"
        exit 1
        ;;
    esac
  done
}

# ============================================================================
# Main
# ============================================================================

main() {
  parse_args "$@"

  # Check upstream exists
  if ! check_upstream_exists; then
    exit 1
  fi

  # Handle different modes
  case "${MODE}" in
    status)
      show_status
      ;;
    check|dry-run|sync)
      sync_all_files
      ;;
    *)
      log ERROR "Unknown mode: ${MODE}"
      exit 1
      ;;
  esac
}

main "$@"
