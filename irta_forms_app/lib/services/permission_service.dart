import '../data/models/role_model.dart';
import '../data/repositories/role_repository.dart';

/// Service to check user permissions based on their role
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  final RoleRepository _roleRepository = RoleRepository();
  
  // Cache for roles to avoid repeated Firestore queries
  Map<String, RoleModel?> _roleCache = {};
  bool _isLoadingRoles = false;

  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Get role by name from Firestore (with caching)
  Future<RoleModel?> _getRoleByName(String roleName) async {
    // Check cache first
    if (_roleCache.containsKey(roleName.toLowerCase())) {
      return _roleCache[roleName.toLowerCase()];
    }

    if (_isLoadingRoles) {
      // If already loading, wait a bit
      await Future.delayed(const Duration(milliseconds: 100));
      return _roleCache[roleName.toLowerCase()];
    }

    try {
      _isLoadingRoles = true;
      final role = await _roleRepository.getRoleByName(roleName);
      _roleCache[roleName.toLowerCase()] = role;
      return role;
    } catch (e) {
      return null;
    } finally {
      _isLoadingRoles = false;
    }
  }

  /// Check if a role has a specific permission
  Future<bool> hasPermission(String roleName, String permission) async {
    if (roleName.isEmpty) return false;
    
    final role = await _getRoleByName(roleName);
    if (role == null) {
      // If role not found, deny access (fail secure)
      return false;
    }
    
    return role.permissions.contains(permission);
  }

  /// Check if a role has any of the specified permissions
  Future<bool> hasAnyPermission(String roleName, List<String> permissions) async {
    for (final permission in permissions) {
      if (await hasPermission(roleName, permission)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a role has all of the specified permissions
  Future<bool> hasAllPermissions(String roleName, List<String> permissions) async {
    for (final permission in permissions) {
      if (!await hasPermission(roleName, permission)) {
        return false;
      }
    }
    return true;
  }

  /// Clear the role cache (useful when roles are updated)
  void clearCache() {
    _roleCache.clear();
  }

  /// Map route to required permission(s)
  static List<String> getPermissionsForRoute(String route) {
    switch (route) {
      case '/users':
        return [PermissionConstants.manageUsers];
      case '/roles':
        return [PermissionConstants.manageRoles];
      case '/form-config':
        return [PermissionConstants.configureForms];
      case '/reports':
        return [PermissionConstants.viewReports];
      case '/database':
        return [PermissionConstants.databaseAccess];
      case '/system-config':
        return [PermissionConstants.systemConfiguration];
      case '/logs':
        return [PermissionConstants.viewAllLogs];
      case '/individual-irta':
      case '/renewal':
      case '/amendment':
      case '/cancellation':
        return [PermissionConstants.viewAllForms, PermissionConstants.viewAssignedForms];
      case '/vehicle-approval':
        return [PermissionConstants.verify, PermissionConstants.approve];
      default:
        return [];
    }
  }

  /// Map navigation item to required permission
  static String? getPermissionForNavItem(String route) {
    final permissions = getPermissionsForRoute(route);
    return permissions.isNotEmpty ? permissions.first : null;
  }
}

