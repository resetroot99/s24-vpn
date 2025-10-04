#!/bin/sh
# S24 Backend Installation Script - Production

set -e

echo "S24 Backend Installer"
echo "====================="
echo ""

# Check if running on OpenWRT
if [ ! -f "/etc/openwrt_release" ]; then
    echo "Warning: Not running on OpenWRT"
    echo "This script is designed for GL.iNet routers"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    [ "$REPLY" != "y" ] && exit 1
fi

# Install backend scripts
echo "[1/5] Installing backend scripts..."
mkdir -p /usr/bin
cp -f usr/bin/s24-* /usr/bin/
chmod 755 /usr/bin/s24-*

# Install CGI handler
echo "[2/5] Installing CGI handler..."
mkdir -p /www/cgi-bin/s24
cp -f cgi-bin/s24-api.sh /www/cgi-bin/s24/
chmod 755 /www/cgi-bin/s24/s24-api.sh

# Install WireGuard configs
echo "[3/5] Installing WireGuard configurations..."
if [ -d "wireguard-configs" ]; then
    mkdir -p /etc/wireguard
    cp -f wireguard-configs/*.conf /etc/wireguard/ 2>/dev/null || true
    chmod 600 /etc/wireguard/*.conf 2>/dev/null || true
    echo "✓ WireGuard configs installed"
else
    echo "⚠ No WireGuard configs found (install manually)"
fi

# Configure web server
echo "[4/5] Configuring web server..."
if ! grep -q "/cgi-bin/s24" /etc/config/uhttpd 2>/dev/null; then
    cat >> /etc/config/uhttpd << 'UCIEOF'

config uhttpd 's24'
	list listen_http '0.0.0.0:80'
	option home '/www'
	option cgi_prefix '/cgi-bin/s24'
UCIEOF
    /etc/init.d/uhttpd restart
fi

# Initialize state
echo "[5/5] Initializing state..."
mkdir -p /tmp
echo "disconnected" > /tmp/s24-vpn-state
echo "disabled" > /tmp/s24-killswitch

echo ""
echo "✓ Installation complete!"
echo ""
echo "Dashboard: http://192.168.8.1/s24/"
echo "API: http://192.168.8.1/cgi-bin/s24/"
echo ""
