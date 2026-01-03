# Quick Guide: Get Google OAuth Client ID

## Your Project Info
- **Project ID**: irta-forms-app
- **Project Number**: 513224798808

## Step-by-Step: Get Client ID

### Step 1: Go to Google Cloud Console

1. Open: https://console.cloud.google.com/
2. **IMPORTANT**: Make sure you select the project **"irta-forms-app"** (top dropdown)

### Step 2: Navigate to Credentials

1. Click the hamburger menu (☰) on the left
2. Go to: **APIs & Services** → **Credentials**
3. Or direct link: https://console.cloud.google.com/apis/credentials?project=irta-forms-app

### Step 3: Find or Create OAuth 2.0 Client ID

**If you see "OAuth 2.0 Client IDs" section:**

1. Look for a client with type **"Web application"** or **"Web client"**
2. Click on it
3. Copy the **Client ID** (format: `513224798808-xxxxxxxxxxxxx.apps.googleusercontent.com`)

**If you DON'T see any OAuth clients:**

1. Click **"+ CREATE CREDENTIALS"** (top of page)
2. Select **"OAuth client ID"**
3. If prompted, configure OAuth consent screen first (follow the prompts)
4. Fill in:
   - **Application type**: Web application
   - **Name**: IRTA Forms Web
   - **Authorized JavaScript origins**:
     - `https://mohagy.github.io`
     - `http://localhost`
   - **Authorized redirect URIs**:
     - `https://mohagy.github.io/IRTA_Forms/`
     - `http://localhost` (for local dev)
5. Click **"Create"**
6. Copy the **Client ID** (it will be shown in a popup)

### Step 4: Update index.html

1. Open: `irta_forms_app/web/index.html`
2. Find line 25 (looks like this):
   ```html
   <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
   ```
3. Replace `YOUR_CLIENT_ID.apps.googleusercontent.com` with your actual Client ID
4. Example: If your Client ID is `513224798808-abc123def456.apps.googleusercontent.com`, the line should be:
   ```html
   <meta name="google-signin-client_id" content="513224798808-abc123def456.apps.googleusercontent.com">
   ```
5. Save the file

### Step 5: Commit and Push

```bash
cd C:\xampp2\htdocs\IRTA_Forms
git add irta_forms_app/web/index.html
git commit -m "Add Google OAuth Client ID"
git push
```

### Step 6: Wait for Deployment

- Wait 5-10 minutes
- Check: https://github.com/mohagy/IRTA_Forms/actions
- Look for green ✅ checkmark
- Then test Google Sign-In again!

## Quick Links

- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials?project=irta-forms-app
- **Firebase Console**: https://console.firebase.google.com/project/irta-forms-app/authentication/providers

## Troubleshooting

**Can't find OAuth clients?**
- Make sure you're in the correct project (irta-forms-app)
- Check the project selector in the top bar
- You might need to create one (see Step 3 above)

**Client ID format:**
- Should look like: `513224798808-xxxxxxxxxxxxx.apps.googleusercontent.com`
- Starts with your project number (513224798808)
- Ends with `.apps.googleusercontent.com`

**Still stuck?**
- Make sure Google Sign-In is enabled in Firebase Console (which you've already done ✅)
- The OAuth client might be created automatically when you enable Google Sign-In
- Check Google Cloud Console for any auto-created clients


