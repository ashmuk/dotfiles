# Makefile for dotfiles project
# This Makefile provides easy installation and management of dotfiles

# Variables
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
BACKUP_DIR := $(HOME_DIR)/.dotfiles_backup

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Dotfiles Management"
	@echo "=================="
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: validate install-shell install-vim install-git ## Install all dotfiles

.PHONY: install-shell
install-shell: validate ## Install shell configuration
	@echo "$(BLUE)[INFO]$(NC) Installing shell configuration..."
	@chmod +x $(DOTFILES_DIR)/shell/setup_shell.sh
	@$(DOTFILES_DIR)/shell/setup_shell.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Shell configuration installed"

.PHONY: install-vim
install-vim: validate ## Install vim configuration
	@echo "$(BLUE)[INFO]$(NC) Installing vim configuration..."
	@chmod +x $(DOTFILES_DIR)/vim/setup_vimrc.sh
	@$(DOTFILES_DIR)/vim/setup_vimrc.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Vim configuration installed"

.PHONY: install-git
install-git: validate ## Install git configuration
	@echo "$(BLUE)[INFO]$(NC) Installing git configuration..."
	@chmod +x $(DOTFILES_DIR)/git/setup_git.sh
	@$(DOTFILES_DIR)/git/setup_git.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Git configuration installed"

.PHONY: install-windows
install-windows: validate ## Install Windows PowerShell configuration
	@echo "$(BLUE)[INFO]$(NC) Installing Windows configuration..."
	@if command -v powershell.exe >/dev/null 2>&1; then \
		powershell.exe -ExecutionPolicy Bypass -File "$(DOTFILES_DIR)/windows/setup_windows.ps1"; \
	elif command -v pwsh.exe >/dev/null 2>&1; then \
		pwsh.exe -ExecutionPolicy Bypass -File "$(DOTFILES_DIR)/windows/setup_windows.ps1"; \
	else \
		echo "$(RED)[ERROR]$(NC) PowerShell not found. Please install PowerShell or PowerShell Core."; \
		exit 1; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Windows configuration installed"

.PHONY: validate
validate: ## Validate dotfiles directory and dependencies
	@echo "$(BLUE)[INFO]$(NC) Validating dotfiles environment..."
	@if [ ! -f "$(DOTFILES_DIR)/lib/common.sh" ]; then \
		echo "$(RED)[ERROR]$(NC) Common functions library missing. Run 'make bootstrap' first."; \
		exit 1; \
	fi
	@if [ ! -d "$(DOTFILES_DIR)/shell" ]; then \
		echo "$(RED)[ERROR]$(NC) Shell configuration directory missing."; \
		exit 1; \
	fi
	@if [ ! -d "$(DOTFILES_DIR)/vim" ]; then \
		echo "$(RED)[ERROR]$(NC) Vim configuration directory missing."; \
		exit 1; \
	fi
	@if [ ! -d "$(DOTFILES_DIR)/git" ]; then \
		echo "$(RED)[ERROR]$(NC) Git configuration directory missing."; \
		exit 1; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Validation completed"

.PHONY: bootstrap
bootstrap: ## Bootstrap the dotfiles environment (create lib directory if needed)
	@echo "$(BLUE)[INFO]$(NC) Bootstrapping dotfiles environment..."
	@mkdir -p $(DOTFILES_DIR)/lib
	@if [ ! -f "$(DOTFILES_DIR)/lib/common.sh" ]; then \
		echo "$(YELLOW)[WARNING]$(NC) Common functions library missing. Please ensure lib/common.sh exists."; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Bootstrap completed"

