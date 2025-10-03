# Strat24 ImageBuilder Quick Start

## 🎯 Goal
Build custom GL.iNet Opal firmware with your VPN configs pre-installed. Clients get plug-and-play routers!

---

## ⚡ Super Quick Start (3 Commands)

```bash
cd imagebuilder
./download-imagebuilder.sh     # Downloads OpenWRT ImageBuilder (~200MB)
./build-strat24-firmware.sh    # Builds firmware (~10 minutes)
# Result: strat24-opal-multi-v1.0.0-YYYYMMDD.bin
```

**Then flash to router:**
- Upload via web UI: http://192.168.8.1 → System → Upgrade
- Or via SSH: `sysupgrade -n firmware.bin`

---

## 📋 What This Does

### Traditional Way (Manual):
1. Flash stock OpenWRT
2. SSH into router
3. Install packages
4. Upload configs
5. Configure firewall
6. Configure WiFi
7. Test everything
8. **Repeat for EVERY router** ❌

### ImageBuilder Way:
1. Build firmware ONCE ✅
2. Flash to ALL routers (5 minutes each)
3. Done! All identical, all working! ✅

---

## 🏗️ What Gets Included

Your custom firmware contains:

### Pre-Installed:
- ✅ WireGuard VPN (4 servers: NL, CA, US, TH)
- ✅ VPN configs with YOUR keys
- ✅ Strat24 WiFi branding
- ✅ Kill switch enabled
- ✅ Firewall configured
- ✅ Web portal
- ✅ Auto-start on boot

### Default Settings:
- WiFi SSID: `Strat24-Secure`
- WiFi Password: `ChangeThisPassword123!`
- Admin IP: `192.168.8.1`
- VPN: Auto-connects to Netherlands

---

## 🔧 Build Profiles

### Profile: **single** (smallest, ~15MB)
```bash
./build-strat24-firmware.sh single
```
- 1 VPN server (Netherlands only)
- Minimal packages
- Use case: Basic deployment, limited flash space

### Profile: **multi** (recommended, ~16MB)
```bash
./build-strat24-firmware.sh multi
```
- 4 VPN servers (NL, CA, US, TH)
- WireGuard web UI
- Use case: Standard client deployment

### Profile: **full** (feature-rich, ~20MB)
```bash
./build-strat24-firmware.sh full
```
- Everything in multi +
- Monitoring tools (htop, tcpdump, iperf3)
- Use case: Enterprise, troubleshooting

---

## 🎨 Customization

### Change VPN Configs:
Edit your actual configs:
```bash
# Replace with your VPN Resellers configs
cp ~/Downloads/new-nl1.conf nl1.conf
cp ~/Downloads/new-ca3.conf ca3.conf
# etc...
```

### Change WiFi Settings:
Edit in build script, lines 180-190:
```
option ssid 'YourCompanyName'
option key 'YourSecurePassword!'
```

### Change Branding:
Edit `files/etc/banner` - your custom login message
Edit `files/www/index.html` - your custom web portal

### Rebuild:
```bash
./build-strat24-firmware.sh multi
```

---

## 🧪 Testing Checklist

### Before Mass Deployment:

**Flash Test Router:**
```bash
# Upload firmware via web UI or:
scp strat24-opal-*.bin root@192.168.8.1:/tmp/
ssh root@192.168.8.1 "sysupgrade -n /tmp/strat24-opal-*.bin"
```

**Test (30 minutes):**
- [ ] Router boots (wait 3 minutes)
- [ ] WiFi "Strat24-Secure" appears
- [ ] Can connect with password
- [ ] Gets IP from router (192.168.8.x)
- [ ] Can access web UI (192.168.8.1)
- [ ] VPN is connected: `ssh root@192.168.8.1 "wg show"`
- [ ] Check public IP: https://ifconfig.me (should show VPN location)
- [ ] Disconnect VPN: `wg-quick down wg-nl`
- [ ] Check internet: Should be BLOCKED (kill switch working)
- [ ] Reconnect VPN: `wg-quick up wg-nl`
- [ ] Internet works again
- [ ] Reboot router: `reboot`
- [ ] Wait 3 minutes, VPN auto-reconnects

