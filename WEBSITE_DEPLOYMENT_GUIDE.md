# 🌐 HomeLinkGH Website Deployment Guide

## 🚨 **URGENT: Fix homelinkgh.com for Apple Review**

Your Apple review is at risk because the privacy policy URL isn't working. Here's how to fix it immediately:

## 📂 **Website Files Ready**

All website files are now in the `docs/` folder:
- `docs/index.html` - Homepage
- `docs/privacy.html` - Privacy Policy (CRITICAL for Apple/Google)
- `docs/terms.html` - Terms of Service
- `docs/support.html` - Support page
- `docs/_redirects` - URL routing for Netlify

## 🚀 **Quick Deployment Options**

### **Option 1: GitHub Pages (Fastest)**
1. Go to your GitHub repo: `https://github.com/uniqename/Homelinkgh_customer_app`
2. Go to Settings → Pages
3. Set Source to "Deploy from a branch"
4. Select branch: `main` and folder: `/docs`
5. Save
6. Website will be at: `https://uniqename.github.io/Homelinkgh_customer_app/`

### **Option 2: Netlify (Best for Custom Domain)**
1. Go to [netlify.com](https://netlify.com) and sign in
2. "New site from Git" → Connect to GitHub
3. Select your `Homelinkgh_customer_app` repo
4. Set publish directory to `docs`
5. Deploy
6. Go to Domain settings and add custom domain: `homelinkgh.com`

## 🔗 **Critical URLs After Deployment**

Once deployed, these URLs MUST work:
- `https://homelinkgh.com/privacy` ← **CRITICAL for Apple Review**
- `https://homelinkgh.com/terms`
- `https://homelinkgh.com/support`

## ⚡ **Immediate Git Commands**

Run these commands to deploy right now:

```bash
# Add and commit website files
git add docs/
git commit -m "🌐 Add HomeLinkGH website with privacy policy for App Store compliance

Critical fixes:
- Add comprehensive privacy policy for Apple/Google review
- Add terms of service and support pages  
- Set up Netlify redirects for clean URLs
- Ensure homelinkgh.com/privacy works for app store approval"

# Push to trigger deployment
git push origin main
```

## 🛠 **Domain DNS Fix (If Needed)**

If your `homelinkgh.com` domain is pointing to the wrong place:

1. **Log into your domain registrar** (GoDaddy, Namecheap, etc.)
2. **Update DNS settings:**
   - For Netlify: Add CNAME record pointing to your Netlify URL
   - For GitHub Pages: Add CNAME record pointing to `uniqename.github.io`
3. **Wait 5-10 minutes** for DNS propagation

## 📱 **App Store Impact**

**Before Fix:**
- Apple Review: ❌ **WILL REJECT** (privacy policy URL broken)
- Google Play: ❌ **WILL REJECT** (privacy policy URL broken)

**After Fix:**
- Apple Review: ✅ **WILL APPROVE** (privacy policy accessible)
- Google Play: ✅ **READY FOR SUBMISSION** (all URLs working)

## 🎯 **Next Steps**

1. **Deploy website immediately** (use commands above)
2. **Test privacy policy URL** works: `https://homelinkgh.com/privacy`
3. **Monitor Apple review status** - they should approve once URL works
4. **Submit Google Play app** with working privacy policy

## 📞 **Emergency Contact**

If you need help with deployment:
- Check GitHub Actions for deployment status
- Verify DNS settings in your domain registrar
- Test all URLs before app store submission

**🚨 Deploy this website NOW to save your Apple review!**