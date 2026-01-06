# Admin Credentials Setup Guide

## Important Note
**There are no default admin credentials.** Firebase Authentication requires you to create users manually. Here's how to set up an admin account:

## Option 1: Create Admin via Firebase Console (Recommended)

### Step 1: Create User in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **irta-forms-app**
3. Navigate to **Authentication** > **Users**
4. Click **Add user**
5. Enter:
   - **Email**: `admin@irta.gov.gy` (or your preferred email)
   - **Password**: Create a strong password
6. Click **Add user**

### Step 2: Set User Role in Firestore

1. Go to **Firestore Database** in Firebase Console
2. Create a collection called `users` (if it doesn't exist)
3. Create a document with ID = User UID (from Authentication)
4. Add a field:
   - **Field name**: `role`
   - **Field value**: `admin`
   - **Type**: string

### Step 3: Update AuthProvider (if needed)

The AuthProvider should read the role from Firestore. Check `lib/presentation/providers/auth_provider.dart` to ensure it reads the role from the user document.

## Option 2: Register via App and Manually Update Role

1. Register a new user through the app registration page
2. Note the user's email
3. Go to Firebase Console > Authentication > Users
4. Find the user and copy their UID
5. Go to Firestore Database
6. Create/update document in `users` collection with:
   - Document ID: User UID
   - Field: `role` = `admin`

## Option 3: Use Firebase CLI (Advanced)

```powershell
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Create user (requires Firebase Admin SDK setup)
# Note: This typically requires backend setup
```

## Recommended Admin Credentials Format

For testing/development, you can create:
- **Email**: `admin@irta.local`
- **Password**: (choose a secure password)
- **Role**: Set to `admin` in Firestore `users` collection

## Security Notes

⚠️ **Important:**
- Use strong passwords for admin accounts
- Never commit admin credentials to version control
- Consider using Firebase Authentication with custom claims for production
- Set up proper security rules in Firestore to protect admin-only data

## Check Current User Role

To verify a user's role:
1. Firebase Console > Firestore Database
2. Navigate to `users` collection
3. Find document with user's UID
4. Check the `role` field

## Testing Roles

Available roles (from `app_constants.dart`):
- `applicant` - Regular users submitting applications
- `admin` - Full system access
- `officer` - Processing applications
- `reception` - Reception review
- `verification` - Verification officers
- `issuing` - Issuing officers

## Next Steps

After creating the admin user:
1. Log in through the app with the admin credentials
2. The dashboard should show admin view
3. You should see all applications (not just your own)



