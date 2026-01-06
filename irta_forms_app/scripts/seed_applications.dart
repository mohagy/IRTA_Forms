import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/core/constants/app_constants.dart' as constants;

/// Script to seed Firestore with sample application data for testing
/// Run this with: dart run scripts/seed_applications.dart
Future<void> main() async {
  try {
    print('Initializing Firebase...');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    print('Creating sample applications...');
    
    // Sample Application 1: Business IRTA with 2 vehicles
    await _createSampleApplication(
      firestore,
      userId: 'test-user-1',
      applicantName: 'John Smith',
      formType: constants.AppConstants.appTypeBusiness,
      status: 'Submitted',
      vehicles: [
        {
          'vehiclePlate': 'GAB-1234',
          'vehicleType': 'Bus',
          'vehicleYear': '2020',
          'vehicleMake': 'Mercedes',
          'vehicleBodyType': 'Passenger Bus',
          'vehicleChassis': 'WDB12345678901234',
          'vehicleAxles': '2',
          'vehicleMtc': '5000',
          'vehicleNwc': '4500',
          'vehicleTare': '8000',
          'vehicleApprovalStatus': 'Pending',
        },
        {
          'vehiclePlate': 'GAB-5678',
          'vehicleType': 'Truck',
          'vehicleYear': '2019',
          'vehicleMake': 'Toyota',
          'vehicleBodyType': 'Flatbed',
          'vehicleChassis': 'JTD12345678901234',
          'vehicleAxles': '3',
          'vehicleMtc': '10000',
          'vehicleNwc': '9000',
          'vehicleTare': '5000',
          'vehicleApprovalStatus': 'Pending',
        },
      ],
    );
    
    // Sample Application 2: Business IRTA with 1 vehicle (Approved)
    await _createSampleApplication(
      firestore,
      userId: 'test-user-2',
      applicantName: 'Sarah Johnson',
      formType: constants.AppConstants.appTypeBusiness,
      status: 'Submitted',
      vehicles: [
        {
          'vehiclePlate': 'GAB-9012',
          'vehicleType': 'Van',
          'vehicleYear': '2021',
          'vehicleMake': 'Ford',
          'vehicleBodyType': 'Cargo Van',
          'vehicleChassis': '1FT12345678901234',
          'vehicleAxles': '2',
          'vehicleMtc': '3500',
          'vehicleNwc': '3000',
          'vehicleTare': '2000',
          'vehicleApprovalStatus': 'Approved',
          'vehicleApprovedBy': 'admin@example.com',
          'vehicleApprovedAt': FieldValue.serverTimestamp(),
        },
      ],
    );
    
    // Sample Application 3: Business IRTA with 1 vehicle (Rejected)
    await _createSampleApplication(
      firestore,
      userId: 'test-user-3',
      applicantName: 'Michael Brown',
      formType: constants.AppConstants.appTypeBusiness,
      status: 'Submitted',
      vehicles: [
        {
          'vehiclePlate': 'GAB-3456',
          'vehicleType': 'Truck',
          'vehicleYear': '2018',
          'vehicleMake': 'VW',
          'vehicleBodyType': 'Box Truck',
          'vehicleChassis': 'WVW12345678901234',
          'vehicleAxles': '2',
          'vehicleMtc': '7500',
          'vehicleNwc': '7000',
          'vehicleTare': '3500',
          'vehicleApprovalStatus': 'Rejected',
          'vehicleApprovalComment': 'Vehicle registration expired',
          'vehicleApprovedBy': 'officer@example.com',
          'vehicleApprovedAt': FieldValue.serverTimestamp(),
        },
      ],
    );
    
    // Sample Application 4: Individual IRTA
    await _createSampleApplication(
      firestore,
      userId: 'test-user-4',
      applicantName: 'Emily Davis',
      formType: constants.AppConstants.appTypeIndividual,
      status: 'Submitted',
      vehicles: [
        {
          'vehiclePlate': 'GAB-7890',
          'vehicleType': 'Bus',
          'vehicleYear': '2022',
          'vehicleMake': 'Mercedes',
          'vehicleBodyType': 'Mini Bus',
          'vehicleChassis': 'WDB98765432109876',
          'vehicleAxles': '2',
          'vehicleMtc': '4000',
          'vehicleNwc': '3500',
          'vehicleTare': '3000',
          'vehicleApprovalStatus': 'Pending',
        },
      ],
    );
    
    // Sample Application 5: Draft application (not submitted)
    await _createSampleApplication(
      firestore,
      userId: 'test-user-5',
      applicantName: 'Robert Wilson',
      formType: constants.AppConstants.appTypeBusiness,
      status: 'Draft',
      vehicles: [
        {
          'vehiclePlate': 'GAB-2468',
          'vehicleType': 'Truck',
          'vehicleYear': '2023',
          'vehicleMake': 'Toyota',
          'vehicleBodyType': 'Refrigerated',
          'vehicleChassis': 'JTD98765432109876',
          'vehicleAxles': '3',
          'vehicleMtc': '12000',
          'vehicleNwc': '11000',
          'vehicleTare': '6000',
          'vehicleApprovalStatus': 'Pending',
        },
      ],
    );
    
    print('✅ Successfully created 5 sample applications!');
    print('');
    print('Applications created:');
    print('1. John Smith - 2 vehicles (Pending)');
    print('2. Sarah Johnson - 1 vehicle (Approved)');
    print('3. Michael Brown - 1 vehicle (Rejected)');
    print('4. Emily Davis - 1 vehicle (Pending) - Individual IRTA');
    print('5. Robert Wilson - 1 vehicle (Pending) - Draft');
    print('');
    print('You can now view these in:');
    print('- Individual IRTA Applications page');
    print('- Vehicle Approval page');
    print('- Dashboard');
    
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Error creating sample applications: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

Future<void> _createSampleApplication(
  FirebaseFirestore firestore, {
  required String userId,
  required String applicantName,
  required String formType,
  required String status,
  required List<Map<String, dynamic>> vehicles,
}) async {
  final now = DateTime.now();
  final year = now.year;
  final random = (now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
  final irtaRef = 'IRTA-$year-$random';
  
  // Create representative data
  final representatives = [
    {
      'name': applicantName,
      'position': 'Director',
      'nationality': 'Guyanese',
      'passportNumber': 'P123456',
      'address': '123 Main Street, Georgetown, Guyana',
      'publicProxyInstrumentFileName': 'proxy_instrument_${applicantName.replaceAll(' ', '_')}.pdf',
      'publicProxyInstrumentFileUrl': 'https://example.com/files/proxy_instrument.pdf',
    },
  ];
  
  // Create organization data
  final organization = {
    'firmName': '$applicantName Transport Services',
    'firmAddress': '123 Main Street, Georgetown, Guyana',
    'legalRepresentative': applicantName,
    'tin': 'TIN${random.substring(0, 6)}',
    'companyRegistrationNumber': 'CR${random.substring(0, 8)}',
    'telephone': '+592-600-${random.substring(0, 4)}',
    'fax': '+592-600-${random.substring(0, 4)}',
    'companyRegistrationFileName': 'company_reg_${applicantName.replaceAll(' ', '_')}.pdf',
    'companyRegistrationFileUrl': 'https://example.com/files/company_reg.pdf',
  };
  
  // Create transportation data
  final transportation = {
    'natureOfTransport': 'Passenger Transport',
    'modalityOfTraffic': 'Regular Route',
    'origin': 'Georgetown, Guyana',
    'destination': 'Federative Republic of Brazil',
    'vehicles': vehicles.map((v) {
      // Add vehicle document file names (mock URLs)
      final plate = (v['vehiclePlate'] as String).replaceAll('-', '_');
      return {
        ...v,
        'vehicleRegistrationFileName': 'registration_$plate.pdf',
        'vehicleRegistrationFileUrl': 'https://example.com/files/registration_$plate.pdf',
        'revenueLicenceFileName': 'revenue_licence_$plate.pdf',
        'revenueLicenceFileUrl': 'https://example.com/files/revenue_licence_$plate.pdf',
        'fitnessCertificateFileName': 'fitness_$plate.pdf',
        'fitnessCertificateFileUrl': 'https://example.com/files/fitness_$plate.pdf',
        'thirdPartyInsuranceFileName': 'insurance_$plate.pdf',
        'thirdPartyInsuranceFileUrl': 'https://example.com/files/insurance_$plate.pdf',
      };
    }).toList(),
  };
  
  // Create application data
  final applicationData = {
    'formType': formType,
    'applicantName': applicantName,
    'nationality': 'Guyanese',
    'purpose': 'Commercial Transport Operations',
    'representatives': representatives,
    'organization': organization,
    'transportation': transportation,
    'currentStep': 4,
    'declarationAgreed': true,
    'savedAt': now.toIso8601String(),
  };
  
  // Create application document
  final application = {
    'irtaRef': irtaRef,
    'userId': userId,
    'formType': formType,
    'applicantName': applicantName,
    'nationality': 'Guyanese',
    'purpose': 'Commercial Transport Operations',
    'submissionDate': FieldValue.serverTimestamp(),
    'status': status,
    'applicationData': applicationData,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
  
  await firestore.collection('applications').add(application);
  print('Created application: $irtaRef for $applicantName');
}

