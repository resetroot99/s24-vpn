#!/bin/sh
# S24 Guest WiFi Script
# Create guest WiFi with QR code and auto-expire

LOG_FILE="/var/log/s24-guest.log"
GUEST_SSID="S24-Guest"
GUEST_PASSWORD=""
QR_FILE="/tmp/s24_guest_qr.txt"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Generate random password
generate_password() {
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12
}

# Create guest network
create_guest() {
    local duration=${1:-3600}  # Default 1 hour
    
    GUEST_PASSWORD=$(generate_password)
    
    log "Creating guest network: $GUEST_SSID"
    
    # Configure guest WiFi
    uci set wireless.guest=wifi-iface
    uci set wireless.guest.device='radio0'
    uci set wireless.guest.network='guest'
    uci set wireless.guest.mode='ap'
    uci set wireless.guest.ssid="$GUEST_SSID"
    uci set wireless.guest.encryption='psk2'
    uci set wireless.guest.key="$GUEST_PASSWORD"
    uci set wireless.guest.isolate='1'
    uci commit wireless
    
    # Configure guest network
    uci set network.guest=interface
    uci set network.guest.proto='static'
    uci set network.guest.ipaddr='192.168.9.1'
    uci set network.guest.netmask='255.255.255.0'
    uci commit network
    
    # Reload
    wifi reload
    /etc/init.d/network reload
    
    # Generate QR code text
    echo "WIFI:T:WPA;S:$GUEST_SSID;P:$GUEST_PASSWORD;;" > "$QR_FILE"
    
    # Schedule auto-expire
    echo "/usr/bin/s24-guest-wifi.sh disable" | at now + $duration seconds
    
    log "Guest network created. Password: $GUEST_PASSWORD"
    echo ""
    echo "Guest WiFi Created!"
    echo "==================="
    echo "SSID: $GUEST_SSID"
    echo "Password: $GUEST_PASSWORD"
    echo "Auto-expires in: $((duration / 3600)) hours"
    echo ""
    echo "QR Code: $QR_FILE"
}

# Disable guest network
disable_guest() {
    log "Disabling guest network"
    
    uci delete wireless.guest
    uci commit wireless
    
    uci delete network.guest
    uci commit network
    
    wifi reload
    /etc/init.d/network reload
    
    rm -f "$QR_FILE"
    
    log "Guest network disabled"
}

# Show guest info
show_info() {
    if uci get wireless.guest.ssid >/dev/null 2>&1; then
        echo "Guest WiFi Active"
        echo "=================="
        echo "SSID: $(uci get wireless.guest.ssid)"
        echo "Password: $(uci get wireless.guest.key)"
        echo "QR Code: $QR_FILE"
    else
        echo "Guest WiFi: Inactive"
    fi
}

# Main command handler
case "$1" in
    create)
        create_guest "$2"
        ;;
    disable)
        disable_guest
        ;;
    info)
        show_info
        ;;
    *)
        echo "Usage: $0 {create|disable|info} [duration_in_seconds]"
        exit 1
        ;;
esac

