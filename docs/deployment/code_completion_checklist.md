# Code Completion Checklist: Secure Access Point Solution

**Author:** Manus AI
**Date:** October 3, 2025

## Overview

This document identifies the specific code components that need to be completed, enhanced, or modified to fully implement the Secure Access Point solution. The checklist is organized by priority and component.

---

## 🔴 Critical (Must Complete Before Pilot)

### 1. Fix Authentication in Dashboard

**File:** `app/dashboard/page.tsx`

**Current Issue:**
```typescript
const licenseKey = 'demo-license'; // TODO: Get from auth
```

**What to Complete:**

The dashboard currently uses a hardcoded demo license key. You need to implement proper session management to retrieve the authenticated user's actual license key.

**Solution A: Cookie-Based Auth (Quick Fix for MVP)**

```typescript
// app/dashboard/page.tsx
'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

export default function Dashboard() {
  const router = useRouter();
  const [licenseKey, setLicenseKey] = useState<string>('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Get license key from session
    const fetchSession = async () => {
      const response = await fetch('/api/auth/session');
      if (!response.ok) {
        router.push('/'); // Redirect to login
        return;
      }
      const data = await response.json();
      setLicenseKey(data.user.licenseKey);
      setLoading(false);
    };
    
    fetchSession();
  }, [router]);

  if (loading) {
    return <div>Loading...</div>;
  }

  // Rest of dashboard code...
}
```

**New File Needed:** `app/api/auth/session/route.ts`

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

    // Parse session cookie (you'll need to implement proper session storage)
    const userId = sessionCookie.value; // Simplified - should be encrypted/signed
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

---

### 2. Update Provision Script API Endpoint

**File:** `provision.sh` (line 26)

**Current Code:**
```bash
API_ENDPOINT="https://s24-vpn.vercel.app/api/vpn/config" # Replace with your actual S24 instance URL
```

**What to Complete:**

Replace the placeholder URL with your actual deployed Vercel instance URL.

**Action Required:**
1. Deploy the S24 VPN platform to Vercel
2. Get the production URL (e.g., `https://your-project-name.vercel.app`)
3. Update line 26 in `provision.sh`:

```bash
API_ENDPOINT="https://your-actual-domain.vercel.app/api/vpn/config"
```

---

### 3. Enhance Endpoint Parsing in Provision Script

**File:** `provision.sh` (lines 52-57)

**Current Issue:**

The WireGuard `Endpoint` field contains both hostname and port (e.g., `vpn.example.com:51820`), but the script needs to split them for proper UCI configuration.

**What to Complete:**

```bash
# Current (line 56):
PEER_ENDPOINT=$(echo "${WG_CONFIG}" | grep 'Endpoint' | awk '{print $3}')

# Replace with:
PEER_ENDPOINT_FULL=$(echo "${WG_CONFIG}" | grep 'Endpoint' | awk '{print $3}')
PEER_ENDPOINT_HOST=$(echo "${PEER_ENDPOINT_FULL}" | cut -d':' -f1)
PEER_ENDPOINT_PORT=$(echo "${PEER_ENDPOINT_FULL}" | cut -d':' -f2)
```

Then update the UCI configuration (line 82):

```bash
# Current:
uci set network.wgclient.endpoint_host="$PEER_ENDPOINT"

# Replace with:
uci set network.wgclient.endpoint_host="$PEER_ENDPOINT_HOST"
uci set network.wgclient.endpoint_port="$PEER_ENDPOINT_PORT"
```

---

### 4. Configure Wi-Fi SSID and Password

**File:** `provision.sh` (new section to add)

**What to Complete:**

Add configuration for the secure Wi-Fi network that clients will connect to. Insert this section after line 103 (after firewall configuration):

```bash
# 5. Configure Secure Wi-Fi Network
log "Configuring secure Wi-Fi network..."

# Set SSID
uci set wireless.@wifi-iface[0].ssid='Strat24-Secure'

# Set WPA3/WPA2 encryption
uci set wireless.@wifi-iface[0].encryption='sae-mixed' # WPA3 with WPA2 fallback
uci set wireless.@wifi-iface[0].key='YourSecureWiFiPassword123!' # Change this!

# Enable the radio
uci set wireless.radio0.disabled='0'

# Commit wireless changes
uci commit wireless

log "Wi-Fi configuration applied."
```

**Important:** Replace `'YourSecureWiFiPassword123!'` with a strong, randomly generated password. Consider making this configurable per device via `device.conf`.

---

## 🟡 Important (Complete Before Limited Rollout)

### 5. Add Session Cookie Management to Login/Register

**Files:** 
- `app/api/auth/login/route.ts`
- `app/api/auth/register/route.ts`

**What to Complete:**

Both endpoints need to set a secure session cookie after successful authentication.

**Add to both files (at the end of successful response):**

```typescript
import { cookies } from 'next/headers';

// After successful user creation/authentication:
const cookieStore = cookies();
cookieStore.set('session', user.id, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 60 * 60 * 24 * 7, // 7 days
  path: '/',
});
```

---

### 6. Add Logout Endpoint

**New File:** `app/api/auth/logout/route.ts`

**What to Complete:**

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

---

### 7. Add DNS Configuration to Provision Script

**File:** `provision.sh` (new section)

**What to Complete:**

Add encrypted DNS configuration for enhanced privacy. Insert after the Wi-Fi configuration section:

