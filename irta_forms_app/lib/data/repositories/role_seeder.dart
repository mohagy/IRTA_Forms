import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role_model.dart';

/// Script to seed Firestore with default roles and permissions
class RoleSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'roles';

  /// Initialize default roles in Firestore
  Future<void> seedRoles() async {
    try {
      // Check if roles already exist
      final existingRoles = await _firestore.collection(_collection).limit(1).get();
      if (existingRoles.docs.isNotEmpty) {
        print('Roles already exist. Skipping seeding.');
        return;
      }

      final defaultRoles = _getDefaultRoles();

      // Add all roles to Firestore
      final batch = _firestore.batch();
      for (final role in defaultRoles) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, role.toMap());
      }

      await batch.commit();
      print('Successfully seeded ${defaultRoles.length} roles to Firestore');
    } catch (e) {
      print('Error seeding roles: $e');
      rethrow;
    }
  }

  /// Get default roles with their permissions
  List<RoleModel> _getDefaultRoles() {
    return [
      // IRTA Admin
      RoleModel(
        id: '',
        name: 'IRTA Admin',
        description: 'Full administrative access to all system features',
        permissions: [
          // Forms
          PermissionConstants.viewAllForms,
          PermissionConstants.createForms,
          PermissionConstants.editForms,
          PermissionConstants.deleteForms,
          PermissionConstants.viewAssignedForms,
          // Workflow
          PermissionConstants.verify,
          PermissionConstants.approve,
          PermissionConstants.reject,
          PermissionConstants.reassign,
          PermissionConstants.requestAdditionalInfo,
          PermissionConstants.review,
          PermissionConstants.assignToOfficers,
          // System
          PermissionConstants.manageUsers,
          PermissionConstants.manageRoles,
          PermissionConstants.configureForms,
          PermissionConstants.viewReports,
          PermissionConstants.systemConfiguration,
          PermissionConstants.databaseAccess,
          PermissionConstants.viewAllLogs,
        ],
        createdAt: DateTime.now(),
      ),

      // Issuing Officer
      RoleModel(
        id: '',
        name: 'Issuing Officer',
        description: 'Can approve applications and issue IRTA documents',
        permissions: [
          PermissionConstants.viewAssignedForms,
          PermissionConstants.editForms,
          PermissionConstants.approve,
          PermissionConstants.reject,
          PermissionConstants.reassign,
          PermissionConstants.viewReports,
        ],
        createdAt: DateTime.now(),
      ),

      // Verification Officer
      RoleModel(
        id: '',
        name: 'Verification Officer',
        description: 'Verifies documents and requests additional information',
        permissions: [
          PermissionConstants.viewAssignedForms,
          PermissionConstants.verify,
          PermissionConstants.requestAdditionalInfo,
          PermissionConstants.viewReports,
        ],
        createdAt: DateTime.now(),
      ),

      // Reception Staff
      RoleModel(
        id: '',
        name: 'Reception Staff',
        description: 'Initial review and assignment of applications',
        permissions: [
          PermissionConstants.viewAllForms,
          PermissionConstants.review,
          PermissionConstants.assignToOfficers,
          PermissionConstants.viewReports,
        ],
        createdAt: DateTime.now(),
      ),

      // Applicant
      RoleModel(
        id: '',
        name: 'Applicant',
        description: 'Standard user role for submitting IRTA applications',
        permissions: [
          PermissionConstants.createForms,
          PermissionConstants.viewOwnForms,
          PermissionConstants.editDraftForms,
        ],
        createdAt: DateTime.now(),
      ),

      // IT Admin
      RoleModel(
        id: '',
        name: 'IT Admin',
        description: 'System administration and technical support',
        permissions: [
          PermissionConstants.viewAllForms,
          PermissionConstants.systemConfiguration,
          PermissionConstants.databaseAccess,
          PermissionConstants.viewAllLogs,
          PermissionConstants.manageUsers,
          PermissionConstants.viewReports,
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Force re-seed (delete existing and create new) - USE WITH CAUTION
  Future<void> forceSeedRoles() async {
    try {
      // Delete all existing roles
      final existingRoles = await _firestore.collection(_collection).get();
      final batch = _firestore.batch();
      for (final doc in existingRoles.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('Deleted ${existingRoles.docs.length} existing roles');

      // Seed new roles
      await seedRoles();
    } catch (e) {
      print('Error force seeding roles: $e');
      rethrow;
    }
  }
}


