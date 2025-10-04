#!/bin/sh
# S24 Privacy Modes Script
# One-touch privacy configurations

LOG_FILE="/var/log/s24-privacy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Home Mode: VPN off + adblock on
home_mode() {
    log "Activating Home Mode"
    
    /usr/bin/s24-vpn-control.sh stop
    /usr/bin/s24-killswitch.sh disable
    /etc/init.d/adblock start
    
    # Show SSID
    uci set wireless.@wifi-iface[0].hidden='0'
    uci commit wireless
    wifi reload
    
    log "Home Mode activated"
}

# Travel Mode: VPN on + kill switch + stealth
travel_mode() {
    log "Activating Travel Mode"
    
    /usr/bin/s24-vpn-control.sh start
    /usr/bin/s24-killswitch.sh enable
    /etc/init.d/adblock start
    
    # Stealth settings
    uci set wireless.@wifi-iface[0].hidden='1'
    uci commit wireless
    
    # Block ICMP
    iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
    
    # Disable UPnP
    /etc/init.d/miniupnpd stop
    
    wifi reload
    
    log "Travel Mode activated"
}

# Coffee Shop Mode: VPN only, SSID hidden
coffee_mode() {
    log "Activating Coffee Shop Mode"
    
    /usr/bin/s24-vpn-control.sh start
    /usr/bin/s24-killswitch.sh disable
    /etc/init.d/adblock start
    
    # Hide SSID
    uci set wireless.@wifi-iface[0].hidden='1'
    uci commit wireless
    wifi reload
    
    log "Coffee Shop Mode activated"
}

# Work Mode: Standard security
work_mode() {
    log "Activating Work Mode"
    
    /usr/bin/s24-vpn-control.sh stop
    /usr/bin/s24-killswitch.sh disable
    /etc/init.d/adblock start
    
    # Show SSID
    uci set wireless.@wifi-iface[0].hidden='0'
    uci commit wireless
    wifi reload
    
    log "Work Mode activated"
}

# Panic Mode: Maximum privacy
panic_mode() {
    log "ACTIVATING PANIC MODE"
    
    /usr/bin/s24-vpn-control.sh start
    /usr/bin/s24-killswitch.sh enable
    /etc/init.d/adblock start
    
    # Stealth settings
    uci set wireless.@wifi-iface[0].hidden='1'
    uci commit wireless
    
    # Block all ICMP
    iptables -A INPUT -p icmp -j DROP
    iptables -A OUTPUT -p icmp -j DROP
    
    # Disable all unnecessary services
    /etc/init.d/miniupnpd stop
    /etc/init.d/dropbear stop
    
    wifi reload
    
    log "PANIC MODE ACTIVATED"
}

# Main command handler
case "$1" in
    home)
        home_mode
        ;;
    travel)
        travel_mode
        ;;
    coffee)
        coffee_mode
        ;;
    work)
        work_mode
        ;;
    panic)
        panic_mode
        ;;
    *)
        echo "Usage: $0 {home|travel|coffee|work|panic}"
        exit 1
        ;;
esac

