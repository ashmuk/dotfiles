# Makefile for dotfiles project
# This Makefile provides easy installation and management of dotfiles
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Variables
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
BACKUP_DIR := $(HOME_DIR)/.dotfiles_backup

# Colors for output (with Windows Git Bash compatibility)
# Check if colors are supported - use a more robust method
ifeq ($(shell test -t 1 && echo "yes" || echo "no"),yes)
    # Color support available (terminal supports colors)
    RED := \033[0;31m
    GREEN := \033[0;32m
    YELLOW := \033[1;33m
    BLUE := \033[0;34m
    NC := \033[0m
else
    # No color support
    RED :=
    GREEN :=
    YELLOW :=
    BLUE :=
    NC :=
endif

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Dotfiles Management"
	@echo "=================="
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Prerequisites:"
	@echo "  $(BLUE)check-prereqs$(NC)   Check for required tools before installation"
	@echo "  $(BLUE)make install$(NC)    Automatically checks prerequisites before installing"
	@echo ""
	@echo "WSL Integration:"
	@echo "  $(BLUE)setup-wsl-bridge$(NC)    WSL-first: Create Windows junction (WSL -> Windows)"
	@echo "  $(BLUE)setup-windows-bridge$(NC) Windows-first: Create WSL symlink (Windows -> WSL)"
	@echo "  $(BLUE)install-windows$(NC)      Install Windows config (auto-detects layout)"

.PHONY: check-prereqs
check-prereqs: ## Check for required tools and suggest installation commands
	@echo "$(BLUE)[INFO]$(NC) Checking prerequisites..."
	@$(MAKE) -s _check_essential_tools
	@$(MAKE) -s _check_core_tools
	@$(MAKE) -s _check_modern_tools
	@$(MAKE) -s _check_dev_tools
	@$(MAKE) -s _check_fonts
	@echo "$(GREEN)[SUCCESS]$(NC) All essential prerequisites are available"

.PHONY: _check_essential_tools
_check_essential_tools:
	@echo "$(BLUE)[INFO]$(NC) Checking essential tools..."
	@missing_tools=""; \
	for tool in make git bash grep sed awk; do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			missing_tools="$$missing_tools $$tool"; \
		fi; \
	done; \
	if [ -n "$$missing_tools" ]; then \
		echo "$(RED)[ERROR]$(NC) Missing essential tools:$$missing_tools"; \
		$(MAKE) -s _suggest_installation TOOLS="$$missing_tools"; \
		exit 1; \
	fi

.PHONY: _check_core_tools
_check_core_tools:
	@echo "$(BLUE)[INFO]$(NC) Checking core tools..."
	@missing_core=""; \
	for tool in vim zsh curl tar find tmux; do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			missing_core="$$missing_core $$tool"; \
		fi; \
	done; \
	if [ -n "$$missing_core" ]; then \
		echo "$(YELLOW)[WARNING]$(NC) Core tools not found:$$missing_core"; \
		echo "$(YELLOW)[WARNING]$(NC) Some features may not work optimally"; \
		$(MAKE) -s _suggest_installation TOOLS="$$missing_core"; \
	fi

.PHONY: _check_modern_tools
_check_modern_tools:
	@echo "$(BLUE)[INFO]$(NC) Checking modern enhancement tools..."
	@missing_modern=""; \
	for tool in rg fd bat fzf exa; do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			missing_modern="$$missing_modern $$tool"; \
		fi; \
	done; \
	if [ -n "$$missing_modern" ]; then \
		echo "$(CYAN)[INFO]$(NC) Modern tools not found:$$missing_modern"; \
		echo "$(CYAN)[INFO]$(NC) These provide enhanced alternatives to traditional tools"; \
		$(MAKE) -s _suggest_installation TOOLS="$$missing_modern"; \
	fi

.PHONY: _check_dev_tools
_check_dev_tools:
	@echo "$(BLUE)[INFO]$(NC) Checking development & quality tools..."
	@missing_dev=""; \
	for tool in shellcheck jq yq tree htop; do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			missing_dev="$$missing_dev $$tool"; \
		fi; \
	done; \
	if [ -n "$$missing_dev" ]; then \
		echo "$(CYAN)[INFO]$(NC) Development tools not found:$$missing_dev"; \
		echo "$(CYAN)[INFO]$(NC) These tools enhance development experience"; \
		$(MAKE) -s _suggest_installation TOOLS="$$missing_dev"; \
	fi

.PHONY: _check_fonts
_check_fonts:
	@echo "$(BLUE)[INFO]$(NC) Checking programming fonts for gvim..."
	@fonts_found=0; \
	if [[ "$(PLATFORM)" == "win" ]]; then \
		for font in "JetBrains Mono" "Fira Code" "Cascadia Code" "Consolas"; do \
			if powershell -Command "Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' | Get-Member -Name '*$$font*'" >/dev/null 2>&1; then \
				fonts_found=$$((fonts_found + 1)); \
			fi; \
		done; \
		if [ $$fonts_found -lt 2 ]; then \
			echo "$(YELLOW)[WARNING]$(NC) Few programming fonts found ($$fonts_found/4)"; \
			echo "$(YELLOW)[WARNING]$(NC) Run 'make install-fonts' to install recommended fonts"; \
		else \
			echo "$(GREEN)[SUCCESS]$(NC) Programming fonts available ($$fonts_found/4)"; \
		fi; \
	elif [[ "$(PLATFORM)" == "mac" ]]; then \
		for font in "JetBrainsMono Nerd Font" "FiraCode Nerd Font" "Menlo" "Monaco"; do \
			if command -v fc-list >/dev/null 2>&1 && fc-list | grep -i "$$font" >/dev/null 2>&1 || system_profiler SPFontsDataType | grep -i "$$font" >/dev/null 2>&1; then \
				fonts_found=$$((fonts_found + 1)); \
			fi; \
		done; \
		if [ $$fonts_found -lt 2 ]; then \
			echo "$(YELLOW)[WARNING]$(NC) Few programming fonts found ($$fonts_found/4)"; \
			echo "$(YELLOW)[WARNING]$(NC) Run 'make install-fonts' to install recommended fonts"; \
		else \
			echo "$(GREEN)[SUCCESS]$(NC) Programming fonts available ($$fonts_found/4)"; \
		fi; \
	else \
		for font in "JetBrainsMono" "FiraCode" "DejaVuSansMono" "UbuntuMono"; do \
			if command -v fc-list >/dev/null 2>&1 && fc-list | grep -i "$$font" >/dev/null 2>&1; then \
				fonts_found=$$((fonts_found + 1)); \
			fi; \
		done; \
		if [ $$fonts_found -lt 2 ]; then \
			echo "$(YELLOW)[WARNING]$(NC) Few programming fonts found ($$fonts_found/4)"; \
			echo "$(YELLOW)[WARNING]$(NC) Run 'make install-fonts' to install recommended fonts"; \
		else \
			echo "$(GREEN)[SUCCESS]$(NC) Programming fonts available ($$fonts_found/4)"; \
		fi; \
	fi

.PHONY: _suggest_installation
_suggest_installation:
	@tools="$(TOOLS)"; \
	echo "$(BLUE)[INFO]$(NC) Installation suggestions:"; \
	\
	if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$${WSL_DISTRO_NAME:-}" ]; then \
		echo "$(YELLOW)[WSL DETECTED]$(NC) Windows Subsystem for Linux"; \
		echo "  Ubuntu/Debian: sudo apt update && sudo apt install $$tools"; \
		echo "  Alpine: sudo apk add $$tools"; \
		echo "  CentOS/RHEL: sudo yum install $$tools"; \
	elif [ -f /etc/debian_version ]; then \
		echo "$(YELLOW)[DEBIAN/UBUNTU]$(NC)"; \
		echo "  sudo apt update && sudo apt install $$tools"; \
	elif [ -f /etc/redhat-release ]; then \
		echo "$(YELLOW)[REDHAT/CENTOS]$(NC)"; \
		echo "  sudo yum install $$tools"; \
	elif [ -f /etc/alpine-release ]; then \
		echo "$(YELLOW)[ALPINE]$(NC)"; \
		echo "  sudo apk add $$tools"; \
	elif [ -f /etc/arch-release ]; then \
		echo "$(YELLOW)[ARCH LINUX]$(NC)"; \
		echo "  sudo pacman -S $$tools"; \
	elif [[ "$$OSTYPE" == darwin* ]]; then \
		echo "$(YELLOW)[MACOS]$(NC)"; \
		echo "  brew install $$tools"; \
		echo "  Note: Install Homebrew first: /bin/bash -c \"\$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
	elif [[ "$$OSTYPE" =~ ^(msys|cygwin) ]] || command -v powershell.exe >/dev/null 2>&1; then \
		echo "$(YELLOW)[WINDOWS]$(NC) Git for Windows/MSYS2/Cygwin detected"; \
		echo "  Recommended: Install Scoop package manager first:"; \
		echo "    powershell.exe -Command \"Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; iwr -useb get.scoop.sh | iex\""; \
		echo "  Then install tools with Scoop:"; \
		scoop_tools=""; \
		for tool in $$tools; do \
			case $$tool in \
				make) scoop_tools="$$scoop_tools make" ;; \
				git) scoop_tools="$$scoop_tools git" ;; \
				bash) echo "    bash: Already available in Git for Windows" ;; \
				grep) echo "    grep: Already available in Git for Windows" ;; \
				sed) echo "    sed: Already available in Git for Windows" ;; \
				awk) echo "    awk: Already available in Git for Windows (gawk)" ;; \
				vim) scoop_tools="$$scoop_tools vim" ;; \
				zsh) scoop_tools="$$scoop_tools zsh" ;; \
				curl) echo "    curl: Already available in Windows 10/11" ;; \
				tar) echo "    tar: Already available in Windows 10/11" ;; \
				find) echo "    find: Use 'where' or install findutils via scoop" ;; \
				rg) scoop_tools="$$scoop_tools ripgrep" ;; \
				fd) scoop_tools="$$scoop_tools fd" ;; \
				bat) scoop_tools="$$scoop_tools bat" ;; \
				fzf) scoop_tools="$$scoop_tools fzf" ;; \
				exa) scoop_tools="$$scoop_tools exa" ;; \
				shellcheck) scoop_tools="$$scoop_tools shellcheck" ;; \
				jq) scoop_tools="$$scoop_tools jq" ;; \
				yq) scoop_tools="$$scoop_tools yq" ;; \
				tree) scoop_tools="$$scoop_tools tree" ;; \
				htop) scoop_tools="$$scoop_tools btop" ;; \
				*) scoop_tools="$$scoop_tools $$tool" ;; \
			esac; \
		done; \
		if [ -n "$$scoop_tools" ]; then \
			echo "    powershell.exe -Command \"scoop install$$scoop_tools\""; \
		fi; \
		echo "  Alternative: Use MSYS2 package manager:"; \
		echo "    pacman -S $$tools"; \
	else \
		echo "$(YELLOW)[UNKNOWN PLATFORM]$(NC)"; \
		echo "  Please install manually: $$tools"; \
	fi; \
	echo ""

