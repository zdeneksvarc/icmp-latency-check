#!/usr/bin/env bash
set -euo pipefail

# --- Defaults ---
DEFAULT_COUNT=3
DEFAULT_FILE="default.txt"

PING_COUNT="$DEFAULT_COUNT"
TARGET_FILE="$DEFAULT_FILE"

# --- Parse arguments ---
if [[ $# -ge 1 ]]; then
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    PING_COUNT="$1"
    [[ $# -ge 2 && "$2" == *.txt ]] && TARGET_FILE="$2"
  elif [[ "$1" == *.txt ]]; then
    TARGET_FILE="$1"
    [[ $# -ge 2 && "$2" =~ ^[0-9]+$ ]] && PING_COUNT="$2"
  fi
fi

# --- Validate ---
if ! [[ "$PING_COUNT" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: COUNT must be a positive integer (got '$PING_COUNT')." >&2
  echo "Usage: $0 [COUNT] [TARGETS.TXT]  or  $0 [TARGETS.TXT] [COUNT]" >&2
  exit 1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Error: target file '$TARGET_FILE' not found." >&2
  echo "Create a CSV file with lines in the form: Target,IP" >&2
  exit 1
fi

command -v ping >/dev/null 2>&1 || { echo "Error: 'ping' not found." >&2; exit 1; }
command -v awk  >/dev/null 2>&1 || { echo "Error: 'awk' not found."  >&2; exit 1; }

# --- Function to extract average latency; prints live output to stderr ---
avg_latency() {
  local ip="$1"
  local out avg

  # Show status to stderr
  echo ">>> Pinging $ip ($PING_COUNT packets)..." >&2
  # Run ping once, stream to stderr for live view, and capture for parsing
  out="$(ping -n -c "$PING_COUNT" "$ip" 2>&1 | tee /dev/stderr || true)"
  echo "----- End of test $name ($ip)" >&2

  # Parse avg from Linux (rtt min/avg/max/mdev) or macOS (round-trip min/avg/max/stddev)
  avg="$(printf "%s\n" "$out" | awk '
    /min\/avg\/max/ || /round-trip/ {
      n=split($0, a, "=")
      n=split(a[2], b, "/")
      if (n>=2) { gsub(/[[:space:]]*ms[[:space:]]*/,"",b[2]); print b[2]; exit }
    }
  ')"

  [[ -n "$avg" ]] && echo "$avg" || echo "N/A"
}

results=()

# --- Read CSV file (no header), each line: Target,IP ---
while IFS=',' read -r name ip || [[ -n "${name}${ip}" ]]; do
  name="$(echo "${name:-}" | xargs)"
  ip="$(echo "${ip:-}" | xargs)"
  [[ -z "$name" || -z "$ip" ]] && continue

  # Add blank line before each block for readability
  echo >&2
  echo "----- Testing $name ($ip)" >&2

  avg="$(avg_latency "$ip")"

  if [[ "$avg" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    key="$avg"
  else
    key="999999"
  fi

  results+=("$key|$avg|$name|$ip")
done < "$TARGET_FILE"

# --- Summary to stdout only ---
echo
echo "=================== SUMMARY =================="
printf "%-20s %-16s %s\n" "Target" "IP" "Avg (ms)"
echo "----------------------------------------------"

LC_ALL=C printf "%s\n" "${results[@]}" \
  | sort -t'|' -k1,1n \
  | awk -F'|' '{ printf "%-20s %-16s %s\n", $3, $4, $2 }'
