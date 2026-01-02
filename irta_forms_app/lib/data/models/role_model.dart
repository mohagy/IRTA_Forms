import 'package:cloud_firestore/cloud_firestore.dart';

class RoleModel {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final int userCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoleModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.permissions,
    this.userCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore document
  factory RoleModel.fromMap(Map<String, dynamic> map, String id) {
    return RoleModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
      userCount: map['userCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'permissions': permissions,
      'userCount': userCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create a copy with updated fields
  RoleModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? permissions,
    int? userCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
      userCount: userCount ?? this.userCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Permission categories and available permissions
class PermissionConstants {
  // Form Permissions
  static const String viewAllForms = 'View All Forms';
  static const String viewAssignedForms = 'View Assigned Forms';
  static const String createForms = 'Create Forms';
  static const String editForms = 'Edit Forms';
  static const String deleteForms = 'Delete Forms';
  static const String viewOwnForms = 'View Own Forms';
  static const String editDraftForms = 'Edit Draft Forms';
  static const String editSubmittedForms = 'Edit Submitted Forms';

  // Workflow Permissions
  static const String verify = 'Verify';
  static const String approve = 'Approve';
  static const String reject = 'Reject';
  static const String reassign = 'Reassign';
  static const String requestAdditionalInfo = 'Request Additional Info';
  static const String review = 'Review';
  static const String assignToOfficers = 'Assign to Officers';

  // System Permissions
  static const String manageUsers = 'Manage Users';
  static const String manageRoles = 'Manage Roles';
  static const String configureForms = 'Configure Forms';
  static const String viewReports = 'View Reports';
  static const String systemConfiguration = 'System Configuration';
  static const String databaseAccess = 'Database Access';
  static const String viewAllLogs = 'View All Logs';

  // Get all permissions grouped by category
  static Map<String, List<String>> getPermissionGroups() {
    return {
      'Forms': [
        viewAllForms,
        viewAssignedForms,
        createForms,
        editForms,
        deleteForms,
        viewOwnForms,
        editDraftForms,
        editSubmittedForms,
      ],
      'Workflow': [
        verify,
        approve,
        reject,
        reassign,
        requestAdditionalInfo,
        review,
        assignToOfficers,
      ],
      'System': [
        manageUsers,
        manageRoles,
        configureForms,
        viewReports,
        systemConfiguration,
        databaseAccess,
        viewAllLogs,
      ],
    };
  }

  // Get all permissions as a flat list
  static List<String> getAllPermissions() {
    return getPermissionGroups().values.expand((x) => x).toList();
  }
}