.PHONY: install
install: check-prereqs install-shell install-vim install-git install-tmux install-claude install-vscode ## Install all dotfiles

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

.PHONY: install-tmux
install-tmux: validate ## Install tmux configuration
	@echo "$(BLUE)[INFO]$(NC) Installing tmux configuration..."
	@chmod +x $(DOTFILES_DIR)/config/tmux/setup_tmux.sh
	@$(DOTFILES_DIR)/config/tmux/setup_tmux.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Tmux configuration installed"

.PHONY: install-claude
install-claude: validate ## Install Claude configuration
	@echo "$(BLUE)[INFO]$(NC) Installing Claude configuration..."
	@chmod +x $(DOTFILES_DIR)/config/claude/setup_claude.sh
	@$(DOTFILES_DIR)/config/claude/setup_claude.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Claude configuration installed"

.PHONY: install-vscode
install-vscode: validate ## Install VS Code configuration
	@echo "$(BLUE)[INFO]$(NC) Installing VS Code configuration..."
	@mkdir -p $(HOME_DIR)/.vscode
	@if [ -f $(HOME_DIR)/.vscode/settings.json ] && [ ! -L $(HOME_DIR)/.vscode/settings.json ]; then \
		echo "$(YELLOW)[WARNING]$(NC) Backing up existing VS Code settings..."; \
		mkdir -p $(BACKUP_DIR); \
		cp $(HOME_DIR)/.vscode/settings.json $(BACKUP_DIR)/vscode_settings.json.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	@ln -sf $(DOTFILES_DIR)/config/vscode/settings.json $(HOME_DIR)/.vscode/settings.json
	@echo "$(GREEN)[SUCCESS]$(NC) VS Code configuration installed"

