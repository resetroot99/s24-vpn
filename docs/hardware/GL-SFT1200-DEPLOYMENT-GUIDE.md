# GL.iNet GL-SFT1200 (Opal) - Complete Deployment & Testing Guide

**Device:** GL.iNet Opal (GL-SFT1200)  
**Solution:** Strat24 Secure Access Point  
**Version:** 1.0  
**Last Updated:** October 3, 2025

---

## Table of Contents

1. [Hardware Overview](#hardware-overview)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Deployment](#step-by-step-deployment)
4. [Complete Testing Procedures](#complete-testing-procedures)
5. [Troubleshooting](#troubleshooting)
6. [Production Checklist](#production-checklist)

---

## Hardware Overview

### GL.iNet Opal (GL-SFT1200) Specifications

| Specification | Details |
|--------------|---------|
| **Model** | GL-SFT1200 |
| **CPU** | MediaTek MT7621A (880 MHz, dual-core) |
| **RAM** | 256 MB DDR3 |
| **Flash** | 32 MB |
| **Wi-Fi** | Dual-band 802.11ac (2.4GHz + 5GHz) |
| **Wi-Fi Speed** | Up to 1200 Mbps (300 Mbps @ 2.4GHz + 867 Mbps @ 5GHz) |
| **Ethernet** | 1x WAN (1 Gbps) + 2x LAN (1 Gbps) |
| **USB** | 1x USB 2.0 |
| **Power** | USB-C, 5V/2A |
| **Dimensions** | 104 x 68 x 25 mm |
| **Weight** | 90g |

### Port Layout

```
Front View:
┌─────────────────────────────────┐
│  [Power LED]  [Wi-Fi LED]       │
│                                 │
│     GL.iNet OPAL                │
│                                 │
│  [Reset Button]                 │
└─────────────────────────────────┘

Rear View:
┌─────────────────────────────────┐
│ [USB-C]  [WAN]  [LAN1]  [LAN2]  │
│  Power   Blue   Yellow  Yellow  │
└─────────────────────────────────┘
```

### LED Indicators

| LED | Color | Status | Meaning |
|-----|-------|--------|---------|
| Power | Blue | Solid | Device powered on |
| Power | Blue | Flashing | Booting or updating |
| Power | Off | - | No power |
| Wi-Fi | White | Solid | Wi-Fi enabled |
| Wi-Fi | White | Flashing | Wi-Fi activity |
| Wi-Fi | Off | - | Wi-Fi disabled |

---

## Prerequisites

### Required Hardware

- [ ] GL.iNet Opal (GL-SFT1200) router
- [ ] Power adapter (USB-C, 5V/2A) - included with device
- [ ] 2x Ethernet cables (Cat5e or better)
- [ ] Computer with Ethernet port (or USB Ethernet adapter)
- [ ] Internet connection (modem or router)

### Required Software

- [ ] SSH client (Terminal on macOS/Linux, PuTTY on Windows)
- [ ] SCP client (built-in on macOS/Linux, WinSCP on Windows)
- [ ] Web browser (Chrome, Firefox, or Safari)
- [ ] Text editor (VS Code, Notepad++, or similar)

### Required Credentials

- [ ] Strat24 VPN platform access (https://vpn.strat24.com)
- [ ] License key from Strat24 VPN platform
- [ ] Strong Wi-Fi password (12+ characters)

### Required Files

Download from the repository:
- [ ] `hardware/provisioning/provision.sh`
- [ ] `hardware/provisioning/device.conf.template`

---

## Step-by-Step Deployment

### Phase 1: Initial Setup (15 minutes)

#### Step 1.1: Unbox and Inspect Device

1. **Remove device from packaging**
2. **Verify contents:**
   - GL-SFT1200 router
   - USB-C power adapter
   - Quick start guide
   - Warranty card

3. **Inspect device:**
   - Check for physical damage
   - Note serial number (on label, bottom of device)
   - Document MAC address (on label)

4. **Record device information:**
   ```
   Device Serial: GL-SFT1200-XXXXX
   MAC Address: XX:XX:XX:XX:XX:XX
   Purchase Date: YYYY-MM-DD
   ```

#### Step 1.2: Power On Device

1. **Connect power adapter:**
   - Plug USB-C cable into router
   - Plug adapter into power outlet

2. **Wait for boot sequence:**
   - Power LED will flash blue (30-60 seconds)
   - Power LED will turn solid blue
   - Wi-Fi LED will turn solid white

3. **Verify boot complete:**
   - Both LEDs should be solid (not flashing)
   - Total boot time: ~60 seconds

#### Step 1.3: Connect to Device

**Option A: Via Wi-Fi (Recommended for first-time setup)**

1. **Find default Wi-Fi network:**
   - Network name: `GL-SFT1200-XXX` (XXX = last 3 digits of MAC)
   - Example: `GL-SFT1200-A1B`

2. **Locate default password:**
   - Check label on bottom of device
   - Look for "Wi-Fi Key" or "Password"
   - Example: `goodlife`

3. **Connect your computer:**
   - Open Wi-Fi settings
   - Select `GL-SFT1200-XXX`
   - Enter default password
   - Wait for connection (5-10 seconds)

**Option B: Via Ethernet**

1. **Connect Ethernet cable:**
   - One end to computer
   - Other end to **LAN1** or **LAN2** port (yellow)
   - **Do NOT use WAN port (blue) yet**

2. **Verify connection:**
   - Computer should auto-obtain IP address
   - IP should be in range: 192.168.8.x

#### Step 1.4: Access Admin Panel

1. **Open web browser**
2. **Navigate to:** `http://192.168.8.1`
3. **You should see:** GL.iNet initial setup wizard

**If you cannot access:**
- Check connection (Wi-Fi or Ethernet)
- Try different browser
- Clear browser cache
- Verify IP address: `ipconfig` (Windows) or `ifconfig` (macOS/Linux)

#### Step 1.5: Complete Initial Setup Wizard

**Screen 1: Set Admin Password**

1. **Choose strong admin password:**
   - Minimum 8 characters
   - Mix of letters, numbers, symbols
   - **Document this password securely**

2. **Confirm password**
3. **Click:** "Next"

**Screen 2: Time Zone**

1. **Select your time zone**
2. **Click:** "Next"

**Screen 3: Internet Connection**

1. **Select:** "Cable" (Ethernet)
2. **Connect WAN cable:**
   - Unplug Ethernet from your modem/router
   - Plug into **WAN port (blue)** on GL-SFT1200
   - Plug other end back into modem/router

3. **Wait for connection:** (10-30 seconds)
4. **Status should show:** "Connected"
5. **Click:** "Next"

**Screen 4: Firmware Update Check**

1. **Router will check for updates**
2. **If update available:**
   - Note the version
   - **Do NOT update yet** (we'll do this in next phase)
3. **Click:** "Finish"

**Setup Complete!**
- You should now see the GL.iNet dashboard
- Note the current firmware version (top right)

---

### Phase 2: Firmware Upgrade (10 minutes)

**Why upgrade?** Latest firmware includes security patches, bug fixes, and improved WireGuard support.

#### Step 2.1: Download Latest Firmware

1. **Visit:** https://dl.gl-inet.com/router/sft1200/stable

2. **Identify latest stable version:**
   - Current latest: **4.3.25** (as of Oct 2025)
   - Look for most recent date

3. **Download firmware:**
   - Click: "Download for Common Upgrade"
   - File format: `.tar`
   - File size: ~15-20 MB
   - Save to your Downloads folder

4. **Verify download:**
   - Check file size (should be 15-20 MB)
   - File name example: `openwrt-sft1200-4.3.25.tar`

#### Step 2.2: Upload Firmware

1. **In admin panel, navigate to:**
   - Left sidebar → **SYSTEM**
   - Click → **Upgrade**

2. **Click tab:** "Local Upgrade"

3. **Click:** "Choose File"

4. **Select downloaded firmware file**

5. **Important settings:**
   - **UNCHECK** "Keep Settings"
   - This ensures clean installation

6. **Click:** "Install"

7. **Confirmation dialog:**
   - Read warning
   - Click: "Install" to confirm

#### Step 2.3: Wait for Upgrade

**Timeline:**
- Upload: 10-20 seconds
- Installation: 2-3 minutes
- Automatic reboot: 30-60 seconds
- **Total time: 3-5 minutes**

**What you'll see:**
1. Progress bar (0-100%)
2. "Installing..." message
3. "Rebooting..." message
4. Browser will lose connection (this is normal)

**LED behavior during upgrade:**
- Power LED: Flashing blue (installing)
- Power LED: Off briefly (rebooting)
- Power LED: Solid blue (boot complete)

**⚠️ CRITICAL: Do NOT power off device during upgrade!**

#### Step 2.4: Reconnect After Upgrade

1. **Wait 2 minutes** after LEDs stabilize

2. **Reconnect to router:**
   - Wi-Fi: Reconnect to `GL-SFT1200-XXX`
   - Ethernet: Should auto-reconnect

3. **Access admin panel:** `http://192.168.8.1`

4. **Log in** with admin password (set in Step 1.5)

5. **Verify firmware version:**
   - Check top-right corner
   - Should show: 4.3.25 (or latest version)

**If you cannot reconnect:**
- Wait another 2 minutes
- Power cycle device (unplug, wait 10 seconds, plug back in)
- Try accessing via Ethernet instead of Wi-Fi
- See Troubleshooting section

---

### Phase 3: Enable SSH Access (5 minutes)

SSH access is required for uploading provisioning scripts.

#### Step 3.1: Access LuCI (OpenWRT Interface)

1. **In admin panel, navigate to:**
   - Left sidebar → **SYSTEM**
   - Click → **Advanced Settings**

2. **Click:** "LuCI" button

3. **New tab opens** with OpenWRT interface

4. **Log in:**
   - Username: `root`
   - Password: (same as admin password)

#### Step 3.2: Configure SSH

1. **In LuCI, navigate to:**
   - Top menu → **System**
   - Click → **Administration**

2. **Scroll to:** "SSH Access" section

3. **Configure settings:**
   ```
   Interface: Unspecified (or LAN)
   Port: 22
   Password authentication: ✓ Enabled
   Allow root logins with password: ✓ Enabled
   Gateway ports: ✗ Disabled
   ```

4. **Click:** "Save & Apply" (bottom right)

5. **Wait 5 seconds** for changes to apply

#### Step 3.3: Test SSH Connection

**On macOS/Linux:**

```bash
ssh root@192.168.8.1
```

**On Windows (using PuTTY):**

1. Open PuTTY
2. Host Name: `192.168.8.1`
3. Port: `22`
4. Connection type: SSH
5. Click: "Open"

**Login:**
- Username: `root`
- Password: (admin password)

**Expected result:**

```
root@192.168.8.1's password: 
BusyBox v1.36.1 (2025-03-07 10:15:23 UTC) built-in shell (ash)

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 GL.iNet OpenWrt 21.02-SNAPSHOT, r16279-5cc0535800
 -----------------------------------------------------
root@GL-SFT1200:~# 
```

**Test commands:**

```bash
# Check system info
uname -a

# Check WireGuard is installed
opkg list-installed | grep wireguard

# Exit SSH
exit
```

**Expected WireGuard output:**

```
kmod-wireguard - 5.4.238+1.0.20220627-1
wireguard-tools - 1.0.20210914-2
```

**If WireGuard is NOT installed:**

```bash
ssh root@192.168.8.1
opkg update
opkg install wireguard-tools kmod-wireguard
exit
```

---

### Phase 4: Create Strat24 VPN Account (5 minutes)

#### Step 4.1: Access Strat24 VPN Platform

1. **Navigate to:** `https://vpn.strat24.com`
   - (Or your actual Strat24 VPN platform URL)

2. **Click:** "Register" or "Sign Up"

#### Step 4.2: Create User Account

1. **Enter client information:**
   ```
   Email: client@example.com
   Password: (strong password)
   Name: John Doe
   Organization: Example NGO
   ```

2. **Click:** "Register"

3. **You'll be redirected to dashboard**

#### Step 4.3: Retrieve License Key

1. **On dashboard, locate:** "License Key" section

2. **Copy license key:**
   - Format: `S24-XXXXXXXXXX-XXXX`
   - Example: `S24-1234567890-ABCD`

3. **Save license key securely:**
   - You'll need this in the next phase
   - Document in device inventory

4. **Optional: Test config download:**
   - Click: "Download Configuration"
   - Select: "WireGuard" protocol
   - Select: "Desktop" platform
   - A `.conf` file should download
   - Open it to verify it contains real credentials (not placeholders)

**If config contains placeholders:**
- Your VPN Resellers API token is not configured correctly
- Check environment variables in Vercel
- See code completion checklist

---

### Phase 5: Provision Device (10 minutes)

#### Step 5.1: Prepare Configuration File

1. **Copy template:**
   ```bash
   cp hardware/provisioning/device.conf.template device.conf
   ```

2. **Edit device.conf:**
   ```bash
   nano device.conf
   # or use any text editor
   ```

3. **Update configuration:**
   ```ini
   # Replace with actual values
   LICENSE_KEY="S24-1234567890-ABCD"  # From Step 4.3
   WIFI_SSID="Strat24-Secure"
   WIFI_PASSWORD="Str@t24!Secure#2025$Dev01"  # Generate unique password
   ```

4. **Generate strong Wi-Fi password:**
   - Minimum 12 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - Unique per device
   - Example: `Str@t24!Secure#2025$Dev01`

5. **Save file**

#### Step 5.2: Update Provisioning Script

1. **Edit provision.sh:**
   ```bash
   nano hardware/provisioning/provision.sh
   ```

2. **Find line 28:**
   ```bash
   API_ENDPOINT="https://vpn.strat24.com/api/vpn/config"
   ```

3. **Update with your actual URL:**
   ```bash
   API_ENDPOINT="https://your-actual-vpn-platform.vercel.app/api/vpn/config"
   ```

4. **Save file**

#### Step 5.3: Upload Files to Router

**On macOS/Linux:**

```bash
# Upload provisioning script
scp hardware/provisioning/provision.sh root@192.168.8.1:/root/provision.sh

# Upload configuration file
scp device.conf root@192.168.8.1:/root/device.conf
```

**On Windows (using WinSCP):**

1. **Open WinSCP**

2. **Connect:**
   - File protocol: SCP
   - Host name: `192.168.8.1`
   - Port: `22`
   - User name: `root`
   - Password: (admin password)

3. **Click:** "Login"

4. **Navigate to:** `/root/` (remote side)

5. **Upload files:**
   - Drag `provision.sh` from local to remote
   - Drag `device.conf` from local to remote

6. **Verify files uploaded:**
   - You should see both files in `/root/`

#### Step 5.4: Set Script Permissions

```bash
ssh root@192.168.8.1
chmod +x /root/provision.sh
ls -la /root/
```

**Expected output:**

```
-rwxr-xr-x    1 root     root          5432 Oct  3 16:30 provision.sh
-rw-r--r--    1 root     root           256 Oct  3 16:30 device.conf
```

#### Step 5.5: Run Provisioning Script

```bash
# Still in SSH session
/root/provision.sh
```

**Expected output:**

```
2025-10-03 16:30:00 - --- Starting Strat24 Provisioning Script v1.1 ---
2025-10-03 16:30:00 - Found License Key: S24-1234567890-ABCD
2025-10-03 16:30:00 - Wi-Fi SSID: Strat24-Secure
2025-10-03 16:30:01 - Fetching configuration from Strat24 VPN platform...
2025-10-03 16:30:02 - Successfully downloaded WireGuard configuration from Strat24.
2025-10-03 16:30:02 - Successfully parsed configuration fields.
2025-10-03 16:30:02 - VPN Server: vpn.example.com:51820
2025-10-03 16:30:03 - Applying configuration using UCI...
2025-10-03 16:30:03 - WireGuard interface configured successfully.
2025-10-03 16:30:04 - Configuring firewall and kill switch...
2025-10-03 16:30:05 - Firewall and kill switch configured.
2025-10-03 16:30:05 - Configuring secure Wi-Fi network...
2025-10-03 16:30:06 - Wi-Fi configuration applied: SSID=Strat24-Secure
2025-10-03 16:30:06 - Configuring DNS settings...
2025-10-03 16:30:07 - Using VPN DNS: 10.0.0.1
2025-10-03 16:30:07 - Committing UCI changes...
2025-10-03 16:30:08 - Restarting network, firewall, and wireless services...
2025-10-03 16:30:18 - Waiting for VPN connection to establish...
2025-10-03 16:30:28 - SUCCESS: VPN tunnel is UP and running!
2025-10-03 16:30:28 - Strat24 Secure Access Point is ready for deployment.
2025-10-03 16:30:28 - --- Strat24 Provisioning Script Finished ---
```

**Watch for:**
- ✅ License key found
- ✅ Configuration downloaded
- ✅ VPN tunnel UP
- ✅ No error messages

**If errors occur:**
- Check `/var/log/strat24_provision.log`
- Verify license key is correct
- Verify API endpoint URL is correct
- Verify router has internet access

#### Step 5.6: Configure Auto-Run on Boot

```bash
# Still in SSH session

# Create init script
cat << 'EOF' > /etc/init.d/strat24-vpn-provision
#!/bin/sh /etc/rc.common

START=99

start() {
    /root/provision.sh &
}
EOF

# Make executable
chmod +x /etc/init.d/strat24-vpn-provision

# Enable on boot
/etc/init.d/strat24-vpn-provision enable

# Verify enabled
ls -la /etc/rc.d/ | grep strat24
```

**Expected output:**

```
lrwxrwxrwx    1 root     root            33 Oct  3 16:31 S99strat24-vpn-provision -> ../init.d/strat24-vpn-provision
```

---

## Complete Testing Procedures

### Test Suite Overview

| Test # | Test Name | Duration | Critical |
|--------|-----------|----------|----------|
| 1 | WireGuard Interface Status | 1 min | ✅ Yes |
| 2 | WireGuard Connection Details | 2 min | ✅ Yes |
| 3 | Routing Table Verification | 1 min | ✅ Yes |
| 4 | VPN Connection from Router | 2 min | ✅ Yes |
| 5 | Client Device Connection | 5 min | ✅ Yes |
| 6 | IP Address Verification | 2 min | ✅ Yes |
| 7 | DNS Leak Test | 3 min | ✅ Yes |
| 8 | Kill Switch Test | 5 min | ✅ Yes |
| 9 | Speed Test | 5 min | ⚠️ Important |
| 10 | Reboot Persistence Test | 5 min | ✅ Yes |

**Total testing time: ~30 minutes**

---

### Test 1: WireGuard Interface Status

**Purpose:** Verify WireGuard interface is active

**Procedure:**

```bash
ssh root@192.168.8.1
ip link show wg0
```

**Expected output:**

```
5: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN qlen 1000
    link/none
```

**Success criteria:**
- ✅ Interface exists (wg0)
- ✅ Status shows: **UP,LOWER_UP**
- ✅ MTU is 1420

**If failed:**
- Interface not found: WireGuard not configured
- Status shows DOWN: VPN not connected
- Re-run provisioning script

---

### Test 2: WireGuard Connection Details

**Purpose:** Verify VPN tunnel is established and data is flowing

**Procedure:**

```bash
ssh root@192.168.8.1
wg show
```

**Expected output:**

```
interface: wg0
  public key: YourPublicKey123456789ABCDEFG=
  private key: (hidden)
  listening port: 51820

peer: ServerPublicKey987654321ZYXWVU=
  endpoint: vpn.example.com:51820
  allowed ips: 0.0.0.0/0
  latest handshake: 45 seconds ago
  transfer: 2.15 MiB received, 1.03 MiB sent
  persistent keepalive: every 25 seconds
```

**Success criteria:**
- ✅ Interface shows public key
- ✅ Peer is configured
- ✅ **Latest handshake** is recent (< 2 minutes)
- ✅ **Transfer** shows data sent/received
- ✅ Endpoint matches your VPN server

**If failed:**
- No handshake: VPN server unreachable
- Old handshake (>3 min): Connection unstable
- No transfer: No traffic flowing
- Check firewall, check VPN server status

---

### Test 3: Routing Table Verification

**Purpose:** Verify all traffic routes through VPN

**Procedure:**

```bash
ssh root@192.168.8.1
ip route
```

**Expected output:**

```
default dev wg0 scope link
10.0.0.0/24 dev wg0 proto kernel scope link src 10.0.0.5
192.168.8.0/24 dev br-lan proto kernel scope link src 192.168.8.1
```

**Success criteria:**
- ✅ **Default route** goes through **wg0**
- ✅ VPN subnet (10.0.0.0/24) via wg0
- ✅ LAN subnet (192.168.8.0/24) via br-lan

**If failed:**
- Default route via eth0 or other: Kill switch not working
- No wg0 routes: VPN not properly configured
- Re-run provisioning script

---

### Test 4: VPN Connection from Router

**Purpose:** Test connectivity from router itself

**Procedure:**

```bash
ssh root@192.168.8.1

# Test ping through VPN
ping -c 4 -I wg0 8.8.8.8

# Test DNS resolution
nslookup google.com

# Check public IP
curl -s --interface wg0 https://api.ipify.org
echo ""
```

**Expected output:**

```
# Ping should succeed
64 bytes from 8.8.8.8: seq=0 ttl=117 time=25.3 ms
64 bytes from 8.8.8.8: seq=1 ttl=117 time=24.8 ms
64 bytes from 8.8.8.8: seq=2 ttl=117 time=26.1 ms
64 bytes from 8.8.8.8: seq=3 ttl=117 time=25.5 ms

# DNS should resolve
Server:    10.0.0.1
Address 1: 10.0.0.1

Name:      google.com
Address 1: 142.250.185.46

# IP should be VPN server IP (not your real IP)
203.0.113.45
```

**Success criteria:**
- ✅ Ping succeeds with low latency (<100ms)
- ✅ DNS resolves correctly
- ✅ Public IP is VPN server (not your ISP IP)

**If failed:**
- Ping fails: VPN tunnel not working
- DNS fails: DNS configuration issue
- IP shows real location: Traffic not routing through VPN

---

### Test 5: Client Device Connection

**Purpose:** Connect a client device to secure Wi-Fi

**Procedure:**

1. **On your computer/phone, open Wi-Fi settings**

2. **Look for network:** `Strat24-Secure`

3. **Enter password:** (from device.conf)

4. **Connect to network**

5. **Verify connection:**
   - Should obtain IP: 192.168.8.x
   - Should have internet access

**Expected result:**
- ✅ Network visible
- ✅ Password accepted
- ✅ Connected successfully
- ✅ Internet works

**If failed:**
- Network not visible: Wi-Fi not configured (check wireless settings)
- Wrong password: Verify password in device.conf
- No internet: VPN tunnel down or routing issue

---

### Test 6: IP Address Verification

**Purpose:** Verify client traffic goes through VPN

**Procedure:**

1. **On client device, open browser**

2. **Visit:** https://www.whatismyip.com

3. **Note the displayed IP address and location**

**Expected result:**
- ✅ IP address is VPN server IP (not your real IP)
- ✅ Location shows VPN server location (not your real location)
- ✅ ISP shows VPN provider (not your real ISP)

**Example:**
```
Your IP: 203.0.113.45
Location: New York, United States
ISP: VPN Provider Name
```

**If failed:**
- Shows real IP: VPN not working or traffic leaking
- Shows real location: Kill switch not working
- **CRITICAL FAILURE** - Do not deploy device

---

### Test 7: DNS Leak Test

**Purpose:** Verify DNS queries go through VPN

**Procedure:**

1. **On client device, visit:** https://www.dnsleaktest.com

2. **Click:** "Standard Test" (or "Extended Test")

3. **Wait for results** (10-20 seconds)

4. **Review DNS servers shown**

**Expected result:**
- ✅ All DNS servers belong to VPN provider
- ✅ No DNS servers from your ISP
- ✅ Location matches VPN server location

**Example:**
```
DNS Server 1: 10.0.0.1 (VPN Provider, New York, US)
DNS Server 2: 10.0.0.2 (VPN Provider, New York, US)
```

**If failed:**
- Shows ISP DNS: DNS leak detected
- Mixed DNS: Partial leak
- **CRITICAL FAILURE** - Fix DNS configuration

**Fix DNS leak:**

```bash
ssh root@192.168.8.1

# Force VPN DNS
uci set dhcp.@dnsmasq[0].noresolv='1'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server='10.0.0.1'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

---

### Test 8: Kill Switch Test

**Purpose:** Verify internet is blocked if VPN fails

**⚠️ CRITICAL SECURITY TEST - DO NOT SKIP**

**Procedure:**

1. **Ensure client device is connected** to Strat24-Secure Wi-Fi

2. **Verify internet works:**
   - Open browser
   - Visit any website
   - Should load normally

3. **SSH into router:**
   ```bash
   ssh root@192.168.8.1
   ```

4. **Disable VPN interface:**
   ```bash
   ifdown wg0
   ```

5. **On client device, try to access internet:**
   - Try loading any website
   - Try pinging 8.8.8.8
   - **Should have NO internet access**

6. **Verify complete blockage:**
   - No websites load
   - No ping responses
   - Connection times out

7. **Re-enable VPN:**
   ```bash
   # In SSH session
   ifup wg0
   
   # Wait 10-15 seconds
   sleep 15
   
   # Verify VPN is up
   wg show
   ```

8. **On client device, verify internet restored:**
   - Websites should load again
   - Ping should work

**Expected result:**
- ✅ Internet works when VPN is up
- ✅ **Internet completely blocked when VPN is down**
- ✅ Internet restores when VPN comes back up

**If failed:**
- Internet works without VPN: **CRITICAL FAILURE**
- Kill switch not working
- Traffic leaking outside VPN tunnel
- **DO NOT DEPLOY DEVICE**

**Fix kill switch:**

```bash
ssh root@192.168.8.1

# Remove LAN to WAN forwarding
uci show firewall | grep forwarding

# Find and delete LAN→WAN rule
# Example: uci delete firewall.@forwarding[0]

# Commit and restart
uci commit firewall
/etc/init.d/firewall restart

# Test again
```

---

### Test 9: Speed Test

**Purpose:** Verify acceptable performance

**Procedure:**

1. **On client device, visit:** https://fast.com

2. **Wait for speed test** to complete (30-60 seconds)

3. **Record results:**
   - Download speed: ____ Mbps
   - Upload speed: ____ Mbps (click "Show more info")
   - Latency: ____ ms

4. **Compare to baseline:**
   - Test without VPN (disconnect from Strat24-Secure)
   - Connect to regular network
   - Run speed test again
   - Record baseline speeds

**Expected result:**
- ✅ VPN speed is 50-80% of baseline
- ✅ Latency increase < 50ms
- ✅ Speeds sufficient for client needs

**Example:**
```
Baseline (no VPN):  100 Mbps down / 20 Mbps up / 10ms latency
With VPN:           70 Mbps down / 15 Mbps up / 35ms latency
Overhead:           30% speed reduction / 25ms latency increase
Result:             ✅ Acceptable
```

**If failed:**
- Speed < 50% of baseline: Try different VPN server
- Very high latency (>100ms): Server too far away
- Speeds too slow for client: Upgrade base internet or VPN plan

---

### Test 10: Reboot Persistence Test

**Purpose:** Verify configuration survives reboot

**Procedure:**

1. **SSH into router:**
   ```bash
   ssh root@192.168.8.1
   ```

2. **Reboot device:**
   ```bash
   reboot
   ```

3. **SSH session will disconnect** (this is normal)

4. **Wait 2 minutes** for device to reboot

5. **Reconnect client device:**
   - Wi-Fi network should reappear
   - Connect to Strat24-Secure

6. **Verify VPN is working:**
   - Check IP: https://www.whatismyip.com
   - Should show VPN IP (not real IP)

7. **SSH back into router:**
   ```bash
   ssh root@192.168.8.1
   ```

8. **Verify VPN tunnel:**
   ```bash
   wg show
   ip link show wg0
   ```

**Expected result:**
- ✅ Device reboots successfully
- ✅ Wi-Fi network comes back with same SSID/password
- ✅ VPN tunnel re-establishes automatically
- ✅ Client traffic routes through VPN
- ✅ Kill switch still active

**If failed:**
- VPN doesn't reconnect: Auto-run not configured
- Wi-Fi changes: Configuration not persistent
- Need to re-run provisioning: Init script not enabled

**Fix auto-run:**

```bash
ssh root@192.168.8.1

# Verify init script exists
ls -la /etc/init.d/strat24-vpn-provision

# Enable if not enabled
/etc/init.d/strat24-vpn-provision enable

# Check enabled
ls -la /etc/rc.d/ | grep strat24

# Reboot and test again
reboot
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Cannot Access Admin Panel (192.168.8.1)

**Symptoms:**
- Browser shows "Connection refused"
- "Unable to connect" error
- Page doesn't load

**Diagnosis:**

```bash
# Check your IP address
ipconfig  # Windows
ifconfig  # macOS/Linux

# Your IP should be 192.168.8.x
```

**Solutions:**

1. **Verify physical connection:**
   - Check Ethernet cable is secure
   - Try different cable
   - Try different LAN port

2. **Manually set IP address:**
   - Windows: Control Panel → Network → Adapter Settings → Properties → IPv4
   - macOS: System Preferences → Network → Ethernet → Configure IPv4: Manually
   - Set IP: 192.168.8.100
   - Subnet: 255.255.255.0
   - Gateway: 192.168.8.1

3. **Clear browser cache:**
   - Use incognito/private mode
   - Clear cache and cookies
   - Try different browser

4. **Factory reset device:**
   - Hold reset button 10 seconds
   - Wait for reboot
   - Try accessing again

---

#### Issue: Provisioning Script Fails

**Symptoms:**
- Script shows error messages
- "Failed to download configuration"
- "VPN tunnel may not be established"

**Diagnosis:**

```bash
ssh root@192.168.8.1
cat /var/log/strat24_provision.log
```

**Common errors and solutions:**

**Error: "LICENSE_KEY not set"**
- Solution: Check device.conf file exists and contains LICENSE_KEY

**Error: "Failed to download configuration. HTTP Code: 404"**
- Solution: License key is invalid or doesn't exist
- Verify license key in Strat24 VPN platform

**Error: "Failed to download configuration. HTTP Code: 500"**
- Solution: VPN platform API error
- Check VPN Resellers API token in platform environment variables

**Error: "Failed to parse WireGuard configuration"**
- Solution: Downloaded config is invalid
- Check VPN Resellers API is working
- Verify config file manually

---

#### Issue: VPN Tunnel Not Establishing

**Symptoms:**
- `wg show` shows no handshake
- `ip link show wg0` shows DOWN
- No internet on client devices

**Diagnosis:**

```bash
ssh root@192.168.8.1

# Check WireGuard status
wg show

# Check interface status
ip link show wg0

# Check logs
logread | grep -i wireguard

# Check routing
ip route
```

**Solutions:**

1. **Check internet connectivity:**
   ```bash
   ping -c 4 8.8.8.8
   ```
   If fails: Router has no internet

2. **Check firewall blocking:**
   - Some ISPs block VPN traffic
   - Try connecting router to mobile hotspot
   - If works: ISP is blocking VPN

3. **Restart WireGuard:**
   ```bash
   ifdown wg0
   sleep 5
   ifup wg0
   sleep 10
   wg show
   ```

4. **Re-run provisioning:**
   ```bash
   /root/provision.sh
   ```

---

#### Issue: Slow VPN Speed

**Symptoms:**
- Internet very slow through VPN
- High latency (>100ms)
- Buffering on video

**Diagnosis:**

```bash
# Test base internet speed
ssh root@192.168.8.1
ifdown wg0
# Client tests speed at fast.com
ifup wg0
```

**Solutions:**

1. **Adjust MTU:**
   ```bash
   ssh root@192.168.8.1
   uci set network.wg0.mtu='1380'
   uci commit network
   /etc/init.d/network restart
   ```

2. **Try different VPN server:**
   - Create new user with different server location
   - Closer server = lower latency

3. **Check CPU usage:**
   ```bash
   ssh root@192.168.8.1
   top
   ```
   WireGuard should use <10% CPU

4. **Verify base internet is adequate:**
   - VPN adds 20-30% overhead
   - If base is 10 Mbps, VPN will be ~7 Mbps

---

#### Issue: Wi-Fi Network Not Visible

**Symptoms:**
- Cannot see "Strat24-Secure" network
- Wi-Fi list doesn't show SSID

**Diagnosis:**

```bash
ssh root@192.168.8.1
wifi status
uci show wireless | grep ssid
```

**Solutions:**

1. **Enable wireless:**
   ```bash
   uci set wireless.radio0.disabled='0'
   uci set wireless.radio1.disabled='0'
   uci commit wireless
   wifi reload
   ```

2. **Verify SSID:**
   ```bash
   uci show wireless | grep ssid
   ```
   Should show: `Strat24-Secure`

3. **Restart wireless:**
   ```bash
   wifi down
   wifi up
   ```

4. **Check 2.4GHz vs 5GHz:**
   - Some devices only see 2.4GHz
   - Try both bands

---

#### Issue: Kill Switch Not Working

**Symptoms:**
- Internet works when VPN is down
- Traffic leaking outside VPN

**⚠️ CRITICAL SECURITY ISSUE**

**Diagnosis:**

```bash
ssh root@192.168.8.1

# Check firewall rules
iptables -L -v -n | grep FORWARD

# Check forwarding rules
uci show firewall | grep forwarding
```

**Solutions:**

1. **Remove LAN→WAN forwarding:**
   ```bash
   # Find LAN to WAN rule
   uci show firewall | grep -A 2 forwarding
   
   # Delete the rule (adjust index as needed)
   uci delete firewall.@forwarding[0]
   
   # Commit
   uci commit firewall
   /etc/init.d/firewall restart
   ```

2. **Manually block:**
   ```bash
   iptables -I FORWARD -i br-lan -o eth0 -j DROP
   ```

3. **Re-run provisioning:**
   ```bash
   /root/provision.sh
   ```

4. **Test kill switch again** (see Test 8)

---

## Production Checklist

Before deploying device to client, verify:

### Configuration Checklist

- [ ] Firmware upgraded to latest stable (4.3.25+)
- [ ] SSH access enabled and tested
- [ ] WireGuard installed and verified
- [ ] Provisioning script uploaded
- [ ] Device configuration created with unique Wi-Fi password
- [ ] Provisioning script executed successfully
- [ ] Auto-run on boot configured and enabled

### Testing Checklist

- [ ] Test 1: WireGuard interface UP ✅
- [ ] Test 2: VPN handshake recent (<2 min) ✅
- [ ] Test 3: Default route via wg0 ✅
- [ ] Test 4: Router can ping through VPN ✅
- [ ] Test 5: Client device connects to Wi-Fi ✅
- [ ] Test 6: Client IP shows VPN location ✅
- [ ] Test 7: No DNS leaks detected ✅
- [ ] Test 8: Kill switch blocks internet when VPN down ✅
- [ ] Test 9: Speed acceptable (>50% baseline) ✅
- [ ] Test 10: Configuration persists after reboot ✅

### Documentation Checklist

- [ ] Device serial number recorded
- [ ] License key documented
- [ ] Wi-Fi SSID documented
- [ ] Wi-Fi password documented (securely)
- [ ] Client name/organization recorded
- [ ] Deployment location recorded
- [ ] VPN server location noted
- [ ] Provisioning date recorded
- [ ] Provisioned by (your name) recorded

### Client Delivery Checklist

- [ ] Device fully tested and working
- [ ] Device powered off and packaged
- [ ] Power adapter included
- [ ] Ethernet cable included
- [ ] Client quick start guide printed and included
- [ ] Wi-Fi password filled in on guide
- [ ] Strat24 support contact card included
- [ ] Shipping label attached
- [ ] Tracking number recorded
- [ ] Client notified of shipment

### Post-Deployment Checklist

- [ ] Delivery confirmed
- [ ] Follow-up email sent (24 hours after delivery)
- [ ] Client confirms device working
- [ ] Client can access internet through VPN
- [ ] Client verified IP shows VPN location
- [ ] No issues reported
- [ ] Device added to monitoring system
- [ ] Support ticket closed

---

## Appendix: Quick Reference

### Essential Commands

```bash
# SSH into router
ssh root@192.168.8.1

# Check VPN status
wg show

# Check interface status
ip link show wg0

# Check routing
ip route

# Restart VPN
ifdown wg0 && sleep 5 && ifup wg0

# Restart network
/etc/init.d/network restart

# Restart firewall
/etc/init.d/firewall restart

# Restart wireless
wifi reload

# View logs
logread | tail -50
cat /var/log/strat24_provision.log

# Reboot device
reboot
```

### Important Files

```
/root/provision.sh              - Provisioning script
/root/device.conf               - Device configuration
/var/log/strat24_provision.log  - Provisioning log
/etc/config/network             - Network configuration
/etc/config/wireless            - Wi-Fi configuration
/etc/config/firewall            - Firewall configuration
/etc/init.d/strat24-vpn-provision - Auto-run script
```

### Default Credentials

```
Admin Panel: http://192.168.8.1
Username: root (for SSH/LuCI)
Password: (set during initial setup)

Default Wi-Fi: GL-SFT1200-XXX
Default Password: (on device label)

After Provisioning:
Wi-Fi: Strat24-Secure
Password: (from device.conf)
```

### Support Contacts

```
Strat24 Support: support@strat24.com
Strat24 Security Operations: security-ops@strat24.com
Strat24 Website: https://strat24.com

GL.iNet Support: https://www.gl-inet.com/support/
GL.iNet Forum: https://forum.gl-inet.com
GL.iNet Docs: https://docs.gl-inet.com
```

---

**Document Version:** 1.0  
**Last Updated:** October 3, 2025  
**Maintained By:** Strat24 Operations Team  
**Classification:** Internal Use Only

For questions or updates to this guide, contact: support@strat24.com
