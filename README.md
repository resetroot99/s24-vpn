# Strat24 Secure Access Point Solution

**Protect what matters most—your people, data, and reputation.**

Enterprise-grade VPN solution with plug-and-play deployment for clients in high-security environments.

---

## 🎯 Overview

The Strat24 Secure Access Point is a turnkey VPN solution that combines:

- **Zero-configuration deployment** for end users
- **Centralized management** through web platform
- **Military-grade encryption** (WireGuard protocol)
- **Automatic kill switch** to prevent data leaks
- **24/7 protection** with no user intervention

Perfect for organizations requiring secure connectivity in challenging environments:
- NGOs and humanitarian organizations in high-risk regions
- Healthcare providers requiring HIPAA-compliant remote access
- Financial institutions needing secure field office connectivity
- Educational institutions protecting student and faculty data
- Corporate clients with remote workers in sensitive locations

---

## 📦 Repository Structure

```
s24-vpn/
├── app/                          # Next.js application
│   ├── api/                      # API routes
│   │   ├── auth/                 # Authentication endpoints
│   │   └── vpn/                  # VPN configuration endpoints
│   ├── dashboard/                # User dashboard
│   └── page.tsx                  # Landing page
├── lib/                          # Shared libraries
│   ├── vpn-api.ts               # VPN Resellers API client
│   └── users.ts                  # User management
├── hardware/                     # Hardware provisioning
│   └── provisioning/
│       ├── provision.sh          # Automated provisioning script
│       └── device.conf.template  # Device configuration template
├── docs/                         # Documentation
│   ├── deployment/               # Deployment guides
│   │   ├── strat24_implementation_guide.md
│   │   └── code_completion_checklist.md
│   ├── hardware/                 # Hardware-specific docs
│   │   ├── GL-SFT1200-DEPLOYMENT-GUIDE.md
│   │   └── vpn_configuration_guide.md
│   └── guides/                   # Client-facing guides
│       └── strat24_client_quick_start.md
└── README.md                     # This file
```

---

## 🚀 Quick Start

### For Administrators

**1. Deploy the Platform**

```bash
# Clone repository
git clone https://github.com/resetroot99/s24-vpn.git
cd s24-vpn

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env.local
# Edit .env.local with your credentials

# Run locally
npm run dev

# Deploy to production
vercel --prod
```

**2. Provision a Device**

```bash
# Create device configuration
cp hardware/provisioning/device.conf.template device.conf
# Edit device.conf with license key and Wi-Fi password

# Upload to GL.iNet router
scp hardware/provisioning/provision.sh root@192.168.8.1:/root/
scp device.conf root@192.168.8.1:/root/

# Run provisioning
ssh root@192.168.8.1
chmod +x /root/provision.sh
/root/provision.sh
```

**3. Deploy to Client**

- Package device with quick start guide
- Ship to client
- Follow up to ensure successful deployment

### For Clients

**Setup (3 Simple Steps):**

1. Connect device to your internet modem
2. Connect your devices to "Strat24-Secure" Wi-Fi
3. You're protected! Browse normally.

See [`docs/guides/strat24_client_quick_start.md`](docs/guides/strat24_client_quick_start.md) for detailed instructions.

---

## 📚 Documentation

### Deployment Guides

| Document | Description | Audience |
|----------|-------------|----------|
| [Strat24 Implementation Guide](docs/deployment/strat24_implementation_guide.md) | Complete end-to-end deployment | Strat24 Operations |
| **[GL-SFT1200 Deployment Guide](docs/hardware/GL-SFT1200-DEPLOYMENT-GUIDE.md)** | **Hardware-specific deployment & testing** | **Technical Staff** |
| [Code Completion Checklist](docs/deployment/code_completion_checklist.md) | Required code changes | Developers |
| [VPN Configuration Guide](docs/hardware/vpn_configuration_guide.md) | Manual VPN configuration options | Advanced Users |

### Client Guides

| Document | Description | Format |
|----------|-------------|--------|
| [Client Quick Start](docs/guides/strat24_client_quick_start.md) | Simple setup instructions | Print-ready |

---

## 🛠️ Technology Stack

### Platform (Web Application)

- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Deployment:** Vercel
- **Database:** In-memory (pilot) → PostgreSQL/Supabase (production)

### Hardware (Access Point)

- **Device:** GL.iNet Opal (GL-SFT1200)
- **OS:** OpenWRT 21.02
- **VPN Protocol:** WireGuard
- **Management:** UCI (Unified Configuration Interface)

### Backend Services

- **VPN Provider:** VPN Resellers API
- **Authentication:** NextAuth.js (future)
- **Encryption:** AES-256 for credential storage

---

## 🔧 Configuration

### Environment Variables

Create `.env.local` with the following variables:

```env
# VPN Resellers API
VPN_RESELLERS_API_BASE=https://api.vpnresellers.com/v3_2
VPN_RESELLERS_API_TOKEN=your_api_token_here

# Encryption
VPN_CREDENTIAL_ENCRYPTION_KEY=your_64_char_hex_key_here

# NextAuth
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_random_secret_here

# Strat24 Branding
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=Strat24 Secure Access
NEXT_PUBLIC_COMPANY_NAME=Strat24
NEXT_PUBLIC_SUPPORT_EMAIL=support@strat24.com
```

