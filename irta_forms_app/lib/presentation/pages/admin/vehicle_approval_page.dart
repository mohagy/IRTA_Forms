import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/stat_card.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class VehicleApprovalPage extends StatelessWidget {
  const VehicleApprovalPage({super.key});

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
    // TODO: Replace with actual vehicle data from Firestore
    final vehicles = <Map<String, dynamic>>[];

    // Calculate stats dynamically
    final pending = vehicles.where((v) => v['status'] == 'Pending').length;
    final approved = vehicles.where((v) => v['status'] == 'Approved').length;
    final rejected = vehicles.where((v) => v['status'] == 'Rejected').length;
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
                                value: null,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                                hint: const Text('All Statuses', style: TextStyle(fontSize: 14)),
                                items: const [
                                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                                ],
                                onChanged: (value) {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: DropdownButtonFormField<String>(
                                value: null,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: AppColors.border),
                                  ),
                                ),
                                hint: const Text('All Types', style: TextStyle(fontSize: 14)),
                                items: const [
                                  DropdownMenuItem(value: 'Bus', child: Text('Bus')),
                                  DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                                  DropdownMenuItem(value: 'Van', child: Text('Van')),
                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (value) {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {},
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
                    child: vehicles.isEmpty
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
                                  'No vehicles found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Vehicles will appear here once they are submitted for approval',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: _buildVehiclesTable(context, vehicles),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclesTable(BuildContext context, List<Map<String, dynamic>> vehicles) {
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
              _TableCell(_buildStatusBadge(vehicle['status'] ?? 'Pending')),
              _TableCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        // View/Approve vehicle
                      },
                      child: const Text('View'),
                    ),
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



