#!/bin/bash
# post-create.sh - DevContainer post-create setup script
# Called by postCreateCommand in devcontainer.json
#
# This script reads requirements.yaml to determine which runtimes and packages
# to set up. If no requirements.yaml exists, it falls back to the DEV_PROFILE
# environment variable or defaults to the 'fullstack' profile.

set -e

WORKSPACE="${WORKSPACE:-/workspace}"
REQUIREMENTS_FILE="${WORKSPACE}/.devcontainer/requirements.yaml"
PROFILES_DIR="${WORKSPACE}/.devcontainer/profiles"
LIB_DIR="${WORKSPACE}/.devcontainer/lib"
HOME_DIR="/home/developer"

echo "[post-create] Starting post-create setup..."

# =============================================================================
# Profile Detection and Configuration Loading
# =============================================================================

# Determine profile
if [[ -f "$REQUIREMENTS_FILE" ]] && command -v yq &>/dev/null; then
    PROFILE=$(yq -r '.profile // "fullstack"' "$REQUIREMENTS_FILE")
    echo "[post-create] Using profile from requirements.yaml: $PROFILE"
elif [[ -n "${DEV_PROFILE:-}" ]]; then
    PROFILE="$DEV_PROFILE"
    echo "[post-create] Using profile from DEV_PROFILE env: $PROFILE"
else
    PROFILE="fullstack"
    echo "[post-create] Using default profile: $PROFILE"
fi

# Load profile configuration
PROFILE_FILE="${PROFILES_DIR}/${PROFILE}.yaml"
if [[ ! -f "$PROFILE_FILE" ]]; then
    echo "[post-create] WARNING: Profile '$PROFILE' not found, using fullstack"
    PROFILE_FILE="${PROFILES_DIR}/fullstack.yaml"
fi

