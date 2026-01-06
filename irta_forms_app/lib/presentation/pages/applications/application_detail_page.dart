import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../../data/models/application_model.dart';
import 'package:intl/intl.dart';

class ApplicationDetailPage extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailPage({
    super.key,
    required this.applicationId,
  });

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  ApplicationModel? _application;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appProvider = context.read<ApplicationProvider>();
      final application = await appProvider.getApplicationById(widget.applicationId);
      
      if (mounted) {
        setState(() {
          _application = application;
          _isLoading = false;
          if (application == null) {
            _errorMessage = 'Application not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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

        return MainLayout(
          currentRoute: AppConstants.routeDashboard,
          onNavigate: (route) {
            context.go(route);
          },
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
          onLogout: () async {
            await authProvider.signOut();
            if (context.mounted) {
              context.go(AppConstants.routeLanding);
            }
          },
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go(AppConstants.routeDashboard);
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    }

    if (_application == null) {
      return const Center(child: Text('Application not found'));
    }

    final app = _application!;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Column(
      children: [
        // Header
        AppHeader(
          title: 'Application Details',
          actions: [
            TextButton.icon(
              onPressed: () {
                context.go(AppConstants.routeDashboard);
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Dashboard'),
            ),
          ],
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Application Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.irtaRef,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              app.formType,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: app.status),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Application Information
                _buildSection(
                  title: 'Application Information',
                  children: [
                    _buildInfoRow('Reference Number', app.irtaRef),
                    _buildInfoRow('Form Type', app.formType),
                    _buildInfoRow('Status', app.status),
                    _buildInfoRow('Applicant Name', app.applicantName),
                    if (app.nationality != null)
                      _buildInfoRow('Nationality', app.nationality!),
                    if (app.purpose != null)
                      _buildInfoRow('Purpose', app.purpose!),
                    _buildInfoRow('Submission Date', dateFormat.format(app.submissionDate)),
                    if (app.assignedOfficer != null)
                      _buildInfoRow('Assigned Officer', app.assignedOfficer!),
                  ],
                ),

                // Detailed Application Data
                if (app.applicationData != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedData(app.applicationData!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedData(Map<String, dynamic> data) {
    final List<Widget> sections = [];

    // Representatives
    if (data['representatives'] != null) {
      final representatives = data['representatives'] as List;
      sections.add(
        _buildSection(
          title: 'Representatives',
          children: representatives.asMap().entries.map((entry) {
            final index = entry.key;
            final rep = entry.value as Map<String, dynamic>;
            final List<Widget> repChildren = [
              if (rep['name'] != null) _buildInfoRow('Name', rep['name']),
              if (rep['email'] != null) _buildInfoRow('Email', rep['email']),
              if (rep['phone'] != null) _buildInfoRow('Phone', rep['phone']),
              if (rep['idNumber'] != null) _buildInfoRow('ID Number', rep['idNumber']),
              if (rep['address'] != null) _buildInfoRow('Address', rep['address']),
              if (rep['dateOfBirth'] != null)
                _buildInfoRow(
                  'Date of Birth',
                  DateFormat('yyyy-MM-dd').format(DateTime.parse(rep['dateOfBirth'])),
                ),
            ];
            
            return _buildSubSection(
              'Representative ${index + 1}',
              repChildren,
            );
          }).toList(),
        ),
      );
    }

    // Organization
    if (data['organization'] != null) {
      final org = data['organization'] as Map<String, dynamic>;
      sections.add(
        _buildSection(
          title: 'Organization Information',
          children: [
            if (org['firmName'] != null) _buildInfoRow('Firm Name', org['firmName']),
            if (org['firmAddress'] != null) _buildInfoRow('Firm Address', org['firmAddress']),
            if (org['legalRepresentative'] != null)
              _buildInfoRow('Legal Representative', org['legalRepresentative']),
            if (org['tin'] != null) _buildInfoRow('TIN', org['tin']),
            if (org['companyRegistrationNumber'] != null)
              _buildInfoRow('Company Registration Number', org['companyRegistrationNumber']),
            if (org['telephone'] != null) _buildInfoRow('Telephone', org['telephone']),
            if (org['fax'] != null) _buildInfoRow('Fax', org['fax']),
          ],
        ),
      );
    }

    // Transportation
    if (data['transportation'] != null) {
      final transport = data['transportation'] as Map<String, dynamic>;
      final List<Widget> transportChildren = [
        if (transport['natureOfTransport'] != null)
          _buildInfoRow('Nature of Transport', transport['natureOfTransport']),
        if (transport['origin'] != null) _buildInfoRow('Origin', transport['origin']),
        if (transport['destination'] != null)
          _buildInfoRow('Destination', transport['destination']),
        if (transport['route'] != null) _buildInfoRow('Route', transport['route']),
      ];
      
      // Add vehicles if they exist
      if (transport['vehicles'] != null) {
        final vehicles = transport['vehicles'] as List;
        final vehicleWidgets = vehicles.asMap().entries.map((entry) {
          final index = entry.key;
          final vehicle = entry.value as Map<String, dynamic>;
          return _buildSubSection(
            'Vehicle ${index + 1}',
            [
              if (vehicle['vehiclePlate'] != null)
                _buildInfoRow('Plate Number', vehicle['vehiclePlate']),
              if (vehicle['vehicleMake'] != null) _buildInfoRow('Make', vehicle['vehicleMake']),
              if (vehicle['vehicleType'] != null) _buildInfoRow('Type', vehicle['vehicleType']),
              if (vehicle['vehicleYear'] != null) _buildInfoRow('Year', vehicle['vehicleYear']),
              if (vehicle['vehicleBodyType'] != null) _buildInfoRow('Body Type', vehicle['vehicleBodyType']),
            ],
          );
        }).toList();
        transportChildren.addAll(vehicleWidgets);
      }
      
      sections.add(
        _buildSection(
          title: 'Transportation Information',
          children: transportChildren,
        ),
      );
    }

    return Column(children: sections);
  }

  Widget _buildSubSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

