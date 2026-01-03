# Add Firestore Document for admin@irta.local

## Quick Steps

You have the UID: `PxzaszZ6S9gUh9YiUhhWTWuSYDk2`

### Step 1: Open Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select project: **irta-forms-app**

### Step 2: Go to Firestore Database

1. Click **Firestore Database** in the left sidebar
2. Click on the **users** collection (or create it if it doesn't exist)

### Step 3: Add Document

1. Click **Add document** (or the "+" button)
2. **Document ID**: Enter: `PxzaszZ6S9gUh9YiUhhWTWuSYDk2`
3. Click **Next**

### Step 4: Add Fields

Add the following fields one by one:

**Field 1:**
- Field name: `email`
- Type: **string**
- Value: `admin@irta.local`
- Click **Done**

**Field 2:**
- Field name: `role`
- Type: **string**
- Value: `admin`
- Click **Done**

**Field 3:**
- Field name: `status`
- Type: **string**
- Value: `Active`
- Click **Done**

**Field 4:**
- Field name: `createdAt`
- Type: **timestamp**
- Click the timestamp icon and select **Set to server timestamp**
- Click **Done**

### Step 5: Save

Click **Save** button

### Step 6: Verify

1. Go back to your Flutter app
2. Navigate to **User Management** page
3. You should now see `admin@irta.local` in the list! ✅

## Summary

The document will have:
- **Document ID**: `PxzaszZ6S9gUh9YiUhhWTWuSYDk2`
- **email**: `admin@irta.local`
- **role**: `admin`
- **status**: `Active`
- **createdAt**: (server timestamp)

This links the Firebase Auth user to the Firestore users collection, making them visible in the User Management page.


