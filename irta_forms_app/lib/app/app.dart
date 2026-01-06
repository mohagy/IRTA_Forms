import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/application_provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/role_provider.dart';
import '../presentation/providers/system_log_provider.dart';
import 'routes.dart';

class IRTAFormsApp extends StatelessWidget {
  const IRTAFormsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => SystemLogProvider()),
      ],
      child: MaterialApp.router(
        title: 'IRTA Forms',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.getRouter(),
      ),
    );
  }
}

