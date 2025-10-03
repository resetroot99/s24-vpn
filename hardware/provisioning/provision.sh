#!/bin/sh

###############################################################################
# Strat24 Secure Access Point - Automated Provisioning Script
# Version: 1.1
# Company: Strat24
# Website: https://strat24.com
#
# Description:
#   Automatically configures GL.iNet Opal router with WireGuard VPN,
#   firewall rules, kill switch, and secure Wi-Fi for Strat24 clients.
#
# Usage:
#   1. Create device.conf with LICENSE_KEY, WIFI_SSID, and WIFI_PASSWORD
#   2. Upload both files to /root/ on the router
#   3. Run: chmod +x /root/provision.sh && /root/provision.sh
#
# Support: support@strat24.com
###############################################################################

set -e

# Configuration
LOG_FILE="/var/log/strat24_provision.log"
CONFIG_FILE="/root/device.conf"
TEMP_CONFIG="/tmp/wireguard_config.conf"

# Strat24 VPN Platform API Endpoint
# IMPORTANT: Update this with your actual Strat24 VPN platform URL
API_ENDPOINT="https://vpn.strat24.com/api/vpn/config"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "--- Starting Strat24 Provisioning Script v1.1 ---"

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log "ERROR: Configuration file not found at $CONFIG_FILE"
    log "Please create device.conf with LICENSE_KEY, WIFI_SSID, and WIFI_PASSWORD"
    exit 1
fi

# Source configuration file
. "$CONFIG_FILE"

# Validate required variables
if [ -z "$LICENSE_KEY" ]; then
    log "ERROR: LICENSE_KEY not set in $CONFIG_FILE"
    exit 1
fi

if [ -z "$WIFI_SSID" ]; then
    log "WARNING: WIFI_SSID not set, using default: Strat24-Secure"
    WIFI_SSID="Strat24-Secure"
fi

if [ -z "$WIFI_PASSWORD" ]; then
    log "ERROR: WIFI_PASSWORD not set in $CONFIG_FILE"
    exit 1
fi

log "Found License Key: $LICENSE_KEY"
log "Wi-Fi SSID: $WIFI_SSID"

# Fetch WireGuard configuration from Strat24 VPN platform
log "Fetching configuration from Strat24 VPN platform..."

HTTP_CODE=$(curl -s -w "%{http_code}" -o "$TEMP_CONFIG" \
    "${API_ENDPOINT}?license=${LICENSE_KEY}&protocol=wireguard&platform=desktop")

if [ "$HTTP_CODE" != "200" ]; then
    log "ERROR: Failed to download WireGuard configuration. HTTP Code: $HTTP_CODE"
    log "Please verify LICENSE_KEY is correct and Strat24 VPN platform is accessible"
    exit 1
fi

log "Successfully downloaded WireGuard configuration from Strat24."

# Parse WireGuard configuration
PRIVATE_KEY=$(grep "PrivateKey" "$TEMP_CONFIG" | cut -d'=' -f2 | tr -d ' ')
ADDRESS=$(grep "Address" "$TEMP_CONFIG" | cut -d'=' -f2 | tr -d ' ')
DNS=$(grep "DNS" "$TEMP_CONFIG" | cut -d'=' -f2 | tr -d ' ')
PUBLIC_KEY=$(grep "PublicKey" "$TEMP_CONFIG" | cut -d'=' -f2 | tr -d ' ')
ENDPOINT=$(grep "Endpoint" "$TEMP_CONFIG" | cut -d'=' -f2 | tr -d ' ')
ALLOWED_IPS=$(grep "AllowedIPs" "$TEMP_CONFIG" | cut -d'=' -f2 | tr -d ' ')

# Validate parsed values
if [ -z "$PRIVATE_KEY" ] || [ -z "$ADDRESS" ] || [ -z "$PUBLIC_KEY" ] || [ -z "$ENDPOINT" ]; then
    log "ERROR: Failed to parse WireGuard configuration. Config file may be invalid."
    exit 1
fi

log "Successfully parsed configuration fields."

# Split endpoint into host and port
ENDPOINT_HOST=$(echo "$ENDPOINT" | cut -d':' -f1)
ENDPOINT_PORT=$(echo "$ENDPOINT" | cut -d':' -f2)

log "VPN Server: $ENDPOINT"

# Configure WireGuard interface using UCI
log "Applying configuration using UCI..."

# Remove existing wg0 interface if present
uci -q delete network.wg0 2>/dev/null || true
uci -q delete network.wgclient 2>/dev/null || true

# Create WireGuard interface
uci set network.wg0='interface'
uci set network.wg0.proto='wireguard'
uci set network.wg0.private_key="$PRIVATE_KEY"
uci add_list network.wg0.addresses="$ADDRESS"

# Set DNS if provided
if [ -n "$DNS" ]; then
    uci set network.wg0.dns="$DNS"
fi

