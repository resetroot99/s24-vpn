#!/bin/sh
# S24 VPN Control Script
# Manages VPN connections, server switching, and failover

VPN_CONFIGS="/etc/wireguard"
CURRENT_SERVER_FILE="/tmp/s24_current_server"
LOG_FILE="/var/log/s24-vpn.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Start VPN with specific server
start_vpn() {
    local server=$1
    if [ -z "$server" ]; then
        server=$(cat "$CURRENT_SERVER_FILE" 2>/dev/null || echo "nl1")
    fi
    
    log "Starting VPN with server: $server"
    wg-quick up "$VPN_CONFIGS/${server}.conf" 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "$server" > "$CURRENT_SERVER_FILE"
        log "VPN started successfully"
        return 0
    else
        log "VPN start failed"
        return 1
    fi
}

# Stop VPN
stop_vpn() {
    local server=$(cat "$CURRENT_SERVER_FILE" 2>/dev/null)
    if [ -n "$server" ]; then
        log "Stopping VPN: $server"
        wg-quick down "$VPN_CONFIGS/${server}.conf" 2>&1 | tee -a "$LOG_FILE"
    fi
}

# Switch VPN server
switch_server() {
    local new_server=$1
    if [ -z "$new_server" ]; then
        echo "Error: No server specified"
        return 1
    fi
    
    log "Switching to server: $new_server"
    stop_vpn
    sleep 2
    start_vpn "$new_server"
}

# Check VPN status
check_status() {
    if wg show | grep -q interface; then
        echo "VPN: Active"
        wg show
        return 0
    else
        echo "VPN: Inactive"
        return 1
    fi
}

# VPN failover - test servers and switch if current fails
failover() {
    local servers="nl1 ca3 us1 th1"
    local current=$(cat "$CURRENT_SERVER_FILE" 2>/dev/null)
    
    # Test current server
    if ping -c 3 -W 5 1.1.1.1 > /dev/null 2>&1; then
        log "Current VPN server working"
        return 0
    fi
    
    log "Current VPN failed, trying failover..."
    
    # Try each server
    for server in $servers; do
        if [ "$server" = "$current" ]; then
            continue
        fi
        
        log "Trying server: $server"
        switch_server "$server"
        sleep 5
        
        if ping -c 3 -W 5 1.1.1.1 > /dev/null 2>&1; then
            log "Failover successful to: $server"
            return 0
        fi
    done
    
    log "All VPN servers failed - enabling kill switch"
    /usr/bin/s24-killswitch.sh enable
    return 1
}

# Main command handler
case "$1" in
    start)
        start_vpn "$2"
        ;;
    stop)
        stop_vpn
        ;;
    switch)
        switch_server "$2"
        ;;
    status)
        check_status
        ;;
    failover)
        failover
        ;;
    *)
        echo "Usage: $0 {start|stop|switch|status|failover} [server]"
        echo "Servers: nl1, ca3, us1, th1"
        exit 1
        ;;
esac

