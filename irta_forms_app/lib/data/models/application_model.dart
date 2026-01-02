import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String irtaRef;
  final String formType;
  final String applicantName;
  final String? nationality;
  final String? purpose;
  final DateTime submissionDate;
  final String status;
  final String? assignedOfficer;
  final String? previousIrtaRef;
  final DateTime? expiryDate;
  final Map<String, dynamic>? applicationData;

  ApplicationModel({
    required this.id,
    required this.irtaRef,
    required this.formType,
    required this.applicantName,
    this.nationality,
    this.purpose,
    required this.submissionDate,
    required this.status,
    this.assignedOfficer,
    this.previousIrtaRef,
    this.expiryDate,
    this.applicationData,
  });

  // Factory constructor from Firestore document
  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      irtaRef: map['irtaRef'] ?? '',
      formType: map['formType'] ?? '',
      applicantName: map['applicantName'] ?? '',
      nationality: map['nationality'],
      purpose: map['purpose'],
      submissionDate: (map['submissionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'Draft',
      assignedOfficer: map['assignedOfficer'],
      previousIrtaRef: map['previousIrtaRef'],
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      applicationData: map['applicationData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'irtaRef': irtaRef,
      'formType': formType,
      'applicantName': applicantName,
      'nationality': nationality,
      'purpose': purpose,
      'submissionDate': Timestamp.fromDate(submissionDate),
      'status': status,
      'assignedOfficer': assignedOfficer,
      'previousIrtaRef': previousIrtaRef,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'applicationData': applicationData,
    };
  }
}

