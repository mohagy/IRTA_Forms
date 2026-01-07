import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/role_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/logging_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load users and roles when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
      context.read<RoleProvider>().loadRoles();
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
          currentRoute: '/users',
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Update search query when text changes
        _searchController.addListener(() {
          userProvider.setSearchQuery(_searchController.text);
        });

        return Column(
          children: [
            // Header
            AppHeader(
              title: 'User Management',
              actions: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New User'),
                ),
              ],
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
                            Text(
                              'All Users (${userProvider.users.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    userProvider.loadUsers();
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Refresh'),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Export functionality coming soon')),
                                    );
                                  },
                                  icon: const Icon(Icons.upload, size: 18),
                                  label: const Text('Export'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Table Content
                      Expanded(
                        child: userProvider.isLoading && userProvider.users.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : userProvider.users.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: AppColors.textTertiary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No users found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _searchController.text.isNotEmpty
                                              ? 'Try adjusting your search'
                                              : 'Users will appear here once they register',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Note: Users created in Firebase Auth need a Firestore document.\nSee USER_SYNC_GUIDE.md for details.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textTertiary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      child: _buildUsersTable(context, userProvider.users, userProvider),
                                    ),
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

  Widget _buildUsersTable(BuildContext context, List<UserModel> users, UserProvider userProvider) {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(AppColors.tableHeaderBg),
      columns: const [
        DataColumn(label: Text('User ID')),
        DataColumn(label: Text('Full Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Role')),
        DataColumn(label: Text('Department')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Last Login')),
        DataColumn(label: Text('Actions')),
      ],
      rows: users.map((user) {
        return DataRow(
          cells: [
            DataCell(Text(user.id.length > 8 ? '${user.id.substring(0, 8)}...' : user.id)),
            DataCell(Text(user.fullName ?? '-')),
            DataCell(Text(user.email)),
            DataCell(_buildRoleBadge(user.role)),
            DataCell(Text(user.department ?? '-')),
            DataCell(StatusBadge(status: user.status)),
            DataCell(Text(
              user.lastLogin != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(user.lastLogin!)
                  : '-',
            )),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _showEditUserDialog(context, user, userProvider),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showPasswordResetDialog(context, user),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Reset Password'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showDeleteUserDialog(context, user, userProvider),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color roleColor;
    switch (role.toLowerCase()) {
      case 'admin':
        roleColor = AppColors.error;
        break;
      case 'officer':
      case 'issuing':
        roleColor = AppColors.primary;
        break;
      case 'reception':
        roleColor = AppColors.statusSubmitted;
        break;
      case 'verification':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: roleColor),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 12,
          color: roleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddEditUserDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => _AddEditUserDialog(user: user),
    );
  }

  void _showPasswordResetDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PasswordResetDialog(user: user),
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserModel user, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName ?? user.email}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await userProvider.deleteUser(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'User deleted successfully' : 'Failed to delete user'),
                    backgroundColor: success ? Colors.green : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PasswordResetDialog extends StatefulWidget {
  final UserModel user;

  const _PasswordResetDialog({required this.user});

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendPasswordReset() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      await authService.sendPasswordResetEmail(widget.user.email);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${widget.user.email}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send a password reset email to ${widget.user.email}? The user will receive an email with instructions to reset their password.',
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendPasswordReset,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Reset Email'),
        ),
      ],
    );
  }
}

class _AddEditUserDialog extends StatefulWidget {
  final UserModel? user;

  const _AddEditUserDialog({this.user});

  @override
  State<_AddEditUserDialog> createState() => _AddEditUserDialogState();
}

