import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userRepository = UserRepository();
  User? _user;
  String _userRole = AppConstants.roleApplicant;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Initialize with current user immediately (synchronous)
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserRole(_user!.uid);
    }
    _isInitialized = true;
    notifyListeners();

    // Listen to auth state changes for future updates
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        _userRole = AppConstants.roleApplicant;
        notifyListeners();
      }
    });
  }

  // Load user role from Firestore
  Future<void> _loadUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        _userRole = userDoc.data()!['role'] as String? ?? AppConstants.roleApplicant;
      } else {
        // Default to applicant if no role document exists
        _userRole = AppConstants.roleApplicant;
      }
      notifyListeners();
    } catch (e) {
      // On error, default to applicant
      _userRole = AppConstants.roleApplicant;
      notifyListeners();
    }
  }

  Future<bool> signUp({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        nationality: nationality,
        dateOfBirth: dateOfBirth,
        idType: idType,
        idNumber: idNumber,
        address: address,
      );

      // Create user document in Firestore
      if (userCredential?.user != null) {
        final user = UserModel(
          id: userCredential!.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          nationality: nationality,
          dateOfBirth: dateOfBirth,
          idType: idType,
          idNumber: idNumber,
          address: address,
          role: AppConstants.roleApplicant, // Default role
          status: 'Active',
          createdAt: DateTime.now(),
        );

        await _userRepository.createUserWithId(userCredential.user!.uid, user);
        
        // Load user role after creating document
        await _loadUserRole(userCredential.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Load user role after successful login
      if (userCredential?.user != null) {
        await _loadUserRole(userCredential!.user!.uid);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential == null || userCredential.user == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = userCredential.user!;
      
      // Check if user document exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create user document with applicant role (first time Google sign-in)
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? '',
          phoneNumber: user.phoneNumber ?? '',
          role: AppConstants.roleApplicant, // Always applicant for Google sign-in
          status: 'Active',
          createdAt: DateTime.now(),
        );

        await _userRepository.createUserWithId(user.uid, userModel);
      } else {
        // User exists, ensure role is applicant (Google sign-in is only for applicants)
        final currentRole = userDoc.data()?['role'] as String?;
        if (currentRole != AppConstants.roleApplicant) {
          // Update role to applicant if it's not already
          await _firestore.collection('users').doc(user.uid).update({
            'role': AppConstants.roleApplicant,
          });
        }
      }
      
      // Load user role after creating/updating document
      await _loadUserRole(user.uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userRole = AppConstants.roleApplicant;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

