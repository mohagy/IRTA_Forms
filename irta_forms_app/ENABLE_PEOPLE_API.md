# Enable People API for Google Sign-In

## The Error

You're seeing: **"People API has not been used in project 513224798808 before or it is disabled"**

## Quick Fix

Google Sign-In requires the **People API** to be enabled in your Google Cloud project.

### Step 1: Enable People API

**Option A: Direct Link (Easiest)**
1. Click this link: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=513224798808
2. Click the **"ENABLE"** button
3. Wait a few seconds for it to enable

**Option B: Manual Steps**
1. Go to: https://console.cloud.google.com/
2. Make sure project **"irta-forms-app"** is selected (top dropdown)
3. Navigate to: **APIs & Services** → **Library**
4. Search for: **"People API"**
5. Click on **"Google People API"**
6. Click the **"ENABLE"** button
7. Wait a few seconds

### Step 2: Wait for Propagation

After enabling:
- Wait 1-2 minutes for the API to propagate
- The API needs to be activated across Google's systems

### Step 3: Test Again

1. Go to: https://mohagy.github.io/IRTA_Forms/#/login
2. Select **"Applicant"** role
3. Click **"Sign in with Google"**
4. It should work now!

## Why This API is Needed

The People API is used by Google Sign-In to:
- Get user profile information (name, email, photo)
- Retrieve user details after authentication
- Required for Google Sign-In to work properly

## Verification

To verify the API is enabled:
1. Go to: https://console.cloud.google.com/apis/library/people.googleapis.com?project=513224798808
2. You should see **"API enabled"** status
3. If it says "Enable", click it

---

**Once enabled, Google Sign-In will work!**