.PHONY: setup-wsl-bridge
setup-wsl-bridge: ## Create Windows junction to WSL dotfiles (for WSL users)
	@echo "$(BLUE)[INFO]$(NC) Setting up WSL-Windows bridge for dotfiles..."
	@if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$${WSL_DISTRO_NAME:-}" ] || [[ "$$MSYSTEM" =~ ^MINGW ]] || [[ "$$OSTYPE" == "msys" ]]; then \
		$(MAKE) -s _create_windows_junction; \
	else \
		echo "$(RED)[ERROR]$(NC) This command is only for WSL or MSYS2 environments"; \
		exit 1; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) WSL-Windows bridge created"

.PHONY: setup-windows-bridge
setup-windows-bridge: ## Create WSL symlink to Windows dotfiles (for Windows-first users)
	@echo "$(BLUE)[INFO]$(NC) Setting up Windows-WSL bridge (Windows-first)..."
	@if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$${WSL_DISTRO_NAME:-}" ] || [[ "$$MSYSTEM" =~ ^MINGW ]] || [[ "$$OSTYPE" == "msys" ]]; then \
		$(MAKE) -s _create_windows_symlink; \
	else \
		echo "$(RED)[ERROR]$(NC) This command is only for WSL or MSYS2 environments"; \
		exit 1; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Windows-WSL bridge created"

