#!/bin/bash
#
# Setup Git hooks for dotfiles repository
# This script installs hooks that run local tests before pushing
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "${RED}[ERROR]${NC} This script must be run from within a git repository"
    exit 1
fi

echo "${BLUE}[INFO]${NC} Setting up git hooks for dotfiles..."

# Create hooks directory if it doesn't exist
HOOKS_DIR="$REPO_ROOT/.git/hooks"
mkdir -p "$HOOKS_DIR"

# Install pre-push hook
PRE_PUSH_HOOK="$HOOKS_DIR/pre-push"
cat > "$PRE_PUSH_HOOK" << 'EOF'
#!/bin/sh
#
# Pre-push hook to run tests before pushing to remote
# This helps catch issues locally before they trigger CI failures
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}[PRE-PUSH]${NC} Running local tests before push..."

# Get the root directory of the repository
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

# Run the comprehensive test suite
echo "${BLUE}[PRE-PUSH]${NC} Running syntax tests..."
if ! make test-syntax; then
    echo "${RED}[ERROR]${NC} Syntax tests failed. Push aborted."
    exit 1
fi

echo "${BLUE}[PRE-PUSH]${NC} Running shellcheck..."
if ! make test-shellcheck; then
    echo "${RED}[ERROR]${NC} ShellCheck tests failed. Push aborted."
    exit 1
fi

echo "${BLUE}[PRE-PUSH]${NC} Running compatibility tests..."
if ! make test-compat; then
    echo "${RED}[ERROR]${NC} Compatibility tests failed. Push aborted."
    exit 1
fi

echo "${GREEN}[PRE-PUSH]${NC} All tests passed! Proceeding with push..."
EOF

chmod +x "$PRE_PUSH_HOOK"
echo "${GREEN}[SUCCESS]${NC} Pre-push hook installed at $PRE_PUSH_HOOK"

# Show user what they can do
echo ""
echo "${BLUE}[INFO]${NC} Git hooks have been set up successfully!"
echo ""
echo "Available commands:"
echo "  ${YELLOW}make test${NC}           - Run all tests (syntax, shellcheck, compatibility)"
echo "  ${YELLOW}make test-syntax${NC}    - Test shell syntax only"
echo "  ${YELLOW}make test-shellcheck${NC} - Run shellcheck only"
echo "  ${YELLOW}make test-compat${NC}    - Test platform compatibility only"
echo ""
echo "The pre-push hook will automatically run these tests before each push."
echo "To bypass the hook temporarily, use: ${YELLOW}git push --no-verify${NC}"
echo ""
echo "To install shellcheck (if not already installed):"
echo "  macOS: ${YELLOW}brew install shellcheck${NC}"
echo "  Ubuntu: ${YELLOW}sudo apt-get install shellcheck${NC}"