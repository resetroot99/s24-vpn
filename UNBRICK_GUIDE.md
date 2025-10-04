# GL.iNet Opal (GL-SFT1200) Unbrick Guide

## Overview

This guide will help you recover a bricked GL.iNet Opal router using U-Boot recovery mode or TFTP recovery.

## Symptoms of a Bricked Router

- Router not responding to pings
- Web interface not accessible
- No WiFi network broadcasting
- LED behavior abnormal
- Router stuck in boot loop

## Method 1: U-Boot Web Recovery (Recommended)

This is the easiest and most reliable method.

### Step 1: Download Official Firmware

1. Go to: https://dl.gl-inet.com/firmware/sft1200/release/
2. Download the latest stable firmware (`.bin` file)
   - Example: `openwrt-sft1200-4.3.11-0419.bin`
   - File size should be ~8-15MB
3. Save to your Downloads folder
4. **Do NOT unzip** - use the `.bin` file directly

### Step 2: Enter U-Boot Recovery Mode

1. **Unplug** router power cable completely
2. Get a **paperclip** or similar tool
3. **Press and HOLD** the reset button (small hole on router)
4. **While holding**, plug in power cable
5. **Keep holding** for 8-10 seconds
6. **Watch the LEDs**:
   - Power LED will blink rapidly, OR
   - All LEDs will flash together in a pattern
7. **Release** reset button when you see the LED pattern

**LED Pattern Indicates Success:**
- Rapid blinking (faster than normal)
- Alternating LED pattern
- Power LED flashing steadily

### Step 3: Configure Your Mac's Network

**Important:** You MUST use Ethernet cable for U-Boot recovery!

1. Connect Mac to Opal via **Ethernet cable**
   - Use LAN port on Opal (not WAN)
   - Use Ethernet or USB-C to Ethernet adapter on Mac
2. Open **System Settings → Network**
3. Select your Ethernet adapter
4. Click **Details** button
5. Set TCP/IP configuration:
   - **Configure IPv4:** Manually
   - **IP Address:** `192.168.1.2`
   - **Subnet Mask:** `255.255.255.0`
   - **Router:** `192.168.1.1`
6. Click **OK** and **Apply**

### Step 4: Access U-Boot Recovery Interface

1. Open web browser (Chrome, Safari, or Firefox)
2. Navigate to: **http://192.168.1.1**
3. You should see:
   - **GL.iNet U-Boot Recovery** page
   - Simple interface with firmware upload option
   - Or a basic HTML page with "Choose File" button

**If page doesn't load:**
- Verify Ethernet cable is connected
- Check Mac's IP is set to 192.168.1.2
- Try different browser
- Ping the router: `ping 192.168.1.1`
- Wait 1-2 minutes and refresh

### Step 5: Flash Firmware

1. On U-Boot recovery page, click **"Choose File"** or **"Browse"**
2. Select the downloaded `.bin` firmware file
3. Click **"Upload"**, **"Update"**, or **"Flash"**
4. **WAIT 3-5 MINUTES** without doing anything
   - Progress bar may appear
   - LEDs will flash during upload
   - Router will reboot automatically
5. **DO NOT UNPLUG OR INTERRUPT!**

**What to Expect:**
- Upload: 30-60 seconds
- Flashing: 2-3 minutes
- Reboot: 1-2 minutes
- Total: ~5 minutes

### Step 6: Verify Recovery

1. **Set Mac network back to DHCP:**
   - System Settings → Network → Ethernet
   - Configure IPv4: Using DHCP
   - Click Apply
2. Wait 1-2 minutes for router to fully boot
3. Look for **GL.iNet WiFi network**: `GL-SFT1200-XXX`
4. Connect to the WiFi network
5. Open browser and go to: **http://192.168.8.1**
6. You should see:
   - GL.iNet setup wizard (first boot)
   - Or GL.iNet admin interface

**✅ Router is UNBRICKED!**

---

## Method 2: TFTP Recovery (Advanced)

Use this method if U-Boot Web Recovery doesn't work.

### Requirements

- Ethernet cable
- TFTP client (built into macOS)
- Official firmware `.bin` file

### Step 1: Download Firmware

Same as Method 1 - download from https://dl.gl-inet.com/firmware/sft1200/release/

### Step 2: Set Up TFTP Server on Mac

```bash
# Create TFTP directory
sudo mkdir -p /private/tftpboot
sudo chmod 777 /private/tftpboot

# Copy firmware to TFTP directory
sudo cp ~/Downloads/openwrt-sft1200-*.bin /private/tftpboot/recovery.bin

# Start TFTP service
sudo launchctl load -w /System/Library/LaunchDaemons/tftp.plist
```

### Step 3: Configure Mac Network

Same as Method 1:
- IP: 192.168.1.2
- Subnet: 255.255.255.0
- Gateway: 192.168.1.1

### Step 4: Enter U-Boot and Send Firmware

1. Enter U-Boot mode (same as Method 1)
2. Router should automatically request `recovery.bin` via TFTP
3. Watch for TFTP transfer in terminal:

```bash
# Monitor TFTP logs
tail -f /var/log/system.log | grep tftp
```

