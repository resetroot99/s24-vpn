#!/bin/bash

###############################################################################
# Strat24 Firmware Builder
# Builds custom OpenWRT firmware with VPN pre-configured
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
OPENWRT_VERSION="22.03.5"
TARGET="ramips"
SUBTARGET="mt7621"
PROFILE="glinet_gl-sft1200"
IMAGEBUILDER_DIR="openwrt-imagebuilder-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}.Linux-x86_64"

# Build profile (default: multi)
BUILD_PROFILE="${1:-multi}"

# Version
FIRMWARE_VERSION="1.0.0"
BUILD_DATE=$(date +%Y%m%d)
FIRMWARE_NAME="strat24-opal-${BUILD_PROFILE}-v${FIRMWARE_VERSION}-${BUILD_DATE}"

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ███████╗████████╗██████╗  █████╗ ████████╗██████╗ ██╗  ██╗║
║   ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝╚════██╗██║  ██║║
║   ███████╗   ██║   ██████╔╝███████║   ██║    █████╔╝███████║║
║   ╚════██║   ██║   ██╔══██╗██╔══██║   ██║   ██╔═══╝ ╚════██║║
║   ███████║   ██║   ██║  ██║██║  ██║   ██║   ███████╗     ██║║
║   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝     ╚═╝║
║                                                              ║
║              Custom Firmware Builder v1.0                    ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Build Configuration:${NC}"
echo "  Profile: ${BUILD_PROFILE}"
echo "  Version: ${FIRMWARE_VERSION}"
echo "  Date: ${BUILD_DATE}"
echo "  Output: ${FIRMWARE_NAME}.bin"
echo ""

# Check if ImageBuilder exists
if [ ! -d "$IMAGEBUILDER_DIR" ]; then
    echo -e "${RED}[✗] ImageBuilder not found!${NC}"
    echo "    Run: ./download-imagebuilder.sh first"
    exit 1
fi

# Create files directory structure
echo -e "${BLUE}[→] Preparing firmware files...${NC}"

mkdir -p files/etc/config
mkdir -p files/etc/wireguard
mkdir -p files/www/strat24
mkdir -p files/www/cgi-bin
mkdir -p files/etc/init.d

# Copy VPN configs
echo -e "${YELLOW}[~] Copying VPN configurations...${NC}"
cp ../nl1.conf files/etc/wireguard/wg-nl.conf
cp ../ca3.conf files/etc/wireguard/wg-ca.conf
cp ../us1.conf files/etc/wireguard/wg-us.conf
cp ../th1.conf files/etc/wireguard/wg-th.conf

# Create network config
cat > files/etc/config/network << 'EOF'
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fd00::/48'

config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'eth0.1'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.8.1'
	option netmask '255.255.255.0'
	option ip6assign '60'

config device
	option name 'eth0.2'
	option macaddr 'auto'

config interface 'wan'
	option device 'eth0.2'
	option proto 'dhcp'

config interface 'wgnl'
	option proto 'wireguard'
	option private_key ''
	list addresses ''

config wireguard_wgnl
	option public_key ''
	option endpoint_host ''
	option endpoint_port ''
	list allowed_ips '0.0.0.0/0'
	option persistent_keepalive '25'
	option route_allowed_ips '1'
EOF

# Create wireless config
cat > files/etc/config/wireless << 'EOF'
config wifi-device 'radio0'
	option type 'mac80211'
	option path 'platform/10300000.wmac'
	option channel '6'
	option band '2g'
	option htmode 'HT20'
	option disabled '0'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'Strat24-Secure'
	option encryption 'psk2'
	option key 'ChangeThisPassword123!'
	option wpa_disable_eapol_key_retries '1'
EOF

# Create firewall config with kill switch
cat > files/etc/config/firewall << 'EOF'
config defaults
	option syn_flood	1
	option input		REJECT
	option output		ACCEPT
	option forward		REJECT

config zone
	option name		lan
	list   network		'lan'
	option input		ACCEPT
	option output		ACCEPT
	option forward		ACCEPT

config zone
	option name		wan
	option input		REJECT
	option output		ACCEPT
	option forward		REJECT
	option masq		1
	option mtu_fix		1
	list   network		'wan'

