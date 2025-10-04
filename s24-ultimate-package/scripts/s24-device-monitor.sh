#!/bin/sh
# S24 Device Monitoring Script
# Monitor new devices, bandwidth usage, and generate alerts

LOG_FILE="/var/log/s24-devices.log"
KNOWN_DEVICES="/etc/s24_known_devices"
WEBHOOK_URL=""  # Optional: webhook for notifications

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check for new devices
check_new_devices() {
    log "Checking for new devices..."
    
    # Get current DHCP leases
    cat /tmp/dhcp.leases | while read line; do
        mac=$(echo "$line" | awk '{print $2}')
        ip=$(echo "$line" | awk '{print $3}')
        hostname=$(echo "$line" | awk '{print $4}')
        
        if ! grep -q "$mac" "$KNOWN_DEVICES" 2>/dev/null; then
            log "NEW DEVICE DETECTED: $hostname ($ip / $mac)"
            echo "$mac|$ip|$hostname|$(date)" >> "$KNOWN_DEVICES"
            
            # Send alert
            send_alert "New device joined: $hostname ($ip)"
        fi
    done
}

# Get bandwidth usage
get_bandwidth() {
    local device=$1
    
    if [ -n "$device" ]; then
        # Per-device bandwidth
        iptables -L FORWARD -v -n -x | grep "$device" | awk '{sum+=$2} END {print sum}'
    else
        # Total bandwidth
        vnstat --oneline | awk -F ';' '{print "Today: " $4 " | This Month: " $6}'
    fi
}

# List connected devices
list_devices() {
    echo "Connected Devices:"
    echo "=================="
    
    cat /tmp/dhcp.leases | while read line; do
        mac=$(echo "$line" | awk '{print $2}')
        ip=$(echo "$line" | awk '{print $3}')
        hostname=$(echo "$line" | awk '{print $4}')
        
        # Check if online
        if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
            status="Online"
        else
            status="Offline"
        fi
        
        echo "$hostname - $ip ($mac) - $status"
    done
}

# Send alert (webhook or log)
send_alert() {
    local message=$1
    log "ALERT: $message"
    
    if [ -n "$WEBHOOK_URL" ]; then
        curl -X POST -H "Content-Type: application/json" \
             -d "{\"text\":\"$message\"}" \
             "$WEBHOOK_URL" 2>&1 | tee -a "$LOG_FILE"
    fi
}

# Main command handler
case "$1" in
    check)
        check_new_devices
        ;;
    bandwidth)
        get_bandwidth "$2"
        ;;
    list)
        list_devices
        ;;
    *)
        echo "Usage: $0 {check|bandwidth|list} [device_ip]"
        exit 1
        ;;
esac