.PHONY: _create_windows_symlink
_create_windows_symlink:
	@echo "$(BLUE)[INFO]$(NC) Creating WSL symlink to Windows dotfiles..."
	@username="$$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"; \
	if [ -z "$$username" ]; then \
		echo "$(RED)[ERROR]$(NC) Failed to get Windows username"; \
		exit 1; \
	fi; \
	\
	windows_path="/mnt/c/Users/$$username/dotfiles"; \
	wsl_dotfiles="$$HOME/dotfiles"; \
	echo "$(BLUE)[INFO]$(NC) Windows dotfiles path: $$windows_path"; \
	echo "$(BLUE)[INFO]$(NC) WSL symlink target: $$wsl_dotfiles"; \
	\
	if [ ! -d "$$windows_path" ]; then \
		echo "$(RED)[ERROR]$(NC) Windows dotfiles not found at: $$windows_path"; \
		echo "$(YELLOW)[INFO]$(NC) Please clone dotfiles to Windows first: %USERPROFILE%\\dotfiles"; \
		exit 1; \
	fi; \
	\
	if [ -e "$$wsl_dotfiles" ]; then \
		if [ -L "$$wsl_dotfiles" ]; then \
			echo "$(GREEN)[INFO]$(NC) Symlink already exists, checking target..."; \
			current_target="$$(readlink "$$wsl_dotfiles")"; \
			if [ "$$current_target" = "$$windows_path" ]; then \
				echo "$(GREEN)[INFO]$(NC) Symlink already points to correct location"; \
			else \
				echo "$(YELLOW)[WARNING]$(NC) Symlink points to different location: $$current_target"; \
				echo "$(BLUE)[INFO]$(NC) Updating symlink to point to: $$windows_path"; \
				rm "$$wsl_dotfiles" && ln -sf "$$windows_path" "$$wsl_dotfiles"; \
			fi; \
		else \
			echo "$(YELLOW)[WARNING]$(NC) Directory exists but is not a symlink: $$wsl_dotfiles"; \
			echo "$(BLUE)[INFO]$(NC) You may need to manually remove it first"; \
			echo "$(BLUE)[INFO]$(NC) Then run this command again"; \
			exit 1; \
		fi; \
	else \
		echo "$(BLUE)[INFO]$(NC) Creating symlink: $$wsl_dotfiles -> $$windows_path"; \
		ln -sf "$$windows_path" "$$wsl_dotfiles" || { \
			echo "$(RED)[ERROR]$(NC) Failed to create symlink"; \
			exit 1; \
		}; \
		echo "$(GREEN)[SUCCESS]$(NC) Symlink created successfully"; \
	fi

