import 'package:cloud_firestore/cloud_firestore.dart';

class SystemLogModel {
  final String id;
  final DateTime timestamp;
  final String level; // Info, Warning, Error, Debug
  final String type; // Login, Form, User, System
  final String? userId;
  final String? userName;
  final String action;
  final String details;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;

  SystemLogModel({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.type,
    this.userId,
    this.userName,
    required this.action,
    required this.details,
    this.ipAddress,
    this.metadata,
  });

  factory SystemLogModel.fromMap(Map<String, dynamic> map, String id) {
    return SystemLogModel(
      id: id,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      level: map['level'] ?? 'Info',
      type: map['type'] ?? 'System',
      userId: map['userId'],
      userName: map['userName'],
      action: map['action'] ?? '',
      details: map['details'] ?? '',
      ipAddress: map['ipAddress'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'level': level,
      'type': type,
      'userId': userId,
      'userName': userName,
      'action': action,
      'details': details,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }
}

