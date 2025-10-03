# Strat24 Secure Access Point - Project Overview

## 🎯 What This Project Is

A **production-ready VPN management platform** that combines:
- Web-based user portal for VPN configuration downloads
- Hardware provisioning system for GL.iNet routers
- Real VPN account creation via VPN Resellers API
- Multi-platform support (iOS, macOS, Windows)

---

## 📁 Project Structure

```
s24-vpn/
├── app/                              # Next.js application
│   ├── api/                          # API routes
│   │   ├── auth/
│   │   │   ├── login/route.ts        # User login
│   │   │   ├── register/route.ts     # User registration + VPN provisioning
│   │   │   └── session/route.ts      # Session validation
│   │   └── vpn/
│   │       ├── config/route.ts       # VPN config generation & download
│   │       └── servers/route.ts      # VPN server list
│   ├── dashboard/
│   │   └── page.tsx                  # User dashboard (download configs)
│   ├── page.tsx                      # Landing page (login/register)
│   ├── layout.tsx                    # Root layout
│   └── globals.css                   # Global styles
│
├── lib/                              # Shared libraries
│   ├── vpn-api.ts                    # VPN Resellers API client
│   └── users.ts                      # User management (in-memory)
│
├── hardware/                         # Hardware provisioning
│   └── provisioning/
│       ├── provision.sh              # Automated router provisioning
│       └── device.conf.template      # Device configuration template
│
├── docs/                             # Documentation
│   ├── deployment/
│   │   ├── strat24_implementation_guide.md
│   │   └── code_completion_checklist.md
│   ├── hardware/
│   │   ├── GL-SFT1200-DEPLOYMENT-GUIDE.md
│   │   └── vpn_configuration_guide.md
│   └── guides/
│       └── strat24_client_quick_start.md
│
├── package.json                      # Dependencies
├── next.config.js                    # Next.js configuration
├── tailwind.config.js                # Tailwind CSS configuration
├── tsconfig.json                     # TypeScript configuration
└── README.md                         # Main documentation
```

---

## 🏗️ Architecture

### **Frontend**
- Next.js 15 (App Router)
- React 19
- Tailwind CSS v4
- TypeScript

### **Backend**
- Next.js API Routes
- In-memory user storage (MVP)
- Cookie-based session management

### **External Services**
- VPN Resellers API v3.2 (real VPN account provisioning)
- WireGuard protocol (primary)
- OpenVPN protocol (optional)

### **Hardware**
- GL.iNet Opal (GL-SFT1200)
- OpenWRT 21.02+
- WireGuard VPN tunnel
- Automated provisioning scripts

---

## 🔑 Key Features

### ✅ User Management
- Email/password registration
- Session-based authentication
- License key generation per user

### ✅ VPN Provisioning
- Automatic VPN account creation via API
- Real WireGuard keys from provider
- Credentials stored securely

### ✅ Config Generation
- **iOS**: `.mobileconfig` auto-install profiles
- **macOS**: `.conf` files for WireGuard app
- **Windows**: `.conf` files for WireGuard app
- **OpenVPN**: `.ovpn` files with embedded credentials

### ✅ Hardware Provisioning
- Automated GL.iNet router configuration
- WireGuard tunnel setup
- Firewall + kill switch implementation
- Secure Wi-Fi configuration

---

## 🔄 User Flow

### Web Portal Flow
1. User visits landing page
2. User registers (email + password)
3. System creates VPN account via API
4. User redirected to dashboard
5. User selects server + platform
6. User downloads pre-configured file
7. User imports to WireGuard/VPN app
8. User connects → **Secure internet!**

### Hardware Provisioning Flow
1. Admin creates device config with license key
2. Admin uploads config + script to router
3. Script fetches VPN config from platform API
4. Script configures WireGuard tunnel
5. Script sets up firewall + kill switch
6. Script configures secure Wi-Fi
7. Device ready for client deployment
8. Client plugs in → **Automatic protection!**

---

## 🛠️ Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Next.js 15 |
| Language | TypeScript |
| Styling | Tailwind CSS v4 |
| Database | In-memory (MVP) → PostgreSQL/Supabase |
| Auth | Cookie-based (MVP) → NextAuth.js |
| VPN Provider | VPN Resellers API v3.2 |
| VPN Protocol | WireGuard (ChaCha20-Poly1305) |
| Hardware | GL.iNet Opal (OpenWRT 21.02+) |
| Deployment | Vercel |

---

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - Create user + provision VPN account
- `POST /api/auth/login` - Authenticate user
- `GET /api/auth/session` - Get current session

### VPN
- `GET /api/vpn/servers` - List available VPN servers
- `GET /api/vpn/config` - Download VPN configuration file

---

## 🔐 Security Features

### Platform Security
- ✅ Encrypted credential storage (AES-256)
- ✅ Secure session management (HttpOnly cookies)
- ✅ License key validation
- ✅ Minimal data retention

### Device Security
- ✅ Military-grade encryption (WireGuard)
- ✅ Automatic kill switch (blocks internet if VPN fails)
- ✅ DNS leak protection
- ✅ IPv6 leak protection
- ✅ Firewall hardening

---

## ⚠️ Current Limitations (MVP)

