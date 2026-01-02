import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/data/repositories/role_seeder.dart';

/// Script to seed Firestore with default roles
/// Run this with: dart run scripts/seed_roles.dart
void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Initializing Firebase...');
    print('Seeding default roles...');

    final seeder = RoleSeeder();
    await seeder.seedRoles();

    print('✅ Roles seeded successfully!');
    
    // Exit
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

