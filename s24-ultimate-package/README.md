# S24 ULTIMATE SECURITY ROUTER
**Complete Privacy & Security Solution for GL.iNet Opal**

---

## What You Get

A **turnkey security router** with enterprise-grade features in a consumer-friendly package:

- **Global & Per-Device Kill Switches**
- **VPN Identity Switching** (4 locations)
- **One-Touch Privacy Modes** (Home/Travel/Coffee/Work/Panic)
- **DNS Leak Protection**
- **Gamified Security Score** (A-F grading)
- **Guest WiFi with QR Codes** & Auto-Expire
- **Parental Controls** (time-based + content filtering)
- **Device Monitoring** & New Device Alerts
- **Bandwidth Tracking** (per device + total)
- **Auto-Failover VPN**
- **Ad & Tracker Blocking**
- **Stealth Mode**

---

## Package Contents

```
s24-ultimate-package/
├── dashboard/
│   └── s24-ultimate.html       # Complete admin interface
├── scripts/
│   ├── install.sh              # One-command installer
│   ├── s24-vpn-control.sh      # VPN management & failover
│   ├── s24-killswitch.sh       # Kill switches
│   ├── s24-privacy-modes.sh    # Privacy profiles
│   ├── s24-device-monitor.sh   # Device tracking
│   ├── s24-security-score.sh   # Security assessment
│   ├── s24-guest-wifi.sh       # Guest network
│   └── s24-parental-control.sh # Parental controls
├── configs/
│   ├── nl1.conf                # Netherlands VPN
│   ├── ca3.conf                # Canada VPN
│   ├── us1.conf                # USA VPN
│   └── th1.conf                # Thailand VPN
└── docs/
    ├── README.md               # This file
    └── QUICKSTART.md           # 5-minute setup guide
```

---

## Quick Start (5 Minutes)

### 1. Prerequisites

- **GL.iNet Opal (GL-SFT1200)** router
- Router connected to internet
- SSH access enabled (root password set to `aperoot`)
- Your VPN config files (nl1.conf, ca3.conf, us1.conf, th1.conf)

### 2. Installation

**Option A: Automated (via SCP)**
```bash
# From your Mac:
cd /Users/v3ctor/s24-vpn/s24-ultimate-package
tar -czf s24-ultimate.tar.gz *
scp s24-ultimate.tar.gz root@192.168.8.1:/tmp/

# SSH into router:
ssh root@192.168.8.1

# On router:
cd /tmp
tar -xzf s24-ultimate.tar.gz
cd s24-ultimate-package
chmod +x scripts/*.sh
./scripts/install.sh
```

**Option B: Manual (via web terminal)**
1. Go to http://192.168.8.1
2. Navigate to: System → Administration → Terminal
3. Copy/paste the installation commands from above

### 3. Add VPN Configs

```bash
# Copy your VPN configs to the router:
scp *.conf root@192.168.8.1:/etc/wireguard/
```

### 4. Access Dashboard

Open: **http://192.168.8.1/s24/**

---

## Features Overview

### Security & Privacy

**Global Kill Switch**
```bash
s24-killswitch.sh enable   # Block all traffic without VPN
s24-killswitch.sh disable  # Disable kill switch
```

**Per-Device Kill Switch**
```bash
s24-killswitch.sh block 192.168.8.100    # Pause device internet
s24-killswitch.sh unblock 192.168.8.100  # Resume device internet
```

**VPN Control**
```bash
s24-vpn-control.sh start           # Start VPN
s24-vpn-control.sh switch nl1      # Switch to Netherlands
s24-vpn-control.sh failover        # Test & switch if failed
```

**Privacy Modes**
```bash
s24-privacy-modes.sh home    # VPN off + adblock on
s24-privacy-modes.sh travel  # VPN + kill switch + stealth
s24-privacy-modes.sh coffee  # VPN only, SSID hidden
s24-privacy-modes.sh panic   # MAXIMUM PRIVACY LOCKDOWN
```

### Monitoring

**Security Score**
```bash
s24-security-score.sh  # Get A-F grade
```

**Device Monitoring**
```bash
s24-device-monitor.sh check      # Check for new devices
s24-device-monitor.sh list       # List all devices
s24-device-monitor.sh bandwidth  # Total bandwidth
```

### Controls

**Guest WiFi**
```bash
s24-guest-wifi.sh create 7200  # Create 2-hour guest network
s24-guest-wifi.sh info         # Show QR code & password
s24-guest-wifi.sh disable      # Remove guest network
```

**Parental Controls**
```bash
# Block device 7AM-9PM
s24-parental-control.sh schedule 192.168.8.100 7 21

# Block domains
s24-parental-control.sh block-domain facebook.com
s24-parental-control.sh list
```

---

## Dashboard Features

### Overview Tab
- VPN status indicator
- Kill switch status
- Connected devices count
- Blocked ads counter
- Bandwidth usage (24h)
- Active profile display
- Quick action buttons

### Security Score Tab
- Real-time A-F grading
- 100-point scoring system
- Feature-by-feature breakdown
- Improvement suggestions

