import '../data/repositories/system_log_repository.dart';

/// Service for logging system events throughout the application
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  final SystemLogRepository _repository = SystemLogRepository();

  factory LoggingService() => _instance;
  LoggingService._internal();

  /// Log an info-level event
  Future<void> logInfo({
    required String type,
    required String action,
    required String details,
    String? userId,
    String? userName,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await _repository.createLog(
      level: 'Info',
      type: type,
      action: action,
      details: details,
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }

  /// Log a warning-level event
  Future<void> logWarning({
    required String type,
    required String action,
    required String details,
    String? userId,
    String? userName,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await _repository.createLog(
      level: 'Warning',
      type: type,
      action: action,
      details: details,
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }

  /// Log an error-level event
  Future<void> logError({
    required String type,
    required String action,
    required String details,
    String? userId,
    String? userName,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await _repository.createLog(
      level: 'Error',
      type: type,
      action: action,
      details: details,
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }

  /// Log a debug-level event
  Future<void> logDebug({
    required String type,
    required String action,
    required String details,
    String? userId,
    String? userName,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await _repository.createLog(
      level: 'Debug',
      type: type,
      action: action,
      details: details,
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }

  /// Log user login
  Future<void> logLogin({
    required String userId,
    required String userName,
    required bool success,
    String? ipAddress,
    String? errorMessage,
  }) async {
    await _repository.createLog(
      level: success ? 'Info' : 'Warning',
      type: 'Login',
      action: success ? 'User Login' : 'Failed Login Attempt',
      details: success
          ? 'Successful login'
          : 'Login failed: ${errorMessage ?? "Invalid credentials"}',
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
    );
  }

  /// Log user logout
  Future<void> logLogout({
    required String userId,
    required String userName,
    String? ipAddress,
  }) async {
    await _repository.createLog(
      level: 'Info',
      type: 'Login',
      action: 'User Logout',
      details: 'User logged out',
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
    );
  }

  /// Log form/application action
  Future<void> logFormAction({
    required String action,
    required String details,
    String? userId,
    String? userName,
    String? applicationId,
    String? ipAddress,
  }) async {
    await _repository.createLog(
      level: 'Info',
      type: 'Form',
      action: action,
      details: details,
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
      metadata: applicationId != null ? {'applicationId': applicationId} : null,
    );
  }

  /// Log user management action
  Future<void> logUserAction({
    required String action,
    required String details,
    required String userId,
    required String userName,
    String? targetUserId,
    String? ipAddress,
  }) async {
    await _repository.createLog(
      level: 'Info',
      type: 'User',
      action: action,
      details: details,
      userId: userId,
      userName: userName,
      ipAddress: ipAddress,
      metadata: targetUserId != null ? {'targetUserId': targetUserId} : null,
    );
  }

  /// Log system action
  Future<void> logSystemAction({
    required String action,
    required String details,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await _repository.createLog(
      level: 'Info',
      type: 'System',
      action: action,
      details: details,
      ipAddress: ipAddress,
      metadata: metadata,
    );
  }
}

