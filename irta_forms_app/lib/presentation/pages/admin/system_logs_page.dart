import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/stat_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/system_log_provider.dart';
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
  void initState() {
    super.initState();
    // Load logs when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemLogProvider>().loadLogs();
    });
  }

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
    return Consumer<SystemLogProvider>(
      builder: (context, logProvider, _) {
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
                    onChanged: (value) {
                      logProvider.setSearchQuery(value.isEmpty ? null : value);
                    },
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
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Old Logs'),
                        content: const Text('Delete logs older than 90 days? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await logProvider.clearOldLogs(90);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Old logs cleared')),
                        );
                      }
                    }
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
                      value: logProvider.statistics['total']?.toString() ?? '0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Today',
                      value: logProvider.statistics['today']?.toString() ?? '0',
                      valueColor: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Errors',
                      value: logProvider.statistics['errors']?.toString() ?? '0',
                      valueColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Warnings',
                      value: logProvider.statistics['warnings']?.toString() ?? '0',
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
                            final logProvider = context.read<SystemLogProvider>();
                            logProvider.loadLogs(level: value, type: _selectedLogType);
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
                            final logProvider = context.read<SystemLogProvider>();
                            logProvider.loadLogs(level: _selectedLogLevel, type: value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          logProvider.refresh();
                          setState(() {
                            _selectedLogLevel = null;
                            _selectedLogType = null;
                            _searchController.clear();
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
                    'Showing ${logProvider.filteredLogs.length} log entries',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Table
                Expanded(
                  child: logProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : logProvider.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading logs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Text(
                                      logProvider.errorMessage!,
                                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => logProvider.refresh(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : logProvider.filteredLogs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.description_outlined, size: 64, color: AppColors.textTertiary),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No logs found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        logProvider.logs.isEmpty
                                            ? 'System logs will appear here as events occur.\nTry logging in, submitting an application, or performing other actions.'
                                            : 'No logs match your search criteria',
                                        style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
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
                                      rows: _buildLogRows(logProvider.filteredLogs),
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
      },
    );
  }

  List<DataRow> _buildLogRows(List logs) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    
    return logs.map((log) {
      Color levelColor;
      Color levelBgColor;
      switch (log.level) {
        case 'Error':
          levelColor = AppColors.error;
          levelBgColor = AppColors.error.withOpacity(0.1);
          break;
        case 'Warning':
          levelColor = AppColors.warning;
          levelBgColor = AppColors.warning.withOpacity(0.1);
          break;
        case 'Debug':
          levelColor = AppColors.textTertiary;
          levelBgColor = AppColors.textTertiary.withOpacity(0.1);
          break;
        case 'Info':
        default:
          levelColor = AppColors.info;
          levelBgColor = AppColors.info.withOpacity(0.1);
          break;
      }

      return DataRow(
        cells: [
          DataCell(Text(dateFormat.format(log.timestamp))),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.level,
                style: TextStyle(
                  color: levelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DataCell(Text(log.type)),
          DataCell(Text(log.userName ?? log.userId ?? 'System')),
          DataCell(Text(log.action)),
          DataCell(Text(log.details)),
          DataCell(Text(log.ipAddress ?? 'N/A')),
        ],
      );
    }).toList();
  }
}




