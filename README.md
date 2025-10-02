# S24 VPN - Simple & Secure VPN Service

A clean, minimal VPN reselling platform built with Next.js and the VPN Resellers API.

## Features

✅ **Simple Authentication** - Email/password login and registration  
✅ **Real VPN Integration** - Uses VPN Resellers API for actual VPN accounts  
✅ **Multi-Platform Support** - iOS, macOS, and Windows configurations  
✅ **Auto-Install Configs** - Pre-configured files that work out of the box  
✅ **No Apps Required** - Just download config and import to WireGuard  
✅ **Clean Dashboard** - Simple UI to download configs for any device  

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Styling**: Tailwind CSS
- **VPN Provider**: VPN Resellers API v3.2
- **Protocol**: WireGuard (primary), OpenVPN (optional)
- **Deployment**: Vercel-ready

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Create `.env.local` file:

```env
VPN_RESELLERS_API_BASE=https://api.vpnresellers.com/v3_2
VPN_RESELLERS_API_TOKEN=your_api_token_here
VPN_CREDENTIAL_ENCRYPTION_KEY=your_64_char_hex_key
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_random_secret
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=S24 VPN
```

Generate encryption key:
```bash
openssl rand -hex 32
```

### 3. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## How It Works

### User Flow

1. **Sign Up** → User creates account with email/password
2. **VPN Provisioning** → System creates real VPN account via API
3. **Dashboard** → User selects server and platform
4. **Download Config** → Pre-configured file with real credentials
5. **Import & Connect** → User imports to WireGuard and connects

### API Integration

The system properly integrates with VPN Resellers API:

- **Account Creation**: `POST /accounts` - Creates real VPN account
- **Server List**: `GET /servers` - Fetches available servers
- **WireGuard Config**: `GET /accounts/{id}/wireguard-configuration` - Gets real config
- **OpenVPN Config**: `GET /configuration` - Gets OpenVPN config

### Config Generation

**WireGuard (Default)**:
- Desktop (macOS/Windows): `.conf` file for WireGuard app
- iOS: `.mobileconfig` file for native iOS VPN

**OpenVPN (Optional)**:
- All platforms: `.ovpn` file with embedded credentials

## Project Structure

```
s24-vpn/
├── app/
│   ├── api/
│   │   ├── auth/
│   │   │   ├── login/route.ts      # Login endpoint
│   │   │   └── register/route.ts   # Registration endpoint
│   │   └── vpn/
│   │       ├── config/route.ts     # Config download
│   │       └── servers/route.ts    # Server list
│   ├── dashboard/
│   │   └── page.tsx                # User dashboard
│   ├── layout.tsx                  # Root layout
│   ├── page.tsx                    # Landing/auth page
│   └── globals.css                 # Global styles
├── lib/
│   ├── vpn-api.ts                  # VPN Resellers API client
│   └── users.ts                    # User management (MVP)
├── .env.local                      # Environment variables
├── package.json
└── README.md
```

## Platform-Specific Setup

### iOS

1. Download `.mobileconfig` file
2. Open file on iOS device
3. Go to Settings → Profile Downloaded
4. Tap "Install"
5. Enter passcode
6. Go to Settings → VPN
7. Toggle VPN on

### macOS

1. Install [WireGuard for macOS](https://apps.apple.com/app/wireguard/id1451685025)
2. Download `.conf` file
3. Open WireGuard app
4. Click "Import tunnel(s) from file"
5. Select downloaded file
6. Click "Activate"

### Windows

1. Install [WireGuard for Windows](https://www.wireguard.com/install/)
2. Download `.conf` file
3. Open WireGuard app
4. Click "Import tunnel(s) from file"
5. Select downloaded file
6. Click "Activate"

## Production Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables in Vercel dashboard
```

### Environment Variables for Production

Make sure to set these in your hosting platform:

- `VPN_RESELLERS_API_BASE`
- `VPN_RESELLERS_API_TOKEN`
- `VPN_CREDENTIAL_ENCRYPTION_KEY`
- `NEXTAUTH_URL` (your production URL)
- `NEXTAUTH_SECRET`

## Upgrading to Production

This MVP uses in-memory storage. For production:

### 1. Add Database

Replace `lib/users.ts` with proper database:

**Option A: Supabase**
```bash
npm install @supabase/supabase-js
```

**Option B: PostgreSQL + Prisma**
```bash
npm install @prisma/client
npx prisma init
```

### 2. Add Proper Authentication

Replace simple cookie auth with:

**Option A: NextAuth.js**
```bash
npm install next-auth
```

**Option B: Clerk**
```bash
npm install @clerk/nextjs
```

### 3. Add Payment Processing

Integrate Stripe for subscriptions:
```bash
npm install stripe @stripe/stripe-js
```

## API Documentation

### POST /api/auth/register

Create new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "licenseKey": "S24-1234567890-ABCD",
    "status": "active"
  }
}
```

### POST /api/auth/login

Authenticate user.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "licenseKey": "S24-1234567890-ABCD",
    "status": "active"
  }
}
```

### GET /api/vpn/servers

List available VPN servers.

**Response:**
```json
{
  "success": true,
  "servers": [
    {
      "id": "1",
      "name": "US East",
      "city": "New York",
      "country": "US"
    }
  ]
}
```

### GET /api/vpn/config

Download VPN configuration.

**Query Parameters:**
- `license` (required): User license key
- `server` (optional): Server ID
- `protocol` (optional): `wireguard` or `openvpn` (default: wireguard)
- `platform` (optional): `ios`, `desktop` (default: desktop)

**Example:**
```
GET /api/vpn/config?license=S24-123&server=1&protocol=wireguard&platform=ios
```

**Response:** Configuration file download

## Troubleshooting

### VPN Not Connecting

1. **Check API Token**: Verify `VPN_RESELLERS_API_TOKEN` is correct
2. **Check Logs**: Look for errors in console
3. **Test API**: Try calling VPN Resellers API directly with curl
4. **Verify Config**: Open config file and check for "PLACEHOLDER" text

### Config Contains Placeholders

If config has fake credentials:
- API token is wrong or missing
- VPN account creation failed
- Check server logs for errors

### No Servers Available

- API token may not have access
- VPN Resellers API may be down
- Check network connectivity

## Security Notes

⚠️ **Important for Production:**

1. **Use HTTPS**: Always use SSL in production
2. **Encrypt Credentials**: Implement proper encryption for stored passwords
3. **Rate Limiting**: Add rate limiting to prevent abuse
4. **Input Validation**: Validate all user inputs
5. **CORS**: Configure CORS properly for API endpoints
6. **Environment Variables**: Never commit `.env.local` to git

## License

MIT

## Support

For VPN Resellers API issues: https://api.vpnresellers.com/docs/v3_2  
For S24 VPN issues: Create an issue in this repository

---

**Built with ❤️ using Next.js and VPN Resellers API**
