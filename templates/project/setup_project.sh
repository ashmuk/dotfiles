#!/bin/bash
# Setup script for Project Template
# Deploys the template to a target project directory with a specified project name
# Converts 'dot.*' files/directories to '.*' (hidden) in target

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-}"
PROJECT_NAME="${2:-}"

# Colors (use $'\033' for proper escape sequence interpretation)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Convert dot.* filename to .* (hidden)
convert_dotname() {
  local src="$1"
  local basename
  basename=$(basename "$src")

  if [[ "$basename" == dot.* ]]; then
    # Remove 'dot.' prefix and add '.' prefix
    echo ".${basename#dot.}"
  else
    echo "$basename"
  fi
}

# Sanitize project name for Docker (lowercase, replace special chars with dash)
sanitize_docker_name() {
  local name="$1"
  # Convert to lowercase and replace underscores/dots with dashes
  echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[_.]/-/g'
}

# Replace project name placeholder in file
replace_project_name() {
  local file="$1"
  local project_name="$2"
  
  if [ -f "$file" ]; then
    # Replace <your-project-name> with actual project name
    if command -v sed >/dev/null 2>&1; then
      if [[ "$OSTYPE" == darwin* ]]; then
        # macOS sed requires -i '' for in-place editing
        sed -i '' "s|<your-project-name>|${project_name}|g" "$file"
      else
        # Linux sed
        sed -i "s|<your-project-name>|${project_name}|g" "$file"
      fi
    fi
  fi
}

# Replace devcontainer names with project-specific names
replace_devcontainer_names() {
  local devcontainer_dir="$1"
  local project_name="$2"
  local docker_name
  
  # Sanitize project name for Docker (lowercase, dashes)
  docker_name=$(sanitize_docker_name "$project_name")
  
  if [ ! -d "$devcontainer_dir" ]; then
    return
  fi
  
  # Replace in devcontainer.json
  if [ -f "$devcontainer_dir/devcontainer.json" ]; then
    if command -v sed >/dev/null 2>&1; then
      if [[ "$OSTYPE" == darwin* ]]; then
        # Replace container name
        sed -i '' "s|\"name\": \".*\"|\"name\": \"${project_name} Dev\"|g" "$devcontainer_dir/devcontainer.json"
        # Replace service name (photo_dev -> ${docker_name}_dev)
        sed -i '' "s|\"service\": \".*\"|\"service\": \"${docker_name}_dev\"|g" "$devcontainer_dir/devcontainer.json"
        # Replace volume names (photo-dev -> ${docker_name}-dev)
        sed -i '' "s|photo-dev-|${docker_name}-dev-|g" "$devcontainer_dir/devcontainer.json"
      else
        # Linux sed
        sed -i "s|\"name\": \".*\"|\"name\": \"${project_name} Dev\"|g" "$devcontainer_dir/devcontainer.json"
        sed -i "s|\"service\": \".*\"|\"service\": \"${docker_name}_dev\"|g" "$devcontainer_dir/devcontainer.json"
        sed -i "s|photo-dev-|${docker_name}-dev-|g" "$devcontainer_dir/devcontainer.json"
      fi
    fi
  fi
  
  # Replace in compose.yml
  if [ -f "$devcontainer_dir/compose.yml" ]; then
    if command -v sed >/dev/null 2>&1; then
      if [[ "$OSTYPE" == darwin* ]]; then
        # Replace service names (photo_dev -> ${docker_name}_dev)
        sed -i '' "s|^  photo_dev:|  ${docker_name}_dev:|g" "$devcontainer_dir/compose.yml"
        sed -i '' "s|^  photo_dev_nonet:|  ${docker_name}_dev_nonet:|g" "$devcontainer_dir/compose.yml"
        # Replace extends reference
        sed -i '' "s|extends: photo_dev|extends: ${docker_name}_dev|g" "$devcontainer_dir/compose.yml"
        # Replace image name (hisamukai-photo-dev -> ${docker_name}-dev)
        sed -i '' "s|image: hisamukai-photo-dev|image: ${docker_name}-dev|g" "$devcontainer_dir/compose.yml"
      else
        # Linux sed
        sed -i "s|^  photo_dev:|  ${docker_name}_dev:|g" "$devcontainer_dir/compose.yml"
        sed -i "s|^  photo_dev_nonet:|  ${docker_name}_dev_nonet:|g" "$devcontainer_dir/compose.yml"
        sed -i "s|extends: photo_dev|extends: ${docker_name}_dev|g" "$devcontainer_dir/compose.yml"
        sed -i "s|image: hisamukai-photo-dev|image: ${docker_name}-dev|g" "$devcontainer_dir/compose.yml"
      fi
    fi
  fi
}