.PHONY: _create_windows_junction
_create_windows_junction:
	@echo "$(BLUE)[INFO]$(NC) Creating Windows junction to WSL dotfiles..."
	@wsl_path="$(DOTFILES_DIR)"; \
	windows_path="$$(wslpath -w "$$wsl_path" 2>/dev/null)"; \
	if [ -z "$$windows_path" ]; then \
		echo "$(RED)[ERROR]$(NC) Failed to convert WSL path to Windows path"; \
		echo "$(YELLOW)[INFO]$(NC) Make sure wslpath is available"; \
		exit 1; \
	fi; \
	\
	home_path="$$(cmd.exe /c 'echo %HOMEPATH%' 2>/dev/null | tr -d '\r\n')"; \
	if [ -z "$$home_path" ]; then \
		echo "$(RED)[ERROR]$(NC) Failed to get Windows HOMEPATH"; \
		exit 1; \
	fi; \
	\
	windows_dotfiles="$$home_path\\dotfiles"; \
	echo "$(BLUE)[INFO]$(NC) WSL dotfiles path: $$wsl_path"; \
	echo "$(BLUE)[INFO]$(NC) Windows path: $$windows_path"; \
	echo "$(BLUE)[INFO]$(NC) Target junction: $$windows_dotfiles"; \
	\
	if cmd.exe /c "if exist \"$$windows_dotfiles\" echo EXISTS" 2>/dev/null | grep -q EXISTS; then \
		echo "$(YELLOW)[WARNING]$(NC) Windows dotfiles directory already exists"; \
		echo "$(BLUE)[INFO]$(NC) Checking if it's already a junction..."; \
		if cmd.exe /c "dir \"$$home_path\" | findstr /C:\"<JUNCTION>\" | findstr dotfiles" >/dev/null 2>&1; then \
			echo "$(GREEN)[INFO]$(NC) Junction already exists, skipping creation"; \
		else \
			echo "$(YELLOW)[WARNING]$(NC) Directory exists but is not a junction"; \
			echo "$(BLUE)[INFO]$(NC) You may need to manually remove: $$windows_dotfiles"; \
			echo "$(BLUE)[INFO]$(NC) Then run this command again"; \
		fi; \
	else \
		echo "$(BLUE)[INFO]$(NC) Creating junction: $$windows_dotfiles -> $$windows_path"; \
		cmd.exe /c "mklink /J \"$$windows_dotfiles\" \"$$windows_path\"" || { \
			echo "$(RED)[ERROR]$(NC) Failed to create junction. You may need to:"; \
			echo "  1. Run from an elevated command prompt, or"; \
			echo "  2. Enable Developer Mode in Windows Settings"; \
			exit 1; \
		}; \
		echo "$(GREEN)[SUCCESS]$(NC) Junction created successfully"; \
	fi

.PHONY: _setup_wsl_bridge_auto
_setup_wsl_bridge_auto:
	@echo "$(BLUE)[INFO]$(NC) Auto-detecting dotfiles layout..."
	@username="$$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"; \
	if [ -z "$$username" ]; then \
		echo "$(YELLOW)[WARNING]$(NC) Could not detect Windows username, using WSL-first approach"; \
		$(MAKE) -s _create_windows_junction; \
	else \
		# Handle both WSL (/mnt/c) and MSYS2 (/c) path formats \
		if [[ "$$OSTYPE" == "msys" ]] || [[ "$$MSYSTEM" =~ ^MINGW ]]; then \
			windows_path="/c/Users/$$username/dotfiles"; \
		else \
			windows_path="/mnt/c/Users/$$username/dotfiles"; \
		fi; \
		wsl_path="$(DOTFILES_DIR)"; \
		echo "$(BLUE)[INFO]$(NC) Checking for Windows dotfiles at: $$windows_path"; \
		echo "$(BLUE)[INFO]$(NC) Current WSL/MSYS2 dotfiles at: $$wsl_path"; \
		\
		if [ -d "$$windows_path" ] && [ ! -L "$$HOME/dotfiles" ]; then \
			echo "$(BLUE)[INFO]$(NC) Windows-first layout detected - creating WSL symlink"; \
			$(MAKE) -s _create_windows_symlink; \
		elif [ -d "$$wsl_path" ] && [ "$$wsl_path" = "$$HOME/dotfiles" ]; then \
			echo "$(BLUE)[INFO]$(NC) WSL-first layout detected - creating Windows junction"; \
			$(MAKE) -s _create_windows_junction; \
		else \
			echo "$(YELLOW)[WARNING]$(NC) Cannot determine layout, defaulting to WSL-first approach"; \
			$(MAKE) -s _create_windows_junction; \
		fi; \
	fi

.PHONY: install-windows
install-windows: validate ## Install Windows PowerShell configuration
	@echo "$(BLUE)[INFO]$(NC) Installing Windows configuration..."
	@if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$${WSL_DISTRO_NAME:-}" ] || [[ "$$MSYSTEM" =~ ^MINGW ]] || [[ "$$OSTYPE" == "msys" ]]; then \
		echo "$(BLUE)[INFO]$(NC) WSL/MSYS2 detected - determining dotfiles layout..."; \
		$(MAKE) -s _setup_wsl_bridge_auto; \
	fi
	@if command -v powershell.exe >/dev/null 2>&1; then \
		powershell.exe -ExecutionPolicy Bypass -File "$(DOTFILES_DIR)/windows/setup_windows.ps1"; \
	elif command -v pwsh.exe >/dev/null 2>&1; then \
		pwsh.exe -ExecutionPolicy Bypass -File "$(DOTFILES_DIR)/windows/setup_windows.ps1"; \
	else \
		echo "$(RED)[ERROR]$(NC) PowerShell not found. Please install PowerShell or PowerShell Core."; \
		exit 1; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Windows configuration installed"