config zone
	option name		vpn
	option input		REJECT
	option output		ACCEPT
	option forward		REJECT
	option masq		1
	option mtu_fix		1
	list   network		'wgnl'

config forwarding
	option src		lan
	option dest		vpn

config rule
	option name		Allow-DHCP-Renew
	option src		wan
	option proto		udp
	option dest_port	68
	option target		ACCEPT
	option family		ipv4

config rule
	option name		Allow-Ping
	option src		wan
	option proto		icmp
	option icmp_type	echo-request
	option family		ipv4
	option target		ACCEPT
EOF

# Create DHCP config
cat > files/etc/config/dhcp << 'EOF'
config dnsmasq
	option domainneeded	1
	option localise_queries	1
	option rebind_protection 1
	option rebind_localhost 1
	option local	'/lan/'
	option domain	'lan'
	option expandhosts	1
	option authoritative	1
	option readethers	1
	option leasefile	'/tmp/dhcp.leases'
	option resolvfile	'/tmp/resolv.conf.d/resolv.conf.auto'
	option localservice	1
	option ednspacket_max	1232

config dhcp 'lan'
	option interface	'lan'
	option start	100
	option limit	150
	option leasetime	12h
	option dhcpv6	'server'
	option ra	'server'
	option ra_slaac	1
	list ra_flags	'managed-config'
	list ra_flags	'other-config'

config dhcp 'wan'
	option interface	'wan'
	option ignore	1
EOF

# Create Strat24 banner
cat > files/etc/banner << 'EOF'
  _____ _____ ____      _  _____ ___  _  _   
 / ____|_   _|  _ \    / \|_   _|__ \| || |  
 \___ \  | | | |_) |  / _ \ | |    ) | || |_ 
  ___) | | | |  _ <  / ___ \| |   / /|__   _|
 |____/  |_| |_| \_\/_/   \_\_|  /_(_)  |_|  
                                              
 Strat24 Secure Access Point
 ----------------------------------------------------------
 Firmware: v1.0.0
 Device: GL.iNet Opal (GL-SFT1200)
 VPN: WireGuard (Multi-Server)
 ----------------------------------------------------------
 Support: support@strat24.com
 Website: https://strat24.com
 ----------------------------------------------------------
EOF

# Create startup script
cat > files/etc/rc.local << 'EOF'
#!/bin/sh

# Strat24 Startup Script
logger -t strat24 "Initializing Strat24 Secure Access Point..."

# Wait for network
sleep 10

# Start WireGuard VPN
if [ -f /etc/wireguard/wg-nl.conf ]; then
    logger -t strat24 "Starting WireGuard VPN (Netherlands)..."
    wg-quick up wg-nl 2>&1 | logger -t wireguard
fi

logger -t strat24 "Strat24 Secure Access Point ready!"

exit 0
EOF

chmod +x files/etc/rc.local

# Create redirect from root to strat24 dashboard
cat > files/www/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0;url=/strat24/">
</head>
<body>
    <p>Redirecting to Strat24 Dashboard...</p>
</body>
</html>
EOF

# Note: Full Strat24 dashboard is in files/www/strat24/index.html
# Note: CGI scripts are in files/www/cgi-bin/

