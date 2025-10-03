# Strat24 Secure Access Point: Complete Implementation Guide

**Company:** Strat24  
**Website:** https://strat24.com  
**Date:** October 3, 2025  
**Version:** 1.0

---

## About This Solution

The **Strat24 Secure Access Point** is a turnkey VPN solution designed for clients working in high-security environments. This solution combines enterprise-grade cybersecurity with plug-and-play simplicity, delivering secure internet connectivity to remote workers, field teams, and high-risk locations.

As part of Strat24's comprehensive cybersecurity operations, this solution provides:

- **Zero-configuration deployment** for end users
- **Centralized management** through the Strat24 VPN platform
- **Military-grade encryption** via WireGuard protocol
- **Automatic kill switch** to prevent data leaks
- **24/7 protection** with no user intervention required

This guide provides complete implementation instructions for Strat24 administrators deploying secure access points to clients.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites and Hardware Requirements](#prerequisites-and-hardware-requirements)
3. [Phase 1: Deploy Strat24 VPN Platform](#phase-1-deploy-strat24-vpn-platform)
4. [Phase 2: Complete Code Implementation](#phase-2-complete-code-implementation)
5. [Phase 3: Prepare GL.iNet Hardware](#phase-3-prepare-glinet-hardware)
6. [Phase 4: Device Provisioning and Testing](#phase-4-device-provisioning-and-testing)
7. [Phase 5: Client Deployment](#phase-5-client-deployment)
8. [Troubleshooting Guide](#troubleshooting-guide)

---

## Overview

The Strat24 Secure Access Point solution is designed for organizations requiring secure connectivity in challenging environments:

- **NGOs and humanitarian organizations** operating in high-risk regions
- **Healthcare providers** requiring HIPAA-compliant remote access
- **Financial institutions** needing secure field office connectivity
- **Educational institutions** protecting student and faculty data
- **Corporate clients** with remote workers in sensitive locations

The solution leverages Strat24's expertise in cybersecurity operations and risk management to deliver enterprise-grade security in a consumer-friendly package.

---

## Prerequisites and Hardware Requirements

### Required Accounts and Services

| Service | Purpose | Setup Required |
|---------|---------|----------------|
| **VPN Resellers** | Backend VPN infrastructure | Contact Strat24 procurement |
| **Vercel** | Hosting for management platform | Free tier available |
| **GitHub** | Code repository | Already configured |

### Required Hardware (Per Client Deployment)

| Item | Quantity | Purpose | Source |
|------|----------|---------|--------|
| **GL.iNet Opal (GL-SFT1200)** | 1 | Secure access point device | Amazon, GL.iNet store |
| **Ethernet cables** | 2 | Setup and client deployment | Strat24 inventory |
| **Branded packaging** (optional) | 1 | Professional client experience | Strat24 marketing |

### Required Software and Tools

- **Computer** with Ethernet port (Windows, macOS, or Linux)
- **Web browser** (Chrome, Firefox, or Safari)
- **SSH client** (built-in on macOS/Linux, PuTTY for Windows)
- **SCP client** (built-in on macOS/Linux, WinSCP for Windows)
- **Text editor** (VS Code recommended)

### Required Credentials

Before beginning, ensure you have:

1. **VPN Resellers API Token** - Available from Strat24 IT operations
2. **Vercel Account** - Create at vercel.com
3. **Strat24 branding assets** - Logo, colors, support contact info

---

## Phase 1: Deploy Strat24 VPN Platform

### Step 1.1: Complete Code Implementation

Navigate to your S24 VPN project directory and implement the authentication fixes.

**1. Create the session management endpoint:**

```bash
mkdir -p app/api/auth/session
```

Create file `app/api/auth/session/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { getUserById } from '@/lib/users';

export async function GET(request: NextRequest) {
  try {
    const cookieStore = cookies();
    const sessionCookie = cookieStore.get('session');
    
    if (!sessionCookie) {
      return NextResponse.json(
        { error: 'Not authenticated' },
        { status: 401 }
      );
    }

    const userId = sessionCookie.value;
    const user = await getUserById(userId);
    
    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      user: {
        id: user.id,
        email: user.email,
        licenseKey: user.licenseKey,
        status: user.status,
      },
    });
  } catch (error) {
    console.error('[Session] Error:', error);
    return NextResponse.json(
      { error: 'Failed to get session' },
      { status: 500 }
    );
  }
}
```

**2. Create the logout endpoint:**

```bash
mkdir -p app/api/auth/logout
```

Create file `app/api/auth/logout/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';

export async function POST(request: NextRequest) {
  try {
    const cookieStore = cookies();
    cookieStore.delete('session');
    
    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('[Logout] Error:', error);
    return NextResponse.json(
      { error: 'Logout failed' },
      { status: 500 }
    );
  }
}
```

**3. Update login and register endpoints:**

Add cookie setting to both `app/api/auth/login/route.ts` and `app/api/auth/register/route.ts`:

```typescript
import { cookies } from 'next/headers';

// Add before the return statement:
const cookieStore = cookies();
cookieStore.set('session', user.id, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 60 * 60 * 24 * 7, // 7 days
  path: '/',
});
```

**4. Replace the dashboard:**

Replace `app/dashboard/page.tsx` with the fixed version that retrieves real session data.

### Step 1.2: Configure Environment Variables

Create `.env.local` in your project root:

```env
# VPN Resellers API Configuration
VPN_RESELLERS_API_BASE=https://api.vpnresellers.com/v3_2
VPN_RESELLERS_API_TOKEN=your_strat24_api_token_here

# Encryption Key (generate with: openssl rand -hex 32)
VPN_CREDENTIAL_ENCRYPTION_KEY=your_64_character_hex_key_here

# NextAuth Configuration
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_random_secret_here

# Strat24 Branding
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=Strat24 Secure Access
NEXT_PUBLIC_COMPANY_NAME=Strat24
NEXT_PUBLIC_SUPPORT_EMAIL=support@strat24.com
NEXT_PUBLIC_SUPPORT_PHONE=+1-XXX-XXX-XXXX
```

**Generate required secrets:**

```bash
# Generate encryption key
openssl rand -hex 32

# Generate NextAuth secret
openssl rand -base64 32
```

### Step 1.3: Test Locally

```bash
npm install
npm run dev
```

Open http://localhost:3000 and verify:

1. ✅ User registration works
2. ✅ Dashboard shows real license key
3. ✅ Config download contains real credentials
4. ✅ Branding shows "Strat24 Secure Access"

### Step 1.4: Deploy to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy to production
vercel --prod
```

### Step 1.5: Configure Production Environment

1. Go to Vercel dashboard
2. Select your project
3. Navigate to **Settings** → **Environment Variables**
4. Add all variables from `.env.local`
5. Update URLs to your production domain:
   - `NEXTAUTH_URL=https://vpn.strat24.com` (or your chosen subdomain)
   - `NEXT_PUBLIC_APP_URL=https://vpn.strat24.com`

### Step 1.6: Configure Custom Domain (Optional)

For professional branding, use a Strat24 subdomain:

1. In Vercel dashboard, go to **Settings** → **Domains**
2. Add custom domain: `vpn.strat24.com`
3. Add the DNS records to your Strat24 domain:
   - Type: `CNAME`
   - Name: `vpn`
   - Value: `cname.vercel-dns.com`
4. Wait for DNS propagation (5-30 minutes)
5. Vercel will automatically provision SSL certificate

---

## Phase 2: Complete Code Implementation

All code implementation is covered in Phase 1, Step 1.1. Verify:

- [ ] Session management endpoint created
- [ ] Logout endpoint created
- [ ] Login/register set session cookies
- [ ] Dashboard retrieves real user data
- [ ] All Strat24 branding variables configured

---

## Phase 3: Prepare GL.iNet Hardware

### Step 3.1: Unbox and Initial Setup

1. Unbox GL.iNet Opal (GL-SFT1200)
2. Connect power adapter
3. Wait 60 seconds for boot

### Step 3.2: Connect to Router

**Option A: Via Wi-Fi**
- Network: `GL-SFT1200-XXX`
- Password: On label (bottom of device)

**Option B: Via Ethernet**
- Connect cable to LAN port (yellow)

### Step 3.3: Access Admin Panel

1. Open browser: **http://192.168.8.1**
2. Complete initial setup wizard
3. Set strong admin password
4. Configure time zone
5. Connect WAN port to internet

### Step 3.4: Upgrade Firmware

**Critical:** Use latest stable firmware for best WireGuard support.

1. Download firmware:
   - Visit: https://dl.gl-inet.com/router/sft1200/stable
   - Download version **4.3.25** (or latest)
   - Click "Download for Common Upgrade" (`.tar` file)

2. Upload firmware:
   - Navigate to: **SYSTEM** → **Upgrade** → **Local Upgrade**
   - Select downloaded `.tar` file
   - **Uncheck** "Keep Settings"
   - Click **Install**
   - Wait 3-5 minutes (do NOT power off)

3. Reconnect after reboot:
   - Access http://192.168.8.1
   - Log in with admin password

### Step 3.5: Enable SSH Access

1. Navigate to: **SYSTEM** → **Advanced Settings**
2. Click **LuCI**
3. Go to: **System** → **Administration**
4. Under SSH Access:
   - Interface: `Unspecified`
   - Port: `22`
   - Password authentication: `Enabled`
   - Root login: `Enabled`
5. Click **Save & Apply**

### Step 3.6: Test SSH Connection

```bash
ssh root@192.168.8.1
```

Enter admin password. You should see OpenWRT shell.

### Step 3.7: Verify WireGuard

```bash
ssh root@192.168.8.1 "opkg list-installed | grep wireguard"
```

Should show WireGuard packages installed.

---

## Phase 4: Device Provisioning and Testing

### Step 4.1: Create Client Account

1. Go to your Strat24 VPN platform (e.g., https://vpn.strat24.com)
2. Register new user (use client's email)
3. **Copy the License Key** from dashboard

### Step 4.2: Prepare Provisioning Files

**1. Update provision script URL:**

Edit `provision_complete.sh` line 28:

```bash
API_ENDPOINT="https://vpn.strat24.com/api/vpn/config"
```

**2. Create device configuration:**

Create `device.conf`:

```ini
# Strat24 Secure Access Point Configuration
LICENSE_KEY="S24-1234567890-ABCD"  # From Step 4.1
WIFI_SSID="Strat24-Secure"
WIFI_PASSWORD="SecurePass2025!"     # Generate unique password per device
```

**Password Requirements:**
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Unique per device
- Document in client record

### Step 4.3: Upload Files to Router

```bash
scp provision_complete.sh root@192.168.8.1:/root/provision.sh
scp device.conf root@192.168.8.1:/root/device.conf
```

### Step 4.4: Set Permissions and Run

```bash
ssh root@192.168.8.1
chmod +x /root/provision.sh
/root/provision.sh
```

**Monitor output for:**
- ✅ License key found
- ✅ Configuration downloaded
- ✅ VPN tunnel established
- ✅ Wi-Fi configured

### Step 4.5: Configure Auto-Run

```bash
ssh root@192.168.8.1

cat << 'EOF' > /etc/init.d/strat24-vpn-provision
#!/bin/sh /etc/rc.common

START=99

start() {
    /root/provision.sh &
}
EOF

chmod +x /etc/init.d/strat24-vpn-provision
/etc/init.d/strat24-vpn-provision enable
```

### Step 4.6: Verify VPN Connection

```bash
# Check WireGuard interface
ssh root@192.168.8.1 "ip link show wg0"
# Should show: UP,LOWER_UP

# Check WireGuard status
ssh root@192.168.8.1 "wg show"
# Should show recent handshake
```

### Step 4.7: Test from Client Device

1. **Connect to Wi-Fi:**
   - Network: `Strat24-Secure`
   - Password: (from device.conf)

2. **Verify VPN connection:**
   - Visit: https://www.whatismyip.com
   - IP should be VPN server location

3. **Test DNS leak protection:**
   - Visit: https://www.dnsleaktest.com
   - Run Extended Test
   - All DNS should be VPN provider

### Step 4.8: Test Kill Switch (Critical)

```bash
# SSH into router
ssh root@192.168.8.1

# Disable VPN
ifdown wg0
```

**On client device:**
- Try accessing any website
- **Should have NO internet access**
- This confirms kill switch works

**Re-enable VPN:**

```bash
ifup wg0
```

Internet should resume after 10-15 seconds.

### Step 4.9: Document Device

Create device record:

```
Device Serial: [from label]
License Key: S24-1234567890-ABCD
Wi-Fi SSID: Strat24-Secure
Wi-Fi Password: SecurePass2025!
Client: John Doe / john@example.com
Organization: Example NGO
Deployment Location: Field Office - Region A
Provisioning Date: 2025-10-03
VPN Server: US East
Provisioned By: [Your Name]
Status: Ready for Deployment
```

---

## Phase 5: Client Deployment

### Step 5.1: Prepare Device Package

**Standard Package Includes:**
1. Configured Strat24 Secure Access Point
2. Power adapter
3. Ethernet cable
4. Quick start guide (see template below)
5. Strat24 support contact card

**Optional Professional Touch:**
- Branded box or packaging
- Strat24 logo sticker on device
- Laminated quick reference card
- Pre-addressed return shipping label

### Step 5.2: Client Quick Start Guide

Print this guide for each client:

```
═══════════════════════════════════════════════════════
            STRAT24 SECURE ACCESS POINT
                 Quick Start Guide
═══════════════════════════════════════════════════════

WHAT YOU RECEIVED:
  • Strat24 Secure Access Point router
  • Power adapter
  • Ethernet cable
  • This quick start guide

SETUP (3 SIMPLE STEPS):

1. CONNECT TO YOUR INTERNET
   • Plug power adapter into router and wall outlet
   • Connect Ethernet cable from your modem/router to the
     BLUE port (labeled "WAN") on the Strat24 device
   • Wait 2 minutes for startup

2. CONNECT YOUR DEVICES
   • On your computer/phone, open Wi-Fi settings
   • Connect to: Strat24-Secure
   • Password: [DEVICE_SPECIFIC_PASSWORD]

3. YOU'RE PROTECTED!
   • All internet traffic is now encrypted
   • Browse normally - protection is automatic
   • No software to install or configure

═══════════════════════════════════════════════════════

WHAT THIS DEVICE DOES:
  ✓ Encrypts all your internet traffic
  ✓ Protects your data from interception
  ✓ Prevents unauthorized access
  ✓ Works automatically - no user action needed
  ✓ Blocks internet if VPN fails (kill switch)

IMPORTANT:
  • Keep device powered on at all times
  • Do not reset or modify device settings
  • Do not share Wi-Fi password outside your team
  • Contact Strat24 support for any issues

═══════════════════════════════════════════════════════

NEED HELP?

Strat24 Support Team
Email: support@strat24.com
Phone: [Your Support Number]
Web: https://strat24.com/support

Available 24/7 for critical security issues

═══════════════════════════════════════════════════════

           Protect what matters most—
         your people, data, and reputation.

                  STRAT24.COM

═══════════════════════════════════════════════════════
```

### Step 5.3: Pre-Deployment Email

Send this email before shipping:

```
Subject: Your Strat24 Secure Access Point is on the way

Dear [Client Name],

Your Strat24 Secure Access Point has been shipped and will arrive by [date].

This device provides military-grade encryption for all your internet traffic,
protecting your team's communications and data in high-risk environments.

WHAT TO EXPECT:
• Compact router device (pocket-sized)
• All cables and power adapter included
• Quick start guide with your unique Wi-Fi password
• Setup takes less than 5 minutes

SETUP IS SIMPLE:
1. Connect device to your internet modem
2. Connect your devices to "Strat24-Secure" Wi-Fi
3. That's it - you're protected automatically

Your secure Wi-Fi network: Strat24-Secure
Your Wi-Fi password: [Will be included in package]

ABOUT YOUR PROTECTION:
This device is part of Strat24's comprehensive cybersecurity operations.
It provides:
• End-to-end encryption (WireGuard protocol)
• Automatic kill switch (blocks internet if VPN fails)
• 24/7 protection with no user intervention
• Centrally managed by Strat24 security team

If you have any questions or need assistance, our support team is
available 24/7.

Best regards,

[Your Name]
Strat24 Cybersecurity Operations
support@strat24.com
[Phone Number]

---
Strat24 - Protect what matters most
https://strat24.com
```

### Step 5.4: Post-Delivery Follow-Up

**24 hours after delivery:**

```
Subject: Is your Strat24 Secure Access Point working?

Dear [Client Name],

I wanted to check in and ensure your Strat24 Secure Access Point is
operational.

QUICK CHECKLIST:
☐ Device connected to your internet modem
☐ Power light is on
☐ Your devices connected to "Strat24-Secure" Wi-Fi
☐ Internet access working normally

VERIFY YOUR PROTECTION:
Visit https://www.whatismyip.com
Your IP address should show as [VPN Server Location], confirming your
connection is encrypted and secure.

If you're experiencing any issues or have questions, please don't
hesitate to reach out. We're here to help 24/7.

Best regards,

[Your Name]
Strat24 Support Team
support@strat24.com
```

---

## Troubleshooting Guide

### Issue: Device Not Connecting to Internet

**Symptoms:** Client reports no internet access

**Diagnosis Steps:**

1. **Check physical connections:**
   ```
   - Power adapter plugged in?
   - Ethernet cable in WAN port (blue)?
   - Modem/router providing internet?
   ```

2. **Check device status:**
   ```bash
   ssh root@192.168.8.1
   ping -c 4 8.8.8.8
   ```

3. **Check VPN tunnel:**
   ```bash
   wg show
   ip link show wg0
   ```

**Solutions:**
- Verify client's modem is working
- Check if ISP is blocking VPN (try mobile hotspot)
- Restart device: `reboot`
- Re-run provisioning script

### Issue: Slow Internet Speed

**Symptoms:** Client reports very slow connection

**Diagnosis:**

1. **Test base internet speed:**
   ```bash
   ssh root@192.168.8.1
   ifdown wg0
   # Client tests speed at fast.com
   ifup wg0
   ```

2. **Check VPN server load:**
   - Try different VPN server
   - Check VPN Resellers status

**Solutions:**
- Adjust MTU: `uci set network.wg0.mtu='1380'`
- Switch to closer VPN server
- Verify client's base internet is adequate

### Issue: Wi-Fi Network Not Visible

**Symptoms:** Client cannot see "Strat24-Secure" network

**Solutions:**

```bash
ssh root@192.168.8.1

# Check wireless status
wifi status

# Enable wireless
uci set wireless.radio0.disabled='0'
uci set wireless.radio1.disabled='0'
uci commit wireless
wifi reload

# Verify SSID
uci show wireless | grep ssid
```

### Issue: Kill Switch Not Working

**Symptoms:** Internet works even when VPN is down

**Critical Security Issue - Fix Immediately:**

```bash
ssh root@192.168.8.1

# Check firewall rules
iptables -L -v -n | grep FORWARD

# Re-apply kill switch
uci delete firewall.@forwarding[0]
uci commit firewall
/etc/init.d/firewall restart

# Test again
ifdown wg0
# Client should have NO internet
ifup wg0
```

### Escalation Process

**Level 1: Client Support**
- Basic troubleshooting
- Physical connection checks
- Device restart

**Level 2: Technical Support**
- SSH diagnostics
- Configuration review
- Log analysis

**Level 3: Strat24 Security Operations**
- VPN infrastructure issues
- Advanced firewall configuration
- Device replacement authorization

**Emergency Contact:**
- Email: security-ops@strat24.com
- Phone: [24/7 Security Hotline]
- Ticket System: [Your Ticketing System]

---

## Appendix: Strat24 Branding Guidelines

### Device Labeling

**Physical Label (Optional):**
```
STRAT24 SECURE ACCESS POINT
Serial: [Device Serial]
Support: support@strat24.com
```

### Wi-Fi Network Naming

**Standard:** `Strat24-Secure`

**Client-Specific (Optional):**
- `Strat24-[ClientName]`
- `Strat24-[Location]`

### Client Communications

**Email Signature:**
```
[Your Name]
Cybersecurity Operations
Strat24

Email: [your.email]@strat24.com
Phone: [Your Number]
Web: https://strat24.com

Protect what matters most—your people, data, and reputation.
```

### Support Materials

All client-facing materials should include:
- Strat24 logo
- Tagline: "Protect what matters most—your people, data, and reputation."
- Support contact: support@strat24.com
- Website: https://strat24.com

---

## Next Steps for Strat24 Operations

### Immediate (Pilot Phase)

1. ✅ Deploy Strat24 VPN platform to production
2. ✅ Configure custom domain (vpn.strat24.com)
3. ✅ Provision 2-3 test devices
4. ✅ Deploy to internal team members
5. ✅ Validate complete workflow

### Short-Term (1-3 Months)

1. Deploy to first 10 clients
2. Gather feedback and refine process
3. Create device inventory tracking system
4. Develop client onboarding automation
5. Build admin dashboard for device management

### Long-Term (3-6 Months)

1. Migrate to production database (PostgreSQL/Supabase)
2. Implement device heartbeat monitoring
3. Add centralized logging and alerting
4. Integrate with Strat24 SOC operations
5. Develop client self-service portal

---

## Conclusion

The Strat24 Secure Access Point solution delivers enterprise-grade security with consumer-level simplicity. By following this implementation guide, you can deploy secure connectivity to clients in high-risk environments, protecting their people, data, and reputation.

This solution aligns with Strat24's mission to provide comprehensive cybersecurity operations, governance, risk & compliance, and offensive security services—all engineered to turn every threat into a competitive edge.

---

**Document Version:** 1.0 - Strat24 Branded Edition  
**Last Updated:** October 3, 2025  
**Prepared By:** Manus AI for Strat24  
**Classification:** Internal Use - Strat24 Operations Team

**For Support:**  
Email: support@strat24.com  
Web: https://strat24.com  

**Strat24** - Protect what matters most—your people, data, and reputation.
