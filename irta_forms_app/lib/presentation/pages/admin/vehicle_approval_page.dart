import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/stat_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import 'package:go_router/go_router.dart';

class VehicleApprovalPage extends StatefulWidget {
  const VehicleApprovalPage({super.key});

  @override
  State<VehicleApprovalPage> createState() => _VehicleApprovalPageState();
}

class _VehicleApprovalPageState extends State<VehicleApprovalPage> {
  String _searchQuery = '';
  String? _statusFilter;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    // Load all applications when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Wait for auth state to be initialized before checking
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
          currentRoute: '/vehicle-approval',
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
          child: _buildContent(context),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        // Extract vehicles from all applications
        final vehicles = _extractVehiclesFromApplications(appProvider.applications);
        
        // Apply filters
        final filteredVehicles = _applyFilters(vehicles);

        // Calculate stats dynamically
        final pending = vehicles.where((v) => (v['vehicleApprovalStatus'] ?? 'Pending') == 'Pending').length;
        final approved = vehicles.where((v) => (v['vehicleApprovalStatus'] ?? 'Pending') == 'Approved').length;
        final rejected = vehicles.where((v) => (v['vehicleApprovalStatus'] ?? 'Pending') == 'Rejected').length;
        final total = vehicles.length;

    return Column(
      children: [
        // Header
        AppHeader(
          title: 'Vehicle Approval',
          actions: [
            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by plate number, chassis, or owner...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // Export to Excel functionality
              },
              child: const Text('Export to Excel'),
            ),
          ],
        ),

