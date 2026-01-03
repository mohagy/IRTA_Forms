# Quick Firebase Setup Guide

Since Firebase login requires browser interaction, please follow these steps in your own terminal:

## Step 1: Login to Firebase

Open PowerShell and run:

```powershell
# Add npm to PATH (if needed)
$env:Path += ";$env:APPDATA\npm;C:\Users\Administrator\AppData\Local\Pub\Cache\bin"

# Login to Firebase (this will open your browser)
firebase login
```

This will:
- Open your default web browser
- Ask you to sign in with your Google account
- Grant Firebase CLI access
- Complete authentication

## Step 2: Configure FlutterFire

After successful login, run:

```powershell
cd C:\xampp2\htdocs\IRTA_Forms\irta_forms_app
flutterfire configure
```

This will:
- Show your Firebase projects (or let you create a new one)
- Configure Firebase for all platforms (Web, Android, iOS, Windows)
- Generate `lib/firebase_options.dart` automatically

## Step 3: Update main.dart

After `flutterfire configure` completes, the `firebase_options.dart` file will be generated. Update `lib/main.dart` to uncomment the Firebase initialization:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Uncomment this
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

## Step 4: Enable Firebase Services

After creating/selecting your Firebase project, enable these services in the [Firebase Console](https://console.firebase.google.com/):

1. **Authentication**
   - Go to: Authentication > Sign-in method
   - Enable: Email/Password
   - Click: Save

2. **Firestore Database**
   - Go to: Firestore Database
   - Click: Create database
   - Choose: Start in test mode
   - Select: Location (closest to your users)
   - Click: Enable

3. **Storage** (Optional, for document uploads)
   - Go to: Storage
   - Click: Get started
   - Start in: Test mode
   - Select: Location
   - Click: Done

## That's It!

Once these steps are complete, your Firebase integration will be fully functional and you can start using authentication in the app.

## Need Help?

If you encounter issues, check:
- You're logged in: `firebase projects:list` should show your projects
- `lib/firebase_options.dart` file exists after running `flutterfire configure`
- All Firebase services are enabled in the Firebase Console


