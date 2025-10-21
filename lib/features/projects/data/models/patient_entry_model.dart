import 'package:isar/isar.dart';
import 'field_value_model.dart';

part 'patient_entry_model.g.dart';

@collection
class PatientEntryModel {
  Id id = Isar.autoIncrement;
  
  late String entryId; // UUID
  late String projectId; // Foreign key to project
  late DateTime createdAt;
  DateTime? updatedAt;
  
  @Index(unique: true)
  String get uniqueEntryId => entryId;
  
  @Index()
  String get projectEntryIndex => projectId;
  
  // Link to field values (many-to-many relationship)
  final fieldValuesLink = IsarLinks<FieldValueModel>();
  
  // Helper getter for field values
  @ignore
  List<FieldValueModel> get fieldValues => fieldValuesLink.toList();
}
