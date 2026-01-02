import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/status_badge.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/role_model.dart';
import '../../../data/models/user_model.dart';

class RolesPermissionsPage extends StatefulWidget {
  const RolesPermissionsPage({super.key});

  @override
  State<RolesPermissionsPage> createState() => _RolesPermissionsPageState();
}

class _RolesPermissionsPageState extends State<RolesPermissionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load roles when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleProvider>().loadRoles();
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
          currentRoute: '/roles',
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
    // Update search query when text changes
    _searchController.addListener(() {
      context.read<RoleProvider>().setSearchQuery(_searchController.text);
    });

    return Column(
      children: [
        // Header
        AppHeader(
          title: 'Roles & Permissions Management',
          actions: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search roles or users...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddRoleDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Role'),
            ),
          ],
        ),

        // Tabs
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Roles Overview'),
              Tab(text: 'Permissions Matrix'),
              Tab(text: 'User Assignments'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRolesOverview(),
              _buildPermissionsMatrix(),
              _buildUserAssignments(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRolesOverview() {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        if (roleProvider.isLoading && roleProvider.roles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (roleProvider.roles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No roles found',
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
                      : 'Create your first role or load default roles',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (_searchController.text.isEmpty) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: roleProvider.isLoading
                        ? null
                        : () async {
                            final success = await roleProvider.seedDefaultRoles();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? 'Default roles loaded successfully!'
                                      : 'Failed to load default roles'),
                                  backgroundColor:
                                      success ? Colors.green : AppColors.error,
                                ),
                              );
                            }
                          },
                    icon: roleProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download),
                    label: const Text('Load Default Roles'),
                  ),
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: roleProvider.roles.length,
            itemBuilder: (context, index) {
              final role = roleProvider.roles[index];
              return _buildRoleCard(role, roleProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleCard(RoleModel role, RoleProvider roleProvider) {
    final permissionGroups = _groupPermissions(role.permissions);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    role.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${role.userCount} users',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Permissions List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: permissionGroups.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map((permission) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: AppColors.statusCompleted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  permission,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEditRoleDialog(context, role, roleProvider),
                    child: const Text('Edit Role'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteRoleDialog(context, role, roleProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _groupPermissions(List<String> permissions) {
    final groups = <String, List<String>>{};
    final allGroups = PermissionConstants.getPermissionGroups();

    for (final permission in permissions) {
      for (final entry in allGroups.entries) {
        if (entry.value.contains(permission)) {
          groups.putIfAbsent(entry.key, () => []).add(permission);
          break;
        }
      }
    }

    return groups;
  }

  Widget _buildPermissionsMatrix() {
    return Consumer2<RoleProvider, UserProvider>(
      builder: (context, roleProvider, userProvider, _) {
        final roles = roleProvider.roles;
        final allPermissions = PermissionConstants.getAllPermissions();
        final permissionGroups = PermissionConstants.getPermissionGroups();

        if (roles.isEmpty) {
          return const Center(
            child: Text('No roles available. Create roles first.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.tableHeaderBg),
                  columns: [
                    const DataColumn(
                      label: Text(
                        'Permission',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...roles.map((role) => DataColumn(
                          label: Text(
                            role.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )),
                  ],
                  rows: _buildMatrixRows(permissionGroups, roles, roleProvider),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> _buildMatrixRows(
    Map<String, List<String>> permissionGroups,
    List<RoleModel> roles,
    RoleProvider roleProvider,
  ) {
    final rows = <DataRow>[];

    for (final groupEntry in permissionGroups.entries) {
      // Group header row
      rows.add(DataRow(
        cells: [
          DataCell(
            Text(
              groupEntry.key,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ...roles.map((_) => const DataCell(SizedBox.shrink())),
        ],
      ));

      // Permission rows
      for (final permission in groupEntry.value) {
        rows.add(DataRow(
          cells: [
            DataCell(Text(permission)),
            ...roles.map((role) {
              final hasPermission = role.permissions.contains(permission);
              return DataCell(
                Icon(
                  hasPermission ? Icons.check_circle : Icons.cancel,
                  color: hasPermission
                      ? AppColors.statusCompleted
                      : AppColors.textTertiary,
                  size: 20,
                ),
              );
            }),
          ],
        ));
      }
    }

    return rows;
  }

  Widget _buildUserAssignments() {
    return Consumer2<UserProvider, RoleProvider>(
      builder: (context, userProvider, roleProvider, _) {
        if (userProvider.isLoading && userProvider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = userProvider.users;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
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
                        'User Role Assignments (${users.length})',
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
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: users.isEmpty
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
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(AppColors.tableHeaderBg),
                              columns: const [
                                DataColumn(label: Text('User Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: users.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user.fullName ?? '-')),
                                    DataCell(Text(user.email)),
                                    DataCell(_buildRoleBadge(user.role)),
                                    DataCell(Text(user.department ?? '-')),
                                    DataCell(StatusBadge(status: user.status)),
                                    DataCell(
                                      TextButton(
                                        onPressed: () {
                                          _showEditUserRoleDialog(context, user, userProvider);
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
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

  void _showAddRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddEditRoleDialog(),
    );
  }

  void _showEditRoleDialog(BuildContext context, RoleModel role, RoleProvider roleProvider) {
    showDialog(
      context: context,
      builder: (context) => _AddEditRoleDialog(role: role),
    );
  }

  void _showDeleteRoleDialog(BuildContext context, RoleModel role, RoleProvider roleProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await roleProvider.deleteRole(role.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Role deleted successfully' : 'Failed to delete role'),
                    backgroundColor: success ? Colors.green : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditUserRoleDialog(BuildContext context, UserModel user, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => _EditUserRoleDialog(user: user),
    );
  }
}

class _AddEditRoleDialog extends StatefulWidget {
  final RoleModel? role;

  const _AddEditRoleDialog({this.role});

  @override
  State<_AddEditRoleDialog> createState() => _AddEditRoleDialogState();
}

class _AddEditRoleDialogState extends State<_AddEditRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Map<String, bool> _selectedPermissions = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _nameController.text = widget.role!.name;
      _descriptionController.text = widget.role!.description;
      for (final permission in widget.role!.permissions) {
        _selectedPermissions[permission] = true;
      }
    } else {
      // Initialize all permissions as false
      for (final permission in PermissionConstants.getAllPermissions()) {
        _selectedPermissions[permission] = false;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.read<RoleProvider>();
    final isEdit = widget.role != null;
    final permissionGroups = PermissionConstants.getPermissionGroups();

    return AlertDialog(
      title: Text(isEdit ? 'Edit Role' : 'Add New Role'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Role name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Permissions:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: permissionGroups.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...entry.value.map((permission) {
                            return CheckboxListTile(
                              dense: true,
                              title: Text(permission, style: const TextStyle(fontSize: 13)),
                              value: _selectedPermissions[permission] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPermissions[permission] = value ?? false;
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _saveRole(context, roleProvider, isEdit),
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

  Future<void> _saveRole(BuildContext context, RoleProvider roleProvider, bool isEdit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedPermissions = _selectedPermissions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      if (isEdit && widget.role != null) {
        final updatedRole = widget.role!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          permissions: selectedPermissions,
          updatedAt: DateTime.now(),
        );

        final success = await roleProvider.updateRole(widget.role!.id, updatedRole);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Role updated successfully' : 'Failed to update role'),
              backgroundColor: success ? Colors.green : AppColors.error,
            ),
          );
        }
      } else {
        final newRole = RoleModel(
          id: '',
          name: _nameController.text,
          description: _descriptionController.text,
          permissions: selectedPermissions,
          createdAt: DateTime.now(),
        );

        final success = await roleProvider.createRole(newRole);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Role created successfully' : 'Failed to create role'),
              backgroundColor: success ? Colors.green : AppColors.error,
            ),
          );
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

class _EditUserRoleDialog extends StatefulWidget {
  final UserModel user;

  const _EditUserRoleDialog({required this.user});

  @override
  State<_EditUserRoleDialog> createState() => _EditUserRoleDialogState();
}

class _EditUserRoleDialogState extends State<_EditUserRoleDialog> {
  late String _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final roleProvider = context.read<RoleProvider>();
    final roles = roleProvider.roles;

    return AlertDialog(
      title: const Text('Edit User Role'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('User: ${widget.user.fullName ?? widget.user.email}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                border: OutlineInputBorder(),
              ),
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role.name.toLowerCase(),
                  child: Text(role.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value ?? widget.user.role;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _updateUserRole(context, userProvider),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateUserRole(BuildContext context, UserProvider userProvider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = widget.user.copyWith(
        role: _selectedRole,
        updatedAt: DateTime.now(),
      );

      final success = await userProvider.updateUser(widget.user.id, updatedUser);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User role updated successfully' : 'Failed to update user role'),
            backgroundColor: success ? Colors.green : AppColors.error,
          ),
        );
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