# Create WireGuard peer
uci set network.wgclient='wireguard_wg0'
uci set network.wgclient.public_key="$PUBLIC_KEY"
uci set network.wgclient.endpoint_host="$ENDPOINT_HOST"
uci set network.wgclient.endpoint_port="$ENDPOINT_PORT"
uci set network.wgclient.route_allowed_ips='1'
uci set network.wgclient.persistent_keepalive='25'

# Set allowed IPs (default to all traffic)
if [ -z "$ALLOWED_IPS" ]; then
    ALLOWED_IPS="0.0.0.0/0"
fi
uci set network.wgclient.allowed_ips="$ALLOWED_IPS"

# Commit network configuration
uci commit network

log "WireGuard interface configured successfully."

# Configure firewall and kill switch
log "Configuring firewall and kill switch..."

# Remove existing VPN zone if present
uci -q delete firewall.vpn_zone 2>/dev/null || true
uci -q delete firewall.lan_to_vpn 2>/dev/null || true

# Create VPN firewall zone
uci set firewall.vpn_zone='zone'
uci set firewall.vpn_zone.name='vpn'
uci set firewall.vpn_zone.input='REJECT'
uci set firewall.vpn_zone.output='ACCEPT'
uci set firewall.vpn_zone.forward='REJECT'
uci set firewall.vpn_zone.masq='1'
uci set firewall.vpn_zone.mtu_fix='1'
uci add_list firewall.vpn_zone.network='wg0'

# Allow LAN to VPN forwarding
uci set firewall.lan_to_vpn='forwarding'
uci set firewall.lan_to_vpn.src='lan'
uci set firewall.lan_to_vpn.dest='vpn'

# Implement kill switch by removing LAN to WAN forwarding
# This ensures all traffic MUST go through VPN
FORWARDING_COUNT=$(uci show firewall | grep -c "firewall.@forwarding\[" || true)
for i in $(seq 0 $((FORWARDING_COUNT - 1))); do
    SRC=$(uci -q get firewall.@forwarding[$i].src || echo "")
    DEST=$(uci -q get firewall.@forwarding[$i].dest || echo "")
    if [ "$SRC" = "lan" ] && [ "$DEST" = "wan" ]; then
        uci delete firewall.@forwarding[$i]
        log "Removed LAN to WAN forwarding (kill switch enabled)"
        break
    fi
done

# Commit firewall configuration
uci commit firewall

log "Firewall and kill switch configured."

# Configure secure Wi-Fi network
log "Configuring secure Wi-Fi network..."

# Configure wireless SSID and password
# Note: This assumes standard GL.iNet wireless configuration
# Adjust if your device has different wireless interface names

# Configure 2.4GHz radio
if uci -q get wireless.@wifi-iface[0] >/dev/null 2>&1; then
    uci set wireless.@wifi-iface[0].ssid="$WIFI_SSID"
    uci set wireless.@wifi-iface[0].key="$WIFI_PASSWORD"
    uci set wireless.@wifi-iface[0].encryption='psk2'
    uci set wireless.radio0.disabled='0'
fi

# Configure 5GHz radio
if uci -q get wireless.@wifi-iface[1] >/dev/null 2>&1; then
    uci set wireless.@wifi-iface[1].ssid="$WIFI_SSID"
    uci set wireless.@wifi-iface[1].key="$WIFI_PASSWORD"
    uci set wireless.@wifi-iface[1].encryption='psk2'
    uci set wireless.radio1.disabled='0'
fi

uci commit wireless

log "Wi-Fi configuration applied: SSID=$WIFI_SSID"

# Configure DNS settings
log "Configuring DNS settings..."

if [ -n "$DNS" ]; then
    # Use VPN-provided DNS
    uci set dhcp.@dnsmasq[0].noresolv='1'
    uci -q delete dhcp.@dnsmasq[0].server
    uci add_list dhcp.@dnsmasq[0].server="$DNS"
    uci commit dhcp
    log "Using VPN DNS: $DNS"
else
    log "No DNS specified, using default"
fi

# Commit all UCI changes
log "Committing UCI changes..."
uci commit

# Restart network, firewall, and wireless services
log "Restarting network, firewall, and wireless services..."
/etc/init.d/network restart
sleep 5
/etc/init.d/firewall restart
sleep 2
wifi reload

# Wait for VPN connection to establish
log "Waiting for VPN connection to establish..."
sleep 10

# Verify VPN tunnel is up
if ip link show wg0 | grep -q "state UP"; then
    log "SUCCESS: VPN tunnel is UP and running!"
    log "Strat24 Secure Access Point is ready for deployment."
else
    log "WARNING: VPN tunnel may not be established. Please check manually."
    log "Run: wg show"
fi

# Clean up temporary files
rm -f "$TEMP_CONFIG"

log "--- Strat24 Provisioning Script Finished ---"
log "Device is now configured as a Strat24 Secure Access Point."
log "Support: support@strat24.com | https://strat24.com"

exit 0