.PHONY: validate-env
validate-env: ## Validate dotfiles directory and dependencies
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
	@for file in .bashrc .zshrc .vimrc _vimrc _gvimrc .gitconfig .gitignore .gitattributes .tmux.conf; do \
		if [ -f $(HOME_DIR)/$$file ]; then \
			echo "$(YELLOW)[WARNING]$(NC) Backing up $$file"; \
			cp $(HOME_DIR)/$$file $(BACKUP_DIR)/$$file.backup.$$(date +%Y%m%d_%H%M%S); \
		fi; \
	done
	@if [ -d $(HOME_DIR)/.claude ]; then \
		echo "$(YELLOW)[WARNING]$(NC) Backing up .claude directory"; \
		cp -r $(HOME_DIR)/.claude $(BACKUP_DIR)/.claude.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Backup completed"

.PHONY: clean
clean: ## Remove installed dotfiles (with confirmation)
	@echo "$(YELLOW)[WARNING]$(NC) This will remove all installed dotfiles!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "$(BLUE)[INFO]$(NC) Removing shell configuration..."
	@rm -f $(HOME_DIR)/.bashrc $(HOME_DIR)/.zshrc
	@rm -f $(HOME_DIR)/.bash_logout $(HOME_DIR)/.bash_profile $(HOME_DIR)/.zprofile $(HOME_DIR)/.zlogout
	@echo "$(BLUE)[INFO]$(NC) Removing vim configuration..."
	@rm -f $(HOME_DIR)/.vimrc $(HOME_DIR)/_vimrc $(HOME_DIR)/.gvimrc $(HOME_DIR)/_gvimrc $(HOME_DIR)/.ideavimrc $(HOME_DIR)/_ideavimrc
	@if [ -L "$(HOME_DIR)/.vim" ]; then rm "$(HOME_DIR)/.vim"; fi
	@if [ -L "$(HOME_DIR)/vimfiles" ]; then rm "$(HOME_DIR)/vimfiles"; fi
	@echo "$(BLUE)[INFO]$(NC) Removing git configuration..."
	@rm -f $(HOME_DIR)/.gitconfig $(HOME_DIR)/.gitignore $(HOME_DIR)/.gitattributes
	@echo "$(BLUE)[INFO]$(NC) Removing tmux configuration..."
	@rm -f $(HOME_DIR)/.tmux.conf
	@echo "$(BLUE)[INFO]$(NC) Removing Claude configuration..."
	@rm -f $(HOME_DIR)/.claude/settings.json $(HOME_DIR)/.claude/settings.local.json $(HOME_DIR)/.claude/statusline.sh
	@if [ -d $(HOME_DIR)/.claude ] && [ -z "$$(ls -A $(HOME_DIR)/.claude)" ]; then rmdir $(HOME_DIR)/.claude; fi
	@echo "$(BLUE)[INFO]$(NC) Removing VS Code configuration..."
	@rm -f $(HOME_DIR)/.vscode/settings.json
	@if [ -d $(HOME_DIR)/.vscode ] && [ -z "$$(ls -A $(HOME_DIR)/.vscode)" ]; then rmdir $(HOME_DIR)/.vscode; fi
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
	@for file in .vimrc _vimrc _gvimrc .ideavimrc vimrc.common mappings.common vimrc.generated gvimrc.generated ideavimrc.generated; do \
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
	@echo ""
	@echo "Tmux Configuration:"
	@echo "  Home directory:"
	@if [ -L $(HOME_DIR)/.tmux.conf ]; then \
		echo "    $(GREEN)✓$(NC) .tmux.conf (symlink)"; \
	elif [ -f $(HOME_DIR)/.tmux.conf ]; then \
		echo "    $(YELLOW)⚠$(NC) .tmux.conf (file)"; \
	else \
		echo "    $(RED)✗$(NC) .tmux.conf (not found)"; \
	fi
	@echo ""
	@echo "Claude Configuration:"
	@echo "  Home directory:"
	@if [ -L $(HOME_DIR)/.claude/settings.json ]; then \
		echo "    $(GREEN)✓$(NC) .claude/settings.json (symlink)"; \
	elif [ -f $(HOME_DIR)/.claude/settings.json ]; then \
		echo "    $(YELLOW)⚠$(NC) .claude/settings.json (file)"; \
	else \
		echo "    $(RED)✗$(NC) .claude/settings.json (not found)"; \
	fi
	@if [ -f $(HOME_DIR)/.claude/settings.local.json ]; then \
		if [ -L $(HOME_DIR)/.claude/settings.local.json ]; then \
			echo "    $(GREEN)✓$(NC) .claude/settings.local.json (symlink)"; \
		else \
			echo "    $(YELLOW)⚠$(NC) .claude/settings.local.json (file)"; \
		fi; \
	fi
	@if [ -f $(HOME_DIR)/.claude/statusline.sh ]; then \
		echo "    $(GREEN)✓$(NC) .claude/statusline.sh (exists)"; \
	else \
		echo "    $(RED)✗$(NC) .claude/statusline.sh (not found)"; \
	fi
	@echo ""
	@echo "VS Code Configuration:"
	@echo "  Home directory:"
	@if [ -L $(HOME_DIR)/.vscode/settings.json ]; then \
		echo "    $(GREEN)✓$(NC) .vscode/settings.json (symlink)"; \
	elif [ -f $(HOME_DIR)/.vscode/settings.json ]; then \
		echo "    $(YELLOW)⚠$(NC) .vscode/settings.json (file)"; \
	else \
		echo "    $(RED)✗$(NC) .vscode/settings.json (not found)"; \
	fi

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
	@for dir in shell vim git config/tmux config/claude config/vscode; do \
		if [ ! -d "$(DOTFILES_DIR)/$$dir" ]; then \
			echo "$(RED)[ERROR]$(NC) Required directory missing: $$dir"; \
			exit 1; \
		else \
			echo "$(GREEN)✓$(NC) $$dir directory exists"; \
		fi; \
	done
	@echo ""
	@echo "Checking setup scripts..."
	@for script in shell/setup_shell.sh vim/setup_vimrc.sh git/setup_git.sh config/tmux/setup_tmux.sh config/claude/setup_claude.sh; do \
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
		shellcheck_files="$(DOTFILES_DIR)/shell/shell.common $(DOTFILES_DIR)/shell/shell.bash $(DOTFILES_DIR)/shell/shell.zsh $(DOTFILES_DIR)/shell/shell.ohmy.zsh"; \
		shellcheck $$shellcheck_files || exit 1; \
		echo "$(GREEN)[SUCCESS]$(NC) All shell scripts passed shellcheck"; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) shellcheck not found, skipping shellcheck tests"; \
	fi

