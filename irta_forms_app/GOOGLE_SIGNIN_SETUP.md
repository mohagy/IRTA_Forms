# Google Sign-In Setup Guide

## Overview

Google Sign-In has been added to the IRTA Forms application for **applicants only**. This allows applicants to quickly sign in or register using their Google account without filling out the full registration form.

## Features

- ✅ Google Sign-In button on Login page (only visible when "Applicant" role is selected)
- ✅ Google Sign-Up button on Registration page
- ✅ Automatic user creation in Firestore with "applicant" role
- ✅ Seamless integration with existing authentication system

## Firebase Configuration

### Step 1: Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **irta-forms-app**
3. Navigate to: **Authentication** → **Sign-in method**
4. Find **Google** in the list of providers
5. Click on **Google**
6. Toggle **Enable** to ON
7. Enter a **Project support email** (your email)
8. Click **Save**

### Step 2: Configure OAuth Consent Screen (if needed)

For web apps, you may need to configure the OAuth consent screen:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to: **APIs & Services** → **OAuth consent screen**
4. Fill in the required information:
   - User Type: **External** (or Internal if using Google Workspace)
   - App name: **IRTA Forms**
   - User support email: Your email
   - Developer contact: Your email
5. Add scopes (if needed):
   - `email`
   - `profile`
   - `openid`
6. Click **Save and Continue**

### Step 3: Authorized Domains (Already Done)

The GitHub Pages domain should already be in authorized domains:
- `mohagy.github.io`
- `localhost` (for local development)

If not, add them:
1. Firebase Console → **Authentication** → **Settings** → **Authorized domains**
2. Add: `mohagy.github.io`
3. Click **Add**

## How It Works

### For Applicants (Login Page)

1. User selects **"Applicant"** role on login page
2. **"Sign in with Google"** button appears
3. User clicks the button
4. Google Sign-In popup opens
5. User selects/authorizes their Google account
6. User is signed in and redirected to dashboard
7. User document is created/updated in Firestore with "applicant" role

### For Applicants (Registration Page)

1. User navigates to registration page
2. **"Sign up with Google"** button appears at the top
3. User clicks the button
4. Google Sign-In popup opens
5. User selects/authorizes their Google account
6. User is automatically registered and redirected to dashboard
7. User document is created in Firestore with "applicant" role

### Security Features

- ✅ Google Sign-In is **only available for applicants**
- ✅ Officer/Admin/Staff must use email/password login
- ✅ All Google sign-ins are automatically assigned "applicant" role
- ✅ Existing users with other roles cannot use Google Sign-In (role is reset to applicant)

## User Flow

```
User selects "Applicant" → Google Sign-In button appears
                          ↓
User clicks "Sign in with Google"
                          ↓
Google OAuth popup opens
                          ↓
User authorizes → Firebase creates/updates user
                          ↓
Firestore document created/updated with role="applicant"
                          ↓
User redirected to Dashboard
```

## Testing

### Test Google Sign-In

1. Go to login page: https://mohagy.github.io/IRTA_Forms/#/login
2. Select **"Applicant"** role
3. Click **"Sign in with Google"**
4. Select your Google account
5. Verify you're redirected to dashboard
6. Check Firestore: `users/{userId}` should have `role: "applicant"`

### Test Registration

1. Go to registration page: https://mohagy.github.io/IRTA_Forms/#/registration
2. Click **"Sign up with Google"** (top of form)
3. Select your Google account
4. Verify you're redirected to dashboard
5. Check Firestore: New user document with `role: "applicant"`

## Troubleshooting

### Error: "Google Sign-In failed"

- **Check**: Google Sign-In is enabled in Firebase Console
- **Check**: OAuth consent screen is configured
- **Check**: Authorized domains include your domain

### Error: "Sign-in method not found"

- **Solution**: Enable Google Sign-In in Firebase Console (Step 1 above)

### Button doesn't appear

- **Login Page**: Make sure "Applicant" role is selected
- **Registration Page**: Button should always be visible (page is for applicants only)

### User role is not "applicant"

- **Check**: Firestore document has correct role
- **Note**: Google Sign-In always creates users with "applicant" role

## Important Notes

⚠️ **Google Sign-In is ONLY for Applicants**

- Officer/Admin/Staff must use email/password authentication
- This ensures proper security and role management for staff accounts
- Google Sign-In provides convenience for applicants while maintaining security for staff

## Code Location

- **AuthService**: `lib/services/auth_service.dart` - `signInWithGoogle()` method
- **AuthProvider**: `lib/presentation/providers/auth_provider.dart` - `signInWithGoogle()` method
- **Login Page**: `lib/presentation/pages/login/login_page.dart` - Google button (applicant only)
- **Registration Page**: `lib/presentation/pages/registration/registration_page.dart` - Google button

---

**Next Step**: Enable Google Sign-In in Firebase Console (Step 1 above), then test the feature!


