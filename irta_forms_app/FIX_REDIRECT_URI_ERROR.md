# Fix Google Sign-In Redirect URI Mismatch Error

## The Error

**Error 400: redirect_uri_mismatch**

This means the redirect URI in your OAuth client doesn't match the one being used by your app.

## Solution: Update Authorized Redirect URIs

### Step 1: Go to Google Cloud Console

1. Go to: https://console.cloud.google.com/
2. Make sure project **"irta-forms-app"** is selected (top dropdown)

### Step 2: Find Your OAuth 2.0 Client

1. Navigate to: **APIs & Services** → **Credentials**
2. Find **OAuth 2.0 Client IDs** section
3. Find the client with type **"Web application"** (the one with Client ID: `513224798808-1vlmln0c4ecjfrs5lqkpupqk1oe28knk`)
4. Click on it to edit

### Step 3: Add Authorized Redirect URIs

In the **Authorized redirect URIs** section, add these URIs:

```
https://mohagy.github.io/__/auth/handler
https://mohagy.github.io/IRTA_Forms/__/auth/handler
http://localhost:PORT/__/auth/handler
```

**OR** if the above doesn't work, try:

```
https://mohagy.github.io/
https://mohagy.github.io/IRTA_Forms/
http://localhost/
```

**IMPORTANT**: Make sure you include:
- The Firebase Auth domain redirect handler: `https://mohagy.github.io/__/auth/handler`
- Your GitHub Pages domain with path: `https://mohagy.github.io/IRTA_Forms/__/auth/handler`
- Local development URI: `http://localhost:PORT/__/auth/handler` (replace PORT with your port number, or just use `http://localhost/`)

### Step 4: Also Check Authorized JavaScript Origins

In the **Authorized JavaScript origins** section, make sure you have:

```
https://mohagy.github.io
http://localhost
```

### Step 5: Save

1. Click **"SAVE"** button
2. Wait 1-2 minutes for changes to propagate

### Step 6: Test Again

1. Go to: https://mohagy.github.io/IRTA_Forms/#/login
2. Select "Applicant" role
3. Click "Sign in with Google"
4. It should work now!

## Common Redirect URIs for Firebase Auth

Firebase Auth typically uses these redirect URI patterns:
- `https://YOUR_DOMAIN/__/auth/handler`
- `https://YOUR_DOMAIN/PATH/__/auth/handler`

For your case:
- Domain: `mohagy.github.io`
- Path: `/IRTA_Forms/`
- Redirect URI: `https://mohagy.github.io/IRTA_Forms/__/auth/handler`

## Alternative: Use Firebase Auth Domain

If you're using Firebase Authentication, you might also need:
- `https://irta-forms-app.firebaseapp.com/__/auth/handler`

Check your Firebase Console → Authentication → Settings for the exact auth domain.

## Quick Checklist

✅ OAuth 2.0 Client ID exists
✅ Authorized JavaScript origins include: `https://mohagy.github.io`
✅ Authorized redirect URIs include: `https://mohagy.github.io/__/auth/handler` or `https://mohagy.github.io/IRTA_Forms/__/auth/handler`
✅ Changes saved
✅ Waited 1-2 minutes for propagation

---

**Once you update the redirect URIs, the error should be resolved!**


