import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/permission_service.dart';
import '../../data/models/role_model.dart';
import '../providers/role_provider.dart';

class Sidebar extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final String userRole;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.userRole,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        final navItems = _getNavItemsForRole(context, widget.userRole, roleProvider);
        final initials = _getInitials(widget.userName);

    return Container(
      width: AppConstants.sidebarWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.sidebarStart,
            AppColors.sidebarEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.sidebarBorder,
                  width: 1,
                ),
              ),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

            // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: navItems.map((item) => _NavItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                route: item['route'] as String,
                isActive: widget.currentRoute == item['route'],
                onTap: () => widget.onNavigate(item['route'] as String),
              )).toList(),
            ),
          ),

          // Sidebar Footer (User Info & Logout)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.sidebarBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // User Info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.avatarBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              color: AppColors.sidebarText,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getRoleDisplayName(widget.userRole),
                            style: const TextStyle(
                              color: AppColors.sidebarText,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onLogout,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.sidebarHover,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.sidebarText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  List<Map<String, dynamic>> _getAllNavItems() {
    return [
      {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': AppConstants.routeDashboard},
      {'icon': Icons.description, 'label': 'Individual IRTA', 'route': '/individual-irta'},
      {'icon': Icons.refresh, 'label': 'Renewal', 'route': '/renewal'},
      {'icon': Icons.edit, 'label': 'Amendment', 'route': '/amendment'},
      {'icon': Icons.cancel, 'label': 'Cancellation', 'route': '/cancellation'},
      {'icon': Icons.people, 'label': 'User Management', 'route': '/users'},
      {'icon': Icons.security, 'label': 'Roles & Permissions', 'route': '/roles'},
      {'icon': Icons.settings_applications, 'label': 'Form Config', 'route': '/form-config'},
      {'icon': Icons.assessment, 'label': 'Reports', 'route': '/reports'},
      {'icon': Icons.directions_car, 'label': 'Vehicle Approval', 'route': '/vehicle-approval'},
      {'icon': Icons.storage, 'label': 'Database Access', 'route': '/database'},
      {'icon': Icons.settings, 'label': 'System Configuration', 'route': '/system-config'},
      {'icon': Icons.history, 'label': 'View All Logs', 'route': '/logs'},
    ];
  }

  List<Map<String, dynamic>> _getNavItemsForRole(BuildContext context, String role, RoleProvider roleProvider) {
    // Applicants always see limited navigation
    if (role == AppConstants.roleApplicant) {
      return [
        {'icon': Icons.dashboard, 'label': 'My Applications', 'route': AppConstants.routeDashboard},
        {'icon': Icons.add, 'label': 'New Application', 'route': AppConstants.routeNewApplication},
      ];
    }

    // Find the user's role in the roles list
    final userRoleModel = roleProvider.roles.firstWhere(
      (r) => r.name.toLowerCase() == role.toLowerCase(),
      orElse: () => RoleModel(
        id: '',
        name: role,
        permissions: [],
        createdAt: DateTime.now(),
      ),
    );

    // For other roles, check permissions for each navigation item
    final allItems = _getAllNavItems();
    final filteredItems = <Map<String, dynamic>>[];

    for (final item in allItems) {
      final route = item['route'] as String;
      final permissions = PermissionService.getPermissionsForRoute(route);

      // If no permissions required, always show
      if (permissions.isEmpty) {
        filteredItems.add(item);
        continue;
      }

      // Check if user has any of the required permissions
      bool hasAccess = false;
      for (final permission in permissions) {
        if (userRoleModel.permissions.contains(permission)) {
          hasAccess = true;
          break;
        }
      }

      if (hasAccess) {
        filteredItems.add(item);
      }
    }

    // Always show Dashboard for authenticated users
    if (!filteredItems.any((item) => item['route'] == AppConstants.routeDashboard)) {
      filteredItems.insert(0, {
        'icon': Icons.dashboard,
        'label': 'Dashboard',
        'route': AppConstants.routeDashboard,
      });
    }

    return filteredItems;
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleApplicant:
        return 'Applicant';
      case AppConstants.roleOfficer:
        return 'Issuing Officer';
      case AppConstants.roleAdmin:
        return 'Administrator';
      case AppConstants.roleReception:
        return 'Reception Staff';
      case AppConstants.roleVerification:
        return 'Verification Officer';
      case AppConstants.roleIssuing:
        return 'Issuing Officer';
      default:
        return 'User';
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.sidebarActive : Colors.transparent,
            border: isActive
                ? const Border(
                    left: BorderSide(color: AppColors.activeBorder, width: 4),
                  )
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.sidebarText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.sidebarText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

