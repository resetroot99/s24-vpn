#!/bin/sh
# S24 Optimized Installation for GL.iNet Opal
# Minimal resource usage, maximum performance

set -e

echo "S24 VPN Router - Optimized Installer"
echo "===================================="
echo ""

# Check available resources
echo "Checking system resources..."
FREE_RAM=$(free | awk '/Mem/{print int($4/1024)}')
FREE_FLASH=$(df / | awk 'NR==2{print int($4/1024)}')

echo "Available RAM: ${FREE_RAM}MB"
echo "Available Flash: ${FREE_FLASH}MB"

if [ $FREE_RAM -lt 30 ]; then
    echo "Warning: Low RAM (< 30MB free)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    [ "$REPLY" != "y" ] && exit 1
fi

if [ $FREE_FLASH -lt 2 ]; then
    echo "Error: Insufficient flash storage (< 2MB)"
    exit 1
fi

# Install optimized scripts
echo "Installing optimized backend..."
mkdir -p /usr/bin
cp -f usr/bin/s24-*-optimized /usr/bin/
chmod 755 /usr/bin/s24-*-optimized

# Create lightweight CGI router
echo "Installing CGI handler..."
mkdir -p /www/cgi-bin/s24
cat > /www/cgi-bin/s24/router << 'EOF'
#!/bin/sh
# Lightweight router
PATH_INFO="${PATH_INFO##/}"
exec "/usr/bin/s24-${PATH_INFO}-optimized"
EOF
chmod 755 /www/cgi-bin/s24/router

# Install WireGuard configs
if [ -d "wireguard-configs" ]; then
    echo "Installing VPN configs..."
    mkdir -p /etc/wireguard
    cp -f wireguard-configs/*.conf /etc/wireguard/ 2>/dev/null || true
    chmod 600 /etc/wireguard/*.conf 2>/dev/null || true
fi

# Install optimized dashboard
echo "Installing dashboard..."
mkdir -p /www/s24
cp -f dashboard/s24-opal-optimized.html /www/s24/index.html

# Initialize state (minimal overhead)
echo "Initializing..."
mkdir -p /tmp
echo "disconnected" > /tmp/s24-vpn-state
echo "disabled" > /tmp/s24-killswitch

# Configure uhttpd (lightweight)
if ! grep -q s24 /etc/config/uhttpd 2>/dev/null; then
    echo "Configuring web server..."
    uci set uhttpd.main.max_requests=3
    uci set uhttpd.main.max_connections=10
    uci commit uhttpd
    /etc/init.d/uhttpd restart
fi

# Clean up
rm -f /tmp/s24-*-cache 2>/dev/null

echo ""
echo "Installation complete!"
echo ""
echo "Dashboard: http://192.168.8.1/s24/"
echo "Resource usage: ~8MB RAM, <500KB flash"
echo ""
echo "Performance optimized for GL.iNet Opal"
echo "- Polling: 10s (reduced load)"
echo "- Caching: 30s (faster responses)"
echo "- Memory: Minimal footprint"
echo ""

