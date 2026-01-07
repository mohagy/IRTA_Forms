import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart';
import '../../core/theme/app_colors.dart';
import '../providers/role_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final Function(String) onNavigate;
  final String userRole;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.onNavigate,
    required this.userRole,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    // Ensure roles are loaded when layout initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roleProvider = context.read<RoleProvider>();
      if (roleProvider.roles.isEmpty) {
        roleProvider.loadRoles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Sidebar(
          currentRoute: widget.currentRoute,
          onNavigate: widget.onNavigate,
          userRole: widget.userRole,
          userName: widget.userName,
          userEmail: widget.userEmail,
          onLogout: widget.onLogout,
        ),
        Expanded(
          child: Material(
            color: AppColors.background,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

