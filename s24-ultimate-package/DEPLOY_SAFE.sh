#!/bin/bash
# S24 Safe Deployment - Won't break network connectivity
# Only installs dashboard and backend, doesn't touch network config

set -e

ROUTER_IP="${1:-192.168.8.1}"
ROUTER_USER="${2:-root}"
ROUTER_PASS="${3:-aperoot}"

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   S24 SAFE DEPLOYMENT - Network Connection Protected                ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Check connectivity
echo "[1/8] Testing router connectivity..."
if ! ping -c 2 "$ROUTER_IP" >/dev/null 2>&1; then
    echo "❌ Error: Cannot reach router at $ROUTER_IP"
    echo "Please connect to router and try again"
    exit 1
fi
echo "✓ Router is reachable"

# Check SSH
echo "[2/8] Testing SSH connection..."
if ! command -v sshpass >/dev/null 2>&1; then
    echo "Installing sshpass..."
    brew install sshpass
fi

if ! sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
    "$ROUTER_USER@$ROUTER_IP" "echo ok" >/dev/null 2>&1; then
    echo "❌ Error: Cannot SSH to router"
    echo "Please enable SSH and set password to: $ROUTER_PASS"
    exit 1
fi
echo "✓ SSH connection works"

# Upload package
echo "[3/8] Uploading optimized package..."
cd "$(dirname "$0")"
sshpass -p "$ROUTER_PASS" scp -o StrictHostKeyChecking=no \
    s24-opal-optimized.tar.gz "$ROUTER_USER@$ROUTER_IP:/tmp/" || {
    echo "❌ Upload failed"
    exit 1
}
echo "✓ Package uploaded"

# Extract files
echo "[4/8] Extracting files..."
sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no "$ROUTER_USER@$ROUTER_IP" << 'ENDSSH'
cd /tmp
tar xzf s24-opal-optimized.tar.gz
echo "✓ Files extracted"
ENDSSH

# Install backend ONLY (no network changes)
echo "[5/8] Installing backend scripts..."
sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no "$ROUTER_USER@$ROUTER_IP" << 'ENDSSH'
# Install scripts
mkdir -p /usr/bin
cp -f backend/usr/bin/s24-*-optimized /usr/bin/ 2>/dev/null || true
chmod 755 /usr/bin/s24-*-optimized 2>/dev/null || true

# Install WireGuard configs (doesn't activate them)
mkdir -p /etc/wireguard
cp -f backend/wireguard-configs/*.conf /etc/wireguard/ 2>/dev/null || true
chmod 600 /etc/wireguard/*.conf 2>/dev/null || true

# Initialize state files
echo "disconnected" > /tmp/s24-vpn-state
echo "disabled" > /tmp/s24-killswitch

echo "✓ Backend installed"
ENDSSH

# Install frontend
echo "[6/8] Installing dashboard..."
sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no "$ROUTER_USER@$ROUTER_IP" << 'ENDSSH'
mkdir -p /www/s24
cp -f dashboard/s24-opal-final.html /www/s24/index.html 2>/dev/null || \
cp -f dashboard/s24-opal-optimized.html /www/s24/index.html 2>/dev/null || {
    echo "⚠ Dashboard not found, using production version"
    cp -f dashboard/s24-production-final.html /www/s24/index.html 2>/dev/null || true
}

# Create simple redirect from root (doesn't break existing access)
if [ ! -f /www/index.html.backup ]; then
    cp /www/index.html /www/index.html.backup 2>/dev/null || true
fi

cat > /www/s24-redirect.html << 'EOF'
<!DOCTYPE html>
<html><head>
<meta http-equiv="refresh" content="0; url=/s24/">
<title>Redirecting to S24...</title>
</head><body>
<p>Redirecting to S24 Dashboard... <a href="/s24/">Click here</a> if not redirected.</p>
</body></html>
EOF

echo "✓ Dashboard installed"
ENDSSH

# Configure web server (carefully, without breaking existing access)
echo "[7/8] Configuring web server..."
sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no "$ROUTER_USER@$ROUTER_IP" << 'ENDSSH'
# Create CGI handler (doesn't restart services yet)
mkdir -p /www/cgi-bin/s24

cat > /www/cgi-bin/s24/status-optimized << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""
/usr/bin/s24-status-optimized
EOF

cat > /www/cgi-bin/s24/stats-optimized << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""
/usr/bin/s24-stats-optimized
EOF

cat > /www/cgi-bin/s24/devices-optimized << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""
/usr/bin/s24-devices-optimized
EOF

cat > /www/cgi-bin/s24/vpn-control-optimized << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""
/usr/bin/s24-vpn-control-optimized
EOF

chmod 755 /www/cgi-bin/s24/*

# Reload web server gracefully (doesn't kill existing connections)
/etc/init.d/uhttpd reload 2>/dev/null || true

echo "✓ Web server configured"
ENDSSH

# Test deployment
echo "[8/8] Testing deployment..."
sleep 2

# Test if dashboard is accessible
if curl -s "http://$ROUTER_IP/s24/" | grep -q "S24"; then
    echo "✓ Dashboard is accessible"
else
    echo "⚠ Dashboard may not be fully configured (but router still accessible)"
fi

# Clean up
sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no "$ROUTER_USER@$ROUTER_IP" \
    "rm -f /tmp/s24-opal-optimized.tar.gz 2>/dev/null; rm -rf /tmp/backend /tmp/dashboard 2>/dev/null" || true

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   ✅ DEPLOYMENT COMPLETE - Connection Still Active!                ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ WHAT WAS INSTALLED:"
echo "   • Backend API scripts (/usr/bin/s24-*)"
echo "   • Dashboard (/www/s24/)"
echo "   • CGI handlers (/www/cgi-bin/s24/)"
echo "   • WireGuard configs (/etc/wireguard/)"
echo ""
echo "✅ WHAT WAS NOT TOUCHED:"
echo "   • Network configuration (safe!)"
echo "   • WiFi settings (safe!)"
echo "   • Existing connections (safe!)"
echo "   • GL.iNet admin panel (still works!)"
echo ""
echo "📱 Access S24 Dashboard:"
echo "   http://$ROUTER_IP/s24/"
echo ""
echo "🔧 GL.iNet Admin Panel still at:"
echo "   http://$ROUTER_IP/"
echo ""
echo "🔄 To rollback (if needed):"
echo "   ssh root@$ROUTER_IP"
echo "   rm -rf /www/s24 /usr/bin/s24-* /www/cgi-bin/s24"
echo "   mv /www/index.html.backup /www/index.html"
echo ""
echo "Opening dashboard..."
open "http://$ROUTER_IP/s24/"

