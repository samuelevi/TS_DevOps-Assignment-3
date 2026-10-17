#!/usr/bin/env bash

set -u

show_help() {
    echo "Usage: app.sh <command> [options]"
    echo
    echo "Commands:"
    echo "  system-info              Show system details"
    echo "  check-host <host>        Check if a host is reachable"
    echo "  check-port <host> <port> Test TCP connection to a port"
    echo "  help                     Show this message"
}

get_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Date: $(date)"
    echo "OS: $(uname -o 2>/dev/null || uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

    echo ""
    echo "=== CPU ==="
    if [ -f /proc/cpuinfo ]; then
        grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //'
        echo "Cores: $(grep -c '^processor' /proc/cpuinfo)"
    fi

    echo ""
    echo "=== Memory ==="
    if command -v free >/dev/null 2>&1; then
        free -h
    fi
}

do_check_host() {
    if [ $# -lt 1 ]; then
        echo "Error: hostname is required" >&2
        echo "Usage: app.sh check-host <host>" >&2
        exit 2
    fi

    local host="$1"
    echo "=== Host Check: $host ==="

    local reachable=0

    if command -v getent >/dev/null 2>&1; then
        local resolved
        resolved=$(getent hosts "$host" 2>/dev/null | awk '{print $1}')
        if [ -n "$resolved" ]; then
            echo "Resolved: $resolved"
        else
            echo "Could not resolve $host"
        fi
    fi

    if command -v ping >/dev/null 2>&1; then
        if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
            echo "Ping: OK"
            reachable=1
        else
            echo "Ping: FAILED"
        fi
    fi

    if command -v ip >/dev/null 2>&1; then
        echo ""
        echo "=== Network Interfaces ==="
        ip -brief addr show 2>/dev/null
    fi

    if [ "$reachable" -eq 0 ]; then
        return 1
    fi
}

do_check_port() {
    if [ $# -lt 2 ]; then
        echo "Error: host and port are required" >&2
        echo "Usage: app.sh check-port <host> <port>" >&2
        exit 2
    fi

    local host="$1"
    local port="$2"

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: port must be a number" >&2
        exit 2
    fi

    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Error: port out of range (1-65535)" >&2
        exit 2
    fi

    echo "=== TCP Check: $host:$port ==="

    if (echo >/dev/tcp/"$host"/"$port") 2>/dev/null; then
        echo "Connection to $host:$port: SUCCESS"
    elif command -v nc >/dev/null 2>&1; then
        if nc -z -w 3 "$host" "$port" 2>/dev/null; then
            echo "Connection to $host:$port: SUCCESS"
        else
            echo "Connection to $host:$port: FAILED"
        fi
    else
        echo "Connection to $host:$port: FAILED"
    fi
}

if [ $# -lt 1 ]; then
    echo "Error: no command provided" >&2
    show_help >&2
    exit 2
fi

cmd="$1"
shift

case "$cmd" in
    system-info)  get_system_info ;;
    check-host)   do_check_host "$@" ;;
    check-port)   do_check_port "$@" ;;
    help)         show_help ;;
    *)
        echo "Error: unknown command '$cmd'" >&2
        show_help >&2
        exit 2
        ;;
esac
