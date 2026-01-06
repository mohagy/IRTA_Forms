import 'package:cloud_firestore/cloud_firestore.dart';

class FormConfigRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'form_configs';

  Future<void> saveFormConfig({
    required String formType,
    required Map<String, dynamic> config,
    String? updatedBy,
  }) async {
    final now = FieldValue.serverTimestamp();
    final docRef = _firestore.collection(_collection).doc(formType);
    await docRef.set({
      'formType': formType,
      'config': config,
      'updatedAt': now,
      if (updatedBy != null) 'updatedBy': updatedBy,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getFormConfig(String formType) async {
    try {
      final docRef = _firestore.collection(_collection).doc(formType);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data()!;
      return data['config'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get form config: $e');
    }
  }

  Future<void> publishFormConfig({
    required String formType,
    String? publishedBy,
  }) async {
    final now = FieldValue.serverTimestamp();
    final docRef = _firestore.collection(_collection).doc(formType);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('No configuration found to publish for "$formType".');
    }
    final data = snapshot.data()!;
    final config = data['config'] as Map<String, dynamic>? ?? {};
    // Create a new version entry
    final versionsRef = docRef.collection('versions').doc();
    await versionsRef.set({
      'formType': formType,
      'config': config,
      'publishedAt': now,
      if (publishedBy != null) 'publishedBy': publishedBy,
    });
    // Update a pointer to the latest published version
    await docRef.set({
      'lastPublishedAt': now,
      'lastPublishedVersionId': versionsRef.id,
      if (publishedBy != null) 'lastPublishedBy': publishedBy,
    }, SetOptions(merge: true));
  }
}


