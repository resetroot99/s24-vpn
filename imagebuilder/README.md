# Strat24 Custom Firmware Builder
## OpenWRT ImageBuilder for GL.iNet Opal (GL-SFT1200)

This directory contains everything needed to build custom Strat24-branded firmware images with VPN pre-configured.

---

## 🎯 What This Does

Creates flashable firmware images that include:
- ✅ WireGuard VPN pre-configured (4 servers: NL, CA, US, TH)
- ✅ Strat24 branding and WiFi settings
- ✅ Kill switch and firewall pre-configured
- ✅ Zero-touch deployment for clients
- ✅ Automatic VPN connection on boot

---

## 📋 Prerequisites

### On Your Build Machine:

```bash
# macOS
brew install coreutils findutils gnu-tar grep bash

# Linux (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install build-essential gawk unzip ncurses-dev zlib1g-dev git wget

# Check you have at least 10GB free space
df -h
```

---

## 🚀 Quick Start (Build Custom Firmware)

### Step 1: Download ImageBuilder

```bash
cd imagebuilder
./download-imagebuilder.sh
```

This downloads the official GL.iNet Opal ImageBuilder.

### Step 2: Build Firmware

```bash
./build-strat24-firmware.sh
```

This creates: `strat24-opal-firmware-vX.X.X.bin`

### Step 3: Flash to Router

**Option A: Via Web UI**
1. Go to: http://192.168.8.1
2. System → Upgrade
3. Upload: `strat24-opal-firmware-*.bin`
4. Wait 5 minutes
5. Done!

**Option B: Via Command Line**
```bash
scp strat24-opal-firmware-*.bin root@192.168.8.1:/tmp/
ssh root@192.168.8.1 "sysupgrade -n /tmp/strat24-opal-firmware-*.bin"
```

---

## 📁 Directory Structure

```
imagebuilder/
├── README.md                          # This file
├── download-imagebuilder.sh           # Download official ImageBuilder
├── build-strat24-firmware.sh          # Build custom firmware
├── files/                             # Files to include in firmware
│   ├── etc/
│   │   ├── config/
│   │   │   ├── network                # Network config
│   │   │   ├── wireless               # WiFi config
│   │   │   ├── firewall               # Firewall config
│   │   │   └── dhcp                   # DHCP/DNS config
│   │   ├── wireguard/
│   │   │   ├── wg-nl.conf             # Netherlands VPN
│   │   │   ├── wg-ca.conf             # Canada VPN
│   │   │   ├── wg-us.conf             # USA VPN
│   │   │   └── wg-th.conf             # Thailand VPN
│   │   ├── rc.local                   # Startup script
│   │   └── banner                     # Strat24 login banner
│   └── www/
│       └── index.html                 # Strat24 web portal
├── packages/                          # Custom packages (if any)
└── profiles/
    ├── default.profile                # Default build profile
    └── multi-server.profile           # Multi-server build profile
```

---

## 🔧 Customization

### Change WiFi Settings

Edit: `files/etc/config/wireless`

```
config wifi-iface 'default_radio0'
    option ssid 'YourNetworkName'      # Change this
    option key 'YourPassword'          # Change this
```

### Change VPN Servers

Replace configs in: `files/etc/wireguard/`

### Change Branding

Edit: `files/etc/banner`

---

## 📦 What Gets Included

### Packages:
- WireGuard (wireguard-tools, kmod-wireguard)
- Firewall (iptables-nft, firewall4)
- Web UI (luci, luci-theme-material)
- Utilities (curl, wget, openssh-sftp-server)

### Custom Files:
- Pre-configured VPN configs
- Strat24 branding
- Automatic startup scripts
- Web portal

---

## 🎨 Build Profiles

### Profile 1: Single Server (smallest image)
```bash
./build-strat24-firmware.sh single
```
- Includes: 1 VPN server (Netherlands)
- Size: ~15MB
- Use case: Basic deployment

### Profile 2: Multi-Server (recommended)
```bash
./build-strat24-firmware.sh multi
```
- Includes: 4 VPN servers (NL, CA, US, TH)
- Size: ~16MB
- Use case: Client choice of locations

### Profile 3: Full Feature
```bash
./build-strat24-firmware.sh full
```
- Includes: Everything + monitoring tools
- Size: ~20MB
- Use case: Enterprise deployment

---

## 🧪 Testing Firmware

### Before Mass Deployment:

1. **Flash one device**
2. **Test checklist:**
   - [ ] Router boots successfully
   - [ ] WiFi network appears
   - [ ] Can connect to WiFi
   - [ ] VPN tunnel establishes
   - [ ] Internet works through VPN
   - [ ] IP shows VPN location
   - [ ] Kill switch works (disconnect VPN = no internet)
   - [ ] Survives reboot
   - [ ] Web UI accessible
   - [ ] SSH accessible

3. **Run for 24 hours**
4. **Check logs:** `logread | grep -i error`
5. **Monitor connection:** `wg show`

---

## 🔐 Security Notes

### Private Keys in Firmware:

⚠️ **IMPORTANT**: Your VPN private keys will be embedded in the firmware!

**Best practices:**
1. Generate unique configs per client/batch
2. Never share firmware publicly
3. Keep firmware images secure
4. Use different keys for different deployments

### Alternative: On-First-Boot Provisioning

Instead of embedding keys, you can:
1. Build firmware without keys
2. Include provisioning script
3. Script fetches keys from your API on first boot
4. More secure, slightly more complex

See: `profiles/secure-provisioning.profile`

---

## 📊 Version Control

Track your builds:

```bash
# Tag each build
git tag -a firmware-v1.0.0 -m "Initial Strat24 firmware release"
git push origin firmware-v1.0.0

# Build notes
echo "Build: firmware-v1.0.0" >> BUILD_HISTORY.md
echo "Date: $(date)" >> BUILD_HISTORY.md
echo "Changes: Initial release with 4 VPN servers" >> BUILD_HISTORY.md
```

---

## 🆘 Troubleshooting

### Build Fails

```bash
# Clean and retry
rm -rf openwrt-imagebuilder-*
./download-imagebuilder.sh
./build-strat24-firmware.sh
```

### Firmware Too Large

- Use single-server profile
- Remove unnecessary packages
- Compress files

### Router Won't Boot After Flash

- Hold reset 10 seconds
- Flash stock firmware first
- Then reflash Strat24 firmware

---

## 📚 Additional Resources

- OpenWRT ImageBuilder: https://openwrt.org/docs/guide-user/additional-software/imagebuilder
- GL.iNet Forum: https://forum.gl-inet.com
- WireGuard Docs: https://www.wireguard.com

---

## 🤝 Contributing

Internal Strat24 project. For improvements:
1. Test changes thoroughly
2. Document modifications
3. Update BUILD_HISTORY.md
4. Tag releases

---

**Last Updated:** October 3, 2025  
**Maintained By:** Strat24 Operations Team  
**Support:** support@strat24.com

