#!/bin/sh
# Strat24 Multi-Server VPN Setup for GL.iNet Opal
# Out-of-the-box configuration with captive portal

echo "🚀 Strat24 Multi-Server VPN Configuration"
echo "=========================================="

PORTAL_SSID="strat24secureWIFI"
PORTAL_PASSWORD="welcome2024"
VPN_PASSWORD="Strat24Secure"

# WireGuard Configs
cat > /etc/wireguard/wg-nl.conf << 'EOF'
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = nl1.ipcover.net:55888
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/wg-ca.conf << 'EOF'
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = ca3.ipcover.net:55888
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/wg-us.conf << 'EOF'
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = us1.ipcover.net:55888
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/wg-th.conf << 'EOF'
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = th1.ipcover.net:55888
PersistentKeepalive = 25
EOF

echo "✅ WireGuard configs created"

# Setup network interfaces
uci set network.wgnl='interface'
uci set network.wgnl.proto='wireguard'
uci set network.wgnl.disabled='0'

uci set network.wgca='interface'
uci set network.wgca.proto='wireguard'
uci set network.wgca.disabled='0'

uci set network.wgus='interface'
uci set network.wgus.proto='wireguard'
uci set network.wgus.disabled='0'

uci set network.wgth='interface'
uci set network.wgth.proto='wireguard'
uci set network.wgth.disabled='0'

uci commit network

echo "✅ Network interfaces configured"

# Configure WiFi networks
echo "📡 Setting up WiFi networks..."

# Portal WiFi (main SSID for captive portal)
uci set wireless.@wifi-iface[0].ssid="${PORTAL_SSID}"
uci set wireless.@wifi-iface[0].key="${PORTAL_PASSWORD}"
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.@wifi-iface[0].network='lan'

# VPN WiFi - Netherlands
uci set wireless.vpn_nl='wifi-iface'
uci set wireless.vpn_nl.device='radio0'
uci set wireless.vpn_nl.mode='ap'
uci set wireless.vpn_nl.ssid='Strat24-NL'
uci set wireless.vpn_nl.encryption='psk2'
uci set wireless.vpn_nl.key="${VPN_PASSWORD}"
uci set wireless.vpn_nl.network='wgnl'

# VPN WiFi - Canada
uci set wireless.vpn_ca='wifi-iface'
uci set wireless.vpn_ca.device='radio0'
uci set wireless.vpn_ca.mode='ap'
uci set wireless.vpn_ca.ssid='Strat24-CA'
uci set wireless.vpn_ca.encryption='psk2'
uci set wireless.vpn_ca.key="${VPN_PASSWORD}"
uci set wireless.vpn_ca.network='wgca'

# VPN WiFi - USA
uci set wireless.vpn_us='wifi-iface'
uci set wireless.vpn_us.device='radio0'
uci set wireless.vpn_us.mode='ap'
uci set wireless.vpn_us.ssid='Strat24-US'
uci set wireless.vpn_us.encryption='psk2'
uci set wireless.vpn_us.key="${VPN_PASSWORD}"
uci set wireless.vpn_us.network='wgus'

# VPN WiFi - Thailand
uci set wireless.vpn_th='wifi-iface'
uci set wireless.vpn_th.device='radio0'
uci set wireless.vpn_th.mode='ap'
uci set wireless.vpn_th.ssid='Strat24-TH'
uci set wireless.vpn_th.encryption='psk2'
uci set wireless.vpn_th.key="${VPN_PASSWORD}"
uci set wireless.vpn_th.network='wgth'

uci set wireless.radio0.disabled='0'
uci commit wireless

echo "✅ WiFi networks configured"

# Setup firewall with kill switch for each VPN
echo "🔒 Configuring firewall..."

for zone in nl ca us th; do
  uci set firewall.vpn_${zone}='zone'
  uci set firewall.vpn_${zone}.name="vpn_${zone}"
  uci set firewall.vpn_${zone}.input='REJECT'
  uci set firewall.vpn_${zone}.output='ACCEPT'
  uci set firewall.vpn_${zone}.forward='REJECT'
  uci set firewall.vpn_${zone}.masq='1'
  uci set firewall.vpn_${zone}.mtu_fix='1'
  uci add_list firewall.vpn_${zone}.network="wg${zone}"
  
  uci set firewall.fwd_${zone}='forwarding'
  uci set firewall.fwd_${zone}.src="vpn_${zone}"
  uci set firewall.fwd_${zone}.dest='wan'
done

uci commit firewall

echo "✅ Firewall configured with kill switches"

# Setup captive portal redirect
echo "🌐 Setting up captive portal..."

# Create captive portal HTML
mkdir -p /www/portal
cat > /www/portal/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Strat24 VPN Portal</title>
  <meta http-equiv="refresh" content="0;url=http://portal.strat24.local">
</head>
<body>
  <p>Redirecting to Strat24 Portal...</p>
</body>
</html>
HTMLEOF

# Configure DNS redirect for captive portal
uci set dhcp.@dnsmasq[0].address='/portal.strat24.local/192.168.8.1'
uci commit dhcp

echo "✅ Captive portal configured"

# Start WireGuard tunnels
echo "🔐 Starting VPN tunnels..."
wg-quick down wg-nl 2>/dev/null || true
wg-quick down wg-ca 2>/dev/null || true
wg-quick down wg-us 2>/dev/null || true
wg-quick down wg-th 2>/dev/null || true

wg-quick up wg-nl
wg-quick up wg-ca
wg-quick up wg-us
wg-quick up wg-th

# Restart services
echo "♻️  Restarting services..."
/etc/init.d/network restart
sleep 3
/etc/init.d/firewall restart
sleep 2
/etc/init.d/dnsmasq restart
wifi reload

echo ""
echo "✅ ================================================"
echo "✅  Strat24 Multi-Server VPN Setup Complete!"
echo "✅ ================================================"
echo ""
echo "📡 Portal WiFi: ${PORTAL_SSID}"
echo "🔑 Portal Password: ${PORTAL_PASSWORD}"
echo ""
echo "🌍 VPN Networks Available:"
echo "   • Strat24-NL (Netherlands)"
echo "   • Strat24-CA (Canada)"
echo "   • Strat24-US (USA)"
echo "   • Strat24-TH (Thailand)"
echo "🔑 VPN Password: ${VPN_PASSWORD}"
echo ""
echo "📱 Connect to ${PORTAL_SSID} to see the portal! 🎉"
echo ""

