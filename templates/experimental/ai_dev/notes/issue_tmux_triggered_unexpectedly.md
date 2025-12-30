FOUND THE ROOT CAUSE! When you run tmuxinator --version, it:
Checks if tmux exists
Starts the tmux server
Lists tmux sessions
Executes the shell script from .tmuxinator.yml which starts the ai-dev session!
This is happening because tmuxinator --version apparently scans for local project configurations and attempts to process them as part of its version check routine!
Summary
Why make health-check triggers tmuxinator start ai-dev:
Makefile:52 runs ./.devcontainer/health-check.sh
[health-check.sh:120](. devcontainer/health-check.sh#L120) executes tmuxinator --version to check if tmuxinator is installed
tmuxinator --version has a side effect: it scans the current directory for .tmuxinator.yml and executes the tmux session setup script
This causes the ai-dev tmux session to start with 4 split panes running make run, make test, make aider-refactor, and a monitor pane
The fix would be to either:
Not check tmuxinator --version in the health check (just use command -v tmuxinator)
Move/rename .tmuxinator.yml to prevent auto-detection
Use tmuxinator version instead of tmuxinator --version
Would you like me to implement a fix?