**24-Hour Soak Test:**
- Leave running for 24 hours
- Check logs: `logread | grep -i error`
- Monitor connection: `wg show`

**If all pass → Ready for mass deployment!**

---

## 🚀 Mass Deployment Workflow

### For 10+ Routers:

**1. Build Firmware** (once):
```bash
./build-strat24-firmware.sh multi
```

**2. Flash All Routers** (parallel):
```bash
# Connect all routers to network
# Create list of IPs
echo "192.168.8.1
192.168.8.2
192.168.8.3" > router-ips.txt

# Flash all (script runs in parallel)
while read ip; do
  (scp firmware.bin root@$ip:/tmp/ && \
   ssh root@$ip "sysupgrade -n /tmp/firmware.bin") &
done < router-ips.txt
```

**3. Quality Check** (sample 10%):
- Test 1 in 10 routers thoroughly
- Quick check others

**4. Ship to Clients**

---

## 🔐 Security Best Practices

### ⚠️ VPN Keys in Firmware

Your VPN private keys are EMBEDDED in the firmware!

**Do:**
- ✅ Keep firmware files secure
- ✅ Generate unique keys per batch
- ✅ Track which firmware has which keys
- ✅ Rotate keys periodically

**Don't:**
- ❌ Share firmware publicly
- ❌ Put on public GitHub
- ❌ Reuse same keys for years

### Alternative: Secure Provisioning

Instead of embedding keys, use on-first-boot provisioning:

1. Build firmware WITHOUT keys
2. Include provisioning script
3. Script fetches unique keys from your API on first boot
4. More secure, slightly more complex

(Contact support@strat24.com for help implementing)

---

## 📊 Version Control

Track your builds:

```bash
# After successful build
echo "## Build $(date)" >> BUILD_HISTORY.md
echo "- Firmware: strat24-opal-multi-v1.0.0" >> BUILD_HISTORY.md
echo "- VPN Servers: NL, CA, US, TH" >> BUILD_HISTORY.md  
echo "- Deployed: 25 units to Client XYZ" >> BUILD_HISTORY.md

# Tag in git
git add -A
git commit -m "Firmware build v1.0.0 for Client XYZ batch"
git tag firmware-v1.0.0-client-xyz
git push --tags
```

---

## 🆘 Troubleshooting

### Build Fails

**Clean and retry:**
```bash
rm -rf openwrt-imagebuilder-*
./download-imagebuilder.sh
./build-strat24-firmware.sh
```

### Firmware Too Large

GL.iNet Opal has ~16MB flash. If firmware > 16MB:
- Use `single` profile
- Remove unnecessary packages
- Remove monitoring tools

### Router Won't Boot

**Recovery:**
1. Hold reset button 10 seconds
2. Flash stock GL.iNet firmware from:
   https://dl.gl-inet.com
3. Then reflash Strat24 firmware

### VPN Won't Connect

Check config files:
```bash
ssh root@192.168.8.1
cat /etc/wireguard/wg-nl.conf
# Verify keys are present
wg show  # Should show interface
```

---

## 📞 Support

**Questions?**
- Email: support@strat24.com
- Internal Wiki: [link]
- Build Issues: Open GitHub issue

**Resources:**
- OpenWRT ImageBuilder: https://openwrt.org/docs/guide-user/additional-software/imagebuilder
- GL.iNet Docs: https://docs.gl-inet.com
- WireGuard: https://www.wireguard.com

---

## 🎓 Next Steps

1. **Read:** `imagebuilder/README.md` (detailed docs)
2. **Download:** `./download-imagebuilder.sh`
3. **Build:** `./build-strat24-firmware.sh multi`
4. **Test:** Flash one router, run checklist
5. **Deploy:** Flash all routers, ship to clients
6. **Track:** Update BUILD_HISTORY.md

---

**Happy Building! 🚀**

---

**Last Updated:** October 3, 2025  
**Maintained By:** Strat24 Operations Team  
**Version:** 1.0

