# Strat24 GL.iNet Opal Manual Setup Guide

## 🎯 Simple 3-Step Process

Since SSH automation isn't working, here's the manual way (just as easy!):

---

## Step 1: Access Your GL.iNet Opal

### Method A: WiFi Connection (Recommended)
1. **Disconnect** from all networks
2. **Connect to** GL.iNet WiFi: `GL-SFT1200-xxx`
3. **Password:** Check router label (usually "goodlife")
4. **Open browser:** http://192.168.8.1
5. **Login:** admin / (password on label)

### Method B: Factory Reset First (if can't access)
1. **Hold reset button** 10 seconds with paperclip
2. **Wait 1 minute** for reboot
3. **Follow Method A** above

---

## Step 2: Add VPN Configurations

### In GL.iNet Web Interface:

1. **Go to:** VPN → WireGuard Client
2. **Click:** "Add a New WireGuard Configuration"
3. **Choose:** "Manual Input"

### Add All 4 Servers:

#### **Netherlands Server (NL)**
```
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = nl1.ipcover.net:55888
PersistentKeepalive = 25
```
**Name:** Strat24-NL

---

#### **Canada Server (CA)**
```
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = ca3.ipcover.net:55888
PersistentKeepalive = 25
```
**Name:** Strat24-CA

---

#### **USA Server (US)**
```
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = us1.ipcover.net:55888
PersistentKeepalive = 25
```
**Name:** Strat24-US

---

#### **Thailand Server (TH)**
```
[Interface]
PrivateKey = gjMRrgTxpc+KVKjilLz45xMcH/gEaT8dXPS5KzhnEKg=
Address = 10.253.104.145/32
DNS = 172.16.0.1

[Peer]
PublicKey = WxwZf+b2RTA0ixXq/j6z9oVdnS75HxXDVadM1nC36BY=
AllowedIPs = 0.0.0.0/0,::/0
Endpoint = th1.ipcover.net:55888
PersistentKeepalive = 25
```
**Name:** Strat24-TH

---

## Step 3: Configure WiFi & Enable VPN

### Set WiFi Name:
1. **Go to:** Wireless → WiFi Settings
2. **SSID:** `strat24secureWIFI`
3. **Password:** `Strat24Secure`
4. **Save & Apply**

### Enable VPN:
1. **Go to:** VPN → WireGuard Client
2. **Select:** Strat24-NL (or any server)
3. **Click:** Connect
4. **Enable:** "VPN Kill Switch" (blocks internet if VPN fails)

### Test:
1. **Connect device** to `strat24secureWIFI`
2. **Visit:** https://whatismyip.com
3. **Should show:** Netherlands (or selected server country)

---

## 🎉 Done!

Your GL.iNet Opal is now a secure VPN router!

### To Switch Servers:
- Go to VPN → WireGuard Client
- Disconnect current server
- Connect to different server (NL, CA, US, or TH)

### For Multiple WiFi Networks (Advanced):
If you want separate WiFi for each server:
1. Go to: More Settings → Custom DNS & DHCP
2. Set up guest networks
3. Route each to different VPN

---

## 📱 Client Connection:

Users just need to:
1. Connect to WiFi: `strat24secureWIFI`
2. Password: `Strat24Secure`
3. That's it! All traffic is VPN-secured.

---

## 🔧 Troubleshooting:

**Can't access http://192.168.8.1?**
- Make sure you're connected to GL.iNet WiFi
- Try: http://192.168.8.1:83
- Try: http://glinet.local

**VPN won't connect?**
- Check internet connection (WAN cable plugged in?)
- Verify configs are copied exactly
- Check VPN Resellers account is active

**No internet on client devices?**
- Make sure VPN is connected (green status)
- Check WAN cable to Opal
- Restart Opal from web UI

---

## 📞 Need Help?

Check files in your project:
- `nl1.conf`, `ca3.conf`, `us1.conf`, `th1.conf` - Your original configs
- This guide - Keep for reference

---

**Strat24 Secure VPN Access Point**
Built with GL.iNet Opal + VPN Resellers WireGuard

