import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<UserModel> get users => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      return (user.email.toLowerCase().contains(query) ||
          (user.fullName?.toLowerCase().contains(query) ?? false) ||
          (user.department?.toLowerCase().contains(query) ?? false) ||
          user.role.toLowerCase().contains(query));
    }).toList();
  }

  // Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userRepository.getAllUsers().listen((users) {
        _users = users;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Create user (auto-generate ID)
  Future<bool> createUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.createUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create user with specific ID (for Firebase Auth UID)
  Future<bool> createUserWithId(String userId, UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.createUserWithId(userId, user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(String userId, UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUser(userId, user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.deleteUser(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUserRole(userId, role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user role: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user status
  Future<bool> updateUserStatus(String userId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUserStatus(userId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

