#!/usr/bin/env bash
set -euo pipefail

# check_mac_mem_pressure.sh
# - Compact view of macOS memory / swap / compression,
#   heavy processes, and background launchd items
# - Designed to run persistently in a tmux pane
#   (no `watch`; internal refresh loop)

INTERVAL="${1:-2}"     # Interval (seconds)
TOPN="${TOPN:-5}"      # Number of top processes to display
FILTER_REGEX="${FILTER_REGEX:-docker|jetbrains|toolbox|teams|slack|notion|chrome|onedrive|outlook|norton|mds|mdworker|bird}"

# Thresholds — configurable via env vars (values in GB)
COMP_MODERATE="${COMP_MODERATE:-8}"
COMP_WARN="${COMP_WARN:-14}"
COMP_CRITICAL="${COMP_CRITICAL:-20}"
SWAP_MODERATE="${SWAP_MODERATE:-1}"
SWAP_WARN="${SWAP_WARN:-3}"
SWAP_CRITICAL="${SWAP_CRITICAL:-6}"
# Pre-compute byte thresholds and display strings (avoid per-refresh conversions)
COMP_MODERATE_B=$(( COMP_MODERATE * 1024 * 1024 * 1024 ))
COMP_WARN_B=$(( COMP_WARN * 1024 * 1024 * 1024 ))
COMP_CRITICAL_B=$(( COMP_CRITICAL * 1024 * 1024 * 1024 ))
SWAP_MODERATE_B=$(( SWAP_MODERATE * 1024 * 1024 * 1024 ))
SWAP_WARN_B=$(( SWAP_WARN * 1024 * 1024 * 1024 ))
SWAP_CRITICAL_B=$(( SWAP_CRITICAL * 1024 * 1024 * 1024 ))
COMP_THRESHOLDS="${COMP_MODERATE}/${COMP_WARN}/${COMP_CRITICAL}"
SWAP_THRESHOLDS="${SWAP_MODERATE}/${SWAP_WARN}/${SWAP_CRITICAL}"

# ANSI color codes
RED='\033[0;31m'
ORANGE='\033[38;5;208m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'  # No Color

# bytes -> GiB (1 decimal)
_gib() { awk -v b="$1" 'BEGIN{printf "%.1f", b/1024/1024/1024}'; }
_mib() { awk -v b="$1" 'BEGIN{printf "%.0f", b/1024/1024}'; }

_mem_pressure() {
  # pressure: some text output; extract "System-wide memory free percentage" etc
  # We'll just show first few lines.
  /usr/bin/memory_pressure 2>/dev/null | head -n 8 || true
}

_vm_comp_free() {
  # vm_stat gives pages; parse page size + compressed + free
  /usr/bin/vm_stat | awk '
    /page size of/ {gsub("\\.","",$8); ps=$8}
    /Pages free/ {gsub("\\.","",$3); free=$3}
    /Pages occupied by compressor/ {gsub("\\.","",$5); comp=$5}
    END {
      if (ps==0) ps=4096;
      printf "%d %d %d\n", ps, free, comp
    }'
}

_swap_usage_bytes() {
  # sysctl vm.swapusage example:
  # vm.swapusage: total = 1024.00M  used = 188.00M  free = 836.00M  (encrypted)
  /usr/sbin/sysctl -n vm.swapusage 2>/dev/null | awk '
    {for (i=1;i<=NF;i++){
      if ($i=="used") {val=$(i+2); gsub(/=/,"",val)}
    }}
    END{
      # val like 188.00M or 1.25G
      if (val ~ /M$/){sub(/M$/,"",val); bytes=val*1024*1024}
      else if (val ~ /G$/){sub(/G$/,"",val); bytes=val*1024*1024*1024}
      else bytes=0
      printf "%.0f\n", bytes
    }'
}

_top_mem_procs() {
  # RSS (KB) -> sort desc
  # Output: RSS_MB  %CPU  CMD (basename only)
  /bin/ps -axo rss,pcpu,comm | awk 'NR>1{printf "%10d %6.1f %s\n",$1,$2,$3}' \
    | sort -nr \
    | head -n "${TOPN}" \
    | awk '{
        rss_kb=$1; pcpu=$2; cmd=$3
        # Extract basename from path
        n=split(cmd, parts, "/")
        basename=parts[n]
        printf "%6.0fMB  %5.1f%%  %s\n", rss_kb/1024, pcpu, basename
      }'
}

_launchd_hits() {
  # launchctl list is large; just grep keywords to find likely culprits
  /bin/launchctl list 2>/dev/null | egrep -i "${FILTER_REGEX}" | head -n 30 || true
}

_proc_hits() {
  # quick scan of running processes by regex
  # Show: PID  RSS_MB  %CPU  BASENAME
  /bin/ps -axo pid,rss,pcpu,comm | egrep -i "${FILTER_REGEX}" \
    | head -n 40 \
    | awk '{
        pid=$1; rss=$2; pcpu=$3; cmd=$4
        # Extract basename
        n=split(cmd, parts, "/")
        basename=parts[n]
        printf "%6d  %6.0fMB  %5.1f%%  %s\n", pid, rss/1024, pcpu, basename
      }' \
    || true
}

_header() {
  local now; now="$(/bin/date '+%Y-%m-%d %H:%M:%S')"
  echo "=== MemPressure | ${now} | ↻ ${INTERVAL}s ==="
}

_health_line() {
  local ps free_pages comp_pages free_bytes comp_bytes swap_bytes
  read -r ps free_pages comp_pages < <(_vm_comp_free)
  free_bytes=$((ps * free_pages))
  comp_bytes=$((ps * comp_pages))
  swap_bytes="$(_swap_usage_bytes)"

  local free_g comp_g swap_g
  free_g="$(_gib "$free_bytes")"
  comp_g="$(_gib "$comp_bytes")"
  swap_g="$(_gib "$swap_bytes")"

  # Determine status: CRITICAL > WARN > MODERATE > OK
  local status color
  if (( comp_bytes > COMP_CRITICAL_B )) || (( swap_bytes > SWAP_CRITICAL_B )); then
    status="CRITICAL"; color="${RED}"
  elif (( comp_bytes > COMP_WARN_B )) || (( swap_bytes > SWAP_WARN_B )); then
    status="WARN"; color="${ORANGE}"
  elif (( comp_bytes > COMP_MODERATE_B )) || (( swap_bytes > SWAP_MODERATE_B )); then
    status="MODERATE"; color="${CYAN}"
  else
    status="OK"; color="${GREEN}"
  fi

  echo -e "Health: ${color}${status}${NC} | Free=${free_g}GB | Comp=${comp_g}GB [${COMP_THRESHOLDS}] | Swap=${swap_g}GB [${SWAP_THRESHOLDS}]"
}

clear
_header
_health_line
echo

echo "Top ${TOPN} Processes by Memory (RSS: Resident Set Size):"
_top_mem_procs
