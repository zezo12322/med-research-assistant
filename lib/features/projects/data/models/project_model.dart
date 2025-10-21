import 'package:isar/isar.dart';

part 'project_model.g.dart';

@collection
class ProjectModel {
  Id id = Isar.autoIncrement;
  
  late String projectId; // UUID
  late String name;
  String? description;
  late DateTime createdAt;
  DateTime? updatedAt;
  
  // Number of patients/entries in this project
  int entryCount = 0;
  
  // Whether this project is archived
  bool isArchived = false;
  
  @Index(unique: true)
  String get uniqueProjectId => projectId;
}
