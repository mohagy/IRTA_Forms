import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SystemConfigPage extends StatefulWidget {
  const SystemConfigPage({super.key});

  @override
  State<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends State<SystemConfigPage> {
  final _systemNameController = TextEditingController(text: 'IRTA Forms Management System');
  final _sessionTimeoutController = TextEditingController(text: '30');
  final _backupRetentionController = TextEditingController(text: '30');
  String _selectedTimezone = 'America/Guyana (GMT-4)';
  String _selectedBackupSchedule = 'Weekly';
  bool _enableEmailNotifications = true;
  bool _enableSMSNotifications = true;

  @override
  void dispose() {
    _systemNameController.dispose();
    _sessionTimeoutController.dispose();
    _backupRetentionController.dispose();
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
          currentRoute: '/system-config',
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
          title: 'System Configuration',
          actions: [
            SizedBox(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All changes saved successfully')),
                );
              },
              child: const Text('Save All Changes'),
            ),
          ],
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // General Settings
                _buildSettingsSection(
                  title: 'General Settings',
                  children: [
                    _buildTextField(
                      label: 'System Name',
                      controller: _systemNameController,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      label: 'Default Timezone',
                      value: _selectedTimezone,
                      items: const [
                        'America/Guyana (GMT-4)',
                        'UTC (GMT+0)',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTimezone = value ?? _selectedTimezone;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Session Timeout (minutes)',
                      controller: _sessionTimeoutController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildCheckbox(
                      label: 'Enable Email Notifications',
                      value: _enableEmailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _enableEmailNotifications = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildCheckbox(
                      label: 'Enable SMS Notifications',
                      value: _enableSMSNotifications,
                      onChanged: (value) {
                        setState(() {
                          _enableSMSNotifications = value ?? false;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Email Configuration
                _buildSettingsSection(
                  title: 'Email Configuration',
                  children: [
                    _buildTextField(
                      label: 'SMTP Server',
                      controller: TextEditingController(text: 'smtp.gmail.com'),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'SMTP Port',
                      controller: TextEditingController(text: '587'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'From Email Address',
                      controller: TextEditingController(text: 'noreply@irta.gov'),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'From Name',
                      controller: TextEditingController(text: 'IRTA Forms System'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Backup & Maintenance
                _buildSettingsSection(
                  title: 'Backup & Maintenance',
                  children: [
                    _buildDropdown(
                      label: 'Automatic Backup Schedule',
                      value: _selectedBackupSchedule,
                      items: const [
                        'Daily',
                        'Weekly',
                        'Monthly',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBackupSchedule = value ?? _selectedBackupSchedule;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Backup Retention (days)',
                      controller: _backupRetentionController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Backup created successfully')),
                            );
                          },
                          child: const Text('Create Backup Now'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Restore from Backup functionality coming soon')),
                            );
                          },
                          child: const Text('Restore from Backup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}



