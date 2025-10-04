#!/bin/bash
# S24 Complete Deployment Script
# This deploys the full dashboard and backend to your GL.iNet router

ROUTER_IP="${1:-192.168.8.1}"
ROUTER_USER="${2:-root}"
ROUTER_PASS="${3:-aperoot}"

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   S24 VPN ROUTER - COMPLETE DEPLOYMENT                             ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Target: $ROUTER_USER@$ROUTER_IP"
echo ""

# Check if sshpass is installed
if ! command -v sshpass >/dev/null 2>&1; then
    echo "Installing sshpass..."
    brew install sshpass
fi

echo "Step 1: Creating deployment package..."
cd "$(dirname "$0")"
tar czf /tmp/s24-deploy.tar.gz dashboard/s24-production.html backend/

echo "Step 2: Uploading to router..."
sshpass -p "$ROUTER_PASS" scp -o StrictHostKeyChecking=no \
    /tmp/s24-deploy.tar.gz $ROUTER_USER@$ROUTER_IP:/tmp/

echo "Step 3: Extracting files..."
sshpass -p "$ROUTER_PASS" ssh -o StrictHostKeyChecking=no $ROUTER_USER@$ROUTER_IP << 'ENDSSH'
cd /tmp
tar xzf s24-deploy.tar.gz

# Install backend
cd backend
sh install-backend.sh

# Install dashboard
mkdir -p /www/s24
cp -f dashboard/s24-production.html /www/s24/index.html

# Create redirect from root
cat > /www/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0; url=/s24/">
</head>
<body>
    Redirecting to S24 Dashboard...
</body>
</html>
EOF

# Configure uhttpd
if ! grep -q "s24" /etc/config/uhttpd; then
    uci set uhttpd.main.index_page='index.html'
    uci commit uhttpd
    /etc/init.d/uhttpd restart
fi

echo ""
echo "✓ Deployment complete!"
echo ""

ENDSSH

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   DEPLOYMENT COMPLETE!                                              ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Dashboard URL: http://$ROUTER_IP/s24/"
echo ""
echo "Features:"
echo "  ✓ VPN control with 4 server locations"
echo "  ✓ Device management and monitoring"
echo "  ✓ WiFi configuration (main + guest)"
echo "  ✓ Security features (kill switch, privacy modes)"
echo "  ✓ System settings (password, reboot, reset)"
echo ""
echo "Opening dashboard..."
open "http://$ROUTER_IP/s24/"

