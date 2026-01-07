import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../../services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/application_model.dart';

class RepresentativeData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  DateTime? dob;
  PlatformFile? publicProxyInstrumentFile;
  bool isUploadingFile = false;

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    idController.dispose();
    addressController.dispose();
  }
}

class VehicleData {
  final TextEditingController plateController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController bodyTypeController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController axlesController = TextEditingController();
  final TextEditingController mtcController = TextEditingController();
  final TextEditingController nwcController = TextEditingController();
  final TextEditingController tareController = TextEditingController();
  
  String? type;
  String? make;
  
  PlatformFile? registrationFile;
  PlatformFile? revenueLicenceFile;
  PlatformFile? fitnessCertificateFile;
  PlatformFile? insuranceDocumentFile;
  
  bool isUploadingRegistration = false;
  bool isUploadingLicence = false;
  bool isUploadingFitness = false;
  bool isUploadingInsurance = false;

  void dispose() {
    plateController.dispose();
    yearController.dispose();
    bodyTypeController.dispose();
    chassisController.dispose();
    axlesController.dispose();
    mtcController.dispose();
    nwcController.dispose();
    tareController.dispose();
  }
}

class NewApplicationPage extends StatefulWidget {
  final String? editApplicationId;
  
  const NewApplicationPage({super.key, this.editApplicationId});

  @override
  State<NewApplicationPage> createState() => _NewApplicationPageState();
}

