import 'package:isar/isar.dart';

part 'form_field_model.g.dart';

@collection
class FormFieldModel {
  Id id = Isar.autoIncrement;
  
  late String fieldId; // UUID
  late String projectId; // Foreign key to project
  late String label; // Field label (e.g., "Patient ID", "Age")
  late String fieldType; // text, number, date, dropdown, boolean, image
  
  // For dropdown fields, store options as comma-separated values
  String? dropdownOptions; // e.g., "A,B,O,AB"
  
  // Field order in the form
  late int order;
  
  // Whether this field is required
  bool isRequired = false;
  
  // Placeholder or hint text
  String? hint;
  
  late DateTime createdAt;
  
  @Index()
  String get projectFieldIndex => projectId;
  
  // Helper getters
  @ignore
  String get type => fieldType;
  
  @ignore
  List<String> get options {
    if (dropdownOptions == null || dropdownOptions!.isEmpty) {
      return [];
    }
    return dropdownOptions!.split(',').map((s) => s.trim()).toList();
  }
}

// Field type constants
class FieldType {
  static const String text = 'text';
  static const String number = 'number';
  static const String date = 'date';
  static const String dropdown = 'dropdown';
  static const String boolean = 'boolean';
  static const String image = 'image';
  
  static List<String> get all => [text, number, date, dropdown, boolean, image];
  
  static String getDisplayName(String type) {
    switch (type) {
      case text:
        return 'Text';
      case number:
        return 'Number';
      case date:
        return 'Date';
      case dropdown:
        return 'Dropdown';
      case boolean:
        return 'Yes/No';
      case image:
        return 'Image';
      default:
        return 'Unknown';
    }
  }
}

