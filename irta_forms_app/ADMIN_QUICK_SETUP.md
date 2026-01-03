# Quick Admin Setup Guide

## Current Status
⚠️ **Note**: The role system currently defaults all users to "applicant". To test admin functionality, you'll need to create a user first.

## Quick Setup Steps

### 1. Create Admin User in Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **irta-forms-app**
3. Navigate to: **Authentication** > **Users**
4. Click: **Add user**
5. Enter:
   - **Email**: `admin@irta.local`
   - **Password**: `Admin123!` (or your secure password)
6. Click **Add user**
7. **Copy the User UID** (you'll need this)

### 2. Set Role in Firestore

1. In Firebase Console, go to: **Firestore Database**
2. Click **Start collection** (if no collections exist)
3. Collection ID: `users`
4. Document ID: Paste the User UID you copied
5. Add field:
   - Field: `role`
   - Type: `string`
   - Value: `admin`
6. Click **Save**

### 3. Test Admin Login

**Email**: `admin@irta.local`  
**Password**: `Admin123!` (or whatever you set)

## Important Notes

⚠️ The AuthProvider currently has a TODO to fetch roles from Firestore. Currently, it defaults to "applicant" for all users.

To fully enable admin functionality, the AuthProvider needs to be updated to:
1. Fetch user role from Firestore `users` collection
2. Use the user's UID as the document ID
3. Read the `role` field

This is marked as TODO in `lib/presentation/providers/auth_provider.dart` line 23.

## For Testing Right Now

Since roles aren't fully implemented, all users will see the applicant view. The admin dashboard logic exists in the code but won't activate until the role is properly fetched from Firestore.


