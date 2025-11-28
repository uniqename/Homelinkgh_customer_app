# 🚀 Netlify Deployment Instructions for Privacy Policy

## 📂 **Files to Add to Your GitHub Repository**

Copy these files to your GitHub repository that's connected to Netlify:

### **1. Privacy Policy** (Required for Google Play)
```
privacy-policy.html
```
**Place at**: Root of your repository or in a `legal/` folder

### **2. Terms of Service** (Recommended)
```
terms-of-service.html
```
**Place at**: Same location as privacy policy

### **3. Netlify Redirects** (Important for URL routing)
```
_redirects
```
**Place at**: Root of your repository (must be in root)

## 🔄 **GitHub Deployment Steps**

### **Step 1: Add Files to GitHub**
```bash
# Navigate to your website repository
cd /path/to/your/website-repo

# Copy the files
cp /Users/enamegyir/Documents/Projects/blazer_home_services_app/customer_app/netlify_deployment/* .

# Add to git
git add privacy-policy.html terms-of-service.html _redirects

# Commit changes
git commit -m "Add privacy policy and terms for Google Play compliance"

# Push to GitHub
git push origin main
```

### **Step 2: Netlify Auto-Deploy**
- Netlify will automatically detect the GitHub changes
- Site will redeploy with new privacy policy
- URL will be live at: `https://your-netlify-domain.com/privacy-policy`

## 🔗 **Expected URLs After Deployment**

### **Primary Privacy Policy URL:**
```
https://beaconnewbeginnings.org/privacy-policy
```

### **Alternative URLs (via redirects):**
- `https://beaconnewbeginnings.org/privacy`
- `https://beaconnewbeginnings.org/privacy-policy/`
- `https://beaconnewbeginnings.org/privacy.html`

### **Terms of Service:**
```
https://beaconnewbeginnings.org/terms-of-service
```

## ✅ **Verification Steps**

### **After deployment, test these URLs:**
1. **Privacy Policy**: `https://beaconnewbeginnings.org/privacy-policy`
2. **Terms**: `https://beaconnewbeginnings.org/terms-of-service`
3. **Alternative**: `https://beaconnewbeginnings.org/privacy`

### **All URLs should:**
- ✅ Load without errors
- ✅ Display the complete privacy policy
- ✅ Use HTTPS (secure connection)
- ✅ Be mobile-friendly

## 📱 **Google Play Console Update**

### **Once URLs are live:**
1. **Go to**: [Google Play Console](https://play.google.com/console)
2. **Navigate to**: Your Beacon NGO app → Policy → Privacy Policy
3. **Enter URL**: `https://beaconnewbeginnings.org/privacy-policy`
4. **Save changes**
5. **Test URL** in console to verify it works

## 🎯 **Repository Structure**

### **Your GitHub repo should look like:**
```
your-website-repo/
├── index.html                 (your homepage)
├── privacy-policy.html        (NEW - privacy policy)
├── terms-of-service.html      (NEW - terms)
├── _redirects                 (NEW - URL routing)
├── assets/
├── css/
└── other website files...
```

## 🚨 **Important Notes**

### **File Placement:**
- `_redirects` MUST be in repository root
- HTML files can be in root or subfolder
- Netlify will handle URL routing automatically

### **URL Format:**
- Use `privacy-policy.html` (with hyphens)
- Redirects handle various URL formats
- Google Play accepts any working HTTPS URL

### **Testing:**
- Always test URLs after deployment
- Check on mobile devices
- Verify HTTPS works properly

## 📞 **Support**

If deployment fails:
1. **Check Netlify deploy logs** in your dashboard
2. **Verify GitHub repository** has the files
3. **Test redirects** are working properly
4. **Contact Netlify support** if needed

---

## 🎉 **After Successful Deployment:**

1. ✅ **Privacy policy will be live and accessible**
2. ✅ **Google Play Console can be updated with URL**
3. ✅ **App can be resubmitted for review**
4. ✅ **Privacy policy compliance achieved**

**Next step**: Push files to GitHub and wait for Netlify deployment!