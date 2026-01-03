# Correct Setup for Google OAuth Client

## The Problem

You're getting errors because:
1. **Authorized JavaScript origins** cannot contain paths (only domains)
2. **Authorized redirect URIs** can contain paths (these are for the redirect handler)

## Correct Setup Steps

### Step 1: Fix Authorized JavaScript Origins

In the **"Authorized JavaScript origins"** section:

**Remove these (they're wrong because they have paths):**
- ❌ `https://mohagy.github.io/__/auth/handler`
- ❌ `https://mohagy.github.io/IRTA_Forms/__/auth/handler`
- ❌ `http://localhost/__/auth/handler`

**Keep/Add these (correct - no paths):**
- ✅ `http://localhost`
- ✅ `http://localhost:5000`
- ✅ `https://irta-forms-app.firebaseapp.com`
- ✅ `https://mohagy.github.io` (ADD THIS - just the domain, no path)

### Step 2: Find and Use Authorized Redirect URIs Section

Scroll down below the "Authorized JavaScript origins" section. You should see:
- **"Authorized redirect URIs"** section (this is different from JavaScript origins!)

In the **"Authorized redirect URIs"** section, add:
- ✅ `https://mohagy.github.io/__/auth/handler`
- ✅ `http://localhost/__/auth/handler`

### Step 3: Summary

**Authorized JavaScript origins** (just domains, no paths):
```
http://localhost
http://localhost:5000
https://irta-forms-app.firebaseapp.com
https://mohagy.github.io
```

**Authorized redirect URIs** (can have paths):
```
https://mohagy.github.io/__/auth/handler
http://localhost/__/auth/handler
```

### Step 4: Save

1. Click **"SAVE"** button
2. Wait 1-2 minutes
3. Test Google Sign-In again

## Key Difference

- **JavaScript Origins** = Just domains (e.g., `https://mohagy.github.io`)
- **Redirect URIs** = Can have paths (e.g., `https://mohagy.github.io/__/auth/handler`)

---

**If you don't see "Authorized redirect URIs" section, scroll down - it should be below the JavaScript origins section!**