class _NewApplicationPageState extends State<NewApplicationPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  // Form controllers and state
  final _formKey = GlobalKey<FormState>();
  
  // Representative fields
  final List<RepresentativeData> _representatives = [RepresentativeData()];
  
  // Organization file upload
  PlatformFile? _companyRegistrationFile;
  bool _isUploadingCompanyFile = false;
  
  final StorageService _storageService = StorageService();
  
  // Organization fields
  final _firmNameController = TextEditingController();
  final _firmAddressController = TextEditingController();
  final _legalRepresentativeController = TextEditingController();
  final _tinController = TextEditingController();
  final _companyRegController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _faxController = TextEditingController();
  
  // Transportation fields
  String _natureOfTransport = '';
  String _modalityOfTraffic = '';
  String _origin = '';
  String _destination = '';
  final List<VehicleData> _vehicles = [VehicleData()];
  
  // Declarations
  bool _declarationAgreed = false;
  
  // Draft Management
  String? _draftId;
  Timer? _autoSaveTimer;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _pageController.dispose();
    for (var rep in _representatives) {
      rep.dispose();
    }
    _firmNameController.dispose();
    _firmAddressController.dispose();
    _legalRepresentativeController.dispose();
    _tinController.dispose();
    _companyRegController.dispose();
    _telephoneController.dispose();
    _faxController.dispose();
    for (var vehicle in _vehicles) {
      vehicle.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Auto-save when moving to next step
      _triggerAutoSave();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Auto-save when moving to previous step
      _triggerAutoSave();
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step <= 4) {
      setState(() {
        _currentStep = step;
      });
      _pageController.jumpToPage(step);
      // Auto-save when jumping to a step
      _triggerAutoSave();
    }
  }

  // Trigger auto-save with debounce (saves 2 seconds after last change)
  void _triggerAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final appProvider = context.read<ApplicationProvider>();
        _saveDraft(context, authProvider, appProvider, silent: true);
      }
    });
  }

  Future<bool> _saveDraft(BuildContext context, AuthProvider authProvider, ApplicationProvider appProvider, {bool silent = false}) async {
    final user = authProvider.user;
    if (user == null) {
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to save a draft'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }

    // Upload files to Firebase Storage and get URLs
    final applicationId = _draftId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final basePath = 'applications/${user.uid}/$applicationId';

    // Upload representative files
    final List<Map<String, dynamic>> representativesData = [];
    for (int i = 0; i < _representatives.length; i++) {
      final rep = _representatives[i];
      String? fileUrl;
      
      if (rep.publicProxyInstrumentFile != null) {
        try {
          final fileName = 'representative_${i}_proxy_${rep.publicProxyInstrumentFile!.name}';
          fileUrl = await _storageService.uploadPlatformFile(
            path: '$basePath/$fileName',
            platformFile: rep.publicProxyInstrumentFile!,
          );
        } catch (e) {
          if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload file: ${rep.publicProxyInstrumentFile!.name}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      representativesData.add({
        'name': rep.nameController.text,
        'email': rep.emailController.text,
        'phone': rep.phoneController.text,
        'idNumber': rep.idController.text,
        'address': rep.addressController.text,
        'dateOfBirth': rep.dob?.toIso8601String(),
        'publicProxyInstrumentFileName': rep.publicProxyInstrumentFile?.name,
        'publicProxyInstrumentFileUrl': fileUrl,
      });
    }

    // Upload organization file
    String? companyRegFileUrl;
    if (_companyRegistrationFile != null) {
      try {
        final fileName = 'company_registration_${_companyRegistrationFile!.name}';
        companyRegFileUrl = await _storageService.uploadPlatformFile(
          path: '$basePath/$fileName',
          platformFile: _companyRegistrationFile!,
        );
      } catch (e) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload company registration file'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    // Upload vehicle files
    final List<Map<String, dynamic>> vehiclesData = [];
    for (int i = 0; i < _vehicles.length; i++) {
      final v = _vehicles[i];
      String? registrationUrl;
      String? revenueLicenceUrl;
      String? fitnessUrl;
      String? insuranceUrl;

      if (v.registrationFile != null) {
        try {
          final fileName = 'vehicle_${i}_registration_${v.registrationFile!.name}';
          registrationUrl = await _storageService.uploadPlatformFile(
            path: '$basePath/$fileName',
            platformFile: v.registrationFile!,
          );
        } catch (e) {
          if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload registration file for vehicle ${i + 1}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      if (v.revenueLicenceFile != null) {
        try {
          final fileName = 'vehicle_${i}_revenue_licence_${v.revenueLicenceFile!.name}';
          revenueLicenceUrl = await _storageService.uploadPlatformFile(
            path: '$basePath/$fileName',
            platformFile: v.revenueLicenceFile!,
          );
        } catch (e) {
          if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload revenue licence file for vehicle ${i + 1}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      if (v.fitnessCertificateFile != null) {
        try {
          final fileName = 'vehicle_${i}_fitness_${v.fitnessCertificateFile!.name}';
          fitnessUrl = await _storageService.uploadPlatformFile(
            path: '$basePath/$fileName',
            platformFile: v.fitnessCertificateFile!,
          );
        } catch (e) {
          if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload fitness certificate file for vehicle ${i + 1}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      if (v.insuranceDocumentFile != null) {
        try {
          final fileName = 'vehicle_${i}_insurance_${v.insuranceDocumentFile!.name}';
          insuranceUrl = await _storageService.uploadPlatformFile(
            path: '$basePath/$fileName',
            platformFile: v.insuranceDocumentFile!,
          );
        } catch (e) {
          if (!silent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload insurance file for vehicle ${i + 1}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      vehiclesData.add({
        'vehiclePlate': v.plateController.text,
        'vehicleType': v.type,
        'vehicleYear': v.yearController.text,
        'vehicleMake': v.make,
        'vehicleBodyType': v.bodyTypeController.text,
        'vehicleChassis': v.chassisController.text,
        'vehicleAxles': v.axlesController.text,
        'vehicleMtc': v.mtcController.text,
        'vehicleNwc': v.nwcController.text,
        'vehicleTare': v.tareController.text,
        'vehicleRegistrationFileName': v.registrationFile?.name,
        'vehicleRegistrationFileUrl': registrationUrl,
        'revenueLicenceFileName': v.revenueLicenceFile?.name,
        'revenueLicenceFileUrl': revenueLicenceUrl,
        'fitnessCertificateFileName': v.fitnessCertificateFile?.name,
        'fitnessCertificateFileUrl': fitnessUrl,
        'thirdPartyInsuranceFileName': v.insuranceDocumentFile?.name,
        'thirdPartyInsuranceFileUrl': insuranceUrl,
      });
    }

    // Collect all form data with file URLs
    final applicationData = {
      'formType': AppConstants.appTypeBusiness,
      'applicantName': _representatives.isNotEmpty && _representatives[0].nameController.text.isNotEmpty 
          ? _representatives[0].nameController.text 
          : user.displayName ?? user.email ?? 'Unknown',
      'nationality': null, // Not in current form
      'purpose': null, // Could be added later
      
      // Representative information with file URLs
      'representatives': representativesData,
      
      // Organization information with file URL
      'organization': {
        'firmName': _firmNameController.text,
        'firmAddress': _firmAddressController.text,
        'legalRepresentative': _legalRepresentativeController.text,
        'tin': _tinController.text,
        'companyRegistrationNumber': _companyRegController.text,
        'telephone': _telephoneController.text,
        'fax': _faxController.text,
        'companyRegistrationFileName': _companyRegistrationFile?.name,
        'companyRegistrationFileUrl': companyRegFileUrl,
      },
      
      // Transportation information with file URLs
      'transportation': {
        'natureOfTransport': _natureOfTransport,
        'modalityOfTraffic': _modalityOfTraffic,
        'origin': _origin,
        'destination': _destination,
        'vehicles': vehiclesData,
      },
      
      // Metadata
      'currentStep': _currentStep,
      'declarationAgreed': _declarationAgreed,
      'savedAt': DateTime.now().toIso8601String(),
    };

    try {
      if (_draftId != null) {
        // Update existing draft - wrap in applicationData field
        final updates = {
          'applicationData': applicationData,
          'applicantName': applicationData['applicantName'],
        };
        final success = await appProvider.updateApplication(_draftId!, updates);
        
        if (success && mounted) {
          if (!silent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Draft updated successfully!'),
                backgroundColor: AppColors.statusCompleted,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return true;
        } else if (mounted) {
          throw Exception('Failed to update draft');
        }
      } else {
        // Create new draft
        final applicationId = await appProvider.createApplication(
          userId: user.uid,
          applicationData: applicationData,
        );

        if (applicationId != null && mounted) {
          setState(() {
            _draftId = applicationId;
          });
          
          if (!silent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Draft saved successfully!'),
                backgroundColor: AppColors.statusCompleted,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return true;
        } else if (mounted) {
          throw Exception('Failed to create draft');
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
    return false;
  }

  Future<void> _submitApplication(BuildContext context, AuthProvider authProvider, ApplicationProvider appProvider) async {
    if (_formKey.currentState!.validate() && _declarationAgreed) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Save draft first (silently)
        final success = await _saveDraft(context, authProvider, appProvider, silent: true);
        
        if (success && _draftId != null && mounted) {
          // Submit application
          final submitted = await appProvider.submitApplication(_draftId!);
          
          // Close loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }
          
          if (submitted && mounted) {
            // Reload user applications to ensure the submitted application appears
            final user = authProvider.user;
            if (user != null) {
              appProvider.loadUserApplications(user.uid, forceRefresh: true);
            }

            // Show success dialog
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.statusCompleted, size: 32),
                    SizedBox(width: 12),
                    Expanded(child: Text('Application Submitted!')),
                  ],
                ),
                content: const Text(
                  'Your application has been submitted successfully. You can view it in "My Applications".',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to application detail page
                      context.go('${AppConstants.routeApplications}/${_draftId}');
                    },
                    child: const Text('View Application'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to dashboard
                      context.go(AppConstants.routeDashboard);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to submit application. Please try again.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else if (mounted) {
          // Close loading dialog if still open
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save application. Please try again.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting application: ${e.toString()}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else if (!_declarationAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the declarations'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _representatives[index].dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 21)),
    );
    if (picked != null && picked != _representatives[index].dob) {
      setState(() {
        _representatives[index].dob = picked;
      });
    }
  }

  Future<void> _pickPublicProxyInstrument(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        // Validate file size
        if (file.size > 0) {
          final fileSizeMB = file.size / (1024 * 1024);
          if (fileSizeMB > 10.0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File size must be less than 10MB'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
        }

        setState(() {
          _representatives[index].publicProxyInstrumentFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickCompanyRegistrationFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        // Validate file size
        if (file.size > 0) {
          final fileSizeMB = file.size / (1024 * 1024);
          if (fileSizeMB > 10.0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File size must be less than 10MB'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
        }

        setState(() {
          _companyRegistrationFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickVehicleRegistrationFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.size > 0 && (file.size / (1024 * 1024)) > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        setState(() {
          _vehicles[index].registrationFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickRevenueLicenceFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.size > 0 && (file.size / (1024 * 1024)) > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        setState(() {
          _vehicles[index].revenueLicenceFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickFitnessCertificateFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.size > 0 && (file.size / (1024 * 1024)) > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        setState(() {
          _vehicles[index].fitnessCertificateFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickInsuranceDocumentFile(int index) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.size > 0 && (file.size / (1024 * 1024)) > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        setState(() {
          _vehicles[index].insuranceDocumentFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppConstants.routeLogin);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.user;
        final userName = user?.displayName ?? 'User';
        final userEmail = user?.email ?? '';
        final userRole = authProvider.userRole;

        // For applicants, check if they already have an application
        if (userRole == AppConstants.roleApplicant && user != null) {
          return Consumer<ApplicationProvider>(
            builder: (context, appProvider, _) {
              // If editing an existing application, skip the check
              if (widget.editApplicationId != null) {
                return _buildNewApplicationForm(context, authProvider, user, userName, userEmail, userRole);
              }

              // Load applications to check if user already has one
              if (appProvider.applications.isEmpty && !appProvider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  appProvider.loadUserApplications(user.uid);
                });
              }

              // If user already has an active application (not draft, not rejected), redirect to dashboard
              // Allow new application if all existing applications are rejected or draft
              final hasActiveApp = appProvider.applications.any(
                (app) => app.status != AppConstants.statusDraft && app.status != AppConstants.statusRejected
              );
              
              if (!appProvider.isLoading && hasActiveApp) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have an active application. Please manage your existing application or wait for it to be processed.'),
                        backgroundColor: AppColors.error,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    context.go(AppConstants.routeDashboard);
                  }
                });
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Show loading while checking
              if (appProvider.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Continue with normal new application form (or editing draft)
              return _buildNewApplicationForm(context, authProvider, user, userName, userEmail, userRole);
            },
          );
        }

        // For non-applicants (admin/officer), allow multiple applications
        return _buildNewApplicationForm(context, authProvider, user, userName, userEmail, userRole);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Check for existing draft
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForDraft();
    });
  }

  Future<void> _checkForDraft() async {
    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<ApplicationProvider>();
    final user = authProvider.user;

    if (user != null) {
      // If editing a specific application, load that one
      if (widget.editApplicationId != null) {
        final application = await appProvider.getApplicationById(widget.editApplicationId!);
        if (application != null && mounted) {
          // Check if it's a draft and belongs to the user
          if (application.status == AppConstants.statusDraft && application.userId == user.uid) {
            _populateFormFromDraft(application);
          } else {
            // Not a draft or doesn't belong to user - redirect
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    application.status != AppConstants.statusDraft
                        ? 'This application cannot be edited. Only draft applications can be edited.'
                        : 'You can only edit your own applications.'
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 3),
                ),
              );
              context.go(AppConstants.routeDashboard);
            }
          }
        }
      } else {
        // Otherwise, check for latest draft
        final draft = await appProvider.getLatestDraft(user.uid);
        if (draft != null && mounted) {
          _populateFormFromDraft(draft);
        }
      }
    }
  }

  void _populateFormFromDraft(ApplicationModel draft) {
    setState(() {
      _draftId = draft.id;
      final data = draft.applicationData ?? {};
      
      _currentStep = data['currentStep'] ?? 0;
      _declarationAgreed = data['declarationAgreed'] ?? false;
      
      // Organization Info
      final org = data['organization'] ?? {};
      _firmNameController.text = org['firmName'] ?? '';
      _firmAddressController.text = org['firmAddress'] ?? '';
      _legalRepresentativeController.text = org['legalRepresentative'] ?? '';
      _tinController.text = org['tin'] ?? '';
      _companyRegController.text = org['companyRegistrationNumber'] ?? '';
      _telephoneController.text = org['telephone'] ?? '';
      _faxController.text = org['fax'] ?? '';
      
      // Transportation Info
      final trans = data['transportation'] ?? {};
      _natureOfTransport = trans['natureOfTransport'] ?? '';
      _modalityOfTraffic = trans['modalityOfTraffic'] ?? '';
      _origin = trans['origin'] ?? '';
      _destination = trans['destination'] ?? '';
      
      // Representatives
      final reps = data['representatives'] as List?;
      if (reps != null && reps.isNotEmpty) {
        // Clear existing and rebuild
        for (var r in _representatives) r.dispose();
        _representatives.clear();
        
        for (var repData in reps) {
          final rep = RepresentativeData();
          rep.nameController.text = repData['name'] ?? '';
          rep.emailController.text = repData['email'] ?? '';
          rep.phoneController.text = repData['phone'] ?? '';
          rep.idController.text = repData['idNumber'] ?? '';
          rep.addressController.text = repData['address'] ?? '';
          if (repData['dateOfBirth'] != null) {
            rep.dob = DateTime.tryParse(repData['dateOfBirth']);
          }
          _representatives.add(rep);
        }
      }
      
      // Vehicles
      final vehicles = trans['vehicles'] as List?;
      if (vehicles != null && vehicles.isNotEmpty) {
        // Clear existing and rebuild
        for (var v in _vehicles) v.dispose();
        _vehicles.clear();
        
        for (var vData in vehicles) {
          final v = VehicleData();
          v.plateController.text = vData['vehiclePlate'] ?? '';
          v.type = vData['vehicleType'];
          v.yearController.text = vData['vehicleYear'] ?? '';
          v.make = vData['vehicleMake'];
          v.bodyTypeController.text = vData['vehicleBodyType'] ?? '';
          v.chassisController.text = vData['vehicleChassis'] ?? '';
          v.axlesController.text = vData['vehicleAxles'] ?? '';
          v.mtcController.text = vData['vehicleMtc'] ?? '';
          v.nwcController.text = vData['vehicleNwc'] ?? '';
          v.tareController.text = vData['vehicleTare'] ?? '';
          _vehicles.add(v);
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resumed existing draft'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildNewApplicationForm(BuildContext context, AuthProvider authProvider, user, String userName, String userEmail, String userRole) {

    // Pre-fill representative info from user profile
    if (_representatives.isNotEmpty) {
      if (_representatives[0].nameController.text.isEmpty && userName != 'User') {
        _representatives[0].nameController.text = userName;
      }
      if (_representatives[0].emailController.text.isEmpty && userEmail.isNotEmpty) {
        _representatives[0].emailController.text = userEmail;
      }
    }

    return MainLayout(
          currentRoute: AppConstants.routeNewApplication,
          onNavigate: (route) => context.go(route),
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
          onLogout: () async {
            await authProvider.signOut();
            if (context.mounted) {
              context.go(AppConstants.routeLanding);
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                AppHeader(
                  title: 'New IRTA Application',
                  actions: [
                    Consumer<ApplicationProvider>(
                      builder: (context, appProvider, _) {
                        return TextButton(
                          onPressed: appProvider.isLoading 
                              ? null 
                              : () => _saveDraft(context, authProvider, appProvider),
                          child: appProvider.isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save Draft'),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        context.go(AppConstants.routeDashboard);
                      },
                      child: const Text('Exit'),
                    ),
                  ],
                ),

                // Wizard Progress
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: List.generate(5, (index) {
                      final isActive = index == _currentStep;
                      final isCompleted = index < _currentStep;
                      final stepLabels = [
                        'Introduction',
                        'Representative',
                        'Organization',
                        'Transportation',
                        'Declarations',
                      ];

                      return Expanded(
                        child: GestureDetector(
                          // Disable tapping step headers to avoid accidental jumps that feel like "going back"
                          onTap: null,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isActive || isCompleted
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive || isCompleted
                                          ? Colors.white
                                          : AppColors.textTertiary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stepLabels[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Form Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIntroductionStep(),
                      _buildRepresentativeStep(),
                      _buildOrganizationStep(),
                      _buildTransportationStep(),
                      _buildDeclarationsStep(),
                    ],
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: _previousStep,
                          child: const Text('Previous'),
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: _currentStep < 4
                            ? [
                                Consumer<ApplicationProvider>(
                                  builder: (context, appProvider, _) {
                                    return TextButton(
                                      onPressed: appProvider.isLoading 
                                          ? null 
                                          : () => _saveDraft(context, authProvider, appProvider),
                                      child: appProvider.isLoading 
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text('Save Draft'),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _nextStep,
                                  child: const Text('Next'),
                                ),
                              ]
                            : [
                                Consumer<ApplicationProvider>(
                                  builder: (context, appProvider, _) {
                                    return ElevatedButton(
                                      onPressed: appProvider.isLoading
                                          ? null
                                          : () => _submitApplication(context, authProvider, appProvider),
                                      child: appProvider.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Submit Application'),
                                    );
                                  },
                                ),
                              ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildIntroductionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IRTA Document of Competence',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to the official application portal for the International Road Transport Agreement (IRTA) between the Cooperative Republic of Guyana and the Federative Republic of Brazil.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This application is for firms seeking a Document of Competence to operate international road transport services between Guyana and Brazil. The process involves several steps:',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Representative Information: Details of the firm\'s legal representative.'),
                        SizedBox(height: 8),
                        Text('• Organization Details: Information about your firm and its legal status.'),
                        SizedBox(height: 8),
                        Text('• Transportation Details: Nature of transport and vehicle information.'),
                        SizedBox(height: 8),
                        Text('• Declarations: Final review and legal declarations.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: const Border(
                        left: BorderSide(color: AppColors.primary, width: 4),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please ensure you have all required documents (Registration, Insurance, Fitness, etc.) in digital format (PDF or Image) before starting.',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                const SizedBox(height: 20),
                // New Requirements (as requested)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Representatives:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1) Owner ID card or Passport'),
                            SizedBox(height: 6),
                            Text('2) Primary representative ID/Passport and Legal Representative (notarised via Power of Attorney)'),
                            SizedBox(height: 6),
                            Text('3) Secondary representative ID/Passport and Legal Representative (notarised via Power of Attorney)'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Organization:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1) Business Registration or Certificate of Incorporation'),
                            SizedBox(height: 6),
                            Text('2) GRA Compliance'),
                            SizedBox(height: 6),
                            Text('3) NIS Compliance'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Transportation (for each vehicle):',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1) Registration of Vehicle'),
                            SizedBox(height: 6),
                            Text('2) Revenue Licence'),
                            SizedBox(height: 6),
                            Text('3) Certificate of Fitness'),
                            SizedBox(height: 6),
                            Text('4) Third-party Insurance (death, personal injuries and material damages of third person(s) not transported and of passengers)'),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Note: Country of Origin selection (Guyana or Brazil) is available under Transportation → Origin.',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepresentativeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Representative Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide details of the firm\'s legal representative.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 32),
            
            ..._representatives.asMap().entries.map((entry) {
              final index = entry.key;
              final rep = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Representative ${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (_representatives.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {
                              setState(() {
                                rep.dispose();
                                _representatives.removeAt(index);
                              });
                            },
                            tooltip: 'Remove Representative',
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 2.5,
                      children: [
                        TextFormField(
                          controller: rep.nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'Enter representative name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter full name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: rep.emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address *',
                            hintText: 'representative@example.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email address';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: rep.phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: 'e.g., +592-226-2444',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: rep.idController,
                          decoration: const InputDecoration(
                            labelText: 'National ID / Passport',
                            hintText: 'Enter ID or passport number',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, index),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth *',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                rep.dob != null
                                    ? '${rep.dob!.day}/${rep.dob!.month}/${rep.dob!.year}'
                                    : 'Select date',
                                style: TextStyle(
                                  color: rep.dob != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 12),
                      child: Text(
                        'Must be 21 years or older',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: rep.addressController,
                      decoration: const InputDecoration(
                        labelText: 'Residential Address *',
                        hintText: 'Enter residential address',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter residential address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Public Proxy Instrument',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: rep.isUploadingFile ? null : () => _pickPublicProxyInstrument(index),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(
                                color: rep.publicProxyInstrumentFile != null
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                if (rep.isUploadingFile)
                                  const Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 12),
                                      Text(
                                        'Uploading...',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (rep.publicProxyInstrumentFile != null)
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        rep.publicProxyInstrumentFile!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (rep.publicProxyInstrumentFile!.size > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '${(rep.publicProxyInstrumentFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            rep.publicProxyInstrumentFile = null;
                                          });
                                        },
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        label: const Text('Remove'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.cloud_upload,
                                        size: 48,
                                        color: AppColors.textTertiary,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Click to upload or drag and drop',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'PDF or Image (Max 10MB)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            'Upload Public Proxy Instrument granting legal Representative in Brazil full powers (English & Portuguese)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _representatives.add(RepresentativeData());
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Another Representative',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Organization Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide information about your firm and its legal status.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.5,
                    children: [
                      TextFormField(
                        controller: _firmNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name of Firm *',
                          hintText: 'Enter firm name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter firm name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _firmAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Legal Address of Firm *',
                          hintText: 'Enter legal address',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter legal address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _legalRepresentativeController,
                        decoration: const InputDecoration(
                          labelText: 'Legal Representative in Country of Origin *',
                          hintText: 'Enter representative name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter legal representative';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _tinController,
                        decoration: const InputDecoration(
                          labelText: 'Tax Identification Number (TIN)',
                          hintText: 'Enter TIN',
                        ),
                      ),
                      TextFormField(
                        controller: _companyRegController,
                        decoration: const InputDecoration(
                          labelText: 'Company Registration Number',
                          hintText: 'Enter registration number',
                        ),
                      ),
                      TextFormField(
                        controller: _telephoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telephone Number',
                          hintText: 'e.g., 226-2444',
                          prefixText: '+592 ',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: _faxController,
                        decoration: const InputDecoration(
                          labelText: 'Fax Number',
                          hintText: 'e.g., 226-2740',
                          prefixText: '+592 ',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Registration Certificate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isUploadingCompanyFile ? null : _pickCompanyRegistrationFile,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            border: Border.all(
                              color: _companyRegistrationFile != null
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              if (_isUploadingCompanyFile)
                                const Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 12),
                                    Text(
                                      'Uploading...',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              else if (_companyRegistrationFile != null)
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _companyRegistrationFile!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_companyRegistrationFile!.size > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${(_companyRegistrationFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _companyRegistrationFile = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      label: const Text('Remove'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    const Icon(Icons.cloud_upload, size: 48, color: AppColors.textTertiary),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Click to upload or drag and drop',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'PDF or Image (Max 10MB)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'Upload Company Registration Certificate (Required)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transportation Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Specify your transport operations, routes, and vehicle information.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nature of Transport *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Goods (Cargo)'),
                          value: 'Goods',
                          groupValue: _natureOfTransport,
                          onChanged: (value) {
                            setState(() {
                              _natureOfTransport = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Passenger'),
                          value: 'Passenger',
                          groupValue: _natureOfTransport,
                          onChanged: (value) {
                            setState(() {
                              _natureOfTransport = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Both Goods and Passenger'),
                          value: 'Both',
                          groupValue: _natureOfTransport,
                          onChanged: (value) {
                            setState(() {
                              _natureOfTransport = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Modality of Traffic *',
                      hintText: 'Select modality',
                    ),
                    value: _modalityOfTraffic.isEmpty ? null : _modalityOfTraffic,
                    items: const [
                      DropdownMenuItem(
                        value: 'Bilateral with traffic through common border',
                        child: Text('Bilateral with traffic through common border'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _modalityOfTraffic = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select modality';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Origin *',
                            hintText: 'Select origin',
                          ),
                          value: _origin.isEmpty ? null : _origin,
                          items: const [
                            DropdownMenuItem(
                              value: 'Cooperative Republic of Guyana',
                              child: Text('Cooperative Republic of Guyana'),
                            ),
                            DropdownMenuItem(
                              value: 'Federative Republic of Brazil',
                              child: Text('Federative Republic of Brazil'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _origin = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select origin';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Destination *',
                            hintText: 'Select destination',
                          ),
                          value: _destination.isEmpty ? null : _destination,
                          items: const [
                            DropdownMenuItem(
                              value: 'Cooperative Republic of Guyana',
                              child: Text('Cooperative Republic of Guyana'),
                            ),
                            DropdownMenuItem(
                              value: 'Federative Republic of Brazil',
                              child: Text('Federative Republic of Brazil'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _destination = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select destination';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add vehicles authorized for international road transport.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._vehicles.asMap().entries.map((entry) {
              final index = entry.key;
              final vehicle = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vehicle ${index + 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_vehicles.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {
                              setState(() {
                                vehicle.dispose();
                                _vehicles.removeAt(index);
                              });
                            },
                            tooltip: 'Remove Vehicle',
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 2.5,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Vehicle Type *'),
                          value: vehicle.type,
                          items: ['Bus', 'Truck', 'Van', 'Other']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => vehicle.type = v),
                        ),
                        TextFormField(
                          controller: vehicle.yearController,
                          decoration: const InputDecoration(labelText: 'Year', hintText: 'e.g., 2020'),
                          keyboardType: TextInputType.number,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Make'),
                          value: vehicle.make,
                          items: ['VW', 'Mercedes', 'Toyota', 'Ford', 'Other']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => vehicle.make = v),
                        ),
                        TextFormField(
                          controller: vehicle.bodyTypeController,
                          decoration: const InputDecoration(labelText: 'Body Type', hintText: 'e.g., Flatbed'),
                        ),
                        TextFormField(
                          controller: vehicle.chassisController,
                          decoration: const InputDecoration(labelText: 'Chassis Number'),
                        ),
                        TextFormField(
                          controller: vehicle.axlesController,
                          decoration: const InputDecoration(labelText: 'Axles / Eixos'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: vehicle.mtcController,
                          decoration: const InputDecoration(
                            labelText: 'MTC (Maximum Total Capacity) / CMT',
                            hintText: 'MTC in tons',
                          ),
                        ),
                        TextFormField(
                          controller: vehicle.nwcController,
                          decoration: const InputDecoration(
                            labelText: 'NWC (Net Weight Capacity) / CCU',
                            hintText: 'NWC in tons',
                          ),
                        ),
                        TextFormField(
                          controller: vehicle.tareController,
                          decoration: const InputDecoration(
                            labelText: 'Tare Weight / TARA',
                            hintText: 'Tare in tons',
                          ),
                        ),
                        TextFormField(
                          controller: vehicle.plateController,
                          decoration: const InputDecoration(labelText: 'Plate Number / Placa *'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Vehicle Documents',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    _buildFileUploader(
                      label: '1. Vehicle Registration Certificate *',
                      file: vehicle.registrationFile,
                      onTap: () => _pickVehicleRegistrationFile(index),
                      isUploading: vehicle.isUploadingRegistration,
                      onClear: () => setState(() => vehicle.registrationFile = null),
                    ),
                    const SizedBox(height: 12),
                    _buildFileUploader(
                      label: '2. Revenue Licence *',
                      file: vehicle.revenueLicenceFile,
                      onTap: () => _pickRevenueLicenceFile(index),
                      isUploading: vehicle.isUploadingLicence,
                      onClear: () => setState(() => vehicle.revenueLicenceFile = null),
                    ),
                    const SizedBox(height: 12),
                    _buildFileUploader(
                      label: '3. Certificate of Fitness *',
                      file: vehicle.fitnessCertificateFile,
                      onTap: () => _pickFitnessCertificateFile(index),
                      isUploading: vehicle.isUploadingFitness,
                      onClear: () => setState(() => vehicle.fitnessCertificateFile = null),
                    ),
                    const SizedBox(height: 12),
                    _buildFileUploader(
                      label: '4. Third Party Insurance *',
                      file: vehicle.insuranceDocumentFile,
                      onTap: () => _pickInsuranceDocumentFile(index),
                      isUploading: vehicle.isUploadingInsurance,
                      onClear: () => setState(() => vehicle.insuranceDocumentFile = null),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _vehicles.add(VehicleData());
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Another Vehicle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploader({
    required String label,
    required PlatformFile? file,
    required VoidCallback onTap,
    required bool isUploading,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isUploading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                color: file != null ? AppColors.primary : AppColors.border,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: file != null ? AppColors.primary : AppColors.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isUploading)
                        const LinearProgressIndicator()
                      else if (file != null)
                        Text(file.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
                      else
                        const Text('Click to upload document',
                            style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
                      if (file != null)
                        Text('${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                if (file != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeclarationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Declarations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please review all information and confirm your declarations.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Application Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryRow('Representative Name', _representatives.isNotEmpty ? _representatives[0].nameController.text : ''),
                  _buildSummaryRow('Firm Name', _firmNameController.text),
                  _buildSummaryRow('Nature of Transport', _natureOfTransport.isEmpty ? 'Not selected' : _natureOfTransport),
                  _buildSummaryRow('Origin', _origin.isEmpty ? 'Not selected' : _origin),
                  _buildSummaryRow('Destination', _destination.isEmpty ? 'Not selected' : _destination),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Legal Declarations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      'I declare that all information provided is true and accurate to the best of my knowledge.',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _declarationAgreed,
                    onChanged: (value) {
                      setState(() {
                        _declarationAgreed = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text(
                      'I understand that providing false information may result in rejection of my application.',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _declarationAgreed,
                    onChanged: (value) {
                      setState(() {
                        _declarationAgreed = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (!_declarationAgreed && _currentStep == 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        'Please agree to the declarations to submit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
