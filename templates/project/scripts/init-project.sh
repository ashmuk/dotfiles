#!/usr/bin/env bash
# init-project.sh - Initialize project after template deployment
# Supports both interactive (wizard) and non-interactive (CLI) modes
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

# Mode: "wizard" (interactive) or "cli" (non-interactive)
MODE="${1:-wizard}"

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
  echo -e "${CYAN}▶${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# Ask yes/no question (wizard mode only)
ask_yes_no() {
  local prompt="$1"
  local default="${2:-y}"

  if [[ "$MODE" == "cli" ]]; then
    [[ "$default" == "y" ]] && return 0 || return 1
  fi

  local yn_hint="[Y/n]"
  [[ "$default" == "n" ]] && yn_hint="[y/N]"

  read -p "$prompt $yn_hint " -n 1 -r
  echo

  if [[ -z "$REPLY" ]]; then
    [[ "$default" == "y" ]] && return 0 || return 1
  fi

  [[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}

# Ask for input (wizard mode only)
ask_input() {
  local prompt="$1"
  local default="$2"
  local varname="$3"

  if [[ "$MODE" == "cli" ]]; then
    eval "$varname=\"$default\""
    return
  fi

  read -p "$prompt [$default]: " input
  eval "$varname=\"${input:-$default}\""
}

# ============================================
# Step 1: Git Repository
# ============================================
init_git() {
  print_header "Step 1: Git Repository"

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_success "Git repository already initialized"
    return 0
  fi

  if [[ "$MODE" == "wizard" ]]; then
    if ! ask_yes_no "Initialize git repository?"; then
      print_warning "Skipping git initialization"
      return 0
    fi
  fi

  print_step "Initializing git repository..."
  git init
  print_success "Git repository initialized"

  # Ask about default branch
  local branch_name="main"
  if [[ "$MODE" == "wizard" ]]; then
    ask_input "Default branch name" "main" branch_name
  fi

  if [[ "$branch_name" != "main" ]] && [[ "$branch_name" != "master" ]]; then
    git checkout -b "$branch_name" 2>/dev/null || true
    print_success "Default branch set to: $branch_name"
  fi
}

# ============================================
# Step 2: Git Hooks
# ============================================
setup_hooks() {
  print_header "Step 2: Git Hooks"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_warning "Not a git repository, skipping hooks setup"
    return 0
  fi

  if [[ "$MODE" == "wizard" ]]; then
    if ! ask_yes_no "Set up git hooks (pre-commit, pre-push)?"; then
      print_warning "Skipping git hooks setup"
      return 0
    fi
  fi

  if [[ -x "./scripts/setup-git-hooks.sh" ]]; then
    print_step "Running setup-git-hooks.sh..."
    ./scripts/setup-git-hooks.sh
  elif [[ -d ".githooks" ]]; then
    print_step "Configuring git to use .githooks/..."
    git config core.hooksPath .githooks
    chmod +x .githooks/* 2>/dev/null || true
    print_success "Git hooks configured"
  else
    print_warning "No .githooks directory found, skipping"
  fi
}

# ============================================
# Step 3: Environment File
# ============================================
setup_env() {
  print_header "Step 3: Environment Configuration"

  if [[ -f ".env" ]]; then
    print_success ".env file already exists"

    if [[ "$MODE" == "wizard" ]]; then
      if ask_yes_no "Review/edit .env file now?" "n"; then
        ${EDITOR:-nano} .env
      fi
    fi
    return 0
  fi

  if [[ ! -f ".env.example" ]]; then
    print_warning "No .env.example found, skipping"
    return 0
  fi

  if [[ "$MODE" == "wizard" ]]; then
    if ! ask_yes_no "Create .env from .env.example?"; then
      print_warning "Skipping .env creation"
      return 0
    fi
  fi

  print_step "Creating .env from .env.example..."
  cp .env.example .env
  print_success ".env file created"

  if [[ "$MODE" == "wizard" ]]; then
    print_warning "Remember to edit .env and add your configuration values!"
    if ask_yes_no "Edit .env file now?" "n"; then
      ${EDITOR:-nano} .env
    fi
  fi
}

# ============================================
# Step 4: Sync Agents
# ============================================
run_sync() {
  print_header "Step 4: Sync Agent Configuration"

  if [[ "$MODE" == "wizard" ]]; then
    if ! ask_yes_no "Run initial sync (agents, cursor rules, codex skills)?"; then
      print_warning "Skipping sync"
      return 0
    fi
  fi

  if [[ -f "Makefile" ]] && grep -q "^sync:" Makefile; then
    print_step "Running make sync..."
    make sync 2>/dev/null || print_warning "make sync had warnings (may be OK)"

    if grep -q "^sync-codex-skills:" Makefile; then
      print_step "Running make sync-codex-skills..."
      make sync-codex-skills 2>/dev/null || print_warning "make sync-codex-skills had warnings (may be OK)"
    fi

    print_success "Sync completed"
  else
    print_warning "No Makefile with sync target found, skipping"
  fi
}

# ============================================
# Step 5: Initial Commit (wizard only)
# ============================================
initial_commit() {
  if [[ "$MODE" != "wizard" ]]; then
    return 0
  fi

  print_header "Step 5: Initial Commit"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_warning "Not a git repository, skipping"
    return 0
  fi

  # Check if there are already commits
  if git rev-parse HEAD >/dev/null 2>&1; then
    print_info "Repository already has commits"
    return 0
  fi

  if ! ask_yes_no "Create initial commit?"; then
    print_warning "Skipping initial commit"
    return 0
  fi

  local project_name
  project_name=$(basename "$PROJECT_ROOT")

  print_step "Staging files..."
  git add .

  print_step "Creating initial commit..."
  git commit -m "feat: initial project setup for ${project_name}

- Project template deployed
- Git hooks configured
- Agent configuration synced

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

  print_success "Initial commit created"
}

# ============================================
# Step 6: Remote Repository (wizard only)
# ============================================
setup_remote() {
  if [[ "$MODE" != "wizard" ]]; then
    return 0
  fi

  print_header "Step 6: Remote Repository"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print_warning "Not a git repository, skipping"
    return 0
  fi

  # Check if remote already exists
  if git remote get-url origin >/dev/null 2>&1; then
    local remote_url
    remote_url=$(git remote get-url origin)
    print_success "Remote 'origin' already configured: $remote_url"
    return 0
  fi

  if ! ask_yes_no "Add a remote repository (GitHub/GitLab)?"; then
    print_info "You can add a remote later with: git remote add origin <url>"
    return 0
  fi

  # Check if gh CLI is available and offer to create GitHub repo
  if command -v gh >/dev/null 2>&1; then
    if ask_yes_no "Create a new GitHub repository using gh CLI?"; then
      create_github_repo
      return 0
    fi
  fi

  # Fallback to manual remote URL entry
  local remote_url=""
  ask_input "Remote URL (e.g., git@github.com:user/repo.git)" "" remote_url

  if [[ -n "$remote_url" ]]; then
    git remote add origin "$remote_url"
    print_success "Remote 'origin' added: $remote_url"

    if ask_yes_no "Push to remote now?" "n"; then
      local branch
      branch=$(git branch --show-current)
      git push -u origin "$branch"
      print_success "Pushed to origin/$branch"
    fi
  fi
}

# ============================================
# Create GitHub Repository via gh CLI
# ============================================
create_github_repo() {
  local project_name
  project_name=$(basename "$PROJECT_ROOT")

  local repo_name=""
  ask_input "Repository name" "$project_name" repo_name

  # Check if repository already exists on GitHub
  local gh_user
  gh_user=$(gh api user --jq '.login' 2>/dev/null || echo "")

  if [[ -n "$gh_user" ]]; then
    local full_repo_name="$repo_name"
    # If repo_name doesn't contain '/', assume it's under current user
    if [[ "$repo_name" != *"/"* ]]; then
      full_repo_name="$gh_user/$repo_name"
    fi

    if gh repo view "$full_repo_name" >/dev/null 2>&1; then
      print_warning "Repository '$full_repo_name' already exists on GitHub!"
      if ask_yes_no "Connect local project to existing repository?"; then
        connect_existing_github_repo "$full_repo_name"
        return 0
      else
        print_info "Skipping remote setup"
        return 0
      fi
    fi
  fi

  local visibility="private"
  echo ""
  echo "Repository visibility:"
  echo "  1) Private (default)"
  echo "  2) Public"
  read -p "Choose [1/2]: " -n 1 -r visibility_choice
  echo ""

  if [[ "$visibility_choice" == "2" ]]; then
    visibility="public"
  fi

  print_step "Creating GitHub repository: $repo_name ($visibility)..."

  # Ensure we're on 'main' branch before creating repo
  ensure_main_branch

  # Create the repository
  local gh_args=("repo" "create" "$repo_name" "--$visibility" "--source=." "--remote=origin")

  if ask_yes_no "Push to GitHub after creating?" "y"; then
    gh_args+=("--push")
  fi

  if gh "${gh_args[@]}"; then
    print_success "GitHub repository created successfully!"
    local repo_url
    repo_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$repo_url" ]]; then
      print_info "Repository URL: $repo_url"
    fi
  else
    print_error "Failed to create GitHub repository"
    print_info "You can try manually: gh repo create $repo_name --$visibility --source=. --remote=origin"
  fi
}

# ============================================
# Connect to Existing GitHub Repository
# ============================================
connect_existing_github_repo() {
  local full_repo_name="$1"

  print_step "Connecting to existing repository: $full_repo_name"

  # Get the clone URL
  local repo_url
  repo_url=$(gh repo view "$full_repo_name" --json sshUrl --jq '.sshUrl' 2>/dev/null)

  if [[ -z "$repo_url" ]]; then
    # Fallback to HTTPS URL
    repo_url=$(gh repo view "$full_repo_name" --json url --jq '.url' 2>/dev/null)
  fi

  if [[ -z "$repo_url" ]]; then
    print_error "Could not get repository URL"
    return 1
  fi

  # Add remote
  git remote add origin "$repo_url"
  print_success "Remote 'origin' added: $repo_url"

  # Ensure we're on 'main' branch
  ensure_main_branch

  # Check if remote has commits
  local remote_has_commits=false
  if git ls-remote --heads origin main >/dev/null 2>&1; then
    if [[ -n "$(git ls-remote --heads origin main)" ]]; then
      remote_has_commits=true
    fi
  fi

  local local_has_commits=false
  if git rev-parse HEAD >/dev/null 2>&1; then
    local_has_commits=true
  fi

  if [[ "$remote_has_commits" == "true" && "$local_has_commits" == "true" ]]; then
    print_warning "Both local and remote have commits."
    echo ""
    echo "Options:"
    echo "  1) Pull remote changes first, then push (recommended if remote has important content)"
    echo "  2) Force push local (overwrites remote - use if remote is empty/template)"
    echo "  3) Skip - handle manually later"
    read -p "Choose [1/2/3]: " -n 1 -r sync_choice
    echo ""

    case "$sync_choice" in
      1)
        print_step "Pulling remote changes..."
        if git pull origin main --rebase --allow-unrelated-histories; then
          print_success "Pulled remote changes"
          if ask_yes_no "Push local commits now?" "y"; then
            git push -u origin main
            print_success "Pushed to origin/main"
          fi
        else
          print_error "Pull failed - resolve conflicts manually"
        fi
        ;;
      2)
        if ask_yes_no "Are you sure you want to force push? This will OVERWRITE remote!" "n"; then
          git push -u origin main --force
          print_success "Force pushed to origin/main"
        else
          print_info "Skipped push"
        fi
        ;;
      *)
        print_info "Skipped - handle sync manually"
        ;;
    esac
  elif [[ "$local_has_commits" == "true" ]]; then
    if ask_yes_no "Push local commits to remote?" "y"; then
      git push -u origin main
      print_success "Pushed to origin/main"
    fi
  elif [[ "$remote_has_commits" == "true" ]]; then
    if ask_yes_no "Pull remote commits to local?" "y"; then
      git pull origin main
      print_success "Pulled from origin/main"
    fi
  else
    print_info "Both local and remote are empty - ready for first commit"
  fi
}

# ============================================
# Ensure main branch
# ============================================
ensure_main_branch() {
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null || echo "")

  if [[ -z "$current_branch" ]]; then
    # No commits yet, create main branch
    git checkout -b main 2>/dev/null || true
  elif [[ "$current_branch" != "main" ]]; then
    if ask_yes_no "Current branch is '$current_branch'. Switch to 'main' for GitHub default?" "y"; then
      git branch -m "$current_branch" main 2>/dev/null || git checkout -b main 2>/dev/null || true
      print_success "Switched to 'main' branch"
    fi
  fi
}

# ============================================
# Summary
# ============================================
print_summary() {
  print_header "Setup Complete!"

  echo ""
  echo -e "${GREEN}✓ Project initialization completed!${NC}"
  echo ""

  echo -e "${BLUE}What was configured:${NC}"

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "  ✓ Git repository initialized"
    if [[ -n "$(git config --get core.hooksPath)" ]]; then
      echo "  ✓ Git hooks configured"
    fi
  fi

  [[ -f ".env" ]] && echo "  ✓ Environment file created"
  [[ -d ".claude/agents" ]] && echo "  ✓ Claude agents synced"
  [[ -d ".cursor/rules" ]] && echo "  ✓ Cursor rules generated"
  [[ -d ".codex/skills" ]] && echo "  ✓ Codex skills synced"

  echo ""
  echo -e "${BLUE}Next steps:${NC}"
  echo "  1. Edit .env with your configuration values"
  echo "  2. Review CLAUDE.md and AGENTS.md for AI guidelines"
  echo "  3. Open in DevContainer: Cmd+Shift+P → 'Reopen in Container'"
  echo "  4. Start coding!"
  echo ""

  echo -e "${BLUE}Useful commands:${NC}"
  echo "  make help              # Show all available commands"
  echo "  make sync              # Sync agent configuration"
  echo "  make sync-codex-skills # Sync Codex skills"
  echo ""
}

# ============================================
# Main
# ============================================
main() {
  if [[ "$MODE" == "wizard" ]]; then
    print_header "Project Initialization Wizard"
    echo ""
    echo "This wizard will help you set up your new project."
    echo "Press Enter to accept defaults, or type your choice."
    echo ""
  else
    print_header "Project Initialization (CLI Mode)"
    echo ""
    echo "Running non-interactive setup with defaults..."
    echo ""
  fi

  init_git
  setup_hooks
  setup_env
  run_sync
  initial_commit
  setup_remote
  print_summary
}

main
