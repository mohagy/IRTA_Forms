# Admin Credentials Setup

## ✅ Role System Updated

The AuthProvider now fetches user roles from Firestore! Follow these steps to create an admin account.

## Step-by-Step Setup

### Step 1: Create User in Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select your project: **irta-forms-app**
3. Navigate to: **Authentication** > **Users**
4. Click: **Add user**
5. Enter:
   - **Email**: `admin@irta.local` (or your preferred email)
   - **Password**: `Admin123!` (create a strong password)
6. Click: **Add user**
7. **IMPORTANT**: Copy the **User UID** (you'll need this in the next step)

### Step 2: Set Admin Role in Firestore

1. In Firebase Console, go to: **Firestore Database**
2. Click **Start collection** (if no collections exist yet)
3. **Collection ID**: `users`
4. **Document ID**: Paste the User UID you copied from Step 1
5. Add a field:
   - **Field name**: `role`
   - **Field type**: `string`
   - **Field value**: `admin`
6. Click **Save**

### Step 3: Test Admin Login

**Email**: `admin@irta.local`  
**Password**: `Admin123!` (or whatever password you created)

After logging in, the app will:
- Fetch your role from Firestore
- Show the admin dashboard (all applications view)
- Display admin navigation items in the sidebar

## Available Roles

You can set any of these roles in Firestore:
- `applicant` - Regular users (default)
- `admin` - Full system access
- `officer` - Processing applications
- `reception` - Reception review staff
- `verification` - Verification officers
- `issuing` - Issuing officers

## Testing Different Roles

To test different role views:
1. Create users with different emails
2. Set their `role` field in Firestore `users` collection
3. Login with each user to see different dashboards

## Security Notes

⚠️ **Important:**
- Use strong passwords for admin accounts
- Never commit credentials to version control
- Consider using Firebase Security Rules to protect the `users` collection
- For production, implement proper access control

## Troubleshooting

**If admin view doesn't show:**
1. Check that the `users` collection exists in Firestore
2. Verify the document ID matches the User UID exactly
3. Ensure the `role` field is set to `admin` (lowercase)
4. Try logging out and logging back in
5. Check browser console for any errors

**If you see applicant view instead:**
- The role document might not exist or the UID doesn't match
- Check Firestore to verify the role was saved correctly
- Default behavior is `applicant` if role can't be found


