import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar_service.dart';
import '../models/project_model.dart';
import '../models/form_field_model.dart';
import '../models/patient_entry_model.dart';
import '../models/field_value_model.dart';

class ProjectsRepository {
  final Isar _isar = IsarService.instance;
  final _uuid = const Uuid();

  // Projects CRUD
  Future<String> createProject(String name, String? description) async {
    final projectId = _uuid.v4();
    final project = ProjectModel()
      ..projectId = projectId
      ..name = name
      ..description = description
      ..createdAt = DateTime.now()
      ..entryCount = 0
      ..isArchived = false;

    await _isar.writeTxn(() async {
      await _isar.projectModels.put(project);
    });

    return projectId;
  }

  Stream<List<ProjectModel>> watchAllProjects() {
    return _isar.projectModels
        .where()
        .filter()
        .isArchivedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Stream<ProjectModel?> watchProject(String projectId) {
    return _isar.projectModels
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .watch(fireImmediately: true)
        .map((projects) => projects.isNotEmpty ? projects.first : null);
  }

  Future<ProjectModel?> getProject(String projectId) async {
    return await _isar.projectModels
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .findFirst();
  }

  Future<void> updateProject(String projectId, String name, String? description) async {
    await _isar.writeTxn(() async {
      final project = await getProject(projectId);
      if (project != null) {
        project.name = name;
        project.description = description;
        project.updatedAt = DateTime.now();
        await _isar.projectModels.put(project);
      }
    });
  }

  Future<void> deleteProject(String projectId) async {
    await _isar.writeTxn(() async {
      // Delete all related data
      await _deleteProjectData(projectId);
      
      // Delete project
      final project = await getProject(projectId);
      if (project != null) {
        await _isar.projectModels.delete(project.id);
      }
    });
  }

  Future<void> _deleteProjectData(String projectId) async {
    // Delete all fields
    final fields = await _isar.formFieldModels
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
    
    for (final field in fields) {
      await _isar.formFieldModels.delete(field.id);
    }

    // Delete all entries and their values
    final entries = await _isar.patientEntryModels
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .findAll();
    
    for (final entry in entries) {
      // Delete field values
      final values = await _isar.fieldValueModels
          .where()
          .filter()
          .entryIdEqualTo(entry.entryId)
          .findAll();
      
      for (final value in values) {
        await _isar.fieldValueModels.delete(value.id);
      }
      
      // Delete entry
      await _isar.patientEntryModels.delete(entry.id);
    }
  }

  // Form Fields CRUD
  Future<void> createFormField({
    required String projectId,
    required String label,
    required String fieldType,
    String? dropdownOptions,
    required int order,
    bool isRequired = false,
    String? hint,
  }) async {
    final fieldId = _uuid.v4();
    final field = FormFieldModel()
      ..fieldId = fieldId
      ..projectId = projectId
      ..label = label
      ..fieldType = fieldType
      ..dropdownOptions = dropdownOptions
      ..order = order
      ..isRequired = isRequired
      ..hint = hint
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.formFieldModels.put(field);
    });
  }

  Future<List<FormFieldModel>> getProjectFields(String projectId) async {
    return await _isar.formFieldModels
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .sortByOrder()
        .findAll();
  }

  Future<void> deleteFormField(String fieldId) async {
    await _isar.writeTxn(() async {
      final field = await _isar.formFieldModels
          .where()
          .filter()
          .fieldIdEqualTo(fieldId)
          .findFirst();
      
      if (field != null) {
        await _isar.formFieldModels.delete(field.id);
      }
    });
  }

  // Patient Entries CRUD
  Future<String> createNewPatientEntry(String projectId) async {
    final entryId = _uuid.v4();
    final entry = PatientEntryModel()
      ..entryId = entryId
      ..projectId = projectId
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.patientEntryModels.put(entry);
      
      // Update project entry count
      final project = await getProject(projectId);
      if (project != null) {
        project.entryCount++;
        await _isar.projectModels.put(project);
      }
    });

    return entryId;
  }

  Future<List<PatientEntryModel>> getProjectEntries(String projectId) async {
    return await _isar.patientEntryModels
        .where()
        .filter()
        .projectIdEqualTo(projectId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> deletePatientEntry(String entryId) async {
    await _isar.writeTxn(() async {
      final entry = await _isar.patientEntryModels
          .where()
          .filter()
          .entryIdEqualTo(entryId)
          .findFirst();
      
      if (entry != null) {
        // Delete all field values
        final values = await _isar.fieldValueModels
            .where()
            .filter()
            .entryIdEqualTo(entryId)
            .findAll();
        
        for (final value in values) {
          await _isar.fieldValueModels.delete(value.id);
        }
        
        // Update project entry count
        final project = await getProject(entry.projectId);
        if (project != null && project.entryCount > 0) {
          project.entryCount--;
          await _isar.projectModels.put(project);
        }
        
        // Delete entry
        await _isar.patientEntryModels.delete(entry.id);
      }
    });
  }

  // Field Values CRUD
  Future<void> saveFieldValue({
    required String entryId,
    required String fieldId,
    String? textValue,
    String? imagePath,
  }) async {
    await _isar.writeTxn(() async {
      // Check if value already exists
      final existing = await _isar.fieldValueModels
          .where()
          .filter()
          .entryIdEqualTo(entryId)
          .and()
          .fieldIdEqualTo(fieldId)
          .findFirst();

      if (existing != null) {
        // Update existing
        existing.textValue = textValue;
        existing.imagePath = imagePath;
        existing.updatedAt = DateTime.now();
        await _isar.fieldValueModels.put(existing);
      } else {
        // Create new
        final value = FieldValueModel()
          ..entryId = entryId
          ..fieldId = fieldId
          ..textValue = textValue
          ..imagePath = imagePath
          ..createdAt = DateTime.now();
        await _isar.fieldValueModels.put(value);
      }
    });
  }

  Future<Map<String, FieldValueModel>> getEntryValues(String entryId) async {
    final values = await _isar.fieldValueModels
        .where()
        .filter()
        .entryIdEqualTo(entryId)
        .findAll();

    return {for (var value in values) value.fieldId: value};
  }
  
  // Additional helper methods
  Future<ProjectModel?> getProjectById(String projectId) async {
    return await getProject(projectId);
  }
  
  Future<List<FormFieldModel>> getFormFields(String projectId) async {
    return await getProjectFields(projectId);
  }
  
  Future<void> updatePatientEntry(PatientEntryModel entry) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.patientEntryModels
          .where()
          .filter()
          .entryIdEqualTo(entry.entryId)
          .findFirst();
      
      if (existing != null) {
        existing.updatedAt = DateTime.now();
        await _isar.patientEntryModels.put(existing);
        
        // Save field values links
        await existing.fieldValuesLink.save();
      }
    });
  }
  
  Future<void> createPatientEntry(PatientEntryModel entry) async {
    await _isar.writeTxn(() async {
      await _isar.patientEntryModels.put(entry);
      
      // Save field values links
      await entry.fieldValuesLink.save();
      
      // Update project entry count
      final project = await getProject(entry.projectId);
      if (project != null) {
        project.entryCount++;
        await _isar.projectModels.put(project);
      }
    });
  }
  
  // Delete all data
  Future<void> deleteAllData() async {
    await _isar.writeTxn(() async {
      await _isar.projectModels.clear();
      await _isar.formFieldModels.clear();
      await _isar.patientEntryModels.clear();
      await _isar.fieldValueModels.clear();
    });
  }
}
