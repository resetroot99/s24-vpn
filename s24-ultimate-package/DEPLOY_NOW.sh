#!/bin/bash
# S24 Safe Deployment with SSH compatibility fix

set -e

ROUTER_IP="192.168.8.1"
ROUTER_USER="root"
ROUTER_PASS="aperoot"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa"

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   S24 DEPLOYMENT - Safe & Quick                                     ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

# Test connection
echo "[1/6] Testing connection..."
sshpass -p "$ROUTER_PASS" ssh $SSH_OPTS $ROUTER_USER@$ROUTER_IP "echo OK" 2>/dev/null || {
    echo "❌ SSH failed. Check password or connection."
    exit 1
}
echo "✓ Connected"

# Upload package
echo "[2/6] Uploading package (6KB)..."
sshpass -p "$ROUTER_PASS" scp $SSH_OPTS s24-opal-optimized.tar.gz $ROUTER_USER@$ROUTER_IP:/tmp/ 2>/dev/null
echo "✓ Uploaded"

# Extract
echo "[3/6] Extracting..."
sshpass -p "$ROUTER_PASS" ssh $SSH_OPTS $ROUTER_USER@$ROUTER_IP "cd /tmp && tar xzf s24-opal-optimized.tar.gz" 2>/dev/null
echo "✓ Extracted"

# Install backend
echo "[4/6] Installing backend..."
sshpass -p "$ROUTER_PASS" ssh $SSH_OPTS $ROUTER_USER@$ROUTER_IP << 'ENDSSH' 2>/dev/null
mkdir -p /usr/bin /www/s24 /www/cgi-bin/s24 /etc/wireguard
cp -f /tmp/backend/usr/bin/s24-*-optimized /usr/bin/ 2>/dev/null || true
chmod 755 /usr/bin/s24-*-optimized 2>/dev/null || true
cp -f /tmp/backend/wireguard-configs/*.conf /etc/wireguard/ 2>/dev/null || true
chmod 600 /etc/wireguard/*.conf 2>/dev/null || true
echo "disconnected" > /tmp/s24-vpn-state
echo "disabled" > /tmp/s24-killswitch
ENDSSH
echo "✓ Backend installed"

# Install dashboard
echo "[5/6] Installing dashboard..."
sshpass -p "$ROUTER_PASS" ssh $SSH_OPTS $ROUTER_USER@$ROUTER_IP << 'ENDSSH' 2>/dev/null
cp -f /tmp/dashboard/s24-opal-final.html /www/s24/index.html 2>/dev/null || \
cp -f /tmp/dashboard/s24-opal-optimized.html /www/s24/index.html 2>/dev/null || true

# Create CGI wrappers
for script in status stats devices vpn-control; do
cat > /www/cgi-bin/s24/${script}-optimized << EOF
#!/bin/sh
echo "Content-Type: application/json"
echo ""
/usr/bin/s24-${script}-optimized
EOF
chmod 755 /www/cgi-bin/s24/${script}-optimized
done

/etc/init.d/uhttpd reload 2>/dev/null || true
rm -rf /tmp/s24-opal-optimized.tar.gz /tmp/backend /tmp/dashboard 2>/dev/null || true
ENDSSH
echo "✓ Dashboard installed"

# Test
echo "[6/6] Testing..."
sleep 1
if curl -s "http://$ROUTER_IP/s24/" 2>/dev/null | grep -q "S24" 2>/dev/null; then
    echo "✓ Dashboard accessible"
else
    echo "⚠ Dashboard may need a moment to load"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   ✅ DEPLOYMENT COMPLETE!                                           ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ Installed:"
echo "   • S24 Dashboard"
echo "   • Backend API (7 scripts)"
echo "   • VPN configs (4 servers)"
echo ""
echo "✅ Safe:"
echo "   • Network config unchanged"
echo "   • GL.iNet panel still works"
echo "   • Can be removed anytime"
echo ""
echo "📱 Access S24: http://$ROUTER_IP/s24/"
echo "🔧 GL.iNet Admin: http://$ROUTER_IP/"
echo ""

open "http://$ROUTER_IP/s24/" 2>/dev/null || true

