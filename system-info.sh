#!/usr/bin/env bash

# DevOps Assignment 1
# Collect and display Linux system information.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/diagnostic.log"

log_message() {
    local message="$1"
    mkdir -p "$LOG_DIR" || return 1
    printf '%s | SYSTEM_INFO | %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$message" >> "$LOG_FILE"
}

get_os_name() {
    if [[ -r /etc/os-release ]]; then
        (
            . /etc/os-release
            printf '%s\n' "${PRETTY_NAME:-Unknown}"
        )
    else
        printf '%s\n' "Unknown"
    fi
}

main() {
    log_message "System information collection started" || {
        echo "ERROR: Unable to write diagnostic log" >&2
        return 1
    }

    echo "=========================================="
    echo "          SYSTEM INFORMATION"
    echo "=========================================="

    printf 'Hostname          : %s\n' "$(hostname)"
    printf 'Current User      : %s\n' "$(id -un)"
    printf 'Date and Time     : %s\n' "$(date)"
    printf 'Operating System  : %s\n' "$(get_os_name)"
    printf 'Kernel Version    : %s\n' "$(uname -r)"
    printf 'Uptime            : %s\n' "$(uptime -p)"
    printf 'CPU Information   : %s\n' \
        "$(lscpu | awk -F: '/^Model name:/ {sub(/^[ \t]+/, "", $2); print $2; exit}')"
    printf 'CPU Cores         : %s\n' "$(nproc)"
    echo "Memory Information:"
    free -h
    printf 'Working Directory : %s\n' "$PWD"

    echo "=========================================="

    log_message "System information collected successfully"
}

main "$@"
