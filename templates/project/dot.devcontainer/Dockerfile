FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Switch default apt sources to HTTPS to avoid environments that block plain HTTP
RUN sed -i 's|http://ports.ubuntu.com/ubuntu-ports/|https://ports.ubuntu.com/ubuntu-ports/|g' /etc/apt/sources.list.d/ubuntu.sources

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Tokyo
ENV TZ=${TZ}
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2
ARG ZSH_IN_DOCKER_VERSION=1.2.0

# Install development tools including security tools (iptables, ipset)
# Also includes Playwright system dependencies for web scraping
RUN apt-get update -o Acquire::Retries=5 -o Acquire::http::Timeout=30 \
 && apt-get install -y --no-install-recommends \
      tmux python3 python3-venv python3-pip ruby-full vim iputils-ping \
      less procps fzf zsh man-db unzip gnupg2 \
      iptables ipset iproute2 dnsutils aggregate nano \
      libglib2.0-0t64 libnspr4 libnss3 libdbus-1-3 \
      libatk1.0-0t64 libatspi2.0-0t64 libx11-6 libxcomposite1 \
      libxdamage1 libxext6 libxfixes3 libxrandr2 libgbm1 \
      libxcb1 libxkbcommon0 libasound2t64 libpango-1.0-0 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install tmuxinator
RUN gem install tmuxinator

# Install Node.js and devcontainer CLI
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npm install -g @devcontainers/cli \
 && rm -rf /var/lib/apt/lists/*

# Install act (GitHub Actions runner) - Multi-arch compatible
RUN ARCH=$(dpkg --print-architecture) \
 && if [ "$ARCH" = "arm64" ]; then ACT_ARCH="arm64"; \
    elif [ "$ARCH" = "amd64" ]; then ACT_ARCH="x86_64"; \
    else ACT_ARCH="$ARCH"; fi \
 && curl -fsSL https://github.com/nektos/act/releases/latest/download/act_Linux_${ACT_ARCH}.tar.gz -o /tmp/act.tar.gz \
 && tar -xzf /tmp/act.tar.gz -C /usr/local/bin act \
 && rm /tmp/act.tar.gz \
 && chmod +x /usr/local/bin/act

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && apt-get update \
 && apt-get install -y gh \
 && rm -rf /var/lib/apt/lists/*

# Install git-delta for better diff viewing
RUN ARCH=$(dpkg --print-architecture) && \
 wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
 dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
 rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Create developer user from existing vscode user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Rename vscode user to developer
RUN usermod -l ${USERNAME} vscode && \
 usermod -d /home/${USERNAME} -m ${USERNAME} && \
 groupmod -n ${USERNAME} vscode && \
 echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
 chmod 0440 /etc/sudoers.d/${USERNAME}

# Ensure npm global directory exists with proper permissions
RUN mkdir -p /usr/local/share/npm-global && \
 chown -R ${USERNAME}:${USERNAME} /usr/local/share

# Persist bash history
RUN mkdir -p /commandhistory && \
 touch /commandhistory/.bash_history && \
 chown -R ${USERNAME}:${USERNAME} /commandhistory

# Set DEVCONTAINER environment variable
ENV DEVCONTAINER=true

# Set up npm global path
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set default editor
ENV EDITOR=nano
ENV VISUAL=nano

# Switch to non-root user for remaining setup
USER ${USERNAME}

# Install zsh with plugins (git only - fzf is already installed via apt)
# Note: fzf from apt package works directly, no Oh My Zsh plugin needed
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
 -p git \
 -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
 -a "[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh || true" \
 -a "[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh || true" \
 -x

# Set zsh as default shell
ENV SHELL=/bin/zsh

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Create directories for workspace and Claude config
USER root
RUN mkdir -p /workspace /home/${USERNAME}/.claude && \
 chown -R ${USERNAME}:${USERNAME} /workspace /home/${USERNAME}/.claude

# Copy and set up firewall script (optional security feature)
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh && \
 echo "${USERNAME} ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/${USERNAME}-firewall && \
 chmod 0440 /etc/sudoers.d/${USERNAME}-firewall

# Switch back to non-root user
USER ${USERNAME}

WORKDIR /workspace

# Create claude settings for user level
RUN ln -sf ${WORKDIR}/dot.claude/statusline.sh /home/${USERNAME}/.claude/statusline.sh
RUN ln -sf ${WORKDIR}/dot.claude/settings.json /home/${USERNAME}/.claude/settings.json

# Alias
RUN echo "alias claude-hard=\"claude --dangerously-skip-permissions\"" >> "/home/${USERNAME}/.zshrc"

# Enable vi mode
RUN echo "bindkey -v" >> "/home/${USERNAME}/.zshrc"

