import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role_model.dart';

class RoleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'roles';

  // Get all roles as a stream
  Stream<List<RoleModel>> getAllRoles() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoleModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get role by ID
  Future<RoleModel?> getRoleById(String roleId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(roleId).get();
      if (doc.exists) {
        return RoleModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get role: $e');
    }
  }

  // Get role by name
  Future<RoleModel?> getRoleByName(String roleName) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: roleName)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return RoleModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get role by name: $e');
    }
  }

  // Create role
  Future<String> createRole(RoleModel role) async {
    try {
      final docRef = await _firestore.collection(_collection).add(role.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  // Update role
  Future<void> updateRole(String roleId, RoleModel role) async {
    try {
      await _firestore.collection(_collection).doc(roleId).update({
        ...role.toMap(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  // Delete role
  Future<void> deleteRole(String roleId) async {
    try {
      await _firestore.collection(_collection).doc(roleId).delete();
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }

  // Update role permissions
  Future<void> updateRolePermissions(String roleId, List<String> permissions) async {
    try {
      await _firestore.collection(_collection).doc(roleId).update({
        'permissions': permissions,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update role permissions: $e');
    }
  }

  // Update user count for a role (called when users are assigned/unassigned)
  Future<void> updateUserCount(String roleId, int count) async {
    try {
      await _firestore.collection(_collection).doc(roleId).update({
        'userCount': count,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user count: $e');
    }
  }
}