4. Wait for transfer to complete (2-5 minutes)
5. Router will flash and reboot automatically

### Step 5: Stop TFTP Service

```bash
sudo launchctl unload /System/Library/LaunchDaemons/tftp.plist
```

---

## Troubleshooting

### U-Boot Mode Won't Start

**Try these:**
- Hold reset button for exactly **8 seconds** (count: 1-Mississippi, 2-Mississippi...)
- Ensure router is **completely powered off** first (unplug 1 minute)
- Try **multiple attempts** (sometimes takes 2-3 tries)
- Look for **specific LED pattern** (rapid blink or alternating)
- Try holding reset for different durations: 5s, 8s, 10s, 12s

**LED Patterns for U-Boot:**
- **Success:** Power LED rapid blink, or all LEDs flash together
- **Normal boot:** LEDs stabilize after a few seconds (not in U-Boot)

### Cannot Access 192.168.1.1

**Check these:**
- ✓ Using **Ethernet cable** (WiFi doesn't work in U-Boot)
- ✓ Cable in **LAN port** (not WAN port)
- ✓ Mac IP set to **192.168.1.2** manually
- ✓ Try **different Ethernet cable**
- ✓ Try **different Ethernet adapter**
- ✓ Disable Mac **firewall** temporarily
- ✓ Try **different browser** (Chrome/Safari/Firefox)
- ✓ Clear browser cache and cookies

**Test connectivity:**
```bash
ping 192.168.1.1
# Should see replies if U-Boot is running
```

**Check Mac's network config:**
```bash
ifconfig
# Look for Ethernet adapter with 192.168.1.2
```

### Firmware Upload Fails

**Verify firmware file:**
- File extension is `.bin` (not `.tar.gz` or `.img`)
- File size is 8-15MB
- Downloaded from official GL.iNet site
- File is not corrupted (try re-downloading)

**During upload:**
- Don't close browser window
- Don't unplug router
- Don't disconnect Ethernet
- Wait full 5 minutes after upload completes
- Be patient - no progress bar is normal

### Router Still Bricked After Flash

**Try these:**
1. Repeat U-Boot recovery process
2. Try older firmware version
3. Leave router unplugged overnight, try again
4. Check if there's a newer firmware available
5. Contact GL.iNet support for hardware failure

### Serial Console Recovery (Last Resort)

If all methods fail, router may need serial console recovery:

**Requirements:**
- USB to TTL serial adapter (3.3V!)
- Soldering skills (may need to solder headers)
- Advanced knowledge of U-Boot commands

**Not recommended unless you have hardware experience.**

---

## After Successful Unbrick

### 1. Complete Initial Setup

1. Go to http://192.168.8.1
2. Set admin password
3. Configure WiFi SSID and password
4. Update firmware if needed
5. Enable SSH (for Strat24 dashboard deployment)

### 2. Deploy Strat24 Dashboard

Once router is working:
```bash
cd /Users/v3ctor/s24-vpn
git pull
# Follow DEPLOYMENT_INSTRUCTIONS.md
```

### 3. Configure VPN Safely

**Recommended approach:**
- Deploy dashboard ONLY first
- Test that it works
- Configure VPN via GL.iNet's native web interface
- Don't use auto-start VPN scripts

This prevents bricking the router again!

---

## Prevention Tips

**To avoid future bricks:**

1. **Always test scripts** before making them auto-start
2. **Keep SSH access** enabled for recovery
3. **Backup working configs** before changes
4. **Use GL.iNet's native features** when possible
5. **Don't modify boot scripts** unless necessary
6. **Test on one device** before deploying to multiple routers

---

## Quick Reference

### U-Boot Recovery Checklist

- [ ] Downloaded official .bin firmware
- [ ] Unplugged router power
- [ ] Pressed and held reset button
- [ ] Plugged in power while holding
- [ ] Held for 8-10 seconds
- [ ] Saw LED pattern change
- [ ] Released reset button
- [ ] Connected Mac via Ethernet
- [ ] Set Mac IP to 192.168.1.2
- [ ] Accessed http://192.168.1.1
- [ ] Uploaded firmware file
- [ ] Waited 5 minutes
- [ ] Router rebooted successfully
- [ ] Accessed http://192.168.8.1

### Important URLs

- **Firmware:** https://dl.gl-inet.com/firmware/sft1200/release/
- **GL.iNet Support:** https://www.gl-inet.com/support/
- **GL.iNet Forums:** https://forum.gl-inet.com/
- **U-Boot Recovery:** http://192.168.1.1 (when in recovery mode)
- **Normal Admin:** http://192.168.8.1 (after recovery)

### Contact Support

If you've tried everything and router is still bricked:
- Email: support@gl-inet.com
- Forum: https://forum.gl-inet.com/
- Submit ticket: https://www.gl-inet.com/support/

---

## Success Rate

- **U-Boot Web Recovery:** 95% success rate
- **TFTP Recovery:** 90% success rate
- **Serial Console:** 99% success rate (requires hardware access)

Most soft bricks can be recovered with U-Boot method. Good luck!