# Helper function to get config value (merges requirements.yaml over profile)
get_config() {
    local path="$1"
    local default="$2"

    if ! command -v yq &>/dev/null; then
        echo "$default"
        return
    fi

    local value=""

    # First check requirements.yaml
    if [[ -f "$REQUIREMENTS_FILE" ]]; then
        value=$(yq -r "$path // \"\"" "$REQUIREMENTS_FILE" 2>/dev/null || echo "")
    fi

    # Fall back to profile if not set in requirements.yaml
    if [[ -z "$value" || "$value" == "null" ]] && [[ -f "$PROFILE_FILE" ]]; then
        value=$(yq -r "$path // \"\"" "$PROFILE_FILE" 2>/dev/null || echo "")
    fi

    # Use default if still not set
    if [[ -z "$value" || "$value" == "null" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Helper to get array values as newline-separated list
get_config_array() {
    local path="$1"

    if ! command -v yq &>/dev/null; then
        return
    fi

    local values=""

    # First check requirements.yaml
    if [[ -f "$REQUIREMENTS_FILE" ]]; then
        values=$(yq -r "$path // [] | .[]" "$REQUIREMENTS_FILE" 2>/dev/null || echo "")
    fi

    # If empty, fall back to profile
    if [[ -z "$values" ]] && [[ -f "$PROFILE_FILE" ]]; then
        values=$(yq -r "$path // [] | .[]" "$PROFILE_FILE" 2>/dev/null || echo "")
    fi

    echo "$values"
}

# =============================================================================
# Runtime Configuration
# =============================================================================

PYTHON_ENABLED=$(get_config '.runtimes.python.enabled' 'true')
NODE_ENABLED=$(get_config '.runtimes.node.enabled' 'true')
JAVA_ENABLED=$(get_config '.runtimes.java.enabled' 'false')

echo "[post-create] Runtime configuration:"
echo "[post-create]   Python: $PYTHON_ENABLED"
echo "[post-create]   Node.js: $NODE_ENABLED"
echo "[post-create]   Java: $JAVA_ENABLED"

# =============================================================================
# Python Setup
# =============================================================================

if [[ "$PYTHON_ENABLED" == "true" ]]; then
    echo "[post-create] Setting up Python environment..."

    # Create virtual environment
    if [[ ! -d "${HOME_DIR}/.venv" ]]; then
        echo "[post-create] Creating Python virtual environment..."
        python3 -m venv "${HOME_DIR}/.venv"
    fi

    # Activate venv and upgrade pip
    source "${HOME_DIR}/.venv/bin/activate"
    pip install --upgrade pip --quiet

    # Install packages from configuration
    PYTHON_PACKAGES=$(get_config_array '.runtimes.python.packages')
    if [[ -n "$PYTHON_PACKAGES" ]]; then
        echo "[post-create] Installing Python packages..."
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                pip install --quiet "$package" || echo "[post-create]   WARNING: Failed to install $package"
            fi
        done <<< "$PYTHON_PACKAGES"
    fi

    # Add venv activation to .zshrc if not already present
    if ! grep -q "source ${HOME_DIR}/.venv/bin/activate" "${HOME_DIR}/.zshrc" 2>/dev/null; then
        echo "[post-create] Adding venv activation to .zshrc..."
        echo "source ${HOME_DIR}/.venv/bin/activate" >> "${HOME_DIR}/.zshrc"
    fi

    echo "[post-create] Python setup complete"
fi

# =============================================================================
# Node.js Setup
# =============================================================================

if [[ "$NODE_ENABLED" == "true" ]]; then
    echo "[post-create] Setting up Node.js environment..."

    # Get package manager preference
    PACKAGE_MANAGER=$(get_config '.runtimes.node.package_manager' 'npm')

    # Install pnpm or yarn if specified
    if [[ "$PACKAGE_MANAGER" == "pnpm" ]]; then
        if ! command -v pnpm &>/dev/null; then
            echo "[post-create] Installing pnpm..."
            npm install -g pnpm --quiet
        fi
    elif [[ "$PACKAGE_MANAGER" == "yarn" ]]; then
        if ! command -v yarn &>/dev/null; then
            echo "[post-create] Installing yarn..."
            npm install -g yarn --quiet
        fi
    fi

    # Install global packages from configuration
    NODE_PACKAGES=$(get_config_array '.runtimes.node.packages')
    if [[ -n "$NODE_PACKAGES" ]]; then
        echo "[post-create] Installing Node.js packages..."
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                npm install -g --quiet "$package" || echo "[post-create]   WARNING: Failed to install $package"
            fi
        done <<< "$NODE_PACKAGES"
    fi

    echo "[post-create] Node.js setup complete"
fi

# =============================================================================
# Java Setup
# =============================================================================

if [[ "$JAVA_ENABLED" == "true" ]]; then
    echo "[post-create] Setting up Java environment..."

    # Get build tool preference
    BUILD_TOOL=$(get_config '.runtimes.java.build_tool' 'maven')

    # Verify Java installation
    if command -v java &>/dev/null; then
        echo "[post-create] Java version: $(java -version 2>&1 | head -1)"
    fi

    # Verify build tool
    if [[ "$BUILD_TOOL" == "maven" ]] && command -v mvn &>/dev/null; then
        echo "[post-create] Maven version: $(mvn -version 2>&1 | head -1)"
    elif [[ "$BUILD_TOOL" == "gradle" ]] && command -v gradle &>/dev/null; then
        echo "[post-create] Gradle version: $(gradle -version 2>&1 | grep Gradle | head -1)"
    fi

    echo "[post-create] Java setup complete"
fi

# =============================================================================
# Directory Setup
# =============================================================================

DIRECTORIES=$(get_config_array '.directories')
if [[ -n "$DIRECTORIES" ]]; then
    echo "[post-create] Creating project directories..."
    while IFS= read -r dir; do
        if [[ -n "$dir" ]]; then
            mkdir -p "${WORKSPACE}/${dir}"
            echo "[post-create]   Created: ${dir}"
        fi
    done <<< "$DIRECTORIES"
fi

# =============================================================================
# Custom Hooks
# =============================================================================
# SECURITY NOTE: Hooks are executed via bash -c in a subshell.
# Only use trusted requirements.yaml files. Malicious hooks could execute
# arbitrary commands. This is intentional to allow flexibility, but be careful
# when syncing requirements.yaml from untrusted sources.
# =============================================================================

POST_CREATE_HOOKS=$(get_config_array '.hooks.post_create')
if [[ -n "$POST_CREATE_HOOKS" ]]; then
    echo "[post-create] Running custom post_create hooks..."
    while IFS= read -r hook; do
        if [[ -n "$hook" ]]; then
            echo "[post-create]   Executing: $hook"
            # Run in subshell to isolate from main script environment
            (bash -c "$hook") || echo "[post-create]   WARNING: Hook failed: $hook"
        fi
    done <<< "$POST_CREATE_HOOKS"
fi

# =============================================================================
# Universal Setup (AI Tool Integration)
# =============================================================================

echo "[post-create] Setting up AI tool integration..."

# Ensure directories exist
mkdir -p "${HOME_DIR}/.claude"
mkdir -p "${HOME_DIR}/.codex"

# Link AGENTS_global.md to ~/.codex/AGENTS.md
if [ -f "${WORKSPACE}/AGENTS_global.md" ]; then
    if [ -L "${HOME_DIR}/.codex/AGENTS.md" ] || [ ! -f "${HOME_DIR}/.codex/AGENTS.md" ]; then
        ln -sf "${WORKSPACE}/AGENTS_global.md" "${HOME_DIR}/.codex/AGENTS.md"
        echo "[post-create] Created symlink: ~/.codex/AGENTS.md -> AGENTS_global.md"
    else
        echo "[post-create] Warning: ~/.codex/AGENTS.md already exists (not a symlink), skipping"
    fi
else
    echo "[post-create] Info: AGENTS_global.md not found, skipping symlink"
fi

# Link CLAUDE_global.md to ~/.claude/CLAUDE.md
if [ -f "${WORKSPACE}/CLAUDE_global.md" ]; then
    if [ -L "${HOME_DIR}/.claude/CLAUDE.md" ] || [ ! -f "${HOME_DIR}/.claude/CLAUDE.md" ]; then
        ln -sf "${WORKSPACE}/CLAUDE_global.md" "${HOME_DIR}/.claude/CLAUDE.md"
        echo "[post-create] Created symlink: ~/.claude/CLAUDE.md -> CLAUDE_global.md"
    else
        echo "[post-create] Warning: ~/.claude/CLAUDE.md already exists (not a symlink), skipping"
    fi
else
    echo "[post-create] Info: CLAUDE_global.md not found, skipping symlink"
fi

# =============================================================================
# Complete
# =============================================================================

echo ""
echo "[post-create] Setup complete!"
echo "[post-create] Profile: $PROFILE"
echo "[post-create] Use 'claude' for standard mode or 'claude-hard' for dangerous mode"
