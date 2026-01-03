import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? nationality;
  final DateTime? dateOfBirth;
  final String? idType;
  final String? idNumber;
  final String? address;
  final String role;
  final String? department;
  final String status; // Active, Inactive
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.nationality,
    this.dateOfBirth,
    this.idType,
    this.idNumber,
    this.address,
    required this.role,
    this.department,
    this.status = 'Active',
    this.lastLogin,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      nationality: map['nationality'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      idType: map['idType'],
      idNumber: map['idNumber'],
      address: map['address'],
      role: map['role'] ?? 'applicant',
      department: map['department'],
      status: map['status'] ?? 'Active',
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'idType': idType,
      'idNumber': idNumber,
      'address': address,
      'role': role,
      'department': department,
      'status': status,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? nationality,
    DateTime? dateOfBirth,
    String? idType,
    String? idNumber,
    String? address,
    String? role,
    String? department,
    String? status,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationality: nationality ?? this.nationality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      department: department ?? this.department,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