```bash
# 6. Configure Encrypted DNS (DNS over TLS)
log "Configuring encrypted DNS..."

# Install DNS over TLS package (if not already installed)
# opkg update && opkg install https-dns-proxy

# Configure DNS over TLS with Cloudflare
uci set dhcp.@dnsmasq[0].noresolv='1'
uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#5053'

# Configure https-dns-proxy for Cloudflare DoT
uci set https-dns-proxy.dns.bootstrap_dns='1.1.1.1,1.0.0.1'
uci set https-dns-proxy.dns.resolver_url='https://cloudflare-dns.com/dns-query'
uci set https-dns-proxy.dns.listen_addr='127.0.0.1'
uci set https-dns-proxy.dns.listen_port='5053'

uci commit dhcp
uci commit https-dns-proxy

log "Encrypted DNS configured."
```

---

## 🟢 Enhancement (Complete Before Full-Scale Deployment)

### 8. Add Device Status Reporting

**What to Complete:**

Implement a heartbeat mechanism where devices periodically report their status back to the S24 VPN platform.

**New File:** `app/api/device/heartbeat/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getUserByLicense } from '@/lib/users';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { licenseKey, status, vpnConnected, publicIp } = body;

    const user = await getUserByLicense(licenseKey);
    if (!user) {
      return NextResponse.json(
        { error: 'Invalid license' },
        { status: 404 }
      );
    }

    // Store device status (implement when you add database)
    console.log('[Heartbeat]', {
      user: user.email,
      status,
      vpnConnected,
      publicIp,
      timestamp: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('[Heartbeat] Error:', error);
    return NextResponse.json(
      { error: 'Failed to process heartbeat' },
      { status: 500 }
    );
  }
}
```

**Add to `provision.sh`:**

```bash
# 7. Setup Status Reporting (runs every 5 minutes)
cat << 'EOF' > /root/heartbeat.sh
#!/bin/sh
. /root/device.conf
VPN_STATUS=$(ip link show wg0 2>/dev/null | grep -q "state UP" && echo "connected" || echo "disconnected")
PUBLIC_IP=$(curl -s https://api.ipify.org)
curl -s -X POST https://your-domain.vercel.app/api/device/heartbeat \
  -H "Content-Type: application/json" \
  -d "{\"licenseKey\":\"$LICENSE_KEY\",\"status\":\"online\",\"vpnConnected\":\"$VPN_STATUS\",\"publicIp\":\"$PUBLIC_IP\"}"
EOF

chmod +x /root/heartbeat.sh

# Add to crontab
echo "*/5 * * * * /root/heartbeat.sh" >> /etc/crontabs/root
/etc/init.d/cron restart
```

---

### 9. Add Admin Dashboard for Device Management

**New File:** `app/admin/page.tsx`

**What to Complete:**

Create an admin dashboard to view all users and their device status.

```typescript
'use client';

import { useEffect, useState } from 'react';

export default function AdminDashboard() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch('/api/admin/users')
      .then(res => res.json())
      .then(data => setUsers(data.users));
  }, []);

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Device Management</h1>
      <table className="w-full border">
        <thead>
          <tr className="bg-gray-100">
            <th className="p-3 text-left">Email</th>
            <th className="p-3 text-left">License Key</th>
            <th className="p-3 text-left">Status</th>
            <th className="p-3 text-left">VPN Account</th>
            <th className="p-3 text-left">Actions</th>
          </tr>
        </thead>
        <tbody>
          {users.map((user: any) => (
            <tr key={user.id} className="border-t">
              <td className="p-3">{user.email}</td>
              <td className="p-3 font-mono text-sm">{user.licenseKey}</td>
              <td className="p-3">
                <span className={`px-2 py-1 rounded text-xs ${
                  user.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                }`}>
                  {user.status}
                </span>
              </td>
              <td className="p-3">{user.vpnAccountId || 'Not provisioned'}</td>
              <td className="p-3">
                <button className="text-blue-600 hover:underline mr-3">View</button>
                <button className="text-red-600 hover:underline">Suspend</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

---

## Summary: Priority Order

### Start Here (Critical for Pilot):
1. ✅ Fix authentication in dashboard (`app/dashboard/page.tsx`)
2. ✅ Create session endpoint (`app/api/auth/session/route.ts`)
3. ✅ Update API endpoint in `provision.sh`
4. ✅ Fix endpoint parsing in `provision.sh`
5. ✅ Configure Wi-Fi SSID/password in `provision.sh`

### Before Limited Rollout:
6. ✅ Add session cookies to login/register
7. ✅ Create logout endpoint
8. ✅ Add encrypted DNS configuration

### Before Full Production:
9. ✅ Implement device heartbeat/status reporting
10. ✅ Build admin dashboard for device management
11. ✅ Migrate to production database (Supabase/PostgreSQL)
12. ✅ Add payment integration (Stripe)

---

## Testing Checklist

After completing the critical items, test the following workflow:

- [ ] User can register on S24 VPN platform
- [ ] VPN account is created automatically
- [ ] User can log in and see their dashboard
- [ ] Dashboard displays the correct license key
- [ ] Config download works with the license key
- [ ] Provision script successfully fetches config
- [ ] WireGuard tunnel establishes on GL.iNet device
- [ ] Client devices can connect to secure Wi-Fi
- [ ] All traffic routes through VPN tunnel
- [ ] Kill switch blocks traffic when VPN drops
- [ ] DNS leak test shows VPN DNS servers only