.PHONY: backup
backup: ## Create backup of existing dotfiles
	@echo "$(BLUE)[INFO]$(NC) Creating backup directory..."
	@mkdir -p $(BACKUP_DIR)
	@echo "$(BLUE)[INFO]$(NC) Backing up existing dotfiles..."
	@for file in .bashrc .zshrc .vimrc _vimrc _gvimrc .gitconfig .gitignore .gitattributes; do \
		if [ -f $(HOME_DIR)/$$file ]; then \
			echo "$(YELLOW)[WARNING]$(NC) Backing up $$file"; \
			cp $(HOME_DIR)/$$file $(BACKUP_DIR)/$$file.backup.$$(date +%Y%m%d_%H%M%S); \
		fi; \
	done
	@echo "$(GREEN)[SUCCESS]$(NC) Backup completed"

.PHONY: clean
clean: ## Remove installed dotfiles (with confirmation)
	@echo "$(YELLOW)[WARNING]$(NC) This will remove all installed dotfiles!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "$(BLUE)[INFO]$(NC) Removing shell configuration..."
	@rm -f $(HOME_DIR)/.bashrc $(HOME_DIR)/.zshrc
	@rm -f $(HOME_DIR)/.bash_logout $(HOME_DIR)/.bash_profile $(HOME_DIR)/.zprofile
	@rm -f $(HOME_DIR)/shell.common $(HOME_DIR)/shell.bash $(HOME_DIR)/shell.zsh
	@rm -f $(HOME_DIR)/aliases.common $(HOME_DIR)/aliases.shell
	@echo "$(BLUE)[INFO]$(NC) Removing vim configuration..."
	@rm -f $(HOME_DIR)/.vimrc $(HOME_DIR)/_vimrc $(HOME_DIR)/_gvimrc $(HOME_DIR)/.ideavimrc
	@if [ -L "$(HOME_DIR)/.vim" ]; then rm "$(HOME_DIR)/.vim"; fi
	@if [ -L "$(HOME_DIR)/vimfiles" ]; then rm "$(HOME_DIR)/vimfiles"; fi
	@echo "$(BLUE)[INFO]$(NC) Removing git configuration..."
	@rm -f $(HOME_DIR)/.gitconfig $(HOME_DIR)/.gitignore $(HOME_DIR)/.gitattributes
	@echo "$(GREEN)[SUCCESS]$(NC) Cleanup completed"

