#!/bin/bash
# DevContainer Health Check Script
# Verifies that the development environment is properly configured
#
# Usage: ./health-check.sh
# Exit codes: 0 = healthy, 1 = unhealthy

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Helper functions
print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_check() {
  echo -n "  Checking $1... "
}

print_pass() {
  echo -e "${GREEN}✓ PASS${NC}"
  ((CHECKS_PASSED++))
}

print_fail() {
  echo -e "${RED}✗ FAIL${NC}"
  if [ -n "$1" ]; then
    echo -e "    ${RED}→ $1${NC}"
  fi
  ((CHECKS_FAILED++))
}

print_warn() {
  echo -e "${YELLOW}⚠ WARNING${NC}"
  if [ -n "$1" ]; then
    echo -e "    ${YELLOW}→ $1${NC}"
  fi
  ((CHECKS_WARNING++))
}

print_info() {
  echo -e "    ${BLUE}ℹ $1${NC}"
}

# Start health check
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DevContainer Health Check                                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

# 1. Container Environment
print_header "Container Environment"

print_check "DevContainer detection"
if [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ] || [ -f "/.dockerenv" ]; then
  print_pass
else
  print_warn "Not running in a container"
  print_info "This script is designed to run inside a DevContainer"
fi

print_check "Working directory"
if [ -d "/workspace" ]; then
  print_pass
  print_info "Working directory: /workspace"
else
  print_warn "Expected /workspace directory not found"
  print_info "Current directory: $(pwd)"
fi

print_check "User permissions"
if [ "$(id -u)" != "0" ]; then
  print_pass
  print_info "Running as non-root user: $(whoami)"
else
  print_warn "Running as root (not recommended)"
fi

# Check for virtual environment
print_check "Python virtual environment"
if [ -d "/home/ashmuk/.venv" ]; then
  print_pass
  print_info "Virtual environment: /home/ashmuk/.venv"
else
  print_warn "Virtual environment not found"
  print_info "Run postCreateCommand to create it"
fi

# 2. Required Tools
print_header "Development Tools"

check_tool() {
  local tool=$1
  local required=$2
  local tool_path=""

  print_check "$tool"

  # Check system PATH first
  if command -v "$tool" >/dev/null 2>&1; then
    tool_path=$(command -v "$tool")
  # Check virtual environment
  elif [ -f "/home/ashmuk/.venv/bin/$tool" ]; then
    tool_path="/home/ashmuk/.venv/bin/$tool"
  fi

  if [ -n "$tool_path" ]; then
    local version
    version=$("$tool_path" --version 2>&1 | head -1 || echo "unknown")
    print_pass
    print_info "$version"
    # Show location if it's in venv
    if [[ "$tool_path" == *".venv"* ]]; then
      print_info "Location: venv"
    fi
  else
    if [ "$required" = "true" ]; then
      print_fail "Not installed (required)"
    else
      print_warn "Not installed (optional)"
    fi
  fi
}

check_tool "git" "true"
check_tool "python3" "true"
check_tool "tmux" "true"
check_tool "tmuxinator" "true"
check_tool "node" "false"
check_tool "npm" "false"
check_tool "aider" "false"
check_tool "ruff" "false"
check_tool "pytest" "false"
check_tool "gh" "false"
check_tool "act" "false"

# 3. Environment Variables
print_header "Environment Variables"

check_env_var() {
  local var_name=$1
  local required=$2
  print_check "$var_name"
  if [ -n "${!var_name}" ]; then
    print_pass
    # Mask sensitive values
    local value="${!var_name}"
    if [[ "$var_name" == *"KEY"* ]] || [[ "$var_name" == *"TOKEN"* ]] || [[ "$var_name" == *"SECRET"* ]]; then
      print_info "${value:0:10}...${value: -4}"
    else
      print_info "$value"
    fi
  else
    if [ "$required" = "true" ]; then
      print_fail "Not set (required)"
    else
      print_warn "Not set (optional)"
    fi
  fi
}

