import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/form_config_repository.dart';

class FormConfigPage extends StatefulWidget {
  const FormConfigPage({super.key});

  @override
  State<FormConfigPage> createState() => _FormConfigPageState();
}

class _FormConfigPageState extends State<FormConfigPage> {
  String _selectedFormType = 'individual';
  String _selectedSection = 'introduction';
  bool _isSaving = false;
  bool _isPublishing = false;
  final FormConfigRepository _repository = FormConfigRepository();

  Map<String, dynamic> _buildCurrentConfig() {
    // Minimal stub configuration aligned with sections in the UI.
    // This can be extended into a full builder later.
    return {
      'formType': _selectedFormType,
      'sections': [
        {'key': 'introduction', 'title': 'Introduction', 'fields': []},
        {'key': 'representative', 'title': 'Representative', 'fields': []},
        {'key': 'organization', 'title': 'Organization', 'fields': []},
        {'key': 'transportation', 'title': 'Transportation', 'fields': []},
        {'key': 'declarations', 'title': 'Declarations', 'fields': []},
      ],
      'updatedAt': DateTime.now().toIso8601String(),
    };
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

        // Restrict access to admins only
        final isAdmin = userRole == AppConstants.roleAdmin;
        if (!isAdmin) {
          return MainLayout(
            currentRoute: '/form-config',
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 12),
                  Text(
                    'Access Denied',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Only administrators can access Form Configuration.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return MainLayout(
          currentRoute: '/form-config',
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
          title: 'Form Configuration',
          actions: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _selectedFormType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'individual', child: Text('Individual IRTA')),
                  DropdownMenuItem(value: 'renewal', child: Text('Renewal Application')),
                  DropdownMenuItem(value: 'amendment', child: Text('Amendment Request')),
                  DropdownMenuItem(value: 'cancellation', child: Text('Cancellation Request')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFormType = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      try {
                        await _repository.saveFormConfig(
                          formType: _selectedFormType,
                          config: _buildCurrentConfig(),
                          updatedBy: userEmail,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Form configuration saved to database')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save configuration: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
              child: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Configuration'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isPublishing
                  ? null
                  : () async {
                      setState(() => _isPublishing = true);
                      try {
                        // Ensure latest is saved first
                        await _repository.saveFormConfig(
                          formType: _selectedFormType,
                          config: _buildCurrentConfig(),
                          updatedBy: userEmail,
                        );
                        await _repository.publishFormConfig(
                          formType: _selectedFormType,
                          publishedBy: userEmail,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Form version published')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to publish version: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isPublishing = false);
                      }
                    },
              child: _isPublishing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Publish Version'),
            ),
          ],
        ),

        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar - Form Sections
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: const Text(
                          'Form Sections',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildSectionItem('introduction', 'Introduction', Icons.info_outline),
                      _buildSectionItem('representative', 'Representative', Icons.person_outline),
                      _buildSectionItem('organization', 'Organization', Icons.business_outlined),
                      _buildSectionItem('transportation', 'Transportation', Icons.directions_car_outlined),
                      _buildSectionItem('declarations', 'Declarations', Icons.check_circle_outline),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Main Form Builder Area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                _getSectionTitle(_selectedSection),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.construction_outlined,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Form Builder Coming Soon',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Drag fields here or click field types to add',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSectionItem(String section, String label, IconData icon) {
    final isSelected = _selectedSection == section;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSection = section;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSectionTitle(String section) {
    switch (section) {
      case 'introduction':
        return 'Introduction Section';
      case 'representative':
        return 'Representative Section';
      case 'organization':
        return 'Organization Section';
      case 'transportation':
        return 'Transportation Section';
      case 'declarations':
        return 'Declarations Section';
      default:
        return 'Form Section';
    }
  }
}




