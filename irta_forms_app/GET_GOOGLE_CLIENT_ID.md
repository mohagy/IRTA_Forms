# How to Get Google OAuth Client ID for Web

## Step 1: Get Client ID from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **irta-forms-app**
3. Go to: **Project Settings** (gear icon) → **General** tab
4. Scroll down to **Your apps** section
5. Find the **Web app** (should be named something like "irta_forms_app (web)")
6. Look for **Web API Key** and **App ID** - but we need the OAuth Client ID

## Step 2: Get OAuth Client ID from Google Cloud Console

The OAuth Client ID is in Google Cloud Console (Firebase uses Google Cloud behind the scenes):

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project: **irta-forms-app** (or the project ID)
3. Navigate to: **APIs & Services** → **Credentials**
4. Look for **OAuth 2.0 Client IDs**
5. Find the one with type **Web application** (or **Web client**)
6. Click on it to see details
7. Copy the **Client ID** (looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)

**OR** if you don't see it:

1. In Google Cloud Console → **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Application type: **Web application**
4. Name: **IRTA Forms Web**
5. Authorized JavaScript origins:
   - `https://mohagy.github.io`
   - `http://localhost` (for local development)
6. Authorized redirect URIs:
   - `https://mohagy.github.io/IRTA_Forms/`
   - `http://localhost:PORT/` (for local development)
7. Click **Create**
8. Copy the **Client ID**

## Step 3: Add Client ID to index.html

Once you have the Client ID, it needs to be added to `web/index.html` as a meta tag.

The meta tag should look like:
```html
<meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com" />
```

## Alternative: Get from Firebase Console (Newer Method)

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click on **Google** provider
3. You might see the **Web client ID** listed there
4. Copy it

---

**Note**: The Client ID is different from the Web API Key. Make sure you're getting the OAuth 2.0 Client ID specifically.


