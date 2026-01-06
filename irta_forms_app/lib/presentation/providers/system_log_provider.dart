import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/system_log_model.dart';
import '../../data/repositories/system_log_repository.dart';

class SystemLogProvider with ChangeNotifier {
  final SystemLogRepository _repository = SystemLogRepository();
  
  List<SystemLogModel> _logs = [];
  Map<String, int> _statistics = {
    'total': 0,
    'today': 0,
    'errors': 0,
    'warnings': 0,
  };
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<SystemLogModel>>? _logsSubscription;
  
  String? _filterLevel;
  String? _filterType;
  String? _searchQuery;

  List<SystemLogModel> get logs => _logs;
  Map<String, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SystemLogProvider() {
    loadLogs();
    loadStatistics();
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    super.dispose();
  }

  // Load logs with real-time updates
  void loadLogs({String? level, String? type}) {
    _filterLevel = level;
    _filterType = type;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _logsSubscription?.cancel();
    _logsSubscription = _repository.getLogsStream(
      level: level,
      type: type,
      limit: 1000,
    ).listen(
      (logs) {
        _logs = logs;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _logs = [];
        notifyListeners();
      },
    );
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getLogStatistics();
      notifyListeners();
    } catch (e) {
      // Silently fail statistics loading
    }
  }

  // Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Get filtered logs based on search query
  List<SystemLogModel> get filteredLogs {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return _logs;
    }
    
    final query = _searchQuery!.toLowerCase();
    return _logs.where((log) {
      return log.action.toLowerCase().contains(query) ||
          log.details.toLowerCase().contains(query) ||
          (log.userName?.toLowerCase().contains(query) ?? false) ||
          (log.ipAddress?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Refresh logs
  void refresh() {
    loadLogs(level: _filterLevel, type: _filterType);
    loadStatistics();
  }

  // Clear old logs
  Future<void> clearOldLogs(int daysToKeep) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _repository.deleteOldLogs(daysToKeep);
      
      // Reload logs and statistics
      loadLogs(level: _filterLevel, type: _filterType);
      loadStatistics();
    } catch (e) {
      _errorMessage = 'Failed to clear old logs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}