### VPN Control Tab
- Toggle VPN on/off
- Server selection (NL, CA, US, TH)
- Connection details
- Public IP display

### Kill Switches Tab
- Global kill switch toggle
- Per-device internet pause
- Device list with controls

### Privacy Modes Tab
- Home Mode (local network)
- Travel Mode (maximum security)
- Coffee Shop Mode (public WiFi)
- Work Mode (balanced)
- Panic Button (emergency)

### Device Monitoring Tab
- Real-time device list
- New device alerts
- Per-device bandwidth
- Device blocking controls

### Guest WiFi Tab
- One-click guest network
- QR code generation
- Auto-expire scheduling
- Password display

### Parental Controls Tab
- Time-based restrictions
- Domain blocking
- Schedule management

---

## Configuration

### Default Settings

- **Default Mode**: Home (VPN off, adblock on)
- **Security Score Check**: Every hour
- **Device Monitoring**: Every 5 minutes
- **VPN Failover**: Every hour
- **Guest WiFi**: Disabled by default

### Customization

**Change Default VPN Server**
```bash
echo "nl1" > /tmp/s24_current_server
```

**Set Webhook for Alerts**
```bash
# Edit /usr/bin/s24-device-monitor.sh
# Set WEBHOOK_URL="https://your-webhook-url"
```

**Adjust Monitoring Intervals**
```bash
# Edit /etc/crontabs/root
# Current: check every 5 minutes
# Change to every 10 minutes:
sed -i 's/\*\/5/\*\/10/g' /etc/crontabs/root
/etc/init.d/cron restart
```

---

## Security Features Explained

### Kill Switch
Blocks ALL internet traffic when VPN is disconnected. Prevents IP leaks.

### DNS Leak Protection
Forces all DNS queries through router. Prevents DNS provider tracking.

### Stealth Mode
- Hides SSID
- Blocks ICMP ping
- Disables UPnP
- Makes router "invisible"

### VPN Failover
Automatically tests VPN connection and switches servers if failed.

### Panic Button
One-click emergency privacy lockdown:
- Enables VPN
- Activates kill switch
- Enables stealth mode
- Blocks unnecessary services

---

## Mobile Access

Dashboard is **fully responsive** and works on:
- Smartphones
- Tablets
- Laptops
- Desktop browsers

Access from any device on your network: http://192.168.8.1/s24/

---

## Troubleshooting

**Dashboard Not Loading**
```bash
# Check web server
/etc/init.d/uhttpd restart

# Verify files
ls -la /www/s24/
```

**VPN Not Connecting**
```bash
# Check WireGuard
wg show

# Manual test
wg-quick up nl1

# Check logs
tail -f /var/log/s24-vpn.log
```

**Kill Switch Not Working**
```bash
# Check firewall rules
iptables -L FORWARD -v -n

# Re-enable
s24-killswitch.sh enable
```

**Device Monitoring Not Working**
```bash
# Check cron
cat /etc/crontabs/root

# Manual run
s24-device-monitor.sh check
```

---

## Updates

**Update S24 Scripts**
```bash
# Download latest package
cd /tmp
wget https://your-server/s24-ultimate-latest.tar.gz
tar -xzf s24-ultimate-latest.tar.gz
cd s24-ultimate-package
./scripts/install.sh
```

**Backup Configuration**
```bash
# Backup all S24 settings
tar -czf /tmp/s24-backup.tar.gz \
    /etc/wireguard/*.conf \
    /etc/s24_* \
    /tmp/s24_*
    
# Download backup
scp root@192.168.8.1:/tmp/s24-backup.tar.gz ~/Desktop/
```

---

## Tips & Best Practices

1. **Always test features** before deploying to multiple routers
2. **Enable kill switch** before connecting to VPN
3. **Use Travel Mode** on public WiFi
4. **Set up webhooks** for device alerts
5. **Check security score weekly**
6. **Use guest WiFi** for visitors (auto-expire)
7. **Enable parental controls** during specific hours
8. **Test VPN failover** regularly

---

## Support

**Logs Location**
- `/var/log/s24-vpn.log` - VPN operations
- `/var/log/s24-killswitch.log` - Kill switch events
- `/var/log/s24-privacy.log` - Privacy mode changes
- `/var/log/s24-devices.log` - Device monitoring
- `/var/log/s24-guest.log` - Guest WiFi events
- `/var/log/s24-parental.log` - Parental controls

**Advanced Settings**
Access GL.iNet's advanced settings: http://192.168.8.1/cgi-bin/luci

**Factory Reset**
Hold reset button for 10+ seconds to restore router to factory defaults.

---

## You're All Set!

Your S24 Ultimate Security Router is ready to protect your privacy!

**Next Steps:**
1. Access dashboard: http://192.168.8.1/s24/
2. Check security score
3. Enable VPN
4. Activate desired privacy mode
5. Enjoy secure browsing!

---

**Version:** 1.0.0  
**Compatible with:** GL.iNet Opal (GL-SFT1200)  
**License:** Custom S24 License  
**Support:** support@s24.com

