import 'package:isar/isar.dart';

part 'field_value_model.g.dart';

@collection
class FieldValueModel {
  Id id = Isar.autoIncrement;
  
  late String entryId; // Foreign key to patient entry
  late String fieldId; // Foreign key to form field
  
  // Store all values as strings, convert when needed
  String? textValue;
  String? imagePath; // For image fields, store local path
  
  late DateTime createdAt;
  DateTime? updatedAt;
  
  @Index()
  String get entryFieldIndex => '$entryId-$fieldId';
  
  // Helper getter for value (returns textValue or imagePath based on what's set)
  @ignore
  String get value => textValue ?? imagePath ?? '';
}
