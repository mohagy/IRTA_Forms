import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Initialize GoogleSignIn with clientId for web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For web, the clientId should be set in index.html meta tag
    // But we can also set it here as a fallback
    // Include 'openid' scope to ensure idToken is returned
    scopes: ['email', 'profile', 'openid'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nationality,
    required DateTime dateOfBirth,
    required String idType,
    required String idNumber,
    required String address,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Change password (user must be signed in)
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        throw Exception('Failed to get authentication from Google account: $e');
      }

      // Check if we have the access token (required)
      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get access token from Google. '
            'This may be due to OAuth configuration issues or browser security policies. '
            'Please check: 1) OAuth redirect URIs in Google Cloud Console, 2) People API is enabled, 3) Browser allows popups.');
      }

      // Note: idToken may be null on web due to deprecated signIn() method
      // Firebase Auth's GoogleAuthProvider.credential can work with just accessToken
      // Create a new credential (idToken is optional for GoogleAuthProvider)
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken, // May be null on web, but Firebase can handle it
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Provide more context in the error message
      final errorMessage = e.toString();
      if (errorMessage.contains('Failed to get authentication tokens')) {
        throw Exception('Google Sign-In failed: Authentication tokens were not returned. '
            'This is often caused by:\n'
            '1. OAuth redirect URIs not properly configured\n'
            '2. People API not enabled\n'
            '3. Browser blocking popup communication (COOP policy)\n'
            '4. OAuth consent screen not fully configured\n\n'
            'Please check the troubleshooting guide for detailed steps.');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

