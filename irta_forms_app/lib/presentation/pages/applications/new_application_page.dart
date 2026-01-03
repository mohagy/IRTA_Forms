import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../../services/storage_service.dart';
import 'package:file_picker/file_picker.dart';

class NewApplicationPage extends StatefulWidget {
  const NewApplicationPage({super.key});

  @override
  State<NewApplicationPage> createState() => _NewApplicationPageState();
}

class _NewApplicationPageState extends State<NewApplicationPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  // Form controllers and state
  final _formKey = GlobalKey<FormState>();
  
  // Representative fields
  final _representativeNameController = TextEditingController();
  final _representativeEmailController = TextEditingController();
  final _representativePhoneController = TextEditingController();
  final _representativeIdController = TextEditingController();
  final _representativeAddressController = TextEditingController();
  DateTime? _representativeDob;
  PlatformFile? _publicProxyInstrumentFile;
  bool _isUploadingFile = false;
  
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
  final _vehiclePlateController = TextEditingController();
  
  // Declarations
  bool _declarationAgreed = false;

  @override
  void dispose() {
    _pageController.dispose();
    _representativeNameController.dispose();
    _representativeEmailController.dispose();
    _representativePhoneController.dispose();
    _representativeIdController.dispose();
    _representativeAddressController.dispose();
    _firmNameController.dispose();
    _firmAddressController.dispose();
    _legalRepresentativeController.dispose();
    _tinController.dispose();
    _companyRegController.dispose();
    _telephoneController.dispose();
    _faxController.dispose();
    _vehiclePlateController.dispose();
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
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step <= 4) {
      setState(() {
        _currentStep = step;
      });
      _pageController.jumpToPage(step);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _representativeDob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 21)),
    );
    if (picked != null && picked != _representativeDob) {
      setState(() {
        _representativeDob = picked;
      });
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

        // Pre-fill representative info from user profile
        if (_representativeNameController.text.isEmpty && userName != 'User') {
          _representativeNameController.text = userName;
        }
        if (_representativeEmailController.text.isEmpty && userEmail.isNotEmpty) {
          _representativeEmailController.text = userEmail;
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
                    TextButton(
                      onPressed: () {
                        // Save draft functionality
                      },
                      child: const Text('Save Draft'),
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
                          onTap: () => _goToStep(index),
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
                        children: [
                          if (_currentStep < 4) ...[
                            TextButton(
                              onPressed: () {
                                // Save draft
                              },
                              child: const Text('Save Draft'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _nextStep,
                              child: const Text('Next'),
                            ),
                          ] else
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate() && _declarationAgreed) {
                                  // Submit application
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Application submitted successfully!'),
                                    ),
                                  );
                                  context.go(AppConstants.routeDashboard);
                                } else if (!_declarationAgreed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please agree to the declarations'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Submit Application'),
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
      },
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
                      border: Border(
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Primary Representative',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
                        controller: _representativeNameController,
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
                        controller: _representativeEmailController,
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
                        controller: _representativePhoneController,
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
                        controller: _representativeIdController,
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
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date of Birth *',
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _representativeDob != null
                                  ? '${_representativeDob!.day}/${_representativeDob!.month}/${_representativeDob!.year}'
                                  : 'Select date',
                              style: TextStyle(
                                color: _representativeDob != null
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
                    controller: _representativeAddressController,
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
                        onTap: _isUploadingFile ? null : _pickPublicProxyInstrument,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            border: Border.all(
                              color: _publicProxyInstrumentFile != null
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              if (_isUploadingFile)
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
                              else if (_publicProxyInstrumentFile != null)
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _publicProxyInstrumentFile!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_publicProxyInstrumentFile!.size > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${(_publicProxyInstrumentFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
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
                                          _publicProxyInstrumentFile = null;
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
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement add another representative functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adding multiple representatives will be available soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Another Representative'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
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
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // File upload functionality
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Company Registration Certificate *'),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Vehicle Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _vehiclePlateController,
                          decoration: const InputDecoration(
                            labelText: 'Plate Number / Placa *',
                            hintText: 'Enter license plate',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Note: Full vehicle details and document uploads will be implemented in the next phase.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
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
                  _buildSummaryRow('Representative Name', _representativeNameController.text),
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
