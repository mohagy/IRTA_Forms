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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
          // Redirect to login if not authenticated
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

        // Determine if this is applicant dashboard or admin dashboard
        final isApplicant = userRole == AppConstants.roleApplicant;

        return MainLayout(
          currentRoute: AppConstants.routeDashboard,
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
          child: isApplicant 
              ? _buildApplicantDashboard(context, authProvider) 
              : _buildAdminDashboard(context, authProvider),
        );
      },
    );
  }

  Widget _buildAdminDashboard(BuildContext context, AuthProvider authProvider) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        // Load applications on first build
        final user = authProvider.user;
        if (user != null && appProvider.applications.isEmpty && !appProvider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appProvider.loadAllApplications();
          });
        }

        final applications = appProvider.applications;

        // Calculate stats dynamically
        final totalApplications = applications.length;
        final pendingReview = applications.where((app) => 
          app.status == AppConstants.statusSubmitted || 
          app.status == AppConstants.statusReceptionReview
        ).length;
        final inVerification = applications.where((app) => 
          app.status == AppConstants.statusVerification
        ).length;
        final now = DateTime.now();
        final completedThisMonth = applications.where((app) => 
          app.status == AppConstants.statusCompleted &&
          app.submissionDate.year == now.year &&
          app.submissionDate.month == now.month
        ).length;

        return Column(
          children: [
            // Header
            AppHeader(
              title: 'IRTA Applications Dashboard',
              actions: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by reference, name, or ID...',
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
                ElevatedButton(
                  onPressed: () {
                    // Generate Report functionality
                  },
                  child: const Text('Generate Report'),
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
                      label: 'Total Applications',
                      value: totalApplications.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Pending Review',
                      value: pendingReview.toString(),
                      valueColor: AppColors.statusSubmitted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'In Verification',
                      value: inVerification.toString(),
                      valueColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Completed This Month',
                      value: completedThisMonth.toString(),
                      valueColor: AppColors.statusCompleted,
                    ),
                  ),
                ],
              ),
            ),

            // Error Message
            if (appProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appProvider.errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.error),
                      onPressed: () => appProvider.loadAllApplications(),
                    ),
                  ],
                ),
              ),

            // Applications Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: appProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ApplicationsTable(
                        applications: applications,
                        onRowTap: (app) {
                          // Navigate to application detail
                          context.push('/applications/${app.id}');
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

  Widget _buildApplicantDashboard(BuildContext context, AuthProvider authProvider) {
    return _ApplicantDashboardWidget(authProvider: authProvider);
  }
}

// Separate StatefulWidget to handle one-time initialization
class _ApplicantDashboardWidget extends StatefulWidget {
  final AuthProvider authProvider;

  const _ApplicantDashboardWidget({required this.authProvider});

  @override
  State<_ApplicantDashboardWidget> createState() => _ApplicantDashboardWidgetState();
}

class _ApplicantDashboardWidgetState extends State<_ApplicantDashboardWidget> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      final user = widget.authProvider.user;
      if (user != null) {
        final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
        appProvider.loadUserApplications(user.uid);
        _hasInitialized = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Reload applications when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = widget.authProvider.user;
      if (user != null && mounted) {
        final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
        // Force reload by canceling and restarting the stream
        appProvider.loadUserApplications(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        final applications = appProvider.applications;

        // Calculate stats dynamically
        final myApplications = applications.length;
        final draftCount = applications.where((app) => 
          app.status == AppConstants.statusDraft
        ).length;
        final submittedCount = applications.where((app) => 
          app.status == AppConstants.statusSubmitted
        ).length;
        final completedCount = applications.where((app) => 
          app.status == AppConstants.statusCompleted
        ).length;

        return Column(
          children: [
            // Header
            Builder(
              builder: (context) {
                // Enable "New Application" button if:
                // 1. No applications exist, OR
                // 2. All applications are rejected (applicant can reapply)
                final canCreateNew = applications.isEmpty || 
                    applications.every((app) => app.status == AppConstants.statusRejected || app.status == AppConstants.statusDraft);
                
                return AppHeader(
                  title: 'My IRTA Applications',
                  actions: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search my applications...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (canCreateNew)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to new application
                          context.push(AppConstants.routeNewApplication);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Application'),
                      )
                    else
                      Tooltip(
                        message: 'You have an active application. Please manage your existing application first.',
                        child: ElevatedButton.icon(
                          onPressed: null, // Disabled
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Application'),
                        ),
                      ),
                  ],
                );
              },
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'My Applications',
                      value: myApplications.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Draft',
                      value: draftCount.toString(),
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Submitted',
                      value: submittedCount.toString(),
                      valueColor: AppColors.statusSubmitted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Completed',
                      value: completedCount.toString(),
                      valueColor: AppColors.statusCompleted,
                    ),
                  ),
                ],
              ),
            ),

            // Error Message
            if (appProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appProvider.errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.error),
                      onPressed: () {
                        final user = widget.authProvider.user;
                        if (user != null) {
                          appProvider.loadUserApplications(user.uid);
                        }
                      },
                    ),
                  ],
                ),
              ),

            // Applications Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: appProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ApplicationsTable(
                        applications: applications,
                        onRowTap: (app) {
                          // Navigate to application detail
                          context.push('/applications/${app.id}');
                        },
                        isApplicantView: true,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
