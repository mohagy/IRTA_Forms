import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

/// Script to create a Firestore user document for a Firebase Auth user
/// Usage: dart run scripts/create_user_document.dart <email> <role>
/// Example: dart run scripts/create_user_document.dart admin@irta.local admin
void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run scripts/create_user_document.dart <email> <role>');
    print('Example: dart run scripts/create_user_document.dart admin@irta.local admin');
    exit(1);
  }

  final email = args[0];
  final role = args[1];

  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Looking up user by email: $email');
    print('');
    print('⚠️  Note: This script requires the User UID from Firebase Authentication.');
    print('    Since we cannot list users from the client SDK, please:');
    print('');
    print('    1. Go to Firebase Console: https://console.firebase.google.com/');
    print('    2. Select your project: irta-forms-app');
    print('    3. Go to: Authentication > Users');
    print('    4. Find user: $email');
    print('    5. Copy the User UID');
    print('    6. Run this script with the UID:');
    print('       dart run scripts/create_user_document.dart $email $role <USER_UID>');
    print('');
    print('Alternatively, you can manually create the document in Firebase Console:');
    print('  - Collection: users');
    print('  - Document ID: <USER_UID>');
    print('  - Fields:');
    print('    - email (string): $email');
    print('    - role (string): $role');
    print('    - status (string): Active');
    print('    - createdAt (timestamp): <current time>');
    print('');
    
    // If UID is provided as third argument
    if (args.length >= 3) {
      final uid = args[2];
      print('Creating Firestore document for UID: $uid');
      
      final firestore = FirebaseFirestore.instance;
      final userDoc = {
        'email': email,
        'role': role,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await firestore.collection('users').doc(uid).set(userDoc);
      
      print('✅ Successfully created user document!');
      print('   Document ID: $uid');
      print('   Email: $email');
      print('   Role: $role');
      print('   Status: Active');
      exit(0);
    } else {
      exit(0);
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    if (args.length >= 3) {
      print('Stack trace: $stackTrace');
    }
    exit(1);
  }
}



