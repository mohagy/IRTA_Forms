/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'IRTA Forms';
  static const String appVersion = '1.0.0';
  
  // Layout Constants
  static const double sidebarWidth = 260.0;
  static const double headerHeight = 64.0;
  static const double defaultPadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  
  // User Roles
  static const String roleApplicant = 'applicant';
  static const String roleOfficer = 'officer';
  static const String roleAdmin = 'admin';
  static const String roleReception = 'reception';
  static const String roleVerification = 'verification';
  static const String roleIssuing = 'issuing';
  
  // Application Statuses
  static const String statusDraft = 'Draft';
  static const String statusSubmitted = 'Submitted';
  static const String statusReceptionReview = 'Reception Review';
  static const String statusVerification = 'Verification';
  static const String statusIssuingDecision = 'Issuing Decision';
  static const String statusCompleted = 'Completed';
  static const String statusRejected = 'Rejected';
  
  // Application Types
  static const String appTypeIndividual = 'Individual IRTA';
  
  // Routes
  static const String routeLanding = '/';
  static const String routeRegistration = '/registration';
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routeApplications = '/applications';
  static const String routeNewApplication = '/applications/new';
  static const String routeApplicationDetail = '/applications/:id';
  
  // Storage Keys
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
}