**Generate secrets:**

```bash
# Encryption key (64 characters)
openssl rand -hex 32

# NextAuth secret
openssl rand -base64 32
```

### Custom Domain Setup

For production, use a custom Strat24 subdomain:

1. Deploy to Vercel
2. Add custom domain: `vpn.strat24.com`
3. Configure DNS:
   ```
   Type: CNAME
   Name: vpn
   Value: cname.vercel-dns.com
   ```
4. Update environment variables with production URL

---

## 🧪 Testing

### Platform Testing

```bash
# Run development server
npm run dev

# Test user registration
# Navigate to http://localhost:3000
# Register a new user
# Verify license key is generated

# Test config download
# Click "Download Configuration"
# Verify .conf file contains real credentials
```

### Hardware Testing

Complete testing checklist available in **[GL-SFT1200 Deployment Guide](docs/hardware/GL-SFT1200-DEPLOYMENT-GUIDE.md)**.

**Critical tests:**

1. ✅ VPN tunnel establishes
2. ✅ Client IP shows VPN location
3. ✅ No DNS leaks
4. ✅ Kill switch blocks internet when VPN fails
5. ✅ Configuration persists after reboot

---

## 📋 Deployment Checklist

### Pre-Deployment

- [ ] Platform deployed to production (Vercel)
- [ ] Custom domain configured (vpn.strat24.com)
- [ ] Environment variables set
- [ ] VPN Resellers API token verified
- [ ] Test user account created and working

### Device Provisioning

- [ ] GL-SFT1200 firmware upgraded to 4.3.25+
- [ ] SSH access enabled
- [ ] Provisioning script uploaded
- [ ] Device configuration created
- [ ] Provisioning completed successfully
- [ ] All 10 tests passed (see deployment guide)

### Client Delivery

- [ ] Device fully tested
- [ ] Quick start guide printed
- [ ] Wi-Fi password documented
- [ ] Device packaged securely
- [ ] Client notified of shipment
- [ ] Follow-up scheduled

---

## 🔐 Security Features

### Platform Security

- **Encrypted credential storage** - AES-256 encryption for VPN credentials
- **Secure session management** - HttpOnly, Secure, SameSite cookies
- **API authentication** - License key validation
- **No logging** - Minimal data retention

### Device Security

- **Military-grade encryption** - WireGuard with ChaCha20-Poly1305
- **Automatic kill switch** - Blocks internet if VPN fails
- **DNS leak protection** - Forces DNS through VPN
- **IPv6 leak protection** - Disables IPv6 to prevent leaks
- **Firewall hardening** - Only VPN traffic allowed

---

## 🆘 Support

### For Strat24 Team

**Internal Support:**
- Email: security-ops@strat24.com
- Documentation: This repository
- Issues: GitHub Issues

### For Clients

**Client Support:**
- Email: support@strat24.com
- Website: https://strat24.com/support
- Phone: [Your Support Number]
- Available: 24/7 for critical security issues

---

## 🗺️ Roadmap

### Phase 1: Pilot (Current)
- ✅ Basic platform deployment
- ✅ Manual device provisioning
- ✅ In-memory user storage
- ✅ 2-10 client deployments

### Phase 2: Production (1-3 Months)
- [ ] PostgreSQL/Supabase database
- [ ] Device inventory management
- [ ] Automated client onboarding
- [ ] Admin dashboard for device monitoring
- [ ] 10-50 client deployments

### Phase 3: Scale (3-6 Months)
- [ ] Device heartbeat monitoring
- [ ] Centralized logging (syslog)
- [ ] Client self-service portal
- [ ] Payment processing (Stripe)
- [ ] Multi-factor authentication
- [ ] 50-200 client deployments

### Phase 4: Enterprise (6-12 Months)
- [ ] White-label capability
- [ ] API for third-party integrations
- [ ] Advanced analytics and reporting
- [ ] Automated security updates
- [ ] 200+ client deployments

---

## 🤝 Contributing

This is an internal Strat24 project. For contributions:

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit pull request
5. Request review from Strat24 security team

---

## 📄 License

Proprietary - © 2025 Strat24. All rights reserved.

This software is confidential and proprietary to Strat24. Unauthorized copying, modification, distribution, or use is strictly prohibited.

---

## 📞 Contact

**Strat24**  
Website: https://strat24.com  
Email: support@strat24.com  
Security Operations: security-ops@strat24.com

**Protect what matters most—your people, data, and reputation.**

---

## 🔗 Quick Links

- [Strat24 Website](https://strat24.com)
- [VPN Platform](https://vpn.strat24.com) (production)
- [GL.iNet Documentation](https://docs.gl-inet.com)
- [WireGuard Documentation](https://www.wireguard.com)
- [VPN Resellers API](https://api.vpnresellers.com/docs/v3_2)

---

**Last Updated:** October 3, 2025  
**Version:** 1.0  
**Maintained By:** Strat24 Operations Team