.PHONY: test-compat
test-compat: validate ## Test cross-platform compatibility
	@echo "$(BLUE)[INFO]$(NC) Testing platform compatibility..."
	@bash -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'Shell configuration loaded successfully'" || exit 1
	@bash -c "source $(DOTFILES_DIR)/shell/shell.common && alias | head -3 >/dev/null" || exit 1
	@bash -c "DEBUG_SHELL_COMMON=1 source $(DOTFILES_DIR)/shell/shell.common && echo 'grep_command: $${grep_command:-not set}' && echo 'du_command: $${du_command:-not set}'" || exit 1
	@if command -v zsh >/dev/null 2>&1; then \
		zsh -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'Shell configuration loaded successfully'" || exit 1; \
		zsh -c "source $(DOTFILES_DIR)/shell/shell.common && alias | head -3 >/dev/null" || exit 1; \
		zsh -c "source $(DOTFILES_DIR)/shell/shell.common && echo 'grep_command: $${grep_command:-not set}' && echo 'du_command: $${du_command:-not set}'" || exit 1; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) zsh not found, skipping zsh compatibility tests"; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Platform compatibility tests passed"

.PHONY: lint
lint: test-shellcheck ## Alias for test-shellcheck (deprecated, use test-shellcheck)

# =============================================================================
# Font Management
# =============================================================================

