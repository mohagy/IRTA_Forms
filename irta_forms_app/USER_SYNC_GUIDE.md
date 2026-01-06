# User Sync Guide - Firebase Auth to Firestore

## Problem

Users created directly in Firebase Authentication (like `admin@irta.local`) won't appear in the User Management page because they don't have a corresponding document in the Firestore `users` collection.

## Solution

### Option 1: Manual Sync (Current Method)

When you create a user in Firebase Auth, you need to also create a document in Firestore:

1. **Create user in Firebase Auth:**
   - Go to Firebase Console > Authentication > Users
   - Click "Add user"
   - Enter email and password
   - Copy the User UID

2. **Create document in Firestore:**
   - Go to Firebase Console > Firestore Database
   - Create/select `users` collection
   - Create document with ID = User UID (from step 1)
   - Add fields:
     - `email` (string): user's email
     - `role` (string): user's role (e.g., "admin", "applicant")
     - `status` (string): "Active" or "Inactive"
     - `createdAt` (timestamp): current date/time
     - `fullName` (string, optional): user's full name
     - Other fields as needed

### Option 2: Use the App's User Management (Recommended)

When users register through the app, a Firestore document is automatically created. For admin users created in Firebase Console, you'll need to manually create the Firestore document as described in Option 1.

### Option 3: Future Enhancement

A "Sync Users" feature could be added to automatically create Firestore documents for users that exist in Firebase Auth but not in Firestore. This would require:
- Admin SDK access (server-side)
- Or a Cloud Function to sync users

## Current Status

- ✅ Users registered through the app automatically get Firestore documents
- ⚠️ Users created directly in Firebase Auth need manual Firestore document creation
- ✅ Password reset emails can be sent from the User Management page
- ✅ User roles can be edited and are integrated with Roles & Permissions



