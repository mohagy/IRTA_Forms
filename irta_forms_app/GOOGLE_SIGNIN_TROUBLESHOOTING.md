# Google Sign-In Troubleshooting Guide

## Error: "Failed to get authentication tokens from Google"

This error occurs when Google Sign-In completes but doesn't return the required authentication tokens (accessToken or idToken).

## Step-by-Step Fix

### 1. Verify OAuth Client Configuration

Go to: [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)

Find your OAuth 2.0 Client ID: `513224798808-1vlmln0c4ecjfrs5lqkpupqk1oe28knk.apps.googleusercontent.com`

#### Authorized JavaScript origins (domains only, no paths):
```
https://mohagy.github.io
http://localhost
http://localhost:5000
https://irta-forms-app.firebaseapp.com
```

#### Authorized redirect URIs (must include /__/auth/handler path):
```
https://mohagy.github.io/__/auth/handler
http://localhost/__/auth/handler
```

**Important:** 
- Do NOT put redirect URIs in JavaScript origins
- Do NOT put bare domains in redirect URIs
- JavaScript origins = domains only
- Redirect URIs = full URLs with paths

### 2. Enable Google People API

Go to: [Google Cloud Console - APIs & Services - Library](https://console.cloud.google.com/apis/library)

Search for "Google People API" and click **Enable**

Or use direct link: [Enable People API](https://console.cloud.google.com/apis/library/people.googleapis.com)

### 3. Verify Client ID in index.html

File: `irta_forms_app/web/index.html`

Should contain:
```html
<meta name="google-signin-client_id" content="513224798808-1vlmln0c4ecjfrs5lqkpupqk1oe28knk.apps.googleusercontent.com">
```

### 4. Check Browser Console

1. Open browser Developer Tools (F12)
2. Go to Console tab
3. Try Google Sign-In again
4. Look for any error messages
5. Check Network tab for failed requests

### 5. Verify OAuth Consent Screen

Go to: [Google Cloud Console - OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)

Ensure:
- User type is set (Internal or External)
- App is published (or you're a test user)
- Required scopes are added (email, profile, openid)

### 6. Test in Incognito/Private Window

Sometimes browser extensions or cached data interfere. Try:
- Open an incognito/private browser window
- Clear all cookies and cache
- Try Google Sign-In again

### 7. Check Firebase Authentication Settings

Go to: [Firebase Console - Authentication - Sign-in method](https://console.firebase.google.com/project/irta-forms-app/authentication/providers)

Ensure:
- Google provider is **Enabled**
- Web SDK configuration is set
- Support email is configured

### 8. Common Issues and Solutions

#### Issue: Redirect URI mismatch
**Solution:** Double-check Authorized redirect URIs match exactly (including https/http, trailing slashes, paths)

#### Issue: People API not enabled
**Solution:** Enable People API in Google Cloud Console

#### Issue: OAuth consent screen not configured
**Solution:** Complete OAuth consent screen setup in Google Cloud Console

#### Issue: Browser blocking popups
**Solution:** Allow popups for the site, or check browser settings

#### Issue: Client ID mismatch
**Solution:** Verify the Client ID in `index.html` matches the one in Google Cloud Console

### 9. Quick Verification Checklist

- [ ] OAuth Client ID exists in Google Cloud Console
- [ ] Authorized JavaScript origins are set correctly (domains only)
- [ ] Authorized redirect URIs are set correctly (with /__/auth/handler)
- [ ] People API is enabled
- [ ] OAuth consent screen is configured
- [ ] Client ID is correct in `index.html`
- [ ] Google provider is enabled in Firebase Console
- [ ] Browser console shows no errors
- [ ] Tried in incognito/private window

### 10. Still Not Working?

If all the above is correct and you're still getting the error:

1. **Wait 10-15 minutes** after making changes (OAuth settings can take time to propagate)
2. **Check browser console** for more detailed error messages
3. **Try a different browser** to rule out browser-specific issues
4. **Check Firebase Console logs** for authentication errors
5. **Verify the account email** is allowed (if using Internal user type in OAuth consent screen)

## Contact Points

- Google Cloud Console: https://console.cloud.google.com
- Firebase Console: https://console.firebase.google.com/project/irta-forms-app
- OAuth Client ID: 513224798808-1vlmln0c4ecjfrs5lqkpupqk1oe28knk.apps.googleusercontent.com