        // Stats Cards
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Pending Approval',
                  value: pending.toString(),
                  valueColor: AppColors.statusSubmitted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Approved',
                  value: approved.toString(),
                  valueColor: AppColors.statusCompleted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Rejected',
                  value: rejected.toString(),
                  valueColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Total Vehicles',
                  value: total.toString(),
                ),
              ),
            ],
          ),
        ),

        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.tableHeaderBg,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 2),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Vehicle Approval Queue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: DropdownButtonFormField<String>(
                                value: _statusFilter,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                                hint: const Text('All Statuses', style: TextStyle(fontSize: 14)),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _statusFilter = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: DropdownButtonFormField<String>(
                                value: _typeFilter,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                                hint: const Text('All Types', style: TextStyle(fontSize: 14)),
                                items: const [
                                  DropdownMenuItem(value: null, child: Text('All Types')),
                                  DropdownMenuItem(value: 'Bus', child: Text('Bus')),
                                  DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                                  DropdownMenuItem(value: 'Van', child: Text('Van')),
                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _typeFilter = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                appProvider.loadAllApplications();
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Table Content
                  Expanded(
                    child: appProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredVehicles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      size: 64,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      vehicles.isEmpty ? 'No vehicles found' : 'No vehicles match your filters',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      vehicles.isEmpty
                                          ? 'Vehicles will appear here once they are submitted for approval'
                                          : 'Try adjusting your search or filter criteria',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: _buildVehiclesTable(context, filteredVehicles, appProvider),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  // Extract vehicles from applications and flatten them
  List<Map<String, dynamic>> _extractVehiclesFromApplications(List applications) {
    final List<Map<String, dynamic>> vehicles = [];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    for (final app in applications) {
      final appData = app.applicationData;
      if (appData == null) continue;

      final transportation = appData['transportation'] as Map<String, dynamic>?;
      if (transportation == null) continue;

      final vehiclesList = transportation['vehicles'] as List?;
      if (vehiclesList == null || vehiclesList.isEmpty) continue;

      for (int i = 0; i < vehiclesList.length; i++) {
        final vehicle = vehiclesList[i] as Map<String, dynamic>;
        
        // Get vehicle approval status (stored in vehicle data or default to 'Pending')
        final approvalStatus = vehicle['vehicleApprovalStatus'] ?? 'Pending';
        
        vehicles.add({
          'applicationId': app.id,
          'applicationRef': app.irtaRef,
          'applicantName': app.applicantName,
          'submissionDate': dateFormat.format(app.submissionDate),
          'plateNumber': vehicle['vehiclePlate'] ?? '-',
          'vehicleType': vehicle['vehicleType'] ?? '-',
          'make': vehicle['vehicleMake'] ?? '',
          'model': vehicle['vehicleBodyType'] ?? '', // Using bodyType as model
          'year': vehicle['vehicleYear'] ?? '-',
          'owner': app.applicantName, // Owner is the applicant
          'chassisNumber': vehicle['vehicleChassis'] ?? '-',
          'vehicleIndex': i,
          'vehicleData': vehicle, // Store full vehicle data for details
          'vehicleApprovalStatus': approvalStatus,
          'vehicleApprovalComment': vehicle['vehicleApprovalComment'],
          'vehicleApprovedBy': vehicle['vehicleApprovedBy'],
          'vehicleApprovedAt': vehicle['vehicleApprovedAt'],
        });
      }
    }

    return vehicles;
  }

  // Apply search and filter criteria
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> vehicles) {
    var filtered = vehicles;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((v) {
        final plate = (v['plateNumber'] ?? '').toString().toLowerCase();
        final chassis = (v['chassisNumber'] ?? '').toString().toLowerCase();
        final owner = (v['owner'] ?? '').toString().toLowerCase();
        final applicant = (v['applicantName'] ?? '').toString().toLowerCase();
        return plate.contains(_searchQuery) ||
            chassis.contains(_searchQuery) ||
            owner.contains(_searchQuery) ||
            applicant.contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((v) {
        final status = (v['vehicleApprovalStatus'] ?? 'Pending').toString();
        return status == _statusFilter;
      }).toList();
    }

    // Apply type filter
    if (_typeFilter != null) {
      filtered = filtered.where((v) {
        final type = (v['vehicleType'] ?? '').toString();
        return type == _typeFilter;
      }).toList();
    }

    return filtered;
  }

  Widget _buildVehiclesTable(BuildContext context, List<Map<String, dynamic>> vehicles, ApplicationProvider appProvider) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2), // Plate Number
        1: FlexColumnWidth(1.0), // Vehicle Type
        2: FlexColumnWidth(1.5), // Make/Model
        3: FlexColumnWidth(1.2), // Year
        4: FlexColumnWidth(1.5), // Owner
        5: FlexColumnWidth(1.5), // Chassis Number
        6: FlexColumnWidth(1.2), // Submission Date
        7: FlexColumnWidth(1.0), // Status
        8: FlexColumnWidth(1.2), // Actions
      },
      children: [
        // Table Header Row
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.tableHeaderBg,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          children: const [
            _TableHeaderCell('Plate Number'),
            _TableHeaderCell('Vehicle Type'),
            _TableHeaderCell('Make/Model'),
            _TableHeaderCell('Year'),
            _TableHeaderCell('Owner'),
            _TableHeaderCell('Chassis Number'),
            _TableHeaderCell('Submission Date'),
            _TableHeaderCell('Status'),
            _TableHeaderCell('Actions'),
          ],
        ),
        // Table Data Rows
        ...vehicles.map((vehicle) {
          return TableRow(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            children: [
              _TableCell(Text(
                vehicle['plateNumber'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              _TableCell(Text(vehicle['vehicleType'] ?? '-')),
              _TableCell(Text('${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'.trim())),
              _TableCell(Text(vehicle['year']?.toString() ?? '-')),
              _TableCell(Text(vehicle['owner'] ?? '-')),
              _TableCell(Text(vehicle['chassisNumber'] ?? '-')),
              _TableCell(Text(vehicle['submissionDate']?.toString() ?? '-')),
              _TableCell(_buildStatusBadge(vehicle['vehicleApprovalStatus'] ?? 'Pending')),
              _TableCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigate to application detail page
                        context.push('/applications/${vehicle['applicationId']}');
                      },
                      child: const Text('View'),
                    ),
                    if ((vehicle['vehicleApprovalStatus'] ?? 'Pending') == 'Pending') ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _approveVehicle(context, vehicle, appProvider),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.statusCompleted,
                        ),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _rejectVehicle(context, vehicle, appProvider),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = AppColors.statusCompleted;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      case 'pending':
      default:
        color = AppColors.statusSubmitted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _approveVehicle(BuildContext context, Map<String, dynamic> vehicle, ApplicationProvider appProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Vehicle'),
        content: Text('Are you sure you want to approve vehicle ${vehicle['plateNumber']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCompleted,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Update vehicle approval status in application
        await appProvider.updateVehicleApprovalStatus(
          vehicle['applicationId'],
          vehicle['vehicleIndex'],
          'Approved',
          approvedBy: context.read<AuthProvider>().user?.email ?? 'Unknown',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vehicle ${vehicle['plateNumber']} approved successfully'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error approving vehicle: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectVehicle(BuildContext context, Map<String, dynamic> vehicle, ApplicationProvider appProvider) async {
    final commentController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject vehicle ${vehicle['plateNumber']}?'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'Enter reason for rejection...',
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
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Update vehicle approval status in application
        await appProvider.updateVehicleApprovalStatus(
          vehicle['applicationId'],
          vehicle['vehicleIndex'],
          'Rejected',
          comment: commentController.text.isNotEmpty ? commentController.text : null,
          approvedBy: context.read<AuthProvider>().user?.email ?? 'Unknown',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vehicle ${vehicle['plateNumber']} rejected'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rejecting vehicle: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;

  const _TableCell(this.child);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}




