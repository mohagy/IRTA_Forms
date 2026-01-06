# Google OAuth Client ID Setup - QUICK FIX

## The Error

You're seeing: **"ClientID not set"** error for Google Sign-In.

## Quick Solution

You need to add your Google OAuth Client ID to `web/index.html`.

### Step 1: Get Your Client ID

**Option A: From Google Cloud Console (Recommended)**

1. Go to: https://console.cloud.google.com/
2. Select project: **irta-forms-app**
3. Navigate to: **APIs & Services** → **Credentials**
4. Look for **OAuth 2.0 Client IDs**
5. Find the one with type **Web application** (or **Web client**)
6. Click on it
7. Copy the **Client ID** (looks like: `513224798808-xxxxxxxxxxxxx.apps.googleusercontent.com`)

**Option B: From Firebase Console (Easier)**

1. Go to: https://console.firebase.google.com/
2. Select project: **irta-forms-app**
3. Go to: **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. You might see the **Web client ID** listed there
6. Copy it

**Option C: Create New Client ID (If none exists)**

1. Go to: https://console.cloud.google.com/
2. Select project: **irta-forms-app**
3. Navigate to: **APIs & Services** → **Credentials**
4. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
5. Application type: **Web application**
6. Name: **IRTA Forms Web**
7. Authorized JavaScript origins:
   - `https://mohagy.github.io`
   - `http://localhost` (for local dev)
8. Authorized redirect URIs:
   - `https://mohagy.github.io/IRTA_Forms/`
   - `http://localhost:PORT/` (for local dev)
9. Click **Create**
10. Copy the **Client ID**

### Step 2: Update index.html

1. Open: `irta_forms_app/web/index.html`
2. Find this line (around line 25):
   ```html
   <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
   ```
3. Replace `YOUR_CLIENT_ID.apps.googleusercontent.com` with your actual Client ID
4. Save the file

### Step 3: Commit and Push

```bash
cd C:\xampp2\htdocs\IRTA_Forms
git add irta_forms_app/web/index.html
git commit -m "Add Google OAuth Client ID to index.html"
git push
```

### Step 4: Wait for Deployment

- Wait 5-10 minutes for GitHub Actions to build and deploy
- Check: https://github.com/mohagy/IRTA_Forms/actions
- Once green ✅, test Google Sign-In again

## Example

If your Client ID is `513224798808-abcdefghijklmnop.apps.googleusercontent.com`, 
the meta tag should be:

```html
<meta name="google-signin-client_id" content="513224798808-abcdefghijklmnop.apps.googleusercontent.com">
```

## Need Help?

If you can't find the Client ID, check:
- Google Cloud Console → APIs & Services → Credentials
- Make sure you're in the correct project (irta-forms-app)
- Look for OAuth 2.0 Client IDs (not API keys)

---

**Once you add the Client ID and deploy, Google Sign-In will work!**