class _AddEditUserDialogState extends State<_AddEditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  String _selectedRole = AppConstants.roleApplicant;
  String _selectedStatus = 'Active';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _emailController.text = widget.user!.email;
      _fullNameController.text = widget.user!.fullName ?? '';
      _phoneController.text = widget.user!.phoneNumber ?? '';
      _departmentController.text = widget.user!.department ?? '';
      _selectedRole = widget.user!.role;
      _selectedStatus = widget.user!.status;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final roleProvider = context.watch<RoleProvider>();
    final isEdit = widget.user != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit User' : 'Add New User'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isEdit, // Email cannot be changed
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                  ),
                  items: roleProvider.roles.isEmpty
                      ? [
                          // Fallback to constants if roles not loaded
                          const DropdownMenuItem(value: AppConstants.roleApplicant, child: Text('Applicant')),
                          const DropdownMenuItem(value: AppConstants.roleOfficer, child: Text('Officer')),
                          const DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Admin')),
                          const DropdownMenuItem(value: AppConstants.roleReception, child: Text('Reception')),
                          const DropdownMenuItem(value: AppConstants.roleVerification, child: Text('Verification')),
                          const DropdownMenuItem(value: AppConstants.roleIssuing, child: Text('Issuing')),
                        ]
                      : [
                          // Use roles from Roles collection
                          ...roleProvider.roles.map((role) {
                            return DropdownMenuItem(
                              value: role.name.toLowerCase(),
                              child: Text(role.name),
                            );
                          }),
                        ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value ?? (roleProvider.roles.isNotEmpty
                          ? roleProvider.roles.first.name.toLowerCase()
                          : AppConstants.roleApplicant);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'Active';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _saveUser(context, userProvider, isEdit),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _saveUser(BuildContext context, UserProvider userProvider, bool isEdit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEdit && widget.user != null) {
        // Update existing user
        final updatedUser = widget.user!.copyWith(
          fullName: _fullNameController.text.isEmpty ? null : _fullNameController.text,
          phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
          department: _departmentController.text.isEmpty ? null : _departmentController.text,
          role: _selectedRole,
          status: _selectedStatus,
          updatedAt: DateTime.now(),
        );

        final success = await userProvider.updateUser(widget.user!.id, updatedUser);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'User updated successfully' : 'Failed to update user'),
              backgroundColor: success ? Colors.green : AppColors.error,
            ),
          );
        }
      } else {
        // Create new user with password in Firebase Auth
        try {
          final authService = AuthService();
          
          // Create user in Firebase Auth with email and password
          final userCredential = await authService.signUpWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.isEmpty ? _emailController.text.split('@')[0] : _fullNameController.text,
            phoneNumber: _phoneController.text.isEmpty ? '' : _phoneController.text,
            nationality: '',
            dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default date
            idType: '',
            idNumber: '',
            address: '',
          );

          if (userCredential?.user == null) {
            throw Exception('Failed to create user in Firebase Auth');
          }

          final userId = userCredential!.user!.uid;

          // Update display name if provided
          if (_fullNameController.text.isNotEmpty) {
            await userCredential.user!.updateDisplayName(_fullNameController.text);
          }

          // Create Firestore document with the user's UID
          final newUser = UserModel(
            id: userId,
            email: _emailController.text.trim(),
            fullName: _fullNameController.text.isEmpty ? null : _fullNameController.text,
            phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
            department: _departmentController.text.isEmpty ? null : _departmentController.text,
            role: _selectedRole,
            status: _selectedStatus,
            createdAt: DateTime.now(),
          );

          final success = await userProvider.createUserWithId(userId, newUser);
          
          // Log user creation
          final authProvider = context.read<AuthProvider>();
          final adminUser = authProvider.user;
          await LoggingService().logUserAction(
            action: 'User Created',
            details: 'User ${newUser.email} created with role ${newUser.role}',
            userId: adminUser?.uid ?? 'system',
            userName: adminUser?.displayName ?? adminUser?.email ?? 'System',
            targetUserId: userId,
          );
          
          if (context.mounted) {
            Navigator.pop(context);
            if (success) {
              // Sign out the newly created user (Firebase Auth automatically signs them in after creation)
              await authService.signOut();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User created successfully! Please sign in again to continue.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 5),
                ),
              );
              
              // Reload users list
              userProvider.loadUsers();
              
              // Redirect to login page after a short delay
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.go(AppConstants.routeLogin);
                }
              });
            } else {
              // If Firestore creation failed, we should still sign out
              await authService.signOut();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User created in Firebase Auth but failed to create Firestore document. Please sign in again.'),
                  backgroundColor: AppColors.error,
                  duration: Duration(seconds: 5),
                ),
              );
              
              // Redirect to login page
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.go(AppConstants.routeLogin);
                }
              });
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create user: ${e.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
