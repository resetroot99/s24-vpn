#!/bin/sh
# Strat24 VPN Server Switcher

SERVER=$1

case "$SERVER" in
    nl|ca|us|th)
        echo "Switching to $SERVER..."
        ;;
    *)
        echo "Invalid server"
        exit 1
        ;;
esac

# Stop current VPN
wg-quick down wg0 2>/dev/null
ip link del wg0 2>/dev/null

# Copy selected config
cp /etc/wireguard/${SERVER}1.conf /etc/wireguard/wg0.conf

# Start VPN with wg command
ip link add dev wg0 type wireguard
wg setconf wg0 /etc/wireguard/wg0.conf

# Get IP from config
ADDR=$(grep "^Address" /etc/wireguard/wg0.conf | cut -d= -f2 | tr -d " ")
ip addr add $ADDR dev wg0
ip link set wg0 up

# Set up routing
ip rule del from 192.168.8.0/24 lookup 200 2>/dev/null
ip rule add from 192.168.8.0/24 lookup 200 priority 100
ip route add default dev wg0 table 200

# NAT
iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE 2>/dev/null
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE

# Forwarding
iptables -D FORWARD -i br-lan -o wg0 -j ACCEPT 2>/dev/null
iptables -A FORWARD -i br-lan -o wg0 -j ACCEPT
iptables -D FORWARD -i wg0 -o br-lan -j ACCEPT 2>/dev/null
iptables -A FORWARD -i wg0 -o br-lan -j ACCEPT

echo "VPN switched to $SERVER"

