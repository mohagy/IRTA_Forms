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

class IndividualIRTAPage extends StatefulWidget {
  const IndividualIRTAPage({super.key});

  @override
  State<IndividualIRTAPage> createState() => _IndividualIRTAPageState();
}

class _IndividualIRTAPageState extends State<IndividualIRTAPage> {
  @override
  void initState() {
    super.initState();
    // Load applications when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadAllApplications();
    });
  }

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
          currentRoute: '/individual-irta',
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
        // Filter applications to show both Individual and Business IRTA
        final allApplications = appProvider.applications;
        final individualIRTAApplications = allApplications.where((app) => 
          app.formType == AppConstants.appTypeIndividual || 
          app.formType == AppConstants.appTypeBusiness
        ).toList();

        // Calculate stats dynamically
        final total = individualIRTAApplications.length;
        final pending = individualIRTAApplications.where((app) => 
          app.status == AppConstants.statusSubmitted || 
          app.status == AppConstants.statusReceptionReview
        ).length;
        final inProcess = individualIRTAApplications.where((app) => 
          app.status == AppConstants.statusVerification ||
          app.status == AppConstants.statusIssuingDecision
        ).length;
        final completed = individualIRTAApplications.where((app) => 
          app.status == AppConstants.statusCompleted
        ).length;

        return Column(
          children: [
            // Header
            AppHeader(
              title: 'Individual IRTA Applications',
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
                  label: const Text('New Individual IRTA'),
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
                      label: 'Total Individual IRTA',
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
                  applications: individualIRTAApplications,
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
}