.PHONY: install-fonts
install-fonts: ## Install programming fonts for gvim (cross-platform)
	@echo "$(BLUE)[INFO]$(NC) Installing programming fonts for gvim..."
	@if [[ "$(PLATFORM)" == "win" ]]; then \
		if command -v powershell >/dev/null 2>&1; then \
			powershell -ExecutionPolicy Bypass -File "$(DOTFILES_DIR)/fonts/install_fonts.ps1"; \
		else \
			echo "$(YELLOW)[WARNING]$(NC) PowerShell not found. Please run fonts/install_fonts.ps1 manually."; \
		fi; \
	elif [[ "$(PLATFORM)" == "mac" ]]; then \
		if command -v brew >/dev/null 2>&1; then \
			bash "$(DOTFILES_DIR)/fonts/install_fonts.sh"; \
		else \
			echo "$(YELLOW)[WARNING]$(NC) Homebrew not found. Please install from https://brew.sh/"; \
		fi; \
	else \
		bash "$(DOTFILES_DIR)/fonts/install_fonts.sh"; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) Font installation completed"

.PHONY: install-vim-plug
install-vim-plug: ## Install vim-plug plugin manager (cross-platform)
	@echo "$(BLUE)[INFO]$(NC) Installing vim-plug plugin manager..."
	@if [[ "$(PLATFORM)" == "win" ]]; then \
		if command -v powershell >/dev/null 2>&1; then \
			powershell -ExecutionPolicy Bypass -File "$(DOTFILES_DIR)/vim/install_vim_plug.ps1"; \
		else \
			bash "$(DOTFILES_DIR)/vim/install_vim_plug.sh"; \
		fi; \
	else \
		bash "$(DOTFILES_DIR)/vim/install_vim_plug.sh"; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) vim-plug installation completed"
	@echo "$(BLUE)[INFO]$(NC) Next steps:"
	@echo "  1. Open vim/gvim"
	@echo "  2. Run :PlugInstall to install plugins"
	@echo "  3. Restart vim/gvim to load plugins"

.PHONY: check-fonts
check-fonts: ## Check if recommended fonts are installed
	@echo "$(BLUE)[INFO]$(NC) Checking font availability..."
	@if [[ "$(PLATFORM)" == "win" ]]; then \
		echo "Checking Windows fonts..."; \
		fonts_found=0; \
		for font in "JetBrains Mono" "Fira Code" "Cascadia Code" "Consolas"; do \
			if powershell -Command "Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' | Get-Member -Name '*$$font*'" >/dev/null 2>&1; then \
				echo "  ✓ $$font"; fonts_found=$$((fonts_found + 1)); \
			else \
				echo "  ✗ $$font"; \
			fi; \
		done; \
		echo "Found $$fonts_found/4 recommended fonts"; \
	elif [[ "$(PLATFORM)" == "mac" ]]; then \
		echo "Checking macOS fonts..."; \
		fonts_found=0; \
		for font in "JetBrainsMono Nerd Font" "FiraCode Nerd Font" "Menlo" "Monaco"; do \
			if command -v fc-list >/dev/null 2>&1 && fc-list | grep -i "$$font" >/dev/null 2>&1 || system_profiler SPFontsDataType | grep -i "$$font" >/dev/null 2>&1; then \
				echo "  ✓ $$font"; fonts_found=$$((fonts_found + 1)); \
			else \
				echo "  ✗ $$font"; \
			fi; \
		done; \
		echo "Found $$fonts_found/4 recommended fonts"; \
	else \
		echo "Checking Linux fonts..."; \
		fonts_found=0; \
		for font in "JetBrainsMono" "FiraCode" "DejaVuSansMono" "UbuntuMono"; do \
			if command -v fc-list >/dev/null 2>&1 && fc-list | grep -i "$$font" >/dev/null 2>&1; then \
				echo "  ✓ $$font"; fonts_found=$$((fonts_found + 1)); \
			else \
				echo "  ✗ $$font"; \
			fi; \
		done; \
		echo "Found $$fonts_found/4 recommended fonts"; \
	fi

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
	@echo "  - Vim with multiple configurations and smart font selection"
	@echo "  - Git with common settings"
	@echo "  - Tmux with cross-platform clipboard integration"
	@echo "  - Claude with security-focused AI development setup"
	@echo "  - VS Code with comprehensive editor settings and file associations"
	@echo "  - Windows PowerShell (with install-windows)"
	@echo "  - Programming fonts (with install-fonts)"
	@echo "  - vim-plug plugin manager (with install-vim-plug)"
	@echo ""
	@echo "Platform support:"
	@echo "  - macOS (darwin)"
	@echo "  - Linux"
	@echo "  - Windows (WSL/MSYS/Cygwin/Native PowerShell)"
	@echo ""
	@echo "Use 'make help' to see all available commands"
