# VPN Configuration Guide for GL.iNet Opal (GL-SFT1200)

**Author:** Manus AI  
**Date:** October 3, 2025  
**Version:** 1.0

---

## Table of Contents

1. [Overview](#overview)
2. [Method 1: Automated Configuration (Recommended)](#method-1-automated-configuration-recommended)
3. [Method 2: Manual Configuration via Web Interface](#method-2-manual-configuration-via-web-interface)
4. [Method 3: Manual Configuration via UCI Commands](#method-3-manual-configuration-via-uci-commands)
5. [Verification and Testing](#verification-and-testing)
6. [Advanced Configuration](#advanced-configuration)
7. [Troubleshooting](#troubleshooting)

---

## Overview

After flashing the GL.iNet Opal with the latest firmware, you need to configure it to connect to the VPN and route all traffic through the secure tunnel. This guide provides three methods:

- **Method 1 (Recommended):** Automated configuration using our provisioning script
- **Method 2:** Manual configuration through the GL.iNet web interface
- **Method 3:** Manual configuration using UCI commands via SSH

**Prerequisites:**
- GL.iNet Opal with firmware 4.3.24 or later installed
- Active S24 VPN account with license key
- WireGuard configuration file from S24 VPN platform
- Admin access to the router

---

## Method 1: Automated Configuration (Recommended)

This method uses the provisioning script to automatically configure everything.

### Step 1: Prepare Your Configuration File

Create a file called `device.conf` with your specific settings:

```ini
# GL.iNet Device Configuration
LICENSE_KEY="S24-1234567890-ABCD"  # Your actual license key from S24 VPN
WIFI_SSID="Strat24-Secure"         # Your desired Wi-Fi network name
WIFI_PASSWORD="YourSecurePass123!" # Strong password (12+ characters)
```

### Step 2: Upload Files to Router

**Via SCP (macOS/Linux):**

```bash
# Upload the provisioning script
scp provision_complete.sh root@192.168.8.1:/root/provision.sh

# Upload the configuration file
scp device.conf root@192.168.8.1:/root/device.conf
```

**Via WinSCP (Windows):**

1. Open WinSCP
2. Connect to `192.168.8.1` with username `root`
3. Navigate to `/root/` directory
4. Upload both files

### Step 3: Make Script Executable

```bash
ssh root@192.168.8.1
chmod +x /root/provision.sh
```

### Step 4: Run the Provisioning Script

```bash
/root/provision.sh
```

**Expected Output:**

```
2025-10-03 16:30:00 - --- Starting Provisioning Script v1.1 ---
2025-10-03 16:30:00 - Found License Key: S24-1234567890-ABCD
2025-10-03 16:30:00 - Wi-Fi SSID: Strat24-Secure
2025-10-03 16:30:01 - Fetching configuration from S24 VPN...
2025-10-03 16:30:02 - Successfully downloaded WireGuard configuration
2025-10-03 16:30:02 - Successfully parsed configuration fields
2025-10-03 16:30:02 - VPN Server: vpn.example.com:51820
2025-10-03 16:30:03 - Applying configuration using UCI...
2025-10-03 16:30:04 - Configuring firewall and kill switch...
2025-10-03 16:30:05 - Configuring secure Wi-Fi network...
2025-10-03 16:30:06 - Committing UCI changes...
2025-10-03 16:30:07 - Restarting network services...
2025-10-03 16:30:17 - Waiting for VPN connection to establish...
2025-10-03 16:30:27 - SUCCESS: VPN tunnel is UP and running!
2025-10-03 16:30:27 - --- Provisioning Script Finished ---
```

### Step 5: Enable Auto-Run on Boot

```bash
# Create init script
cat << 'EOF' > /etc/init.d/secure-vpn-provision
#!/bin/sh /etc/rc.common

START=99

start() {
    /root/provision.sh &
}
EOF

# Make executable and enable
chmod +x /etc/init.d/secure-vpn-provision
/etc/init.d/secure-vpn-provision enable
```

**That's it!** The VPN is now configured and will automatically reconnect on reboot.

---

## Method 2: Manual Configuration via Web Interface

This method uses the GL.iNet web interface to configure WireGuard manually.

### Step 1: Download Your WireGuard Configuration

1. Log in to your S24 VPN dashboard
2. Select your preferred VPN server
3. Click "Download for Desktop" (WireGuard)
4. Save the `.conf` file to your computer

### Step 2: Access GL.iNet Admin Panel

1. Connect to the router (via Wi-Fi or Ethernet)
2. Open browser and navigate to: **http://192.168.8.1**
3. Log in with your admin password

### Step 3: Navigate to VPN Settings

1. In the left sidebar, click **VPN**
2. Click **WireGuard Client**
3. Click **Set Up WireGuard Client Manually**

### Step 4: Configure WireGuard Client

You'll need to extract information from your downloaded `.conf` file. Open it in a text editor.

**Example WireGuard config file:**

```ini
[Interface]
PrivateKey = ABC123def456GHI789jkl012MNO345pqr678STU901vwx234YZA=
Address = 10.0.0.5/32
DNS = 10.0.0.1

[Peer]
PublicKey = XYZ789abc012DEF345ghi678JKL901mno234PQR567stu890VWX=
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

**Enter the following in the GL.iNet interface:**

| Field | Value from Config File |
|-------|------------------------|
| **Configuration Name** | S24-VPN (or any name you prefer) |
| **Private Key** | Copy from `PrivateKey` line |
| **IP Address** | Copy from `Address` line (e.g., 10.0.0.5/32) |
| **Public Key** | Copy from `PublicKey` line under [Peer] |
| **Allowed IPs** | Copy from `AllowedIPs` line (should be 0.0.0.0/0) |
| **Endpoint** | Copy from `Endpoint` line (e.g., vpn.example.com:51820) |

**Advanced Settings (click "Show Advanced Settings"):**

| Field | Value |
|-------|-------|
| **Listen Port** | Leave empty (auto-assign) |
| **MTU** | 1420 (default) |
| **Persistent Keepalive** | 25 |

### Step 5: Save and Connect

1. Click **Apply** to save the configuration
2. Toggle the switch to **ON** to connect
3. Wait 10-15 seconds for connection to establish
4. Status should show **Connected** with a green indicator

### Step 6: Configure VPN Policy

This ensures all traffic goes through the VPN.

1. Stay in **VPN** → **WireGuard Client**
2. Scroll down to **VPN Policy**
3. Select **Global Proxy** (routes all traffic through VPN)
4. Click **Apply**

### Step 7: Enable Kill Switch

1. In the left sidebar, click **VPN**
2. Click **VPN Dashboard**
3. Find the **Kill Switch** section
4. Toggle **Enable Kill Switch** to **ON**
5. This prevents internet access if VPN disconnects

### Step 8: Configure DNS

1. In the left sidebar, click **NETWORK**
2. Click **DNS**
3. Select **Manual DNS Server**
4. Enter the DNS from your WireGuard config (e.g., 10.0.0.1)
5. Click **Apply**

### Step 9: Verify Connection

1. In the left sidebar, click **VPN**
2. Click **VPN Dashboard**
3. You should see:
   - Status: **Connected**
   - Upload/Download traffic counters
   - Connection duration

---

## Method 3: Manual Configuration via UCI Commands

This method uses OpenWRT's UCI system for advanced users who prefer command-line configuration.

### Step 1: SSH into the Router

```bash
ssh root@192.168.8.1
```

### Step 2: Extract Configuration Values

You'll need these values from your WireGuard config file:
- Private Key
- Address
- DNS
- Peer Public Key
- Endpoint (host and port)
- Allowed IPs

**Set them as variables for easier configuration:**

```bash
PRIVATE_KEY="ABC123def456GHI789jkl012MNO345pqr678STU901vwx234YZA="
ADDRESS="10.0.0.5/32"
DNS="10.0.0.1"
PEER_PUBLIC_KEY="XYZ789abc012DEF345ghi678JKL901mno234PQR567stu890VWX="
ENDPOINT_HOST="vpn.example.com"
ENDPOINT_PORT="51820"
ALLOWED_IPS="0.0.0.0/0"
```

### Step 3: Configure WireGuard Interface

```bash
# Create WireGuard interface
uci set network.wg0='interface'
uci set network.wg0.proto='wireguard'
uci set network.wg0.private_key="$PRIVATE_KEY"
uci add_list network.wg0.addresses="$ADDRESS"
uci set network.wg0.dns="$DNS"

# Commit network changes
uci commit network
```

### Step 4: Configure WireGuard Peer

```bash
# Create peer configuration
uci set network.wgclient='wireguard_wg0'
uci set network.wgclient.public_key="$PEER_PUBLIC_KEY"
uci set network.wgclient.endpoint_host="$ENDPOINT_HOST"
uci set network.wgclient.endpoint_port="$ENDPOINT_PORT"
uci set network.wgclient.allowed_ips="$ALLOWED_IPS"
uci set network.wgclient.persistent_keepalive='25'
uci set network.wgclient.route_allowed_ips='1'

# Commit network changes
uci commit network
```

### Step 5: Configure Firewall Zones

```bash
# Create VPN firewall zone
uci set firewall.vpn_zone='zone'
uci set firewall.vpn_zone.name='vpn'
uci set firewall.vpn_zone.input='REJECT'
uci set firewall.vpn_zone.output='ACCEPT'
uci set firewall.vpn_zone.forward='REJECT'
uci set firewall.vpn_zone.masq='1'
uci set firewall.vpn_zone.mtu_fix='1'
uci add_list firewall.vpn_zone.network='wg0'

# Commit firewall changes
uci commit firewall
```

### Step 6: Configure Forwarding Rules

```bash
# Allow LAN to VPN forwarding
uci set firewall.lan_to_vpn='forwarding'
uci set firewall.lan_to_vpn.src='lan'
uci set firewall.lan_to_vpn.dest='vpn'

# Commit firewall changes
uci commit firewall
```

### Step 7: Implement Kill Switch

```bash
# Remove LAN to WAN forwarding (forces traffic through VPN only)
uci delete firewall.@forwarding[0]  # This removes the default LAN→WAN rule

# Alternative: Explicitly block LAN to WAN
uci set firewall.block_lan_wan='forwarding'
uci set firewall.block_lan_wan.src='lan'
uci set firewall.block_lan_wan.dest='wan'
uci set firewall.block_lan_wan.enabled='0'

# Commit firewall changes
uci commit firewall
```

### Step 8: Apply Configuration

```bash
# Restart network services
/etc/init.d/network restart

# Restart firewall
/etc/init.d/firewall restart

# Wait for services to stabilize
sleep 5
```

### Step 9: Verify Configuration

```bash
# Check WireGuard interface
ip link show wg0

# Check WireGuard status
wg show

# Check routing table
ip route

# Check if tunnel is up
ping -c 4 -I wg0 8.8.8.8
```

---

## Verification and Testing

After configuration (regardless of method), perform these tests to ensure everything is working correctly.

### Test 1: Check WireGuard Interface Status

```bash
ssh root@192.168.8.1
ip link show wg0
```

**Expected output:**

```
5: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN
```

Look for **UP** and **LOWER_UP** - this means the interface is active.

### Test 2: Check WireGuard Connection Details

```bash
wg show
```

**Expected output:**

```
interface: wg0
  public key: YourPublicKey123=
  private key: (hidden)
  listening port: 51820

peer: ServerPublicKey456=
  endpoint: vpn.example.com:51820
  allowed ips: 0.0.0.0/0
  latest handshake: 30 seconds ago
  transfer: 1.5 MiB received, 456 KiB sent
  persistent keepalive: every 25 seconds
```

**Key indicators:**
- **latest handshake** should be recent (< 2 minutes)
- **transfer** shows data is flowing
- **endpoint** matches your VPN server

### Test 3: Check Routing Table

```bash
ip route
```

**Expected output:**

```
default dev wg0 scope link
10.0.0.0/24 dev wg0 proto kernel scope link src 10.0.0.5
192.168.8.0/24 dev br-lan proto kernel scope link src 192.168.8.1
```

The **default** route should go through **wg0** (the VPN interface).

### Test 4: Test VPN Connection from Router

```bash
# Ping through VPN interface
ping -c 4 -I wg0 8.8.8.8

# Check public IP (should be VPN server's IP)
curl -s --interface wg0 https://api.ipify.org
```

### Test 5: Connect Client Device and Test

1. **Connect to the router's Wi-Fi** (or via Ethernet)
2. **Check your public IP:**
   - Visit: https://www.whatismyip.com
   - The IP should be the VPN server's location, not your actual location
3. **Test DNS leaks:**
   - Visit: https://www.dnsleaktest.com
   - Click "Extended Test"
   - All DNS servers should belong to the VPN provider

### Test 6: Verify Kill Switch

This is critical for security.

```bash
# SSH into router
ssh root@192.168.8.1

# Bring down the VPN interface
ifdown wg0
```

**On your client device:**
- Try to access any website
- **You should have NO internet access**
- This confirms the kill switch is working

**Restore the connection:**

```bash
# SSH into router (if still connected)
ifup wg0

# Or reboot the router
reboot
```

### Test 7: Check System Logs

```bash
# View recent logs
logread | tail -50

# Filter for WireGuard-related logs
logread | grep -i wireguard

# Check for errors
logread | grep -i error
```

---

## Advanced Configuration

### Configure Multiple VPN Servers

You can configure multiple WireGuard profiles and switch between them.

**Via Web Interface:**

1. Go to **VPN** → **WireGuard Client**
2. Click **Add a New WireGuard Client**
3. Configure the second server
4. Toggle between servers using the dropdown menu

**Via UCI:**

```bash
# Create second interface
uci set network.wg1='interface'
uci set network.wg1.proto='wireguard'
uci set network.wg1.private_key="$PRIVATE_KEY_2"
# ... configure remaining settings

# Create second peer
uci set network.wgclient2='wireguard_wg1'
# ... configure peer settings

uci commit network
/etc/init.d/network restart
```

### Configure Split Tunneling

Route only specific traffic through the VPN.

**Via Web Interface:**

1. Go to **VPN** → **VPN Policy**
2. Select **Based on the Client Device**
3. Add devices that should use VPN
4. Other devices will use direct connection

**Via UCI:**

```bash
# Set specific allowed IPs instead of 0.0.0.0/0
uci set network.wgclient.allowed_ips='10.0.0.0/8 192.168.0.0/16'
uci commit network
/etc/init.d/network restart
```

### Configure Custom DNS

Use specific DNS servers instead of VPN-provided DNS.

**Via Web Interface:**

1. Go to **NETWORK** → **DNS**
2. Select **Manual DNS Server**
3. Add DNS servers:
   - Cloudflare: `1.1.1.1` and `1.0.0.1`
   - Quad9: `9.9.9.9` and `149.112.112.112`
   - Google: `8.8.8.8` and `8.8.4.4`

**Via UCI:**

```bash
uci set network.wg0.dns='1.1.1.1 1.0.0.1'
uci commit network
/etc/init.d/network restart
```

### Enable DNS over HTTPS (DoH)

For enhanced privacy:

```bash
# Install https-dns-proxy
opkg update
opkg install https-dns-proxy

# Configure for Cloudflare DoH
uci set https-dns-proxy.dns.bootstrap_dns='1.1.1.1,1.0.0.1'
uci set https-dns-proxy.dns.resolver_url='https://cloudflare-dns.com/dns-query'
uci set https-dns-proxy.dns.listen_addr='127.0.0.1'
uci set https-dns-proxy.dns.listen_port='5053'
uci commit https-dns-proxy

# Configure dnsmasq to use DoH proxy
uci set dhcp.@dnsmasq[0].noresolv='1'
uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#5053'
uci commit dhcp

# Restart services
/etc/init.d/https-dns-proxy restart
/etc/init.d/dnsmasq restart
```

### Configure Automatic Reconnection

Ensure VPN reconnects if it drops:

```bash
# Create watchdog script
cat << 'EOF' > /root/vpn_watchdog.sh
#!/bin/sh
if ! ip link show wg0 | grep -q "state UP"; then
    logger "VPN down, attempting reconnect..."
    ifdown wg0
    sleep 5
    ifup wg0
fi
EOF

chmod +x /root/vpn_watchdog.sh

# Add to crontab (check every 5 minutes)
echo "*/5 * * * * /root/vpn_watchdog.sh" >> /etc/crontabs/root
/etc/init.d/cron restart
```

### Configure Traffic Monitoring

Monitor VPN traffic in real-time:

```bash
# Install vnstat
opkg update
opkg install vnstat

# Initialize monitoring for wg0
vnstat -i wg0 --create

# View statistics
vnstat -i wg0

# View live traffic
vnstat -i wg0 -l
```

---

## Troubleshooting

### Problem: WireGuard Interface Won't Start

**Symptoms:** `ip link show wg0` shows interface is DOWN

**Solutions:**

1. **Check configuration syntax:**
   ```bash
   uci show network | grep wg
   ```
   Look for any empty values or syntax errors

2. **Check WireGuard kernel module:**
   ```bash
   lsmod | grep wireguard
   ```
   If not loaded:
   ```bash
   modprobe wireguard
   ```

3. **Check system logs:**
   ```bash
   logread | grep -i wireguard
   ```

4. **Manually start interface:**
   ```bash
   ifup wg0
   ```

### Problem: VPN Connects But No Internet

**Symptoms:** WireGuard shows connected, but client devices have no internet

**Solutions:**

1. **Check routing:**
   ```bash
   ip route
   ```
   Ensure default route goes through wg0

2. **Check NAT/masquerading:**
   ```bash
   iptables -t nat -L -v -n
   ```
   Should show MASQUERADE rule for wg0

3. **Check DNS:**
   ```bash
   nslookup google.com
   ```
   If DNS fails, configure DNS manually

4. **Check firewall forwarding:**
   ```bash
   uci show firewall | grep forward
   ```
   Ensure LAN→VPN forwarding is enabled

### Problem: Slow VPN Speed

**Symptoms:** Internet is very slow when connected to VPN

**Solutions:**

1. **Check MTU settings:**
   ```bash
   # Try lower MTU
   uci set network.wg0.mtu='1380'
   uci commit network
   /etc/init.d/network restart
   ```

2. **Check CPU usage:**
   ```bash
   top
   ```
   WireGuard should use minimal CPU

3. **Test different VPN servers:**
   - Some servers may be overloaded
   - Try connecting to a geographically closer server

4. **Check your base internet speed:**
   ```bash
   # Temporarily disable VPN
   ifdown wg0
   # Test speed at fast.com
   # Re-enable VPN
   ifup wg0
   ```

### Problem: VPN Disconnects Randomly

**Symptoms:** VPN connection drops every few minutes

**Solutions:**

1. **Increase keepalive:**
   ```bash
   uci set network.wgclient.persistent_keepalive='15'
   uci commit network
   /etc/init.d/network restart
   ```

2. **Check for IP conflicts:**
   ```bash
   ip addr show
   ```
   Ensure no IP conflicts between interfaces

3. **Check router uptime and memory:**
   ```bash
   uptime
   free
   ```
   If memory is low, reboot the router

4. **Enable automatic reconnection:**
   - See "Configure Automatic Reconnection" in Advanced Configuration

### Problem: Kill Switch Not Working

**Symptoms:** Internet still works when VPN is down

**Solutions:**

1. **Check firewall rules:**
   ```bash
   iptables -L -v -n
   ```

2. **Verify LAN→WAN forwarding is disabled:**
   ```bash
   uci show firewall | grep forwarding
   ```

3. **Manually block LAN→WAN:**
   ```bash
   iptables -I FORWARD -i br-lan -o eth0 -j DROP
   ```

4. **Re-apply firewall configuration:**
   ```bash
   /etc/init.d/firewall restart
   ```

### Problem: Cannot Access Router Admin Panel

**Symptoms:** Can't access http://192.168.8.1 after VPN configuration

**Solutions:**

1. **Check if you're on the LAN:**
   ```bash
   # Your IP should be 192.168.8.x
   ipconfig  # Windows
   ifconfig  # macOS/Linux
   ```

2. **Try accessing via SSH:**
   ```bash
   ssh root@192.168.8.1
   ```

3. **Check if uhttpd is running:**
   ```bash
   /etc/init.d/uhttpd status
   /etc/init.d/uhttpd restart
   ```

4. **Clear browser cache:**
   - Use incognito/private mode
   - Clear cookies for 192.168.8.1

---

## Configuration Backup and Restore

### Backup Current Configuration

**Via Web Interface:**

1. Go to **SYSTEM** → **Advanced Settings**
2. Click **Backup / Flash Firmware**
3. Click **Generate archive**
4. Save the `.tar.gz` file

**Via SSH:**

```bash
# Backup all UCI configuration
sysupgrade -b /tmp/backup-$(date +%Y%m%d).tar.gz

# Download to your computer
scp root@192.168.8.1:/tmp/backup-*.tar.gz ./
```

### Restore Configuration

**Via Web Interface:**

1. Go to **SYSTEM** → **Advanced Settings**
2. Click **Backup / Flash Firmware**
3. Under "Restore backup", choose your backup file
4. Click **Upload archive**

**Via SSH:**

```bash
# Upload backup to router
scp backup-20251003.tar.gz root@192.168.8.1:/tmp/

# Restore configuration
sysupgrade -r /tmp/backup-20251003.tar.gz

# Reboot
reboot
```

---

## Summary

You now have three methods to configure VPN on your GL.iNet Opal:

1. **Automated (Recommended):** Use the provisioning script for zero-touch deployment
2. **Web Interface:** User-friendly GUI for manual configuration
3. **UCI Commands:** Advanced command-line configuration for power users

**Best Practices:**

✅ Always test the VPN connection after configuration  
✅ Verify the kill switch is working  
✅ Test DNS leak protection  
✅ Monitor connection stability for 24 hours  
✅ Keep configuration backups  
✅ Document any custom settings  

For production deployments, use **Method 1 (Automated)** to ensure consistency across all devices and reduce human error.

---

**Document Version:** 1.0  
**Last Updated:** October 3, 2025  
**Author:** Manus AI