### 1. In-Memory Storage
- **Issue**: Users stored in RAM, lost on restart
- **Fix**: Migrate to PostgreSQL or Supabase

### 2. Simple Authentication
- **Issue**: Basic cookie-based auth
- **Fix**: Implement NextAuth.js or Clerk

### 3. No Payment Processing
- **Issue**: No subscription management
- **Fix**: Integrate Stripe

### 4. No Admin Panel
- **Issue**: Can't manage users via UI
- **Fix**: Build admin dashboard

---

## 🚀 Deployment

### Production Checklist
- [ ] Deploy to Vercel/Netlify/Railway
- [ ] Configure environment variables
- [ ] Set up custom domain
- [ ] Enable HTTPS
- [ ] Test VPN connections
- [ ] Add database (PostgreSQL/Supabase)
- [ ] Add proper authentication
- [ ] Add payment processing (if selling)
- [ ] Add error tracking (Sentry)
- [ ] Add analytics

### Environment Variables Required
```env
VPN_RESELLERS_API_BASE=https://api.vpnresellers.com/v3_2
VPN_RESELLERS_API_TOKEN=your_api_token_here
VPN_CREDENTIAL_ENCRYPTION_KEY=your_64_char_hex_key
NEXTAUTH_URL=https://yourdomain.com
NEXTAUTH_SECRET=your_random_secret
NEXT_PUBLIC_APP_URL=https://yourdomain.com
NEXT_PUBLIC_APP_NAME=Strat24 Secure Access
NEXT_PUBLIC_COMPANY_NAME=Strat24
NEXT_PUBLIC_SUPPORT_EMAIL=support@strat24.com
```

---

## 📚 Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Main project documentation | All users |
| `PROJECT_OVERVIEW.md` | Architecture & structure (this file) | Developers |
| `docs/deployment/strat24_implementation_guide.md` | End-to-end deployment | Operations |
| `docs/hardware/GL-SFT1200-DEPLOYMENT-GUIDE.md` | Hardware setup & testing | Technical staff |
| `docs/guides/strat24_client_quick_start.md` | Client setup instructions | End users |
| `docs/hardware/vpn_configuration_guide.md` | Manual VPN configuration | Advanced users |
| `docs/deployment/code_completion_checklist.md` | Required code changes | Developers |

---

## 🎯 Use Cases

### 1. NGOs & Humanitarian Organizations
- Deploy secure access points to field offices
- Protect staff in high-risk regions
- Centralized management from HQ

### 2. Healthcare Providers
- HIPAA-compliant remote access
- Secure patient data transmission
- Mobile clinic connectivity

### 3. Financial Institutions
- Secure field office connectivity
- Encrypted financial transactions
- Compliance with regulations

### 4. Educational Institutions
- Protect student data
- Secure faculty remote access
- Campus-wide VPN coverage

### 5. Corporate Remote Workers
- Secure work-from-home connectivity
- Protection on public Wi-Fi
- Centralized security policies

---

## 🔧 Customization Points

### Branding
- `app/page.tsx` - Update logo, colors, company name
- `app/layout.tsx` - Update page title, meta description
- `tailwind.config.js` - Update color scheme

### VPN Provider
- `lib/vpn-api.ts` - Switch to different VPN API
- Environment variables for API credentials

### Hardware
- `hardware/provisioning/provision.sh` - Adapt for different routers
- `hardware/provisioning/device.conf.template` - Custom config options

### Features
- Add payment processing (Stripe)
- Add database (Prisma + PostgreSQL)
- Add admin dashboard
- Add usage analytics
- Add device monitoring

---

## 🐛 Troubleshooting

### VPN Not Connecting
1. Check API token is valid
2. Check VPN account was created
3. Verify config has real credentials (not placeholders)
4. Test API directly with curl

### Build Fails
```bash
npm install @tailwindcss/postcss
npm run build
```

### Config Download Fails
1. Check user is authenticated
2. Check VPN account exists
3. Check API permissions
4. Check server logs

---

## 📈 Roadmap

### Phase 1: Pilot (Current)
- ✅ Basic platform deployment
- ✅ Manual device provisioning
- ✅ In-memory user storage
- ✅ 2-10 client deployments

### Phase 2: Production (1-3 Months)
- [ ] PostgreSQL/Supabase database
- [ ] Device inventory management
- [ ] Automated client onboarding
- [ ] Admin dashboard
- [ ] 10-50 client deployments

### Phase 3: Scale (3-6 Months)
- [ ] Device heartbeat monitoring
- [ ] Centralized logging
- [ ] Client self-service portal
- [ ] Payment processing
- [ ] MFA authentication
- [ ] 50-200 client deployments

### Phase 4: Enterprise (6-12 Months)
- [ ] White-label capability
- [ ] API for integrations
- [ ] Advanced analytics
- [ ] Automated security updates
- [ ] 200+ client deployments

---

## 🤝 Contributing

This is an internal Strat24 project. For contributions:
1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request
5. Request review from security team

---

## 📄 License

Proprietary - © 2025 Strat24. All rights reserved.

---

## 📞 Contact

**Strat24**  
Website: https://strat24.com  
Email: support@strat24.com  
Security Operations: security-ops@strat24.com

---

**Last Updated**: October 3, 2025  
**Version**: 1.0  
**Status**: Production-ready MVP

