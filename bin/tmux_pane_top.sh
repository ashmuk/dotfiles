#!/usr/bin/env bash
set -euo pipefail

# tmux側からペイン情報を取り出し、psでCPU/MEMなどを付加して表にする
echo "TMUX Pane Monitor  $(date)"
echo
printf "%-18s %-7s %-5s %-5s %-10s %-6s %-8s %s\n" "PANE" "PID" "CPU%" "MEM%" "ELAPSED" "STATE" "TTY" "CMD"

# list-panes: PANEID  PID  TTY  CMD  TITLE
tmux list-panes -aF '#{session_name}:#{window_index}.#{pane_index}	#{pane_pid}	#{pane_tty}	#{pane_current_command}	#{pane_title}' \
| while IFS=$'\t' read -r pane pid tty cmd title; do
  : "$cmd" "$title"
  # psでプロセスがまだ居る場合だけ表示
  if psout=$(ps -p "$pid" -o pid=,pcpu=,pmem=,etime=,state=,tty=,comm= 2>/dev/null); then
    read -r pid2 pcpu pmem etime state tty2 comm <<<"$psout"
    printf "%-18s %-7s %-5s %-5s %-10s %-6s %-8s %s\n" \
      "$pane" "$pid2" "$pcpu" "$pmem" "$etime" "$state" "${tty2:-$tty}" "$comm"
  fi
done
