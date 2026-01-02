# Seed Roles & Permissions Data

This guide explains how to populate Firestore with default roles and permissions data.

## ⚡ Quick Method (Recommended)

**The easiest way is to use the button in the app:**

1. Run your app: `flutter run -d chrome`
2. Login as an admin user
3. Navigate to **Roles & Permissions** page
4. If no roles exist, you'll see a "Load Default Roles" button
5. Click the button to automatically create all default roles

That's it! All 6 default roles with their permissions will be created.

## Default Roles

The system includes the following default roles:

1. **IRTA Admin** - Full administrative access
2. **Issuing Officer** - Approve applications and issue IRTA documents
3. **Verification Officer** - Verify documents and request additional info
4. **Reception Staff** - Initial review and assignment of applications
5. **Applicant** - Standard user role for submitting applications
6. **IT Admin** - System administration and technical support

## Method 1: Using Dart Script (Recommended)

1. Make sure Firebase is initialized in your project
2. Run the seed script:

```bash
cd irta_forms_app
dart run scripts/seed_roles.dart
```

The script will:
- Check if roles already exist (skip if they do)
- Create all default roles with their permissions
- Print success message when complete

## Method 2: Manual Setup via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **irta-forms-app**
3. Navigate to **Firestore Database**
4. Create a collection named `roles`

### Add IRTA Admin Role

Create a document with the following fields:

- **name** (string): `IRTA Admin`
- **description** (string): `Full administrative access to all system features`
- **permissions** (array): 
  ```
  View All Forms
  Create Forms
  Edit Forms
  Delete Forms
  View Assigned Forms
  Verify
  Approve
  Reject
  Reassign
  Request Additional Info
  Review
  Assign to Officers
  Manage Users
  Manage Roles
  Configure Forms
  View Reports
  System Configuration
  Database Access
  View All Logs
  ```
- **userCount** (number): `0`
- **createdAt** (timestamp): Current date/time

### Add Issuing Officer Role

- **name** (string): `Issuing Officer`
- **description** (string): `Can approve applications and issue IRTA documents`
- **permissions** (array):
  ```
  View Assigned Forms
  Edit Forms
  Approve
  Reject
  Reassign
  View Reports
  ```
- **userCount** (number): `0`
- **createdAt** (timestamp): Current date/time

### Add Verification Officer Role

- **name** (string): `Verification Officer`
- **description** (string): `Verifies documents and requests additional information`
- **permissions** (array):
  ```
  View Assigned Forms
  Verify
  Request Additional Info
  View Reports
  ```
- **userCount** (number): `0`
- **createdAt** (timestamp): Current date/time

### Add Reception Staff Role

- **name** (string): `Reception Staff`
- **description** (string): `Initial review and assignment of applications`
- **permissions** (array):
  ```
  View All Forms
  Review
  Assign to Officers
  View Reports
  ```
- **userCount** (number): `0`
- **createdAt** (timestamp): Current date/time

### Add Applicant Role

- **name** (string): `Applicant`
- **description** (string): `Standard user role for submitting IRTA applications`
- **permissions** (array):
  ```
  Create Forms
  View Own Forms
  Edit Draft Forms
  ```
- **userCount** (number): `0`
- **createdAt** (timestamp): Current date/time

### Add IT Admin Role

- **name** (string): `IT Admin`
- **description** (string): `System administration and technical support`
- **permissions** (array):
  ```
  View All Forms
  System Configuration
  Database Access
  View All Logs
  Manage Users
  View Reports
  ```
- **userCount** (number): `0`
- **createdAt** (timestamp): Current date/time

## Method 3: Programmatic Initialization

You can also initialize roles programmatically from your app. Add this code to your app initialization (e.g., in `main.dart` or a setup function):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:irta_forms_app/data/repositories/role_seeder.dart';

Future<void> initializeApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Seed roles if they don't exist
  final seeder = RoleSeeder();
  await seeder.seedRoles();
}
```

## Available Permissions

### Forms Permissions
- View All Forms
- View Assigned Forms
- Create Forms
- Edit Forms
- Delete Forms
- View Own Forms
- Edit Draft Forms
- Edit Submitted Forms

### Workflow Permissions
- Verify
- Approve
- Reject
- Reassign
- Request Additional Info
- Review
- Assign to Officers

### System Permissions
- Manage Users
- Manage Roles
- Configure Forms
- View Reports
- System Configuration
- Database Access
- View All Logs

## Notes

- The script checks if roles already exist and won't duplicate them
- User counts are automatically calculated from the users collection
- You can modify permissions for any role after creation
- Roles can be edited or deleted from the Roles & Permissions page in the app

## Troubleshooting

If you encounter errors:

1. **Firebase not initialized**: Make sure Firebase is properly configured
2. **Permission errors**: Check Firestore security rules allow write access
3. **Script not found**: Make sure you're running from the correct directory
4. **Roles already exist**: Use `forceSeedRoles()` method if you need to re-seed (this will delete existing roles first)

