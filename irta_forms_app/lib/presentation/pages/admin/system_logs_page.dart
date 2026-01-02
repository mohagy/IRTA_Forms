import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/stat_card.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({super.key});

  @override
  State<SystemLogsPage> createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  String? _selectedLogLevel;
  String? _selectedLogType;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          currentRoute: '/logs',
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
    return Column(
      children: [
        // Header
        AppHeader(
          title: 'System Logs',
          actions: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search logs...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs exported successfully')),
                );
              },
              child: const Text('Export Logs'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clear Old Logs functionality coming soon')),
                );
              },
              child: const Text('Clear Old Logs'),
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
                  label: 'Total Logs',
                  value: '12,458',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Today',
                  value: '234',
                  valueColor: AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Errors',
                  value: '12',
                  valueColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Warnings',
                  value: '45',
                  valueColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ),

        // Table Section
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header with Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'System Activity Logs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedLogLevel,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          hint: const Text('All Levels', style: TextStyle(fontSize: 14)),
                          items: const [
                            DropdownMenuItem(value: 'Info', child: Text('Info')),
                            DropdownMenuItem(value: 'Warning', child: Text('Warning')),
                            DropdownMenuItem(value: 'Error', child: Text('Error')),
                            DropdownMenuItem(value: 'Debug', child: Text('Debug')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLogLevel = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedLogType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          hint: const Text('All Types', style: TextStyle(fontSize: 14)),
                          items: const [
                            DropdownMenuItem(value: 'Login', child: Text('Login')),
                            DropdownMenuItem(value: 'Form', child: Text('Form Action')),
                            DropdownMenuItem(value: 'User', child: Text('User Management')),
                            DropdownMenuItem(value: 'System', child: Text('System')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLogType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedLogLevel = null;
                            _selectedLogType = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),

                // Log Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Showing 234 log entries',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Table
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(AppColors.background),
                        columns: const [
                          DataColumn(label: Text('Timestamp')),
                          DataColumn(label: Text('Level')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('User')),
                          DataColumn(label: Text('Action')),
                          DataColumn(label: Text('Details')),
                          DataColumn(label: Text('IP Address')),
                        ],
                        rows: _buildLogRows(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<DataRow> _buildLogRows() {
    // Sample log data - in real app, this would come from Firestore
    final logs = [
      {
        'timestamp': '2024-01-15 14:32:15',
        'level': 'Info',
        'type': 'Login',
        'user': 'John Doe',
        'action': 'User Login',
        'details': 'Successful login from office network',
        'ip': '192.168.1.45',
      },
      {
        'timestamp': '2024-01-15 14:28:42',
        'level': 'Info',
        'type': 'Form',
        'user': 'Sarah Johnson',
        'action': 'Application Approved',
        'details': 'IRTA-2024-001234 approved',
        'ip': '192.168.1.32',
      },
      {
        'timestamp': '2024-01-15 14:15:20',
        'level': 'Warning',
        'type': 'System',
        'user': 'System',
        'action': 'Backup Scheduled',
        'details': 'Automatic backup initiated',
        'ip': 'N/A',
      },
      {
        'timestamp': '2024-01-15 13:45:10',
        'level': 'Error',
        'type': 'Form',
        'user': 'Michael Chen',
        'action': 'Document Upload Failed',
        'details': 'File size exceeds limit for IRTA-2024-001235',
        'ip': '192.168.1.28',
      },
      {
        'timestamp': '2024-01-15 13:30:55',
        'level': 'Info',
        'type': 'User',
        'user': 'Ahmed Hassan',
        'action': 'User Created',
        'details': 'New user created: robert.kim@irta.gov',
        'ip': '192.168.1.10',
      },
      {
        'timestamp': '2024-01-15 13:20:18',
        'level': 'Info',
        'type': 'Login',
        'user': 'Ahmad Mahmoud',
        'action': 'User Login',
        'details': 'Successful login',
        'ip': '203.0.113.45',
      },
      {
        'timestamp': '2024-01-15 13:05:33',
        'level': 'Warning',
        'type': 'Login',
        'user': 'unknown',
        'action': 'Failed Login Attempt',
        'details': 'Invalid credentials for email@example.com',
        'ip': '203.0.113.12',
      },
    ];

    return logs.map((log) {
      Color levelColor;
      Color levelBgColor;
      switch (log['level']) {
        case 'Error':
          levelColor = AppColors.error;
          levelBgColor = AppColors.error.withOpacity(0.1);
          break;
        case 'Warning':
          levelColor = AppColors.warning;
          levelBgColor = AppColors.warning.withOpacity(0.1);
          break;
        case 'Info':
        default:
          levelColor = AppColors.info;
          levelBgColor = AppColors.info.withOpacity(0.1);
          break;
      }

      return DataRow(
        cells: [
          DataCell(Text(log['timestamp'] as String)),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log['level'] as String,
                style: TextStyle(
                  color: levelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DataCell(Text(log['type'] as String)),
          DataCell(Text(log['user'] as String)),
          DataCell(Text(log['action'] as String)),
          DataCell(Text(log['details'] as String)),
          DataCell(Text(log['ip'] as String)),
        ],
      );
    }).toList();
  }
}

