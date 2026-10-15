#!/usr/bin/env bash

# DevOps Assignment 1
# Network diagnostics and TCP port connectivity.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/diagnostic.log"

log_message() {
    mkdir -p "$LOG_DIR" || return 1
    printf '%s | NETWORK_CHECK | %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <hostname-or-ip> [port]"
}

main() {
    if (( $# < 1 || $# > 2 )); then
        usage >&2
        return 2
    fi

    local host="$1"
    local port="${2:-}"
    local resolved=""
    local result=0

    # Validate hostname/IP input.
    if [[ -z "$host" || "$host" =~ [[:space:]] ||
          "$host" == -* ||
          ! "$host" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
        echo "ERROR: Invalid hostname or IP address." >&2
        return 2
    fi

    # Validate optional TCP port.
    if (( $# == 2 )); then
        if [[ ! "$port" =~ ^[0-9]+$ || ${#port} -gt 5 ]]; then
            echo "ERROR: Port must be a number between 1 and 65535." >&2
            return 2
        fi

        port=$((10#$port))

        if (( port < 1 || port > 65535 )); then
            echo "ERROR: Port must be between 1 and 65535." >&2
            return 2
        fi
    fi

    echo "=========================================="
    echo "             NETWORK CHECK"
    echo "=========================================="
    echo "Target Host : $host"

    # Resolve the hostname or IP address.
    resolved=$(timeout 5 getent ahosts "$host" |
        awk 'NR==1 {print $1}')

    if [[ -z "$resolved" ]]; then
        echo "ERROR: Unable to resolve host: $host" >&2
        log_message "FAIL host=$host DNS resolution failed" || true
        return 1
    fi

    echo "Resolved IP : $resolved"

    # Basic ICMP connectivity test.
    if timeout 5 ping -c 1 -W 2 "$resolved" >/dev/null 2>&1; then
        echo "Ping Status : SUCCESS"
    else
        echo "Ping Status : FAILED or ICMP blocked"
        result=1
    fi

    echo
    echo "Network Interfaces:"
    ip -brief address show

    # Optional TCP port connectivity.
    if (( $# == 2 )); then
        echo
        echo "Checking TCP port: $port"

        if timeout 5 bash -c 'exec 3<>/dev/tcp/$1/$2' \
            _ "$resolved" "$port" 2>/dev/null; then
            echo "TCP Status  : OPEN"
        else
            echo "TCP Status  : CLOSED or unreachable"
            result=1
        fi
    fi

    echo "=========================================="

    log_message "host=$host resolved=$resolved port=${port:-none} result=$result" || true

    return "$result"
}

main "$@"
