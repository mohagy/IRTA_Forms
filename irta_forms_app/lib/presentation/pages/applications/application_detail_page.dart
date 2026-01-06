import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/user_provider.dart';
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
            // Show Edit button only for Draft applications
            if (app.status == AppConstants.statusDraft)
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.user;
                  final userRole = authProvider.userRole;
                  // Only show edit button for applicants (they can edit their own drafts)
                  if (user != null && userRole == AppConstants.roleApplicant) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to edit page with application ID
                        context.go('${AppConstants.routeNewApplication}?edit=${app.id}');
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Application'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            const SizedBox(width: 12),
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

                // Action Panel for Officers/Admins
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final userRole = authProvider.userRole;
                    final isOfficerOrAdmin = userRole == AppConstants.roleAdmin ||
                        userRole == AppConstants.roleOfficer ||
                        userRole == AppConstants.roleReception ||
                        userRole == AppConstants.roleVerification ||
                        userRole == AppConstants.roleIssuing;
                    
                    if (isOfficerOrAdmin && app.status != AppConstants.statusDraft) {
                      return _buildActionPanel(context, app, authProvider);
                    }
                    return const SizedBox.shrink();
                  },
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

                // Documents Section (Files)
                if (app.applicationData != null) ...[
                  const SizedBox(height: 24),
                  _buildDocumentsSection(app.applicationData!),
                ],

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
              if (rep['publicProxyInstrumentFileName'] != null)
                _buildFileRow('Public Proxy Instrument', rep['publicProxyInstrumentFileName'], rep['publicProxyInstrumentFileUrl']),
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
            if (org['companyRegistrationFileName'] != null)
              _buildFileRow('Company Registration Certificate', org['companyRegistrationFileName'], org['companyRegistrationFileUrl']),
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
          final List<Widget> vehicleChildren = [
            if (vehicle['vehiclePlate'] != null)
              _buildInfoRow('Plate Number', vehicle['vehiclePlate']),
            if (vehicle['vehicleMake'] != null) _buildInfoRow('Make', vehicle['vehicleMake']),
            if (vehicle['vehicleType'] != null) _buildInfoRow('Type', vehicle['vehicleType']),
            if (vehicle['vehicleYear'] != null) _buildInfoRow('Year', vehicle['vehicleYear']),
            if (vehicle['vehicleBodyType'] != null) _buildInfoRow('Body Type', vehicle['vehicleBodyType']),
            if (vehicle['vehicleChassis'] != null) _buildInfoRow('Chassis Number', vehicle['vehicleChassis']),
            if (vehicle['vehicleAxles'] != null) _buildInfoRow('Axles', vehicle['vehicleAxles']),
            if (vehicle['vehicleMtc'] != null) _buildInfoRow('MTC', vehicle['vehicleMtc']),
            if (vehicle['vehicleNwc'] != null) _buildInfoRow('NWC', vehicle['vehicleNwc']),
            if (vehicle['vehicleTare'] != null) _buildInfoRow('Tare Weight', vehicle['vehicleTare']),
            if (vehicle['vehicleRegistrationFileName'] != null)
              _buildFileRow('Vehicle Registration', vehicle['vehicleRegistrationFileName'], vehicle['vehicleRegistrationFileUrl']),
            if (vehicle['revenueLicenceFileName'] != null)
              _buildFileRow('Revenue Licence', vehicle['revenueLicenceFileName'], vehicle['revenueLicenceFileUrl']),
            if (vehicle['fitnessCertificateFileName'] != null)
              _buildFileRow('Fitness Certificate', vehicle['fitnessCertificateFileName'], vehicle['fitnessCertificateFileUrl']),
            if (vehicle['thirdPartyInsuranceFileName'] != null)
              _buildFileRow('Third Party Insurance', vehicle['thirdPartyInsuranceFileName'], vehicle['thirdPartyInsuranceFileUrl']),
          ];
          
          return _buildSubSection(
            'Vehicle ${index + 1}',
            vehicleChildren,
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

  Widget _buildDocumentsSection(Map<String, dynamic> data) {
    final List<Map<String, String>> documents = [];

    // Collect representative files
    if (data['representatives'] != null) {
      final representatives = data['representatives'] as List;
      for (int i = 0; i < representatives.length; i++) {
        final rep = representatives[i] as Map<String, dynamic>;
        if (rep['publicProxyInstrumentFileName'] != null) {
          documents.add({
            'category': 'Representative ${i + 1}',
            'type': 'Public Proxy Instrument',
            'fileName': rep['publicProxyInstrumentFileName'],
            'fileUrl': rep['publicProxyInstrumentFileUrl'] ?? '',
          });
        }
      }
    }

    // Collect organization file
    if (data['organization'] != null) {
      final org = data['organization'] as Map<String, dynamic>;
      if (org['companyRegistrationFileName'] != null) {
        documents.add({
          'category': 'Organization',
          'type': 'Company Registration Certificate',
          'fileName': org['companyRegistrationFileName'],
          'fileUrl': org['companyRegistrationFileUrl'] ?? '',
        });
      }
    }

    // Collect vehicle files
    if (data['transportation'] != null) {
      final transport = data['transportation'] as Map<String, dynamic>;
      if (transport['vehicles'] != null) {
        final vehicles = transport['vehicles'] as List;
        for (int i = 0; i < vehicles.length; i++) {
          final vehicle = vehicles[i] as Map<String, dynamic>;
          
          if (vehicle['vehicleRegistrationFileName'] != null) {
            documents.add({
              'category': 'Vehicle ${i + 1}',
              'type': 'Vehicle Registration',
              'fileName': vehicle['vehicleRegistrationFileName'],
              'fileUrl': vehicle['vehicleRegistrationFileUrl'] ?? '',
            });
          }
          if (vehicle['revenueLicenceFileName'] != null) {
            documents.add({
              'category': 'Vehicle ${i + 1}',
              'type': 'Revenue Licence',
              'fileName': vehicle['revenueLicenceFileName'],
              'fileUrl': vehicle['revenueLicenceFileUrl'] ?? '',
            });
          }
          if (vehicle['fitnessCertificateFileName'] != null) {
            documents.add({
              'category': 'Vehicle ${i + 1}',
              'type': 'Fitness Certificate',
              'fileName': vehicle['fitnessCertificateFileName'],
              'fileUrl': vehicle['fitnessCertificateFileUrl'] ?? '',
            });
          }
          if (vehicle['thirdPartyInsuranceFileName'] != null) {
            documents.add({
              'category': 'Vehicle ${i + 1}',
              'type': 'Third Party Insurance',
              'fileName': vehicle['thirdPartyInsuranceFileName'],
              'fileUrl': vehicle['thirdPartyInsuranceFileUrl'] ?? '',
            });
          }
        }
      }
    }

    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: 'Uploaded Documents',
      children: [
        ...documents.map((doc) => _buildDocumentCard(
          category: doc['category']!,
          type: doc['type']!,
          fileName: doc['fileName']!,
          fileUrl: doc['fileUrl']!,
        )),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String category,
    required String type,
    required String fileName,
    required String fileUrl,
  }) {
    final hasUrl = fileUrl.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasUrl ? AppColors.primary.withOpacity(0.1) : AppColors.borderLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasUrl ? Icons.description : Icons.description_outlined,
              color: hasUrl ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $fileName',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (hasUrl)
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              color: AppColors.primary,
              tooltip: 'Download/View',
              onPressed: () async {
                final uri = Uri.parse(fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open file'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Not uploaded',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String fileName, String? fileUrl) {
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
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (fileUrl != null && fileUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: AppColors.primary,
                    tooltip: 'View/Download',
                    onPressed: () async {
                      final uri = Uri.parse(fileUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to open file'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '(File not uploaded)',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context, ApplicationModel app, AuthProvider authProvider) {
    final userRole = authProvider.userRole;
    final currentStatus = app.status;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Workflow Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Review button - for Reception Staff
              if (userRole == AppConstants.roleReception || userRole == AppConstants.roleAdmin)
                if (currentStatus == AppConstants.statusSubmitted)
                  ElevatedButton.icon(
                    onPressed: () => _reviewApplication(context, app),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),

              // Verify button - for Verification Officers
              if (userRole == AppConstants.roleVerification || userRole == AppConstants.roleAdmin)
                if (currentStatus == AppConstants.statusReceptionReview || currentStatus == AppConstants.statusSubmitted)
                  ElevatedButton.icon(
                    onPressed: () => _verifyApplication(context, app),
                    icon: const Icon(Icons.verified, size: 18),
                    label: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusCompleted,
                      foregroundColor: Colors.white,
                    ),
                  ),

              // Approve button - for Issuing Officers and Admins
              if (userRole == AppConstants.roleIssuing || userRole == AppConstants.roleAdmin)
                if (currentStatus == AppConstants.statusVerification || currentStatus == AppConstants.statusIssuingDecision)
                  ElevatedButton.icon(
                    onPressed: () => _approveApplication(context, app),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusCompleted,
                      foregroundColor: Colors.white,
                    ),
                  ),

              // Reject button - for Issuing Officers and Admins
              if (userRole == AppConstants.roleIssuing || userRole == AppConstants.roleAdmin)
                if (currentStatus != AppConstants.statusCompleted && currentStatus != AppConstants.statusRejected && currentStatus != AppConstants.statusDraft)
                  ElevatedButton.icon(
                    onPressed: () => _rejectApplication(context, app),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),

              // Request Additional Info - for all officers
              if (userRole != AppConstants.roleApplicant)
                if (currentStatus != AppConstants.statusCompleted && currentStatus != AppConstants.statusRejected && currentStatus != AppConstants.statusDraft)
                  ElevatedButton.icon(
                    onPressed: () => _requestAdditionalInfo(context, app),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Request Info'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusSubmitted,
                      foregroundColor: Colors.white,
                    ),
                  ),

              // Assign to Officer - for Reception and Admins
              if (userRole == AppConstants.roleReception || userRole == AppConstants.roleAdmin)
                if (currentStatus == AppConstants.statusSubmitted || currentStatus == AppConstants.statusReceptionReview)
                  ElevatedButton.icon(
                    onPressed: () => _assignToOfficer(context, app),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Assign Officer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),

              // Reassign - for Admins
              if (userRole == AppConstants.roleAdmin)
                if (currentStatus != AppConstants.statusDraft && currentStatus != AppConstants.statusCompleted && currentStatus != AppConstants.statusRejected)
                  ElevatedButton.icon(
                    onPressed: () => _reassignApplication(context, app),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Reassign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reviewApplication(BuildContext context, ApplicationModel app) async {
    final appProvider = context.read<ApplicationProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Application'),
        content: const Text('Move this application to Reception Review status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Review'),
          ),
        ],
      ),
    );

    if (confirmed == true && user != null) {
      final success = await appProvider.updateApplicationStatus(
        app.id,
        AppConstants.statusReceptionReview,
        updatedBy: user.displayName ?? user.email ?? 'Unknown',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application moved to Reception Review'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
          _loadApplication();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${appProvider.errorMessage ?? "Failed to update status"}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _verifyApplication(BuildContext context, ApplicationModel app) async {
    final appProvider = context.read<ApplicationProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Application'),
        content: const Text('Move this application to Verification status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed == true && user != null) {
      final success = await appProvider.updateApplicationStatus(
        app.id,
        AppConstants.statusVerification,
        updatedBy: user.displayName ?? user.email ?? 'Unknown',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application verified'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
          _loadApplication();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${appProvider.errorMessage ?? "Failed to verify"}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _approveApplication(BuildContext context, ApplicationModel app) async {
    final appProvider = context.read<ApplicationProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: const Text('Approve this application and mark it as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && user != null) {
      final success = await appProvider.updateApplicationStatus(
        app.id,
        AppConstants.statusCompleted,
        updatedBy: user.displayName ?? user.email ?? 'Unknown',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application approved and completed'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
          _loadApplication();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${appProvider.errorMessage ?? "Failed to approve"}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectApplication(BuildContext context, ApplicationModel app) async {
    final commentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && commentController.text.trim().isNotEmpty) {
      final appProvider = context.read<ApplicationProvider>();
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user != null) {
        final success = await appProvider.updateApplicationStatus(
          app.id,
          AppConstants.statusRejected,
          comment: commentController.text.trim(),
          updatedBy: user.displayName ?? user.email ?? 'Unknown',
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application rejected'),
                backgroundColor: AppColors.error,
              ),
            );
            _loadApplication();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${appProvider.errorMessage ?? "Failed to reject"}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _requestAdditionalInfo(BuildContext context, ApplicationModel app) async {
    final commentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Additional Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('What additional information is needed?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Request Details',
                hintText: 'Enter what information is needed...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && commentController.text.trim().isNotEmpty) {
      final appProvider = context.read<ApplicationProvider>();
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user != null) {
        final success = await appProvider.requestAdditionalInfo(
          app.id,
          commentController.text.trim(),
          user.displayName ?? user.email ?? 'Unknown',
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request for additional information sent'),
                backgroundColor: AppColors.statusSubmitted,
              ),
            );
            _loadApplication();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${appProvider.errorMessage ?? "Failed to send request"}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _assignToOfficer(BuildContext context, ApplicationModel app) async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.users.isEmpty) {
      await userProvider.loadUsers();
    }

    // Filter to get only officers
    final officers = userProvider.users.where((user) {
      return user.role == AppConstants.roleOfficer ||
          user.role == AppConstants.roleVerification ||
          user.role == AppConstants.roleIssuing ||
          user.role == AppConstants.roleAdmin;
    }).toList();

    if (officers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No officers available to assign'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    String? selectedOfficerId;
    String? selectedOfficerName;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Assign to Officer'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select an officer to assign this application to:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Officer',
                    border: OutlineInputBorder(),
                  ),
                  items: officers.map((officer) {
                    return DropdownMenuItem(
                      value: officer.id,
                      child: Text('${officer.fullName ?? officer.email} (${officer.role})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOfficerId = value;
                      final officer = officers.firstWhere((o) => o.id == value);
                      selectedOfficerName = officer.fullName ?? officer.email;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedOfficerId != null
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedOfficerId != null && selectedOfficerName != null) {
      final appProvider = context.read<ApplicationProvider>();
      final success = await appProvider.assignToOfficer(
        app.id,
        selectedOfficerId!,
        selectedOfficerName!,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Application assigned to $selectedOfficerName'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
          _loadApplication();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${appProvider.errorMessage ?? "Failed to assign"}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _reassignApplication(BuildContext context, ApplicationModel app) async {
    // Reassign is similar to assign, but can change the current assignment
    await _assignToOfficer(context, app);
  }
}

