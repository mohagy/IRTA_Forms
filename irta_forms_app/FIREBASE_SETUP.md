# Firebase Setup Instructions

This guide will help you set up Firebase for the IRTA Forms Flutter application.

## Prerequisites

- Node.js and npm installed (✅ Already installed)
- Firebase CLI installed (✅ Already installed)
- FlutterFire CLI installed (✅ Already installed)
- A Google account for Firebase

## Setup Steps

### Option 1: Using the Setup Script (Recommended)

1. Open PowerShell in the `irta_forms_app` directory
2. Run the setup script:
   ```powershell
   .\setup_firebase.ps1
   ```
3. Follow the prompts:
   - The script will open a browser for Firebase login
   - After logging in, it will configure Firebase for your Flutter project

### Option 2: Manual Setup

#### Step 1: Login to Firebase

Open a terminal/PowerShell and run:

```powershell
# Add npm and pub cache to PATH (if not already added)
$env:Path += ";$env:APPDATA\npm;C:\Users\Administrator\AppData\Local\Pub\Cache\bin"

# Login to Firebase (this will open a browser)
firebase login
```

This will:
- Open your default browser
- Ask you to sign in with your Google account
- Request permission to access Firebase
- Complete the login process

#### Step 2: Create/Select Firebase Project

If you don't have a Firebase project yet:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Follow the wizard to create your project
4. Enable the following services:
   - **Authentication** (Email/Password)
   - **Firestore Database**
   - **Storage** (for document uploads)

#### Step 3: Configure FlutterFire

Navigate to your project directory and run:

```powershell
cd C:\xampp2\htdocs\IRTA_Forms\irta_forms_app
flutterfire configure
```

This command will:
- List your Firebase projects
- Let you select or create a project
- Configure Firebase for all platforms (Web, Android, iOS, Windows)
- Generate `lib/firebase_options.dart` file

#### Step 4: Enable Firebase Services

In the Firebase Console, enable:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"
   - Click "Save"

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Choose "Start in test mode" (we'll configure rules later)
   - Select a location closest to your users
   - Click "Enable"

3. **Storage** (Optional, for file uploads)
   - Go to Storage
   - Click "Get started"
   - Start in test mode
   - Select a location
   - Click "Done"

#### Step 5: Update main.dart

After `flutterfire configure` completes, update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Add this import
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uncomment these lines:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const IRTAFormsApp());
}
```

## Verify Setup

After completing the setup, you can verify it by:

1. Running the app:
   ```powershell
   flutter run
   ```

2. Check that `lib/firebase_options.dart` exists

3. The app should start without Firebase-related errors

## Troubleshooting

### Firebase CLI not found
- Make sure npm global packages are in your PATH
- Run: `$env:Path += ";$env:APPDATA\npm"`

### FlutterFire CLI not found
- Install it: `dart pub global activate flutterfire_cli`
- Add to PATH: `$env:Path += ";C:\Users\Administrator\AppData\Local\Pub\Cache\bin"`

### Authentication errors
- Make sure Email/Password is enabled in Firebase Console
- Check that Firestore is initialized

## Next Steps

After Firebase is configured:
1. The authentication system will be fully functional
2. You can start testing registration and login
3. User data will be stored in Firestore
4. Documents can be uploaded to Firebase Storage

## Support

If you encounter issues:
- Check Firebase Console for error messages
- Verify all services are enabled
- Ensure `firebase_options.dart` is generated correctly
- Check Flutter and Firebase package versions are compatible

