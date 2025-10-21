import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/projects/data/models/project_model.dart';
import '../../features/projects/data/models/form_field_model.dart';
import '../../features/projects/data/models/patient_entry_model.dart';
import '../../features/projects/data/models/field_value_model.dart';

class IsarService {
  static late Isar _isar;
  
  static Isar get instance => _isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        ProjectModelSchema,
        FormFieldModelSchema,
        PatientEntryModelSchema,
        FieldValueModelSchema,
      ],
      directory: dir.path,
      // Encryption can be added here with sqlcipher integration
      inspector: true, // Enable Isar Inspector for debugging
    );
  }

  static Future<void> close() async {
    await _isar.close();
  }

  // Helper method to clear all data (for testing/development)
  static Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