# Usage info
usage() {
  cat <<EOF
${BLUE}Project Template Setup Script${NC}

Usage: $0 <target-directory> <project-name>

This script deploys the project template to a target directory with a specified
project name. The project will be created at <target-directory>/<project-name>.
Files/directories prefixed with 'dot.' in the template are deployed as hidden
files/directories (with '.' prefix) in the target.

Arguments:
  target-directory  Path to the parent directory (will be created if doesn't exist)
  project-name      Name of the project (used to replace <your-project-name> placeholders)
                    Project will be created at <target-directory>/<project-name>

Example:
  $0 /path/to/my-workspace my-awesome-project
  # Creates project at: /path/to/my-workspace/my-awesome-project/

What this script does:
  1. Creates target directory if it doesn't exist
  2. Copies all configuration files to target directory
  3. Converts 'dot.*' to '.*' (hidden files/directories)
  4. Replaces <your-project-name> placeholders with actual project name
  5. Creates .env from dot.env.example
  6. Backs up existing files with .backup extension
  7. Sets appropriate file permissions
  8. Provides next steps for setup

Template structure:
  dot.devcontainer/    → .devcontainer/
  dot.github/          → .github/
  dot.claude/          → .claude/
  dot.agents/          → .agents/
  dot.githooks/        → .githooks/
  dot.gitignore        → .gitignore
  dot.env.example      → .env
  ... etc ...

EOF
  exit 1
}

# Check arguments
if [ -z "$TARGET_DIR" ] || [ -z "$PROJECT_NAME" ]; then
  usage
fi

# Validate project name (basic check - alphanumeric, dash, underscore)
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  print_error "Invalid project name: $PROJECT_NAME"
  print_error "Project name must contain only alphanumeric characters, dashes, and underscores"
  exit 1
fi

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

# Append project name to target directory
PROJECT_DIR="$TARGET_DIR/$PROJECT_NAME"

print_header "Project Template Setup"
print_info "Template source: $SCRIPT_DIR"
print_info "Target directory: $TARGET_DIR"
print_info "Project name: $PROJECT_NAME"
print_info "Project directory: $PROJECT_DIR"
echo ""

# Confirm
read -p "Deploy project template '$PROJECT_NAME' to $PROJECT_DIR? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_warning "Cancelled by user"
  exit 0
fi

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
  print_info "Creating target directory..."
  mkdir -p "$TARGET_DIR"
  print_success "Target directory created"
fi

# Create project directory if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
  print_info "Creating project directory..."
  mkdir -p "$PROJECT_DIR"
  print_success "Project directory created"
else
  print_warning "Project directory already exists: $PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Backup existing files
backup_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    mv "$file" "${file}.backup"
    print_warning "Backed up existing $file to ${file}.backup"
  elif [ -d "$file" ]; then
    mv "$file" "${file}.backup"
    print_warning "Backed up existing $file/ to ${file}.backup/"
  fi
}

print_header "Copying Configuration Files"

