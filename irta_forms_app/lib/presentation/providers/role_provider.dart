import 'package:flutter/foundation.dart';
import '../../data/models/role_model.dart';
import '../../data/repositories/role_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/role_seeder.dart';

class RoleProvider with ChangeNotifier {
  final RoleRepository _roleRepository = RoleRepository();
  final UserRepository _userRepository = UserRepository();
  
  List<RoleModel> _roles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<RoleModel> get roles => _filteredRoles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<RoleModel> get _filteredRoles {
    if (_searchQuery.isEmpty) {
      return _roles;
    }
    final query = _searchQuery.toLowerCase();
    return _roles.where((role) {
      return role.name.toLowerCase().contains(query) ||
          role.description.toLowerCase().contains(query) ||
          role.permissions.any((p) => p.toLowerCase().contains(query));
    }).toList();
  }

  // Load all roles
  Future<void> loadRoles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _roleRepository.getAllRoles().listen((roles) async {
        // Update user counts for each role
        final updatedRoles = await Future.wait(
          roles.map((role) async {
            final userCount = await _getUserCountForRole(role.name);
            return role.copyWith(userCount: userCount);
          }),
        );
        
        _roles = updatedRoles;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to load roles: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user count for a role
  Future<int> _getUserCountForRole(String roleName) async {
    try {
      final users = await _userRepository.getAllUsers().first;
      return users.where((user) => user.role.toLowerCase() == roleName.toLowerCase()).length;
    } catch (e) {
      return 0;
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Create role
  Future<bool> createRole(RoleModel role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _roleRepository.createRole(role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create role: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update role
  Future<bool> updateRole(String roleId, RoleModel role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _roleRepository.updateRole(roleId, role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update role: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete role
  Future<bool> deleteRole(String roleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _roleRepository.deleteRole(roleId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete role: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update role permissions
  Future<bool> updateRolePermissions(String roleId, List<String> permissions) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _roleRepository.updateRolePermissions(roleId, permissions);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update permissions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if a role has a specific permission
  bool roleHasPermission(String roleName, String permission) {
    final role = _roles.firstWhere(
      (r) => r.name.toLowerCase() == roleName.toLowerCase(),
      orElse: () => RoleModel(
        id: '',
        name: roleName,
        permissions: [],
        createdAt: DateTime.now(),
      ),
    );
    return role.permissions.contains(permission);
  }

  // Seed default roles if none exist
  Future<bool> seedDefaultRoles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final seeder = RoleSeeder();
      await seeder.seedRoles();
      
      // Reload roles after seeding
      await loadRoles();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to seed roles: $e';
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

