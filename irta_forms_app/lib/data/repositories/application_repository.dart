import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'applications';

  // Generate IRTA reference number
  String _generateIrtaRef() {
    final now = DateTime.now();
    final year = now.year;
    final random = (now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return 'IRTA-$year-$random';
  }

  // Create a new application
  Future<String> createApplication({
    required String userId,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      final irtaRef = _generateIrtaRef();
      final application = {
        'irtaRef': irtaRef,
        'userId': userId,
        'formType': applicationData['formType'] ?? 'Business IRTA',
        'applicantName': applicationData['applicantName'] ?? '',
        'nationality': applicationData['nationality'],
        'purpose': applicationData['purpose'],
        'submissionDate': FieldValue.serverTimestamp(),
        'status': 'Draft',
        'applicationData': applicationData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection(_collection).add(application);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create application: $e');
    }
  }

  // Update an existing application
  Future<void> updateApplication(String applicationId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update application: $e');
    }
  }

  // Submit application (change status from Draft to Submitted)
  Future<void> submitApplication(String applicationId) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        'status': 'Submitted',
        'submissionDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Get application by ID
  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(applicationId).get();
      if (doc.exists) {
        return ApplicationModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get application: $e');
    }
  }

  // Get applications by user ID
  Stream<List<ApplicationModel>> getUserApplications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('submissionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get all applications (for admin/officers)
  Stream<List<ApplicationModel>> getAllApplications() {
    return _firestore
        .collection(_collection)
        .orderBy('submissionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get applications by status
  Stream<List<ApplicationModel>> getApplicationsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('submissionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Delete application
  Future<void> deleteApplication(String applicationId) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).delete();
    } catch (e) {
      throw Exception('Failed to delete application: $e');
    }
  }
  // Get latest draft for user
  Future<ApplicationModel?> getLatestDraft(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Draft')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return ApplicationModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      // If index is missing, we might get an error. For now, return null or handle gracefully.
      // In production, ensure composite index exists: userId ASC, status ASC, updatedAt DESC
      print('Error getting latest draft: $e'); 
      return null;
    }
  }
}