# DevContainer files
print_info "Copying dot.devcontainer/ → .devcontainer/..."
backup_if_exists ".devcontainer"
mkdir -p .devcontainer
cp -r "$SCRIPT_DIR/dot.devcontainer/"* .devcontainer/
chmod +x .devcontainer/*.sh 2>/dev/null || true
# Replace devcontainer names with project-specific names
replace_devcontainer_names ".devcontainer" "$PROJECT_NAME"
print_success ".devcontainer/ copied (names customized for $PROJECT_NAME)"

# GitHub workflows and templates
print_info "Copying dot.github/ → .github/..."
backup_if_exists ".github"
mkdir -p .github/workflows
if [ -d "$SCRIPT_DIR/dot.github/workflows" ]; then
  cp -r "$SCRIPT_DIR/dot.github/workflows/"* .github/workflows/
fi
if [ -f "$SCRIPT_DIR/dot.github/PULL_REQUEST_TEMPLATE.md" ]; then
  cp "$SCRIPT_DIR/dot.github/PULL_REQUEST_TEMPLATE.md" .github/
fi
print_success ".github/ copied"

# Git hooks
print_info "Copying dot.githooks/ → .githooks/..."
backup_if_exists ".githooks"
mkdir -p .githooks
cp -r "$SCRIPT_DIR/dot.githooks/"* .githooks/
chmod +x .githooks/* 2>/dev/null || true
print_success ".githooks/ copied"

# Claude configuration
print_info "Copying dot.claude/ → .claude/..."
backup_if_exists ".claude"
mkdir -p .claude
cp -r "$SCRIPT_DIR/dot.claude/"* .claude/ 2>/dev/null || true
print_success ".claude/ copied"

# Agents configuration
print_info "Copying dot.agents/ → .agents/..."
backup_if_exists ".agents"
mkdir -p .agents
cp -r "$SCRIPT_DIR/dot.agents/"* .agents/ 2>/dev/null || true
print_success ".agents/ copied"

# Root config files (convert dot.* to .*)
print_info "Copying configuration files..."
for src_file in "$SCRIPT_DIR"/dot.*; do
  # Skip if it's a directory (already handled above)
  if [ -d "$src_file" ]; then
    continue
  fi

  if [ -f "$src_file" ]; then
    target_name=$(convert_dotname "$src_file")

    # Skip .env.example special handling for now
    if [ "$target_name" = ".env.example" ]; then
      continue
    fi

    backup_if_exists "$target_name"
    cp "$src_file" "$target_name"
    print_success "$target_name copied"
  fi
done

# Copy regular files (Makefile, README.md, etc.)
print_info "Copying project files..."

# Copy Makefile
if [ -f "$SCRIPT_DIR/Makefile" ]; then
  backup_if_exists "Makefile"
  cp "$SCRIPT_DIR/Makefile" Makefile
  print_success "Makefile copied"
fi

# Copy README.md and replace project name
if [ -f "$SCRIPT_DIR/README.md" ]; then
  backup_if_exists "README.md"
  cp "$SCRIPT_DIR/README.md" README.md
  replace_project_name "README.md" "$PROJECT_NAME"
  print_success "README.md copied (project name replaced)"
fi

# Copy PLANS.md
if [ -f "$SCRIPT_DIR/PLANS.md" ]; then
  backup_if_exists "PLANS.md"
  cp "$SCRIPT_DIR/PLANS.md" PLANS.md
  replace_project_name "PLANS.md" "$PROJECT_NAME"
  print_success "PLANS.md copied (project name replaced)"
fi

# Copy RULES.md
if [ -f "$SCRIPT_DIR/RULES.md" ]; then
  backup_if_exists "RULES.md"
  cp "$SCRIPT_DIR/RULES.md" RULES.md
  print_success "RULES.md copied"
fi

# Copy AGENTS_project.md as AGENTS.md
if [ -f "$SCRIPT_DIR/AGENTS_project.md" ]; then
  backup_if_exists "AGENTS.md"
  cp "$SCRIPT_DIR/AGENTS_project.md" AGENTS.md
  replace_project_name "AGENTS.md" "$PROJECT_NAME"
  print_success "AGENTS.md copied (project name replaced)"
fi

# Copy CLAUDE_project.md as CLAUDE.md
if [ -f "$SCRIPT_DIR/CLAUDE_project.md" ]; then
  backup_if_exists "CLAUDE.md"
  cp "$SCRIPT_DIR/CLAUDE_project.md" CLAUDE.md
  replace_project_name "CLAUDE.md" "$PROJECT_NAME"
  print_success "CLAUDE.md copied (project name replaced)"
fi

# Create .env from dot.env.example
if [ ! -f ".env" ]; then
  if [ -f "$SCRIPT_DIR/dot.env.example" ]; then
    cp "$SCRIPT_DIR/dot.env.example" .env
    print_success ".env created from dot.env.example"
    print_warning "⚠ IMPORTANT: Edit .env and add your configuration values!"
  fi
else
  print_info ".env already exists, skipping"
fi

# Copy scripts directory
print_info "Copying scripts directory..."
if [ -d "$SCRIPT_DIR/scripts" ]; then
  backup_if_exists "scripts"
  mkdir -p scripts
  cp -r "$SCRIPT_DIR/scripts/"* scripts/
  # Set executable permissions only on shell scripts
  chmod +x scripts/*.sh 2>/dev/null || true
  print_success "scripts/ directory copied (shell scripts made executable)"
else
  print_info "scripts/ directory not found, skipping"
fi

# Copy global templates (for use in devcontainer user home directory)
print_header "Copying Global Templates"
GLOBAL_TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/global"
if [ -d "$GLOBAL_TEMPLATES_DIR" ]; then
  print_info "Copying global templates from $GLOBAL_TEMPLATES_DIR..."
  
  # Copy AGENTS_global.md
  if [ -f "$GLOBAL_TEMPLATES_DIR/AGENTS_global.md" ]; then
    backup_if_exists "AGENTS_global.md"
    cp "$GLOBAL_TEMPLATES_DIR/AGENTS_global.md" AGENTS_global.md
    print_success "AGENTS_global.md copied"
  fi
  
  # Copy CLAUDE_global.md
  if [ -f "$GLOBAL_TEMPLATES_DIR/CLAUDE_global.md" ]; then
    backup_if_exists "CLAUDE_global.md"
    cp "$GLOBAL_TEMPLATES_DIR/CLAUDE_global.md" CLAUDE_global.md
    print_success "CLAUDE_global.md copied"
  fi
  
  print_success "Global templates copied (available for devcontainer user home)"
else
  print_warning "Global templates directory not found at $GLOBAL_TEMPLATES_DIR"
  print_info "Skipping global templates (optional)"
fi

print_header "Setup Complete!"

cat <<EOF

${GREEN}✓ Project template deployed successfully!${NC}

${BLUE}Project Name:${NC} ${PROJECT_NAME}

${BLUE}Files deployed:${NC}
  dot.devcontainer/      → .devcontainer/
  dot.github/            → .github/
    └── workflows/       → .github/workflows/
    └── PULL_REQUEST_TEMPLATE.md → .github/
  dot.githooks/          → .githooks/
  dot.claude/            → .claude/
  dot.agents/            → .agents/
  dot.gitignore          → .gitignore
  dot.env.example        → .env
  Makefile               → Makefile
  README.md              → README.md (project name: ${PROJECT_NAME})
  PLANS.md               → PLANS.md (project name: ${PROJECT_NAME})
  RULES.md               → RULES.md
  AGENTS_project.md      → AGENTS.md (project name: ${PROJECT_NAME})
  CLAUDE_project.md      → CLAUDE.md (project name: ${PROJECT_NAME})
  scripts/               → scripts/
  templates/global/      → AGENTS_global.md, CLAUDE_global.md (for devcontainer)

${BLUE}Next Steps:${NC}

1. ${YELLOW}Configure Environment:${NC}
   ${BLUE}vim .env${NC}
   Add your configuration values (API keys, database URLs, etc.)

2. ${YELLOW}Initialize Git Repository:${NC}
   ${BLUE}git init${NC}
   ${BLUE}git add .${NC}
   ${BLUE}git commit -m "feat: initial project setup for ${PROJECT_NAME}"${NC}

3. ${YELLOW}Setup Git Hooks:${NC}
   ${BLUE}chmod +x .githooks/*${NC}
   ${BLUE}git config core.hooksPath .githooks${NC}
   Or use: ${BLUE}./scripts/setup-git-hooks.sh${NC} (if available)

4. ${YELLOW}Open in DevContainer:${NC}
   ${BLUE}code .${NC}  # or cursor .
   Then: Cmd+Shift+P → "Dev Containers: Reopen in Container"

5. ${YELLOW}Review Project Configuration:${NC}
   ${BLUE}cat README.md${NC}  # Project overview
   ${BLUE}cat PLANS.md${NC}   # Project roadmap
   ${BLUE}cat RULES.md${NC}   # Project rules
   ${BLUE}cat CLAUDE.md${NC}  # AI assistant guidelines (project-specific)
   ${BLUE}cat AGENTS.md${NC}  # Agent collaboration patterns (project-specific)
   ${BLUE}cat CLAUDE_global.md${NC}  # Global AI assistant guidelines
   ${BLUE}cat AGENTS_global.md${NC}  # Global agent patterns

6. ${YELLOW}Customize for Your Project:${NC}
   - Update README.md with project-specific information
   - Modify PLANS.md with your roadmap
   - Adjust RULES.md with your project rules
   - Configure .devcontainer/ for your tech stack
   - Update GitHub workflows in .github/workflows/

${BLUE}Documentation:${NC}
  - Project README: README.md
  - Project Plans: PLANS.md
  - Project Rules: RULES.md
  - AI Guidelines: CLAUDE.md
  - Agent Patterns: AGENTS.md
  - DevContainer: .devcontainer/devcontainer.json
  - Makefile: See 'make' for all commands

${YELLOW}Important:${NC}
  - Never commit .env file (already in .gitignore)
  - Review backed up files (*.backup) before deleting
  - Customize project files for your specific needs
  - Update project name references if needed

${GREEN}Happy coding! 🚀${NC}

EOF

