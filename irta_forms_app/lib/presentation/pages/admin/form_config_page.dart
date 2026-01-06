import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/form_field_model.dart';
import '../../../data/repositories/form_config_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/main_layout.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class FormConfigPage extends StatefulWidget {
  const FormConfigPage({super.key});

  @override
  State<FormConfigPage> createState() => _FormConfigPageState();
}

class _FormConfigPageState extends State<FormConfigPage> {
  final FormConfigRepository _repository = FormConfigRepository();
  final _uuid = const Uuid();
  
  String _selectedFormType = 'individual';
  String _selectedSection = 'introduction';
  List<FormFieldModel> _fields = [];
  FormFieldModel? _selectedField;
  bool _isSaving = false;
  bool _isPublishing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFormConfig();
  }

  Future<void> _loadFormConfig() async {
    setState(() => _isLoading = true);
    try {
      final config = await _repository.getFormConfig(_selectedFormType);
      if (config != null && config['sections'] != null) {
        final sectionData = config['sections'][_selectedSection];
        if (sectionData != null && sectionData['fields'] != null) {
          final fieldsList = sectionData['fields'] as List;
          setState(() {
            _fields = fieldsList
                .map((f) => FormFieldModel.fromMap(f as Map<String, dynamic>))
                .toList();
            _fields.sort((a, b) => a.order.compareTo(b.order));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading config: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _buildCurrentConfig() {
    return {
      'formType': _selectedFormType,
      'sections': {
        _selectedSection: {
          'title': _getSectionTitle(_selectedSection),
          'fields': _fields.map((f) => f.toMap()).toList(),
        },
      },
    };
  }

  void _addField(String fieldType) {
    final newField = FormFieldModel(
      id: _uuid.v4(),
      type: fieldType,
      label: _getDefaultLabel(fieldType),
      order: _fields.length,
      required: false,
    );
    setState(() {
      _fields.add(newField);
      _selectedField = newField;
    });
  }

  String _getDefaultLabel(String fieldType) {
    switch (fieldType) {
      case FormFieldType.text:
        return 'Text Field';
      case FormFieldType.textarea:
        return 'Text Area';
      case FormFieldType.email:
        return 'Email Address';
      case FormFieldType.phone:
        return 'Phone Number';
      case FormFieldType.number:
        return 'Number';
      case FormFieldType.date:
        return 'Date';
      case FormFieldType.dropdown:
        return 'Dropdown';
      case FormFieldType.radio:
        return 'Radio Buttons';
      case FormFieldType.checkbox:
        return 'Checkboxes';
      case FormFieldType.fileUpload:
        return 'File Upload';
      case FormFieldType.heading:
        return 'Heading';
      case FormFieldType.paragraph:
        return 'Paragraph Text';
      default:
        return 'Field';
    }
  }

  void _updateField(FormFieldModel updatedField) {
    setState(() {
      final index = _fields.indexWhere((f) => f.id == updatedField.id);
      if (index != -1) {
        _fields[index] = updatedField;
      }
    });
  }

  void _deleteField(String fieldId) {
    setState(() {
      _fields.removeWhere((f) => f.id == fieldId);
      if (_selectedField?.id == fieldId) {
        _selectedField = null;
      }
      // Reorder remaining fields
      for (int i = 0; i < _fields.length; i++) {
        _fields[i] = _fields[i].copyWith(order: i);
      }
    });
  }

  void _moveField(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final field = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, field);
      // Update order for all fields
      for (int i = 0; i < _fields.length; i++) {
        _fields[i] = _fields[i].copyWith(order: i);
      }
    });
  }

  void _duplicateField(FormFieldModel field) {
    final duplicated = FormFieldModel(
      id: _uuid.v4(),
      type: field.type,
      label: '${field.label} (Copy)',
      placeholder: field.placeholder,
      helpText: field.helpText,
      required: field.required,
      validation: field.validation,
      options: field.options,
      defaultValue: field.defaultValue,
      order: _fields.length,
      properties: field.properties,
    );
    setState(() {
      _fields.add(duplicated);
      _selectedField = duplicated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppConstants.routeLogin);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authProvider.user;
        final userName = user?.displayName ?? 'User';
        final userEmail = user?.email ?? '';
        final userRole = authProvider.userRole;

        // Admin-only access
        if (userRole != AppConstants.roleAdmin) {
          return MainLayout(
            currentRoute: '/form-config',
            onNavigate: (route) => context.go(route),
            userRole: userRole,
            userName: userName,
            userEmail: userEmail,
            onLogout: () async {
              await authProvider.signOut();
              if (context.mounted) context.go(AppConstants.routeLanding);
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 48, color: AppColors.textSecondary),
                  SizedBox(height: 12),
                  Text('Access Denied', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Only administrators can access Form Configuration.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        return MainLayout(
          currentRoute: '/form-config',
          onNavigate: (route) => context.go(route),
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
          onLogout: () async {
            await authProvider.signOut();
            if (context.mounted) context.go(AppConstants.routeLanding);
          },
          child: _buildContent(context, userEmail),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String userEmail) {
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
                      _fields = [];
                      _selectedField = null;
                    });
                    _loadFormConfig();
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
                            const SnackBar(content: Text('Form configuration saved')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
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
                            SnackBar(content: Text('Failed to publish: $e'), backgroundColor: AppColors.error),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Form Sections
                      _buildSectionsSidebar(),
                      const SizedBox(width: 16),
                      // Middle: Field Palette
                      _buildFieldPalette(),
                      const SizedBox(width: 16),
                      // Center: Form Canvas
                      Expanded(child: _buildFormCanvas()),
                      const SizedBox(width: 16),
                      // Right: Properties Panel
                      if (_selectedField != null) _buildPropertiesPanel(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionsSidebar() {
    return Container(
      width: 220,
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
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Text(
              'Form Sections',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          _buildSectionItem('introduction', 'Introduction', Icons.info_outline),
          _buildSectionItem('representative', 'Representative', Icons.person_outline),
          _buildSectionItem('organization', 'Organization', Icons.business_outlined),
          _buildSectionItem('transportation', 'Transportation', Icons.directions_car_outlined),
          _buildSectionItem('declarations', 'Declarations', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildSectionItem(String section, String label, IconData icon) {
    final isSelected = _selectedSection == section;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSection = section;
          _fields = [];
          _selectedField = null;
        });
        _loadFormConfig();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: isSelected ? const Border(left: BorderSide(color: AppColors.primary, width: 4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.textSecondary),
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

  Widget _buildFieldPalette() {
    return Container(
      width: 200,
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
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Text(
              'Field Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: FormFieldType.allTypes.map((fieldType) {
                return _buildFieldTypeItem(
                  fieldType['type'] as String,
                  fieldType['label'] as String,
                  fieldType['icon'] as String,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTypeItem(String type, String label, String iconName) {
    IconData icon;
    switch (iconName) {
      case 'text_fields':
        icon = Icons.text_fields;
        break;
      case 'notes':
        icon = Icons.notes;
        break;
      case 'email':
        icon = Icons.email;
        break;
      case 'phone':
        icon = Icons.phone;
        break;
      case 'numbers':
        icon = Icons.numbers;
        break;
      case 'calendar_today':
        icon = Icons.calendar_today;
        break;
      case 'arrow_drop_down_circle':
        icon = Icons.arrow_drop_down_circle;
        break;
      case 'radio_button_checked':
        icon = Icons.radio_button_checked;
        break;
      case 'check_box':
        icon = Icons.check_box;
        break;
      case 'upload_file':
        icon = Icons.upload_file;
        break;
      case 'title':
        icon = Icons.title;
        break;
      case 'subject':
        icon = Icons.subject;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _addField(type),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCanvas() {
    return Container(
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
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  _getSectionTitle(_selectedSection),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  '${_fields.length} fields',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: _fields.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline, size: 64, color: AppColors.textTertiary),
                        SizedBox(height: 16),
                        Text(
                          'No fields yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Click a field type to add it to the form',
                          style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _fields.length,
                    onReorder: _moveField,
                    itemBuilder: (context, index) {
                      final field = _fields[index];
                      final isSelected = _selectedField?.id == field.id;
                      return _buildFieldCard(field, isSelected, key: ValueKey(field.id));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(FormFieldModel field, bool isSelected, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedField = field;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.drag_indicator, size: 20, color: AppColors.textTertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          field.label,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                        if (field.required) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Required',
                              style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      field.type.toUpperCase(),
                      style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, size: 18),
                onPressed: () => _duplicateField(field),
                tooltip: 'Duplicate',
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => _deleteField(field.id),
                tooltip: 'Delete',
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    if (_selectedField == null) return const SizedBox.shrink();

    return Container(
      width: 320,
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
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Field Properties',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedField = null;
                    });
                  },
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Label
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Field Label',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _selectedField!.label),
                  onChanged: (value) {
                    _updateField(_selectedField!.copyWith(label: value));
                  },
                ),
                const SizedBox(height: 16),
                
                // Placeholder
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Placeholder Text',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _selectedField!.placeholder ?? ''),
                  onChanged: (value) {
                    _updateField(_selectedField!.copyWith(placeholder: value.isEmpty ? null : value));
                  },
                ),
                const SizedBox(height: 16),
                
                // Help Text
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Help Text',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: _selectedField!.helpText ?? ''),
                  maxLines: 2,
                  onChanged: (value) {
                    _updateField(_selectedField!.copyWith(helpText: value.isEmpty ? null : value));
                  },
                ),
                const SizedBox(height: 16),
                
                // Required Toggle
                SwitchListTile(
                  title: const Text('Required Field'),
                  value: _selectedField!.required,
                  onChanged: (value) {
                    _updateField(_selectedField!.copyWith(required: value));
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                
                // Options (for dropdown, radio, checkbox)
                if (_selectedField!.type == FormFieldType.dropdown ||
                    _selectedField!.type == FormFieldType.radio ||
                    _selectedField!.type == FormFieldType.checkbox) ...[
                  const Text(
                    'Options',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  ...(_selectedField!.options ?? []).asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              controller: TextEditingController(text: option),
                              onChanged: (value) {
                                final newOptions = List<String>.from(_selectedField!.options ?? []);
                                newOptions[index] = value;
                                _updateField(_selectedField!.copyWith(options: newOptions));
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () {
                              final newOptions = List<String>.from(_selectedField!.options ?? []);
                              newOptions.removeAt(index);
                              _updateField(_selectedField!.copyWith(options: newOptions));
                            },
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  TextButton.icon(
                    onPressed: () {
                      final newOptions = List<String>.from(_selectedField!.options ?? []);
                      newOptions.add('Option ${newOptions.length + 1}');
                      _updateField(_selectedField!.copyWith(options: newOptions));
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Option'),
                  ),
                ],
              ],
            ),
          ),
        ],
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

