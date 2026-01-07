import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/system_log_model.dart';

class SystemLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'system_logs';

  // Create a new log entry
  Future<void> createLog({
    required String level,
    required String type,
    required String action,
    required String details,
    String? userId,
    String? userName,
    String? ipAddress,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'timestamp': FieldValue.serverTimestamp(),
        'level': level,
        'type': type,
        'userId': userId,
        'userName': userName,
        'action': action,
        'details': details,
        'ipAddress': ipAddress,
        'metadata': metadata,
      });
    } catch (e) {
      // Silently fail logging to prevent logging errors from breaking the app
      print('Failed to create log entry: $e');
    }
  }

  // Get logs stream (real-time updates)
  Stream<List<SystemLogModel>> getLogsStream({
    String? level,
    String? type,
    int? limit,
  }) {
    Query query = _firestore.collection(_collection);

    // Apply filters
    if (level != null && level.isNotEmpty) {
      query = query.where('level', isEqualTo: level);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    // Order by timestamp descending (newest first)
    query = query.orderBy('timestamp', descending: true);

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    } else {
      query = query.limit(1000); // Default limit to prevent performance issues
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SystemLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Get logs (one-time fetch)
  Future<List<SystemLogModel>> getLogs({
    String? level,
    String? type,
    int? limit,
  }) async {
    Query query = _firestore.collection(_collection);

    if (level != null && level.isNotEmpty) {
      query = query.where('level', isEqualTo: level);
    }
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    query = query.orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    } else {
      query = query.limit(1000);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SystemLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get log statistics
  Future<Map<String, int>> getLogStatistics() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Get all logs from today
    final todaySnapshot = await _firestore
        .collection(_collection)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();

    final allSnapshot = await _firestore.collection(_collection).get();

    int totalLogs = allSnapshot.docs.length;
    int todayLogs = todaySnapshot.docs.length;
    int errorCount = 0;
    int warningCount = 0;

    for (var doc in todaySnapshot.docs) {
      final data = doc.data();
      final level = data['level'] as String? ?? 'Info';
      if (level == 'Error') {
        errorCount++;
      } else if (level == 'Warning') {
        warningCount++;
      }
    }

    return {
      'total': totalLogs,
      'today': todayLogs,
      'errors': errorCount,
      'warnings': warningCount,
    };
  }

  // Delete old logs (older than specified days)
  Future<void> deleteOldLogs(int daysToKeep) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

    final snapshot = await _firestore
        .collection(_collection)
        .where('timestamp', isLessThan: cutoffTimestamp)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

