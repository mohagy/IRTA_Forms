# Create Firestore Document for admin@irta.local

## Quick Method

Since we cannot programmatically list Firebase Auth users from the client SDK, follow these steps:

### Step 1: Get the User UID

1. Go to: https://console.firebase.google.com/
2. Select project: **irta-forms-app**
3. Navigate to: **Authentication** > **Users**
4. Find user: **admin@irta.local**
5. Click on the user to see details
6. **Copy the User UID** (long string of characters)

### Step 2: Create Document via Script (Option A)

Once you have the UID, run:

```bash
cd irta_forms_app
dart run scripts/create_user_document.dart admin@irta.local admin <USER_UID>
```

Replace `<USER_UID>` with the actual UID you copied.

### Step 3: Create Document Manually (Option B - Easier)

1. In Firebase Console, go to: **Firestore Database**
2. Click on **users** collection (or create it if it doesn't exist)
3. Click **Add document**
4. **Document ID**: Paste the User UID you copied
5. Add fields:
   - `email` (string): `admin@irta.local`
   - `role` (string): `admin`
   - `status` (string): `Active`
   - `createdAt` (timestamp): Click the timestamp icon and select "Set to server timestamp"
6. Click **Save**

### Step 4: Verify

1. Go back to your app
2. Navigate to **User Management** page
3. You should now see `admin@irta.local` in the list!

## What This Does

This creates a document in Firestore that:
- Links to the Firebase Auth user (via UID as document ID)
- Stores the user's role (`admin`)
- Stores the user's status (`Active`)
- Stores metadata like email and creation timestamp

The User Management page reads from this Firestore collection, so users need both:
1. ✅ Firebase Auth account (for login)
2. ✅ Firestore document (for User Management page)

