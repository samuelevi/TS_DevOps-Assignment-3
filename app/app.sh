#!/usr/bin/env bash
set -u

show_help() {
    echo "Usage: app.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  system-info              Display system information"
    echo "  check-host <host>        Resolve and check a host"
    echo "  check-port <host> <port> Validate port and check TCP connectivity"
    echo "  help                     Display this usage information"
}

cmd_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Current User: $(whoami)"
    echo "Date/Time: $(date)"
    echo "Operating System: $(uname -o 2>/dev/null || uname -s)"
    echo "Kernel Version: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo ""
    echo "=== CPU Information ==="
    if [ -f /proc/cpuinfo ]; then
        grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //'
        echo "CPU Cores: $(grep -c '^processor' /proc/cpuinfo)"
    fi
    echo ""
    echo "=== Memory Information ==="
    if command -v free >/dev/null 2>&1; then
        free -h
    fi
}

cmd_check_host() {
    if [ $# -lt 1 ]; then
        echo "Error: Host argument required." >&2
        echo "Usage: app.sh check-host <host>" >&2
        exit 2
    fi

    local host="$1"
    echo "=== Host Check: $host ==="

    if command -v getent >/dev/null 2>&1; then
        resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}')
        if [ -n "$resolved" ]; then
            echo "Resolved: $resolved"
        else
            echo "Could not resolve: $host"
        fi
    fi

    if command -v ping >/dev/null 2>&1; then
        if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
            echo "Ping: SUCCESS"
        else
            echo "Ping: FAILED"
        fi
    fi

    if command -v ip >/dev/null 2>&1; then
        echo ""
        echo "=== Network Interfaces ==="
        ip -brief addr show 2>/dev/null
    fi
}

cmd_check_port() {
    if [ $# -lt 2 ]; then
        echo "Error: Host and port arguments required." >&2
        echo "Usage: app.sh check-port <host> <port>" >&2
        exit 2
    fi

    local host="$1"
    local port="$2"

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a numeric value." >&2
        exit 2
    fi

    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Error: Port must be between 1 and 65535." >&2
        exit 2
    fi

    echo "=== TCP Port Check: $host:$port ==="
    if (echo >/dev/tcp/"$host"/"$port") 2>/dev/null; then
        echo "TCP connection to $host:$port: SUCCESS"
    elif command -v nc >/dev/null 2>&1; then
        if nc -z -w 3 "$host" "$port" 2>/dev/null; then
            echo "TCP connection to $host:$port: SUCCESS"
        else
            echo "TCP connection to $host:$port: FAILED"
        fi
    else
        echo "TCP connection to $host:$port: FAILED"
    fi
}

if [ $# -lt 1 ]; then
    echo "Error: No command provided." >&2
    show_help >&2
    exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
    system-info)
        cmd_system_info
        ;;
    check-host)
        cmd_check_host "$@"
        ;;
    check-port)
        cmd_check_port "$@"
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'" >&2
        show_help >&2
        exit 2
        ;;
esac
