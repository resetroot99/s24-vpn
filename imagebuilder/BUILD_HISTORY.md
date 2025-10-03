# Strat24 Firmware Build History

## Version 1.0.0 - Initial Release
**Build Date:** October 3, 2025  
**Profile:** multi  
**OpenWRT Version:** 22.03.5

### Features:
- Pre-configured WireGuard VPN (4 servers)
- Strat24 branding
- Kill switch enabled
- WiFi: Strat24-Secure (default)
- Web portal included

### VPN Servers:
- 🇳🇱 Netherlands (nl1.ipcover.net:55888)
- 🇨🇦 Canada (ca3.ipcover.net:55888)
- 🇺🇸 USA (us1.ipcover.net:55888)
- 🇹🇭 Thailand (th1.ipcover.net:55888)

### Packages Included:
- wireguard-tools
- kmod-wireguard
- luci + luci-theme-material
- luci-app-wireguard
- curl, wget
- openssh-sftp-server
- iptables-nft, firewall4

### Testing Status:
- [ ] Boots successfully
- [ ] VPN connects
- [ ] Kill switch works
- [ ] WiFi functional
- [ ] Web UI accessible
- [ ] 24-hour stability test

### Notes:
- First production build
- Ready for initial client deployment
- Default password must be changed on first login

---

## Build Template

```
## Version X.X.X - Title
**Build Date:** YYYY-MM-DD
**Profile:** single/multi/full
**OpenWRT Version:** XX.XX.X

### Changes:
- Change 1
- Change 2

### Testing Status:
- [x] Feature tested
- [ ] Feature pending

### Notes:
- Important notes

---
```