check_env_var "ANTHROPIC_API_KEY" "false"
check_env_var "OPENAI_API_KEY" "false"
check_env_var "GITHUB_TOKEN" "false"
check_env_var "PATH" "true"
check_env_var "HOME" "true"

# 4. Project Files
print_header "Project Configuration"

check_file() {
  local file=$1
  local required=$2
  print_check "$file"
  if [ -f "$file" ]; then
    print_pass
    local size
    size=$(du -h "$file" | cut -f1)
    print_info "Size: $size"
  else
    if [ "$required" = "true" ]; then
      print_fail "Not found (required)"
    else
      print_warn "Not found (optional)"
    fi
  fi
}

check_file ".aider.conf.yml" "false"
check_file "ai_dev.yml" "false"
check_file "Makefile" "false"
check_file ".env" "false"
check_file ".gitignore" "false"
check_file ".pre-commit-config.yaml" "false"

# 5. Aider Configuration
if command -v aider >/dev/null 2>&1; then
  print_header "Aider AI Configuration"

  print_check "Aider executable"
  print_pass
  print_info "$(which aider)"

  print_check "API key configuration"
  if [ -n "$ANTHROPIC_API_KEY" ] || [ -n "$OPENAI_API_KEY" ]; then
    print_pass
    [ -n "$ANTHROPIC_API_KEY" ] && print_info "Anthropic API key configured"
    [ -n "$OPENAI_API_KEY" ] && print_info "OpenAI API key configured"
  else
    print_warn "No API keys found"
    print_info "Set ANTHROPIC_API_KEY or OPENAI_API_KEY in .env"
  fi

  if [ -f ".aider.conf.yml" ]; then
    print_check "Aider config file"
    print_pass
  fi
fi

# 6. Git Configuration
print_header "Git Configuration"

print_check "Git user name"
if git config user.name >/dev/null 2>&1; then
  print_pass
  print_info "$(git config user.name)"
else
  print_fail "Not configured"
  print_info "Set with: git config --global user.name 'Your Name'"
fi

print_check "Git user email"
if git config user.email >/dev/null 2>&1; then
  print_pass
  print_info "$(git config user.email)"
else
  print_fail "Not configured"
  print_info "Set with: git config --global user.email 'you@example.com'"
fi

print_check "Git repository"
if git rev-parse --git-dir >/dev/null 2>&1; then
  print_pass
  branch=$(git branch --show-current 2>/dev/null || echo "detached")
  print_info "Branch: $branch"
else
  print_warn "Not a git repository"
fi

# 7. Network Connectivity
print_header "Network Connectivity"

check_http_connectivity() {
  local url=$1
  local name=$2
  print_check "$name connectivity"
  if curl -s -o /dev/null --connect-timeout 3 --max-time 5 "$url" 2>/dev/null; then
    print_pass
    print_info "Reachable via HTTP/HTTPS"
  else
    print_warn "Cannot reach $url"
    print_info "Check network or firewall settings"
  fi
}

check_http_connectivity "https://www.google.com" "Internet"
check_http_connectivity "https://api.anthropic.com" "Anthropic API"
check_http_connectivity "https://api.openai.com" "OpenAI API"
check_http_connectivity "https://github.com" "GitHub"

# 8. Summary
print_header "Health Check Summary"

echo ""
echo -e "  ${GREEN}✓ Passed:${NC}   $CHECKS_PASSED"
echo -e "  ${YELLOW}⚠ Warnings:${NC} $CHECKS_WARNING"
echo -e "  ${RED}✗ Failed:${NC}   $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  Environment is HEALTHY ✓                                      ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  Environment has ISSUES ✗                                      ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${YELLOW}Recommendations:${NC}"
  echo -e "  1. Review failed checks above"
  echo -e "  2. Install missing required tools"
  echo -e "  3. Configure environment variables in .env"
  echo -e "  4. Run 'make setup' to install dependencies"
  echo ""
  exit 1
fi
