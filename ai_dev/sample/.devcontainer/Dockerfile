FROM mcr.microsoft.com/vscode/devcontainers/python:3.11

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    git \
    tmux \
    zsh \
    curl \
    wget \
    vim \
    build-essential \
    shellcheck \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (for act and other tools)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to vscode user
USER vscode

# Install Python tools
RUN pip install --user --no-cache-dir \
    aider-chat \
    ruff \
    black \
    pytest \
    pytest-cov \
    pre-commit

# Install act (GitHub Actions local runner)
RUN curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Set up zsh as default shell
RUN sudo chsh -s $(which zsh) vscode

WORKDIR /work
