# Strat24 VPN - Quick Start Guide

**⚡ Get to production in 1 hour!**

---

## ✅ Prerequisites

- [x] Supabase already set up ✅
- [ ] VPN Resellers API token
- [ ] Vercel account

---

## 🚀 Deploy in 5 Steps (55 minutes)

### Step 1: Configure Environment (10 minutes)

```bash
cd s24-vpn
cp .env.local.example .env.local
```

Edit `.env.local`:

```env
# VPN Resellers API (REQUIRED)
VPN_RESELLERS_API_BASE=https://api.vpnresellers.com/v3_2
VPN_RESELLERS_API_TOKEN=your_actual_token_here

# Generate these:
VPN_CREDENTIAL_ENCRYPTION_KEY=$(openssl rand -hex 32)
NEXTAUTH_SECRET=$(openssl rand -base64 32)

# Supabase (you already have these)
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...

# Strat24 Branding
NEXT_PUBLIC_APP_NAME=Strat24 Secure Access
NEXT_PUBLIC_COMPANY_NAME=Strat24
NEXT_PUBLIC_SUPPORT_EMAIL=support@strat24.com
```

### Step 2: Test Locally (15 minutes)

```bash
npm install
npm run dev
```

**Test these:**
1. Register new user → Should go to dashboard ✅
2. See license key displayed ✅
3. Download config → Should have real credentials ✅
4. Click logout → Should go to homepage ✅
5. Login again → Should work ✅

### Step 3: Deploy to Vercel (10 minutes)

```bash
npm install -g vercel
vercel
```

**In Vercel Dashboard:**
1. Go to your project → Settings → Environment Variables
2. Add ALL variables from `.env.local`
3. Update these for production:
   ```
   NEXT_PUBLIC_APP_URL=https://your-project.vercel.app
   NEXTAUTH_URL=https://your-project.vercel.app
   ```

```bash
vercel --prod
```

### Step 4: Test Production (10 minutes)

Visit your production URL and test:
1. Register new user ✅
2. Download config ✅
3. Verify config has real credentials ✅
4. Logout ✅
5. Login ✅

### Step 5: Update Provisioning Script (2 minutes)

```bash
nano hardware/provisioning/provision.sh
```

**Line 28:** Change to your production URL:
```bash
API_ENDPOINT="https://your-project.vercel.app/api/vpn/config"
```

```bash
git add hardware/provisioning/provision.sh
git commit -m "Update provisioning script with production URL"
git push
```

---

## ✅ You're Done!

**Platform Status:** 🟢 Live and ready for users  
**Hardware Status:** 🟢 Ready to provision devices  
**Time Taken:** ~55 minutes

---

## 🎯 Next: Provision Your First Device

### What You Need:
- GL.iNet Opal (GL-SFT1200) router
- Ethernet cable
- Computer with SSH client

### Follow This Guide:
`docs/hardware/GL-SFT1200-DEPLOYMENT-GUIDE.md`

**Time:** ~1 hour (setup + testing)

**Steps:**
1. Upgrade firmware to 4.3.25
2. Enable SSH
3. Upload provisioning script
4. Run script
5. Run 10 tests
6. Deploy to client

---

## 📋 Production Checklist

### Platform:
- [x] Code fixes applied ✅
- [ ] Environment configured
- [ ] Tested locally
- [ ] Deployed to Vercel
- [ ] Tested production
- [ ] Provisioning script updated

### Hardware:
- [ ] Router purchased
- [ ] Firmware upgraded
- [ ] Provisioning tested
- [ ] All 10 tests passed
- [ ] Ready for client deployment

---

## 🆘 Quick Troubleshooting

**Config has placeholders?**
→ Check VPN_RESELLERS_API_TOKEN is correct

**Session expired after register?**
→ Already fixed! Just redeploy.

**Can't logout?**
→ Already fixed! Just redeploy.

**Provisioning fails?**
→ Check API_ENDPOINT URL in provision.sh

---

## 📚 Full Documentation

- **Deployment:** `DEPLOYMENT_INSTRUCTIONS.md`
- **Hardware:** `docs/hardware/GL-SFT1200-DEPLOYMENT-GUIDE.md`
- **Fixes Applied:** `FINAL_FIXES_APPLIED.md`
- **Client Guide:** `docs/guides/strat24_client_quick_start.md`

---

**Status:** ✅ All fixes applied - Ready to deploy!

**Support:** support@strat24.com  
**Website:** https://strat24.com
