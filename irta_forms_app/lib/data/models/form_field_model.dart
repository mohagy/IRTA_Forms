/// Model representing a form field in the form builder
class FormFieldModel {
  final String id;
  final String type;
  final String label;
  final String? placeholder;
  final String? helpText;
  final bool required;
  final Map<String, dynamic>? validation;
  final List<String>? options; // For dropdown, radio, checkbox
  final String? defaultValue;
  final int order;
  final Map<String, dynamic>? properties; // Additional field-specific properties

  FormFieldModel({
    required this.id,
    required this.type,
    required this.label,
    this.placeholder,
    this.helpText,
    this.required = false,
    this.validation,
    this.options,
    this.defaultValue,
    required this.order,
    this.properties,
  });

  factory FormFieldModel.fromMap(Map<String, dynamic> map) {
    return FormFieldModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'text',
      label: map['label'] ?? '',
      placeholder: map['placeholder'],
      helpText: map['helpText'],
      required: map['required'] ?? false,
      validation: map['validation'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      defaultValue: map['defaultValue'],
      order: map['order'] ?? 0,
      properties: map['properties'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'placeholder': placeholder,
      'helpText': helpText,
      'required': required,
      'validation': validation,
      'options': options,
      'defaultValue': defaultValue,
      'order': order,
      'properties': properties,
    };
  }

  FormFieldModel copyWith({
    String? id,
    String? type,
    String? label,
    String? placeholder,
    String? helpText,
    bool? required,
    Map<String, dynamic>? validation,
    List<String>? options,
    String? defaultValue,
    int? order,
    Map<String, dynamic>? properties,
  }) {
    return FormFieldModel(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      helpText: helpText ?? this.helpText,
      required: required ?? this.required,
      validation: validation ?? this.validation,
      options: options ?? this.options,
      defaultValue: defaultValue ?? this.defaultValue,
      order: order ?? this.order,
      properties: properties ?? this.properties,
    );
  }
}

/// Available field types in the form builder
class FormFieldType {
  static const String text = 'text';
  static const String textarea = 'textarea';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String number = 'number';
  static const String date = 'date';
  static const String dropdown = 'dropdown';
  static const String radio = 'radio';
  static const String checkbox = 'checkbox';
  static const String fileUpload = 'file_upload';
  static const String heading = 'heading';
  static const String paragraph = 'paragraph';

  static const List<Map<String, dynamic>> allTypes = [
    {'type': text, 'label': 'Text Input', 'icon': 'text_fields'},
    {'type': textarea, 'label': 'Text Area', 'icon': 'notes'},
    {'type': email, 'label': 'Email', 'icon': 'email'},
    {'type': phone, 'label': 'Phone', 'icon': 'phone'},
    {'type': number, 'label': 'Number', 'icon': 'numbers'},
    {'type': date, 'label': 'Date', 'icon': 'calendar_today'},
    {'type': dropdown, 'label': 'Dropdown', 'icon': 'arrow_drop_down_circle'},
    {'type': radio, 'label': 'Radio Buttons', 'icon': 'radio_button_checked'},
    {'type': checkbox, 'label': 'Checkboxes', 'icon': 'check_box'},
    {'type': fileUpload, 'label': 'File Upload', 'icon': 'upload_file'},
    {'type': heading, 'label': 'Heading', 'icon': 'title'},
    {'type': paragraph, 'label': 'Paragraph', 'icon': 'subject'},
  ];
}

