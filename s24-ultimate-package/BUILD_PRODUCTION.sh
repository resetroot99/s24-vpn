#!/bin/bash
# S24 Production Build Script
# Creates a complete, optimized, production-ready package

set -e

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   S24 VPN ROUTER - PRODUCTION BUILD                                ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

# 1. Embed logo in dashboard
echo "[1/6] Embedding logo..."
LOGO_BASE64=$(base64 -i "../image copy.png" | tr -d '\n')
sed "s|../../image copy.png|data:image/png;base64,$LOGO_BASE64|g" \
    dashboard/s24-production.html > dashboard/s24-production-final.html

# 2. Package WireGuard configs
echo "[2/6] Packaging WireGuard configs..."
mkdir -p backend/wireguard-configs
cp -f ../nl1.conf backend/wireguard-configs/ 2>/dev/null || echo "nl1.conf not found"
cp -f ../ca3.conf backend/wireguard-configs/ 2>/dev/null || echo "ca3.conf not found"
cp -f ../us1.conf backend/wireguard-configs/ 2>/dev/null || echo "us1.conf not found"
cp -f ../th1.conf backend/wireguard-configs/ 2>/dev/null || echo "th1.conf not found"

# 3. Validate all backend scripts
echo "[3/6] Validating backend scripts..."
chmod +x backend/usr/bin/s24-*
chmod +x backend/cgi-bin/s24-api.sh
chmod +x backend/install-backend.sh

for script in backend/usr/bin/s24-*; do
    if ! sh -n "$script" 2>/dev/null; then
        echo "Error: Syntax error in $script"
        exit 1
    fi
done
echo "✓ All scripts valid"

# 4. Create deployment package
echo "[4/6] Creating deployment package..."
tar czf s24-production-package.tar.gz \
    dashboard/s24-production-final.html \
    backend/

# 5. Generate checksums
echo "[5/6] Generating checksums..."
shasum -a 256 s24-production-package.tar.gz > s24-production-package.sha256

# 6. Create deployment instructions
echo "[6/6] Creating deployment instructions..."
cat > DEPLOY_INSTRUCTIONS.txt << 'EOF'
S24 VPN ROUTER - DEPLOYMENT INSTRUCTIONS
═══════════════════════════════════════════

PREREQUISITES:
• GL.iNet Opal router (GL-SFT1200)
• Connected via Ethernet or WiFi
• SSH enabled on router
• Root password set

DEPLOYMENT:
1. Connect to router:
   ssh root@192.168.8.1
   Password: [your_password]

2. Upload package:
   scp s24-production-package.tar.gz root@192.168.8.1:/tmp/

3. Install:
   ssh root@192.168.8.1
   cd /tmp
   tar xzf s24-production-package.tar.gz
   cd backend
   sh install-backend.sh
   
   mkdir -p /www/s24
   cp ../dashboard/s24-production-final.html /www/s24/index.html

4. Access dashboard:
   http://192.168.8.1/s24/

VERIFICATION:
• VPN connects successfully
• Device list shows connected devices
• WiFi configuration works
• Password change works
• All sections accessible

EOF

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║   BUILD COMPLETE!                                                   ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Package: s24-production-package.tar.gz"
echo "Size: $(du -h s24-production-package.tar.gz | cut -f1)"
echo ""
echo "Next steps:"
echo "1. Review: cat DEPLOY_INSTRUCTIONS.txt"
echo "2. Deploy: ./DEPLOY_COMPLETE.sh 192.168.8.1 root your_password"
echo ""

