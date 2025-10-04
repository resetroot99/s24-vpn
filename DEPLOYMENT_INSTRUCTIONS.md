# STRAT24 Router Dashboard - Deployment Instructions

## Summary

Custom GL.iNet router dashboard with Strat24 branding, VPN server selection, WiFi configuration, and captive portal support.

## What's Included

### Dashboard Features
- **Dark Theme**: Muted brown/tan colors (#8b6644, #997755)
- **VPN Control**: User-controlled toggle with 4 server options
- **Server Selection**: Netherlands, Canada, USA, Thailand
- **WiFi Config**: Change router SSID/password
- **Captive Portal**: Connect to public WiFi networks
- **NO GL.iNet Branding**: Completely custom Strat24 interface

### Files
- `strat24-with-switching.html` - Main dashboard (RECOMMENDED)
- `strat24-darker-functional.html` - Alternative functional version
- `vpn-switch.sh` - VPN switching script
- `vpn-switch-cgi.sh` - CGI endpoint for dashboard
- `nl1.conf`, `ca3.conf`, `us1.conf`, `th1.conf` - WireGuard configs

## Deployment Steps

### 1. Prepare Router

**Factory Reset** (if needed):
```bash
# Hold reset button on router for 10 seconds
# Wait 3 minutes for reboot
```

**Connect to Router**:
- WiFi: GL-SFT1200-XXX
- Web UI: http://192.168.8.1
- Default password: (check router sticker)

### 2. Enable SSH

1. Go to: http://192.168.8.1
2. Navigate to: System → Administration (in Advanced Settings)
3. Enable SSH Access
4. Set root password: `aperoot`
5. Click "Save & Apply"

### 3. Deploy Dashboard

**Option A: Automatic (via script)**:
```bash
# From your Mac:
cd /Users/v3ctor/s24-vpn

# Upload dashboard
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'cat > /www/index.html' < strat24-with-switching.html

# Replace GL.iNet homepage
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'cat > /www/gl_home.html' < strat24-with-switching.html

# Disable GL.iNet JavaScript
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'mv /www/js /www/js.disabled 2>/dev/null'

# Upload VPN configs
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'mkdir -p /etc/wireguard'
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'cat > /etc/wireguard/nl1.conf' < nl1.conf
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'cat > /etc/wireguard/ca3.conf' < ca3.conf
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'cat > /etc/wireguard/us1.conf' < us1.conf
sshpass -p 'aperoot' ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.8.1 'cat > /etc/wireguard/th1.conf' < th1.conf
```

**Option B: Manual (via web terminal)**:
1. Go to: http://192.168.8.1
2. Advanced Settings → System → Administration
3. Look for "Terminal" or "Shell Access"
4. Copy contents of `DEPLOY_VIA_WEB.txt`
5. Paste into terminal
6. Press Enter

### 4. VPN Setup (Optional - For Actual VPN Functionality)

**IMPORTANT**: The dashboard provides UI only. For working VPN:

**Option A: Use GL.iNet's Native VPN** (RECOMMENDED):
1. Go to: http://192.168.8.1/cgi-bin/luci
2. Navigate to: VPN → WireGuard
3. Add new peer using one of the configs (nl1.conf, etc.)
4. Enable the VPN
5. Dashboard shows current state

**Option B: Deploy VPN Scripts** (ADVANCED - use with caution):
```bash
# Upload VPN switch script
sshpass -p 'aperoot' ssh root@192.168.8.1 'cat > /usr/bin/strat24-vpn-switch' < vpn-switch.sh
sshpass -p 'aperoot' ssh root@192.168.8.1 'chmod +x /usr/bin/strat24-vpn-switch'

# Upload CGI endpoint
sshpass -p 'aperoot' ssh root@192.168.8.1 'cat > /www/cgi-bin/vpn-switch' < vpn-switch-cgi.sh
sshpass -p 'aperoot' ssh root@192.168.8.1 'chmod +x /www/cgi-bin/vpn-switch'
```

⚠️ **WARNING**: Custom VPN scripts can break router networking if not properly configured. Use GL.iNet's native VPN first.

### 5. Test

1. Refresh browser: http://192.168.8.1
2. Should see: Strat24 dashboard (dark theme)
3. Test features:
   - VPN tab shows 4 servers
   - WiFi Config tab (if needed)
   - Captive Portal tab (for public networks)
4. Click "Advanced Settings" to access router admin

## Troubleshooting

### Dashboard Not Showing
- Clear browser cache (Cmd+Shift+R on Mac)
- Check if SSH upload completed successfully
- Verify files exist: `ssh root@192.168.8.1 'ls -la /www/index.html'`

### Still Seeing GL.iNet Interface
- Ensure `/www/js` was disabled
- Clear browser cache completely
- Try accessing: http://192.168.8.1/strat24/

### Router Unreachable After VPN Setup
- Factory reset router (hold reset 10 seconds)
- Deploy ONLY dashboard (skip VPN scripts)
- Use GL.iNet's native VPN instead

### SSH Connection Issues
- Check router IP: might be 192.168.1.1 instead of 192.168.8.1
- Verify SSH is enabled in router settings
- Try without sshpass: `ssh root@192.168.8.1`

## Architecture

### Dashboard Design
- Pure HTML/CSS/JavaScript (no build step)
- Monospace font (Courier New)
- Dark background (#0f0f0f)
- Muted tan/brown accents
- Responsive grid layout
- Tab-based navigation

### VPN Integration
- Dashboard provides UI/UX only
- Actual VPN handled by:
  - GL.iNet's native WireGuard client (recommended)
  - Custom scripts via CGI endpoints (advanced)
- 4 pre-configured servers ready to use

### File Structure on Router
```
/www/
  ├── index.html          # Strat24 dashboard
  ├── gl_home.html        # Backup of dashboard
  ├── strat24/
  │   └── index.html      # Another copy
  ├── js.disabled/        # Original GL.iNet JS (disabled)
  └── cgi-bin/
      └── vpn-switch      # VPN control endpoint (optional)

/etc/wireguard/
  ├── nl1.conf            # Netherlands VPN config
  ├── ca3.conf            # Canada VPN config
  ├── us1.conf            # USA VPN config
  └── th1.conf            # Thailand VPN config

/usr/bin/
  └── strat24-vpn-switch  # VPN switching script (optional)
```

## Customization

### Change Colors
Edit dashboard HTML, find:
- Background: `#0f0f0f`
- Primary: `#997755`
- Secondary: `#8b6644`
- Accent: `#aa8866`
- Borders: `#664422`

### Add More Servers
1. Get WireGuard config file
2. Upload to `/etc/wireguard/`
3. Add server card in dashboard HTML
4. Update VPN switch script

### Modify Branding
- Logo: Search for "STRAT24" in HTML
- Footer: Update support email/URL
- Colors: Follow color scheme above

## Security Notes

- Change default SSH password from `aperoot`
- Keep router firmware updated
- Use strong WiFi password
- VPN configs contain private keys - keep secure
- Review firewall rules in Advanced Settings

## Support

For issues or questions:
- Email: support@strat24.com
- GitHub: Check repo issues
- GL.iNet Forums: For router-specific issues

## License

Custom dashboard for Strat24 use.
VPN configs provided by user.
GL.iNet router firmware: GPL license.
