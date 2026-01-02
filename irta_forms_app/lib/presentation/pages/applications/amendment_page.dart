import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/applications_table.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import 'package:go_router/go_router.dart';

class AmendmentPage extends StatelessWidget {
  const AmendmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Wait for auth state to be initialized before checking
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppConstants.routeLogin);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.user;
        final userName = user?.displayName ?? 'User';
        final userEmail = user?.email ?? '';
        final userRole = authProvider.userRole;

        return MainLayout(
          currentRoute: '/amendment',
          onNavigate: (route) {
            context.go(route);
          },
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
          onLogout: () async {
            await authProvider.signOut();
            if (context.mounted) {
              context.go(AppConstants.routeLanding);
            }
          },
          child: _buildContent(context),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        // Filter applications to only show Amendment type
        final allApplications = appProvider.applications;
        final amendmentApplications = allApplications.where((app) => 
          app.formType.toLowerCase().contains('amendment')
        ).toList();

        // Calculate stats dynamically
        final total = amendmentApplications.length;
        final pending = amendmentApplications.where((app) => 
          app.status == AppConstants.statusSubmitted || 
          app.status == AppConstants.statusReceptionReview
        ).length;
        final inProcess = amendmentApplications.where((app) => 
          app.status == AppConstants.statusVerification ||
          app.status == AppConstants.statusIssuingDecision
        ).length;
        final completed = amendmentApplications.where((app) => 
          app.status == AppConstants.statusCompleted
        ).length;

        return Column(
          children: [
            // Header
            AppHeader(
              title: 'Amendment / Update Requests',
              actions: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search applications...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Export to Excel functionality
                  },
                  child: const Text('Export to Excel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppConstants.routeNewApplication);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Amendment Request'),
                ),
              ],
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Amendments',
                      value: total.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Pending',
                      value: pending.toString(),
                      valueColor: AppColors.statusSubmitted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'In Process',
                      value: inProcess.toString(),
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Completed',
                      value: completed.toString(),
                      valueColor: AppColors.statusCompleted,
                    ),
                  ),
                ],
              ),
            ),

            // Applications Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ApplicationsTable(
                  applications: amendmentApplications,
                  onRowTap: (app) {
                    // Navigate to application detail
                    // context.push('/applications/${app.id}');
                  },
                  isApplicantView: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