# Create simple fallback portal  
cat > files/www/strat24/fallback.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Strat24 Secure Access Point</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        h1 {
            font-size: 2.5em;
            margin: 0 0 10px 0;
            text-align: center;
        }
        .tagline {
            text-align: center;
            opacity: 0.9;
            margin-bottom: 30px;
        }
        .status {
            background: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .status-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .status-item:last-child {
            border-bottom: none;
        }
        .status-value {
            font-weight: bold;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            opacity: 0.8;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Strat24</h1>
        <p class="tagline">Secure Access Point</p>
        
        <div class="status">
            <div class="status-item">
                <span>Status:</span>
                <span class="status-value">🟢 Protected</span>
            </div>
            <div class="status-item">
                <span>VPN:</span>
                <span class="status-value">WireGuard</span>
            </div>
            <div class="status-item">
                <span>Encryption:</span>
                <span class="status-value">Military-Grade</span>
            </div>
            <div class="status-item">
                <span>Kill Switch:</span>
                <span class="status-value">Enabled</span>
            </div>
        </div>
        
        <p style="text-align: center; margin-top: 20px;">
            All devices connected to this network are protected by enterprise-grade VPN encryption.
        </p>
        
        <div class="footer">
            <p>Strat24 Secure Access Point<br>
            support@strat24.com | https://strat24.com</p>
        </div>
    </div>
</body>
</html>
EOF

# Define packages based on profile
case $BUILD_PROFILE in
    single)
        PACKAGES="wireguard-tools kmod-wireguard luci luci-theme-material \
                 curl wget openssh-sftp-server iptables-nft firewall4 \
                 -wpad-basic-mbedtls wpad-mbedtls"
        ;;
    multi)
        PACKAGES="wireguard-tools kmod-wireguard luci luci-theme-material \
                 curl wget openssh-sftp-server iptables-nft firewall4 \
                 -wpad-basic-mbedtls wpad-mbedtls luci-app-wireguard"
        ;;
    full)
        PACKAGES="wireguard-tools kmod-wireguard luci luci-theme-material \
                 curl wget openssh-sftp-server iptables-nft firewall4 \
                 -wpad-basic-mbedtls wpad-mbedtls luci-app-wireguard \
                 htop tcpdump-mini iperf3"
        ;;
    *)
        echo -e "${RED}[✗] Unknown profile: $BUILD_PROFILE${NC}"
        echo "    Valid profiles: single, multi, full"
        exit 1
        ;;
esac

# Build firmware
echo -e "${GREEN}[→] Building firmware...${NC}"
echo "    This may take 5-10 minutes..."
echo ""

cd "$IMAGEBUILDER_DIR"

make image PROFILE="$PROFILE" \
    PACKAGES="$PACKAGES" \
    FILES="../files" \
    EXTRA_IMAGE_NAME="$FIRMWARE_NAME"

# Find generated firmware
FIRMWARE_PATH=$(find bin/targets/${TARGET}/${SUBTARGET}/ -name "*${FIRMWARE_NAME}*sysupgrade.bin" | head -1)

if [ -z "$FIRMWARE_PATH" ]; then
    echo -e "${RED}[✗] Firmware build failed - output file not found${NC}"
    exit 1
fi

# Copy to main directory
cp "$FIRMWARE_PATH" "../${FIRMWARE_NAME}.bin"

# Generate checksums
cd ..
sha256sum "${FIRMWARE_NAME}.bin" > "${FIRMWARE_NAME}.bin.sha256"

# Build info
cat > "${FIRMWARE_NAME}.info" << EOF
Strat24 Custom Firmware
=======================
Profile: ${BUILD_PROFILE}
Version: ${FIRMWARE_VERSION}
Build Date: ${BUILD_DATE}
OpenWRT Version: ${OPENWRT_VERSION}
Target: ${PROFILE}

VPN Servers Included:
- Netherlands (nl1.ipcover.net)
- Canada (ca3.ipcover.net)
- USA (us1.ipcover.net)
- Thailand (th1.ipcover.net)

Default Settings:
- WiFi SSID: Strat24-Secure
- WiFi Password: ChangeThisPassword123!
- Admin IP: 192.168.8.1
- Admin User: root
- Admin Password: (set on first login)

Flash Instructions:
1. Access router: http://192.168.8.1
2. Go to: System → Upgrade
3. Upload: ${FIRMWARE_NAME}.bin
4. Wait 5 minutes for flash and reboot
5. Reconnect to "Strat24-Secure" WiFi

Support: support@strat24.com
Website: https://strat24.com
EOF

# Success
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           Firmware Build Complete!                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}[✓] Firmware: ${FIRMWARE_NAME}.bin${NC}"
echo -e "${GREEN}[✓] Checksum: ${FIRMWARE_NAME}.bin.sha256${NC}"
echo -e "${GREEN}[✓] Info: ${FIRMWARE_NAME}.info${NC}"
echo ""
echo "File size: $(ls -lh ${FIRMWARE_NAME}.bin | awk '{print $5}')"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Flash to router via web UI or sysupgrade"
echo "2. Test thoroughly before client deployment"
echo "3. Document in BUILD_HISTORY.md"
echo ""
echo -e "${YELLOW}⚠️  Remember: VPN private keys are embedded!${NC}"
echo "   Keep firmware secure and never share publicly."
echo ""

