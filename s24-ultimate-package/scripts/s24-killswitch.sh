#!/bin/sh
# S24 Kill Switch Script
# Global and per-device internet kill switches

LOG_FILE="/var/log/s24-killswitch.log"
KILLSWITCH_STATE="/tmp/s24_killswitch_enabled"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Enable global kill switch
enable_global() {
    log "Enabling global kill switch"
    
    # Block all outgoing traffic except VPN
    iptables -I FORWARD -o eth0 -j DROP 2>&1 | tee -a "$LOG_FILE"
    iptables -I FORWARD -o wg+ -j ACCEPT 2>&1 | tee -a "$LOG_FILE"
    
    # Allow router itself to access internet
    iptables -I OUTPUT -o eth0 -j ACCEPT 2>&1 | tee -a "$LOG_FILE"
    
    echo "1" > "$KILLSWITCH_STATE"
    log "Global kill switch enabled"
}

# Disable global kill switch
disable_global() {
    log "Disabling global kill switch"
    
    # Remove kill switch rules
    iptables -D FORWARD -o eth0 -j DROP 2>/dev/null
    iptables -D FORWARD -o wg+ -j ACCEPT 2>/dev/null
    
    echo "0" > "$KILLSWITCH_STATE"
    log "Global kill switch disabled"
}

# Block specific device (pause internet)
block_device() {
    local device_ip=$1
    if [ -z "$device_ip" ]; then
        echo "Error: No device IP specified"
        return 1
    fi
    
    log "Blocking device: $device_ip"
    
    # Block device from accessing internet
    iptables -I FORWARD -s "$device_ip" -j DROP 2>&1 | tee -a "$LOG_FILE"
    iptables -I FORWARD -d "$device_ip" -j DROP 2>&1 | tee -a "$LOG_FILE"
    
    log "Device $device_ip blocked"
}

# Unblock specific device
unblock_device() {
    local device_ip=$1
    if [ -z "$device_ip" ]; then
        echo "Error: No device IP specified"
        return 1
    fi
    
    log "Unblocking device: $device_ip"
    
    # Remove block rules
    iptables -D FORWARD -s "$device_ip" -j DROP 2>/dev/null
    iptables -D FORWARD -d "$device_ip" -j DROP 2>/dev/null
    
    log "Device $device_ip unblocked"
}

# Check kill switch status
check_status() {
    if [ -f "$KILLSWITCH_STATE" ] && [ "$(cat $KILLSWITCH_STATE)" = "1" ]; then
        echo "Global Kill Switch: Enabled"
    else
        echo "Global Kill Switch: Disabled"
    fi
    
    echo ""
    echo "Blocked devices:"
    iptables -L FORWARD -v -n | grep DROP | grep -v "0.0.0.0/0"
}

# Main command handler
case "$1" in
    enable)
        enable_global
        ;;
    disable)
        disable_global
        ;;
    block)
        block_device "$2"
        ;;
    unblock)
        unblock_device "$2"
        ;;
    status)
        check_status
        ;;
    *)
        echo "Usage: $0 {enable|disable|block|unblock|status} [device_ip]"
        exit 1
        ;;
esac

