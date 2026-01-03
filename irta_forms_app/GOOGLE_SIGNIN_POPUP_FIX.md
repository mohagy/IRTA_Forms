# Fixing Google Sign-In Popup Token Issue

## Problem
You can select your Google account in the popup, but then get the error: "Failed to get authentication tokens from Google"

## Root Cause
The `google_sign_in` package's `signIn()` method is deprecated on web and has issues with:
1. Cross-Origin-Opener-Policy (COOP) blocking popup communication
2. Browser security policies preventing token retrieval
3. OAuth flow completing but tokens not being passed back

## Solutions

### Solution 1: Check Browser Settings (Quick Fix)

1. **Allow Popups for the Site**
   - In Chrome/Edge: Click the popup blocker icon in the address bar
   - Allow popups for `mohagy.github.io`

2. **Disable Popup Blockers**
   - Check browser extensions (ad blockers, privacy tools)
   - Temporarily disable them and try again

3. **Try Different Browser**
   - Test in Chrome, Firefox, or Edge
   - Some browsers handle OAuth popups differently

### Solution 2: Use Incognito/Private Window

1. Open an incognito/private browser window
2. Navigate to the site
3. Try Google Sign-In again
4. This eliminates cache and extension interference

### Solution 3: Verify OAuth Configuration

Even though your OAuth config looks correct, double-check:

1. **Google Cloud Console** → **APIs & Services** → **Credentials**
2. Find your OAuth Client ID: `513224798808-1vlmln0c4ecjfrs5lqkpupqk1oe28knk`
3. Verify:
   - **Authorized JavaScript origins** includes: `https://mohagy.github.io`
   - **Authorized redirect URIs** includes: `https://mohagy.github.io/__/auth/handler`
4. **Save** if you made any changes
5. **Wait 10-15 minutes** for changes to propagate

### Solution 4: Enable People API

1. Go to: https://console.cloud.google.com/apis/library/people.googleapis.com
2. Click **Enable** if not already enabled
3. Wait a few minutes
4. Try again

### Solution 5: Check OAuth Consent Screen

1. Go to: https://console.cloud.google.com/apis/credentials/consent
2. Ensure:
   - User type is set (Internal or External)
   - App is published OR you're added as a test user
   - Required scopes are added (email, profile, openid)
3. If using "Internal" user type, make sure your Google account is in the organization

### Solution 6: Clear Browser Data

1. Clear cookies for `mohagy.github.io`
2. Clear cache
3. Try again

### Solution 7: Check Firebase Authentication Settings

1. Go to: https://console.firebase.google.com/project/irta-forms-app/authentication/providers
2. Click on **Google** provider
3. Verify:
   - Status is **Enabled** ✅
   - Support email is set
   - Web SDK configuration is present

## Testing Steps

1. Open browser Developer Tools (F12)
2. Go to **Console** tab
3. Try Google Sign-In
4. Look for any error messages
5. Check **Network** tab for failed requests
6. Look for any CORS or COOP-related errors

## Alternative: Use Email/Password for Now

If Google Sign-In continues to fail, you can:
1. Use the regular **Email/Password** registration
2. Register with your email: `nathonheart@gmail.com`
3. Use a password you create
4. Google Sign-In can be fixed later without affecting your account

## Note About Registration

**You do NOT need to register separately!** Google Sign-In handles both:
- **First time** → Automatically creates your account
- **Returning user** → Logs you in

The issue is purely technical - the authentication flow completes but tokens aren't being retrieved due to browser security policies.

## Still Not Working?

If all the above fails, the issue may be with the deprecated `google_sign_in` package on web. We may need to:
1. Update to use Firebase Auth's native Google provider (which uses redirect instead of popup)
2. Or wait for a package update that fixes the COOP issues

For now, use Email/Password registration as a workaround.

