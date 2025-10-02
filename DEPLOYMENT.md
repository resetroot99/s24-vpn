# S24 VPN - Deployment Guide

## Quick Deploy to Vercel

### 1. Connect to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/resetroot99/s24-vpn)

Or manually:

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd s24-vpn
vercel
```

### 2. Configure Environment Variables

In Vercel Dashboard → Settings → Environment Variables, add:

```env
VPN_RESELLERS_API_BASE=https://api.vpnresellers.com/v3_2
VPN_RESELLERS_API_TOKEN=ID-9821-KlN9kaPvHE7RgZOVD3cbej50Uw2GfLtyoWBlu6h4SnQrBqFLdMTmAXsYrCpxz
VPN_CREDENTIAL_ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
NEXTAUTH_URL=https://your-domain.vercel.app
NEXTAUTH_SECRET=your_random_secret_here
NEXT_PUBLIC_APP_URL=https://your-domain.vercel.app
NEXT_PUBLIC_APP_NAME=S24 VPN
```

Generate new secrets:
```bash
# For NEXTAUTH_SECRET
openssl rand -base64 32

# For VPN_CREDENTIAL_ENCRYPTION_KEY
openssl rand -hex 32
```

### 3. Deploy

```bash
vercel --prod
```

Your site will be live at: `https://your-project.vercel.app`

---

## Alternative: Deploy to Netlify

### 1. Connect Repository

1. Go to [Netlify](https://netlify.com)
2. Click "Add new site" → "Import an existing project"
3. Connect to GitHub and select `s24-vpn` repository

### 2. Build Settings

- **Build command**: `npm run build`
- **Publish directory**: `.next`
- **Functions directory**: `.netlify/functions`

### 3. Environment Variables

Add the same environment variables as Vercel (see above)

### 4. Deploy

Click "Deploy site"

---

## Alternative: Deploy to Railway

### 1. Connect Repository

1. Go to [Railway](https://railway.app)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select `s24-vpn` repository

### 2. Configure

Railway will auto-detect Next.js and configure build settings.

### 3. Environment Variables

Add environment variables in Railway dashboard (same as above)

### 4. Deploy

Railway will automatically deploy on push to main branch

---

## Alternative: Deploy to Your Own Server

### Requirements

- Node.js 18+ installed
- PM2 or similar process manager
- Nginx or Apache for reverse proxy
- SSL certificate (Let's Encrypt recommended)

### 1. Clone Repository

```bash
git clone https://github.com/resetroot99/s24-vpn.git
cd s24-vpn
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

```bash
cp .env.template .env.local
# Edit .env.local with your values
nano .env.local
```

### 4. Build Application

```bash
npm run build
```

### 5. Start with PM2

```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start npm --name "s24-vpn" -- start

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

### 6. Configure Nginx

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 7. Setup SSL with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

---

## Post-Deployment Checklist

- [ ] Environment variables configured correctly
- [ ] VPN Resellers API token is valid
- [ ] Test user registration
- [ ] Test VPN config download
- [ ] Test VPN connection on iOS
- [ ] Test VPN connection on macOS
- [ ] Test VPN connection on Windows
- [ ] Verify HTTPS is working
- [ ] Check logs for errors
- [ ] Setup monitoring (optional)

---

## Monitoring & Logs

### Vercel

View logs in Vercel Dashboard → Deployments → [Your Deployment] → Logs

### Railway

View logs in Railway Dashboard → [Your Project] → Deployments → Logs

### Self-Hosted (PM2)

```bash
# View logs
pm2 logs s24-vpn

# Monitor
pm2 monit
```

---

## Troubleshooting

### Build Fails

**Error**: `Module not found: Can't resolve '@tailwindcss/postcss'`

**Solution**:
```bash
npm install @tailwindcss/postcss
```

### API Errors

**Error**: `VPN API Error (401): Unauthorized`

**Solution**: Check `VPN_RESELLERS_API_TOKEN` is correct

### Config Download Fails

**Error**: `VPN account not provisioned`

**Solution**: 
1. Check API token has permissions
2. Check logs for account creation errors
3. Try creating a new user

---

## Scaling for Production

### 1. Add Database

Replace in-memory storage with PostgreSQL:

```bash
npm install @prisma/client
npx prisma init
```

### 2. Add Redis for Caching

```bash
npm install ioredis
```

Cache server list and reduce API calls.

### 3. Add Rate Limiting

```bash
npm install express-rate-limit
```

Prevent abuse of API endpoints.

### 4. Add Analytics

```bash
npm install @vercel/analytics
```

Track user behavior and conversions.

### 5. Add Error Tracking

```bash
npm install @sentry/nextjs
```

Monitor errors in production.

---

## Custom Domain

### Vercel

1. Go to Project Settings → Domains
2. Add your custom domain
3. Update DNS records as instructed
4. Update `NEXTAUTH_URL` and `NEXT_PUBLIC_APP_URL` environment variables

### Netlify

1. Go to Site Settings → Domain Management
2. Add custom domain
3. Update DNS records
4. Update environment variables

---

## Backup & Recovery

### Database Backup (when using PostgreSQL)

```bash
# Backup
pg_dump -U username -d database_name > backup.sql

# Restore
psql -U username -d database_name < backup.sql
```

### Code Backup

Code is backed up in GitHub. To restore:

```bash
git clone https://github.com/resetroot99/s24-vpn.git
```

---

## Support

For deployment issues:
- Vercel: https://vercel.com/support
- Netlify: https://netlify.com/support
- Railway: https://railway.app/help

For application issues:
- GitHub Issues: https://github.com/resetroot99/s24-vpn/issues

---

**🚀 Happy Deploying!**
