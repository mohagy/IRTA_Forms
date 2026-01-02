import 'package:flutter/material.dart';
import 'sidebar.dart';
import '../../core/theme/app_colors.dart';

class MainLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        Sidebar(
          currentRoute: currentRoute,
          onNavigate: onNavigate,
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
          onLogout: onLogout,
        ),
        Expanded(
          child: Material(
            color: AppColors.background,
            child: child,
          ),
        ),
      ],
    );
  }
}

