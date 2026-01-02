# How to Create Admin User - Step by Step

## The Error You're Seeing

The error "The supplied auth credential is incorrect, malformed or has expired" means the user `admin@irta.local` doesn't exist in Firebase Authentication yet. You need to create it first.

## Solution: Create User in Firebase Console

### Method 1: Create via Firebase Console (Recommended)

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Select your project: **irta-forms-app**

2. **Navigate to Authentication**
   - Click on **Authentication** in the left sidebar
   - Click on **Users** tab (should be selected by default)

3. **Add User**
   - Click the **Add user** button (usually at the top)
   - Enter:
     - **Email**: `admin@irta.local`
     - **Password**: `Admin123!` (or your preferred password)
   - Click **Add user**

4. **Copy User UID**
   - After the user is created, you'll see them in the users list
   - Click on the user to see details
   - **Copy the UID** (long string of characters) - you'll need this!

5. **Set Role in Firestore**
   - Go to **Firestore Database** in Firebase Console
   - Click **Start collection** (if this is your first collection)
   - Collection ID: `users`
   - Document ID: **Paste the UID you copied**
   - Click **Add field**:
     - Field: `role`
     - Type: `string`
     - Value: `admin`
   - Click **Save**

6. **Try Logging In Again**
   - Go back to your app
   - Use:
     - Email: `admin@irta.local`
     - Password: `Admin123!`
   - Click **Sign In**

### Method 2: Register via App First (Alternative)

If you prefer, you can also:

1. **Register a new user** through the app's registration page
2. **Note the email** you used
3. **Go to Firebase Console** > Authentication > Users
4. **Find your user** and copy their UID
5. **Set the role in Firestore** as described in Step 5 above

## Visual Guide

```
Firebase Console > Authentication > Users
├── Click "Add user"
├── Enter email: admin@irta.local
├── Enter password: Admin123!
├── Click "Add user"
└── Copy the User UID

Firebase Console > Firestore Database
├── Start collection (or use existing)
├── Collection ID: users
├── Document ID: [Paste UID here]
├── Add field: role = "admin"
└── Save
```

## Common Issues

**Issue**: "User already exists"
- Solution: The user might have been created. Just copy the UID and set the role in Firestore.

**Issue**: "Cannot find UID"
- Solution: Click on the user's email in the Users list, the UID will be displayed at the top.

**Issue**: "Collection doesn't exist"
- Solution: You need to create the `users` collection first. Use "Start collection" button.

**Issue**: "Still seeing applicant view after login"
- Solution: 
  - Make sure the document ID in Firestore matches the User UID exactly
  - Verify the `role` field is set to `admin` (lowercase)
  - Try logging out and logging back in
  - Check browser console (F12) for any errors

## Quick Test

After setup, you should:
1. ✅ Be able to login with admin@irta.local
2. ✅ See the admin dashboard (not applicant dashboard)
3. ✅ See all applications in the table (not just your own)
4. ✅ See admin navigation items in the sidebar

If all of these work, your admin account is set up correctly!

