import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/application_repository.dart';

class ApplicationProvider with ChangeNotifier {
  final ApplicationRepository _repository = ApplicationRepository();
  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<ApplicationModel>>? _applicationsSubscription;
  String? _currentUserId; // Track which user's applications are loaded

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ApplicationProvider() {
    // Start with empty list - data will be loaded from Firestore
    _applications = [];
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    super.dispose();
  }

  // Load applications for a specific user (applicant view)
  void loadUserApplications(String userId) {
    // Prevent loading if already loading for the same user
    if (_currentUserId == userId && _applicationsSubscription != null) {
      return;
    }

    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _applicationsSubscription?.cancel();
    _applicationsSubscription = _repository.getUserApplications(userId).listen(
      (applications) {
        _applications = applications;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _applications = [];
        notifyListeners();
      },
    );
  }

  // Load all applications (admin/officer view)
  void loadAllApplications() {
    // Prevent loading if already loading all applications
    if (_currentUserId == null && _applicationsSubscription != null) {
      return;
    }

    _currentUserId = null; // null means loading all applications
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _applicationsSubscription?.cancel();
    _applicationsSubscription = _repository.getAllApplications().listen(
      (applications) {
        _applications = applications;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _applications = [];
        notifyListeners();
      },
    );
  }

  // Create a new application
  Future<String?> createApplication({
    required String userId,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final applicationId = await _repository.createApplication(
        userId: userId,
        applicationData: applicationData,
      );

      _isLoading = false;
      notifyListeners();
      return applicationId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update application
  Future<bool> updateApplication(String applicationId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.updateApplication(applicationId, updates);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Submit application
  Future<bool> submitApplication(String applicationId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.submitApplication(applicationId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // Filter applications
  List<ApplicationModel> filterApplications({
    String? status,
    String? formType,
    String? searchQuery,
  }) {
    var filtered = List<ApplicationModel>.from(_applications);

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((app) => app.status == status).toList();
    }

    if (formType != null && formType.isNotEmpty) {
      filtered = filtered.where((app) => app.formType == formType).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((app) {
        return app.irtaRef.toLowerCase().contains(query) ||
            app.applicantName.toLowerCase().contains(query) ||
            (app.nationality?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }
}


