import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Get all users as a stream
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Create user with specific ID (for Firebase Auth UID)
  Future<String> createUserWithId(String userId, UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(userId).set(user.toMap());
      return userId;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Create user (auto-generate ID)
  Future<String> createUser(UserModel user) async {
    try {
      final docRef = await _firestore.collection(_collection).add(user.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        ...user.toMap(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': role,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}

