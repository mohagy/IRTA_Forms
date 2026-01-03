# Final OAuth Setup - Clean Configuration

## Current Issues

Your redirect URIs have some incorrect entries. Let's clean them up.

## Correct Configuration

### Authorized JavaScript Origins
Keep only these (just domains, no paths):
- ✅ `http://localhost`
- ✅ `http://localhost:5000`
- ✅ `https://irta-forms-app.firebaseapp.com`
- ✅ `https://mohagy.github.io` (ADD THIS if not there)

### Authorized Redirect URIs
Keep only these (must have `/__/auth/handler` path):
- ✅ `https://mohagy.github.io/__/auth/handler`
- ✅ `http://localhost/__/auth/handler`

**REMOVE these (they're wrong - domains without paths don't belong here):**
- ❌ `https://mohagy.github.io` (remove - this is for JavaScript origins, not redirect URIs)
- ❌ `http://localhost` (remove - this is for JavaScript origins, not redirect URIs)
- ❌ `https://mohagy.github.io/IRTA_Forms/__/auth/handler` (remove - not needed, the base domain one works)

## Steps to Fix

1. Go to: https://console.cloud.google.com/apis/credentials?project=513224798808
2. Click on your OAuth 2.0 Client ID
3. In **Authorized redirect URIs** section:
   - Remove: `https://mohagy.github.io`
   - Remove: `http://localhost`
   - Remove: `https://mohagy.github.io/IRTA_Forms/__/auth/handler` (optional, but cleaner)
   - Keep only:
     - `https://mohagy.github.io/__/auth/handler`
     - `http://localhost/__/auth/handler`
4. In **Authorized JavaScript origins**:
   - Make sure you have: `https://mohagy.github.io` (just the domain)
5. Click **SAVE**

## Important Notes

⚠️ **Wait Time**: The console says "It may take 5 minutes to a few hours for settings to take effect"
- This is normal! OAuth settings need time to propagate
- Try again in 10-15 minutes
- If it still doesn't work after an hour, there might be another issue

## Alternative: Try Firebase Auth Domain

If the GitHub Pages domain doesn't work, you might also need:
- Redirect URI: `https://irta-forms-app.firebaseapp.com/__/auth/handler`

This is the Firebase Auth domain, which sometimes works better for authentication flows.

## Final Checklist

✅ JavaScript Origins: Only domains (no paths)
✅ Redirect URIs: Only URIs with `/__/auth/handler` path
✅ Removed incorrect entries
✅ Saved changes
⏳ Waited 10-15 minutes for propagation
✅ Tested again

---

**Clean up the incorrect URIs, save, wait 10-15 minutes, then test again!**