.PHONY: status
status: validate ## Show status of installed dotfiles
	@echo "$(BLUE)[INFO]$(NC) Checking dotfiles status..."
	@echo ""
	@echo "Shell Configuration:"
	@echo "  Dotfiles directory:"
	@for file in shell.common; do \
		if [ -L $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done
	@for file in shell.bash.* shell.zsh.* aliases.shell.*; do \
		if [ -L $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		fi; \
	done
	@for file in aliases.common; do \
		if [ -L $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done
	@echo "  Home directory:"
	@for file in shell.common shell.bash shell.zsh aliases.common aliases.shell; do \
		if [ -L $(HOME_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(HOME_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done
	@echo ""
	@echo "Vim Configuration:"
	@echo "  Dotfiles directory:"
	@for file in vimrc.common mappings.common; do \
		if [ -L $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done
	@for file in vimrc.gui.* vimrc.terminal.* vimrc.idea.*; do \
		if [ -L $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		fi; \
	done
	@echo "  Home directory:"
	@for file in .vimrc _vimrc _gvimrc .ideavimrc vimrc.common mappings.common; do \
		if [ -L $(HOME_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(HOME_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done
	@for file in vimrc.gui.* vimrc.terminal.* vimrc.idea.*; do \
		if [ -L $(HOME_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(HOME_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		fi; \
	done
	@echo ""
	@echo "Git Configuration:"
	@echo "  Dotfiles directory:"
	@for file in gitconfig.common gitignore.common gitattributes.common; do \
		if [ -L $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(DOTFILES_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done
	@echo "  Home directory:"
	@for file in .gitconfig .gitignore .gitattributes gitconfig.common gitignore.common gitattributes.common; do \
		if [ -L $(HOME_DIR)/$$file ]; then \
			echo "    $(GREEN)✓$(NC) $$file (symlink)"; \
		elif [ -f $(HOME_DIR)/$$file ]; then \
			echo "    $(YELLOW)⚠$(NC) $$file (file)"; \
		else \
			echo "    $(RED)✗$(NC) $$file (not found)"; \
		fi; \
	done

.PHONY: update
update: ## Update dotfiles from repository
	@echo "$(BLUE)[INFO]$(NC) Updating dotfiles from repository..."
	@git pull origin main
	@echo "$(GREEN)[SUCCESS]$(NC) Dotfiles updated"

.PHONY: validate
validate: ## Validate configuration files and dependencies
	@echo "$(BLUE)[INFO]$(NC) Validating dotfiles configuration..."
	@echo ""
	@echo "Checking shell configuration syntax..."
	@bash -n $(DOTFILES_DIR)/shell/shell.common || (echo "$(RED)[ERROR]$(NC) shell.common has syntax errors" && exit 1)
	@bash -n $(DOTFILES_DIR)/shell/shell.bash || (echo "$(RED)[ERROR]$(NC) shell.bash has syntax errors" && exit 1)
	@if command -v zsh >/dev/null 2>&1; then \
		zsh -n $(DOTFILES_DIR)/shell/shell.zsh || (echo "$(RED)[ERROR]$(NC) shell.zsh has syntax errors" && exit 1); \
		zsh -n $(DOTFILES_DIR)/shell/shell.ohmy.zsh || (echo "$(RED)[ERROR]$(NC) shell.ohmy.zsh has syntax errors" && exit 1); \
	else \
		echo "$(YELLOW)[WARNING]$(NC) zsh not installed, skipping zsh syntax check"; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Shell configuration syntax is valid"
	@echo ""
	@echo "Checking for required directories..."
	@for dir in shell vim git; do \
		if [ ! -d "$(DOTFILES_DIR)/$$dir" ]; then \
			echo "$(RED)[ERROR]$(NC) Required directory missing: $$dir"; \
			exit 1; \
		else \
			echo "$(GREEN)✓$(NC) $$dir directory exists"; \
		fi; \
	done
	@echo ""
	@echo "Checking setup scripts..."
	@for script in shell/setup_shell.sh vim/setup_vimrc.sh git/setup_git.sh; do \
		if [ ! -x "$(DOTFILES_DIR)/$$script" ]; then \
			echo "$(YELLOW)[WARNING]$(NC) $$script is not executable"; \
			chmod +x "$(DOTFILES_DIR)/$$script"; \
			echo "$(GREEN)✓$(NC) Made $$script executable"; \
		else \
			echo "$(GREEN)✓$(NC) $$script is executable"; \
		fi; \
		bash -n "$(DOTFILES_DIR)/$$script" || (echo "$(RED)[ERROR]$(NC) $$script has syntax errors" && exit 1); \
	done
	@echo ""
	@echo "Checking vim configuration..."
	@if command -v vim >/dev/null 2>&1; then \
		for vimrc in $(DOTFILES_DIR)/vim/vimrc.*; do \
			if [ -f "$$vimrc" ]; then \
				echo "$(GREEN)✓$(NC) Found vim config: $$(basename $$vimrc)"; \
			fi; \
		done; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) vim not installed, skipping vim config check"; \
	fi
	@echo ""
	@echo "Checking for common issues..."
	@if [ -f "$(HOME_DIR)/.bashrc" ] && [ ! -L "$(HOME_DIR)/.bashrc" ]; then \
		echo "$(YELLOW)[WARNING]$(NC) ~/.bashrc exists as regular file (will be backed up on install)"; \
	fi
	@if [ -f "$(HOME_DIR)/.zshrc" ] && [ ! -L "$(HOME_DIR)/.zshrc" ]; then \
		echo "$(YELLOW)[WARNING]$(NC) ~/.zshrc exists as regular file (will be backed up on install)"; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Validation completed successfully"

.PHONY: test
test: validate test-syntax test-shellcheck test-compat ## Run all tests (syntax, shellcheck, compatibility)

.PHONY: test-syntax
test-syntax: validate ## Test shell configuration syntax
	@echo "$(BLUE)[INFO]$(NC) Testing shell configuration syntax..."
	@if [ -f "$(DOTFILES_DIR)/lib/common.sh" ]; then \
		bash -n $(DOTFILES_DIR)/lib/common.sh || exit 1; \
	fi
	@bash -n $(DOTFILES_DIR)/shell/shell.common || exit 1
	@bash -n $(DOTFILES_DIR)/shell/shell.bash || exit 1
	@if command -v zsh >/dev/null 2>&1; then \
		zsh -n $(DOTFILES_DIR)/shell/shell.zsh || exit 1; \
		zsh -n $(DOTFILES_DIR)/shell/shell.ohmy.zsh || exit 1; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) zsh not found, skipping zsh syntax tests"; \
	fi
	@find $(DOTFILES_DIR) -name "*.sh" -type f -exec bash -n {} \; || exit 1
	@echo "$(GREEN)[SUCCESS]$(NC) Shell configuration syntax is valid"

.PHONY: test-shellcheck
test-shellcheck: validate ## Run shellcheck on all shell scripts
	@echo "$(BLUE)[INFO]$(NC) Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find $(DOTFILES_DIR) -name "*.sh" -type f -not -path "*/vim/vimfiles/plugged/*" -exec shellcheck {} \; || exit 1; \
		shellcheck $(DOTFILES_DIR)/shell/shell.common $(DOTFILES_DIR)/shell/shell.bash $(DOTFILES_DIR)/shell/shell.zsh $(DOTFILES_DIR)/shell/shell.ohmy.zsh || exit 1; \
		echo "$(GREEN)[SUCCESS]$(NC) All shell scripts passed shellcheck"; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) shellcheck not found, skipping shellcheck tests"; \
	fi

.PHONY: test-compat
test-compat: validate ## Test cross-platform compatibility
	@echo "$(BLUE)[INFO]$(NC) Testing platform compatibility..."
	@bash -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'Shell configuration loaded successfully'" || exit 1
	@bash -c "source $(DOTFILES_DIR)/shell/shell.common && alias | grep -E '^(g|du|\.\.\.)'" || exit 1
	@bash -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'grep_command: $$grep_command' && echo 'du_command: $$du_command'" || exit 1
	@if command -v zsh >/dev/null 2>&1; then \
		zsh -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'Shell configuration loaded successfully'" || exit 1; \
		zsh -c "source $(DOTFILES_DIR)/shell/shell.common && alias | grep -E '^(g|du|\.\.\.)'" || exit 1; \
		zsh -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'grep_command: $$grep_command' && echo 'du_command: $$du_command'" || exit 1; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) zsh not found, skipping zsh compatibility tests"; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Platform compatibility tests passed"

.PHONY: lint
lint: test-shellcheck ## Alias for test-shellcheck (deprecated, use test-shellcheck)

.PHONY: info
info: ## Show information about this dotfiles project
	@echo "Dotfiles Project Information"
	@echo "==========================="
	@echo "Directory: $(DOTFILES_DIR)"
	@echo "Home: $(HOME_DIR)"
	@echo "Backup: $(BACKUP_DIR)"
	@echo ""
	@echo "Available configurations:"
	@echo "  - Shell (bash/zsh) with aliases and functions"
	@echo "  - Vim with multiple configurations"
	@echo "  - Git with common settings"
	@echo "  - Windows PowerShell (with install-windows)"
	@echo ""
	@echo "Platform support:"
	@echo "  - macOS (darwin)"
	@echo "  - Linux"
	@echo "  - Windows (WSL/MSYS/Cygwin/Native PowerShell)"
	@echo ""
	@echo "Use 'make help' to see all available commands"