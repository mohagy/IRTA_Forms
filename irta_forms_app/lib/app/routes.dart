import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../presentation/pages/landing/landing_page.dart';
import '../../presentation/pages/registration/registration_page.dart';
import '../../presentation/pages/login/login_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/applications/new_application_page.dart';
import '../../presentation/pages/applications/individual_irta_page.dart';
import '../../presentation/pages/applications/renewal_page.dart';
import '../../presentation/pages/applications/amendment_page.dart';
import '../../presentation/pages/applications/cancellation_page.dart';
import '../../presentation/pages/admin/form_config_page.dart';
import '../../presentation/pages/admin/user_management_page.dart';
import '../../presentation/pages/admin/roles_permissions_page.dart';
import '../../presentation/pages/admin/vehicle_approval_page.dart';
import '../../presentation/pages/admin/system_config_page.dart';
import '../../presentation/pages/admin/database_access_page.dart';
import '../../presentation/pages/admin/system_logs_page.dart';
import '../../presentation/pages/applications/application_detail_page.dart';

class AppRoutes {
  static GoRouter getRouter() {
    return GoRouter(
      initialLocation: AppConstants.routeLanding,
      routes: [
        GoRoute(
          path: AppConstants.routeLanding,
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: AppConstants.routeRegistration,
          builder: (context, state) => const RegistrationPage(),
        ),
        GoRoute(
          path: AppConstants.routeLogin,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppConstants.routeDashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppConstants.routeNewApplication,
          builder: (context, state) => const NewApplicationPage(),
        ),
        GoRoute(
          path: '/applications/:id',
          builder: (context, state) {
            final applicationId = state.pathParameters['id']!;
            return ApplicationDetailPage(applicationId: applicationId);
          },
        ),
        GoRoute(
          path: '/individual-irta',
          builder: (context, state) => const IndividualIRTAPage(),
        ),
        GoRoute(
          path: '/renewal',
          builder: (context, state) => const RenewalPage(),
        ),
        GoRoute(
          path: '/amendment',
          builder: (context, state) => const AmendmentPage(),
        ),
        GoRoute(
          path: '/cancellation',
          builder: (context, state) => const CancellationPage(),
        ),
        GoRoute(
          path: '/form-config',
          builder: (context, state) => const FormConfigPage(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UserManagementPage(),
        ),
        GoRoute(
          path: '/roles',
          builder: (context, state) => const RolesPermissionsPage(),
        ),
        GoRoute(
          path: '/vehicle-approval',
          builder: (context, state) => const VehicleApprovalPage(),
        ),
        GoRoute(
          path: '/system-config',
          builder: (context, state) => const SystemConfigPage(),
        ),
        GoRoute(
          path: '/database',
          builder: (context, state) => const DatabaseAccessPage(),
        ),
        GoRoute(
          path: '/logs',
          builder: (context, state) => const SystemLogsPage(),
        ),
      ],
    );
  }
}

