FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04
ARG DEBIAN_FRONTEND=noninteractive

# Install only missing tools (base image already has: git, curl, jq, make, bash, sudo)
RUN apt-get update -o Acquire::Retries=5 -o Acquire::http::Timeout=30 \
 && apt-get install -y --no-install-recommends \
      tmux python3 python3-venv python3-pip ruby-full vim iputils-ping \
 && rm -rf /var/lib/apt/lists/*

# Install tmuxinator (as vscode user)
RUN gem install tmuxinator

# Install devcontainer CLI globally via npm
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
