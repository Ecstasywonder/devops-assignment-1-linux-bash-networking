#!/usr/bin/env bash

# DevOps Assignment 1
# Monitor disk usage against a user-defined threshold.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/diagnostic.log"

log_message() {
    local message="$1"
    mkdir -p "$LOG_DIR" || return 1

    printf '%s | DISK_CHECK | %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$message" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <threshold> [path]"
    echo "Threshold must be an integer between 1 and 100."
}

main() {
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        usage >&2
        return 2
    fi

    local threshold="$1"
    local path="${2:-/}"

    # Validate that the threshold contains only digits.
    if [[ ! "$threshold" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Threshold must be an integer." >&2
        return 2
    fi

    # Convert safely to base 10 and validate the range.
    if [[ ${#threshold} -gt 3 ]]; then
        echo "ERROR: Threshold must be between 1 and 100." >&2
        return 2
    fi

    threshold=$((10#$threshold))

    if (( threshold < 1 || threshold > 100 )); then
        echo "ERROR: Threshold must be between 1 and 100." >&2
        return 2
    fi

    # Validate the supplied path.
    if [[ ! -d "$path" ]]; then
        echo "ERROR: Directory does not exist: $path" >&2
        return 2
    fi

    local usage_percent

    usage_percent=$(df -P "$path" 2>/dev/null | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

    if [[ ! "$usage_percent" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Unable to retrieve disk usage." >&2
        log_message "Failed to retrieve disk usage for path=$path" || true
        return 1
    fi

    echo "=========================================="
    echo "             DISK USAGE CHECK"
    echo "=========================================="
    echo "Path       : $path"
    echo "Usage      : ${usage_percent}%"
    echo "Threshold  : ${threshold}%"

    if (( usage_percent >= threshold )); then
        echo "Status     : WARNING - Threshold reached or exceeded"
        log_message "WARNING path=$path usage=${usage_percent}% threshold=${threshold}%" || true
        return 1
    else
        echo "Status     : OK - Disk usage below threshold"
        log_message "OK path=$path usage=${usage_percent}% threshold=${threshold}%" || true
        return 0
    fi
}

main "$@"
