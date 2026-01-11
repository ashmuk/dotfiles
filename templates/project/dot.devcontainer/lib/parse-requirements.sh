#!/bin/bash
# parse-requirements.sh - YAML parser helper for requirements.yaml
# Uses yq to parse YAML and export environment variables

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="${WORKSPACE:-/workspace}"
REQUIREMENTS_FILE="${WORKSPACE}/.devcontainer/requirements.yaml"
PROFILES_DIR="${WORKSPACE}/.devcontainer/profiles"

# Check if yq is available
if ! command -v yq &>/dev/null; then
    echo "[parse-requirements] ERROR: yq is not installed"
    exit 1
fi

# Determine the profile to use
get_profile() {
    local profile="fullstack"

    if [[ -f "$REQUIREMENTS_FILE" ]]; then
        profile=$(yq -r '.profile // "fullstack"' "$REQUIREMENTS_FILE")
    elif [[ -n "${DEV_PROFILE:-}" ]]; then
        profile="$DEV_PROFILE"
    fi

    echo "$profile"
}

# Get profile file path
get_profile_file() {
    local profile="$1"
    local profile_file="${PROFILES_DIR}/${profile}.yaml"

    if [[ ! -f "$profile_file" ]]; then
        echo "[parse-requirements] WARNING: Profile '$profile' not found, using fullstack" >&2
        profile_file="${PROFILES_DIR}/fullstack.yaml"
    fi

    echo "$profile_file"
}

# Merge profile defaults with requirements.yaml overrides
# Returns merged YAML to stdout
merge_config() {
    local profile="$1"
    local profile_file
    profile_file=$(get_profile_file "$profile")

    if [[ -f "$REQUIREMENTS_FILE" ]]; then
        # Merge: profile defaults + requirements.yaml overrides
        yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
            "$profile_file" "$REQUIREMENTS_FILE"
    else
        # No requirements.yaml, use profile defaults
        cat "$profile_file"
    fi
}

# Check if a runtime is enabled
is_runtime_enabled() {
    local runtime="$1"
    local config="$2"

    echo "$config" | yq -r ".runtimes.${runtime}.enabled // false"
}

# Get packages for a runtime
get_runtime_packages() {
    local runtime="$1"
    local config="$2"

    echo "$config" | yq -r ".runtimes.${runtime}.packages // [] | .[]" 2>/dev/null || true
}

# Get directories to create
get_directories() {
    local config="$1"

    echo "$config" | yq -r '.directories // [] | .[]' 2>/dev/null || true
}

# Get post_create hooks
get_post_create_hooks() {
    local config="$1"

    echo "$config" | yq -r '.hooks.post_create // [] | .[]' 2>/dev/null || true
}

# Get post_start hooks
get_post_start_hooks() {
    local config="$1"

    echo "$config" | yq -r '.hooks.post_start // [] | .[]' 2>/dev/null || true
}

# Export all configuration as environment variables
export_config() {
    local profile
    profile=$(get_profile)

    local config
    config=$(merge_config "$profile")

    # Export profile
    export DEVCONTAINER_PROFILE="$profile"

    # Export runtime states
    export PYTHON_ENABLED=$(is_runtime_enabled "python" "$config")
    export NODE_ENABLED=$(is_runtime_enabled "node" "$config")
    export JAVA_ENABLED=$(is_runtime_enabled "java" "$config")

    # Export packages as space-separated strings
    export PYTHON_PACKAGES=$(get_runtime_packages "python" "$config" | tr '\n' ' ')
    export NODE_PACKAGES=$(get_runtime_packages "node" "$config" | tr '\n' ' ')

    # Export directories
    export PROJECT_DIRECTORIES=$(get_directories "$config" | tr '\n' ' ')

    # Export hooks
    export POST_CREATE_HOOKS=$(get_post_create_hooks "$config")
    export POST_START_HOOKS=$(get_post_start_hooks "$config")

    # Print summary
    echo "[parse-requirements] Profile: $DEVCONTAINER_PROFILE"
    echo "[parse-requirements] Python: $PYTHON_ENABLED (packages: $PYTHON_PACKAGES)"
    echo "[parse-requirements] Node: $NODE_ENABLED (packages: $NODE_PACKAGES)"
    echo "[parse-requirements] Java: $JAVA_ENABLED"
}

# Main: if sourced, export config; if run directly, print config
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being run directly - print configuration
    profile=$(get_profile)
    echo "Profile: $profile"
    echo "---"
    merge_config "$profile"
else
    # Script is being sourced - export variables
    export_config
fi
