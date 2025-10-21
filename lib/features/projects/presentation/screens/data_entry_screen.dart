import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../data/models/form_field_model.dart';
import '../../data/models/patient_entry_model.dart';
import '../../providers/projects_provider.dart';

class DataEntryScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? entryId; // null for new entry, ID for editing

  const DataEntryScreen({
    super.key,
    required this.projectId,
    this.entryId,
  });

  @override
  ConsumerState<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends ConsumerState<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {}; // Store field values
  
  List<FormFieldModel> fields = [];
  PatientEntryModel? existingEntry;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final repository = ref.read(projectsRepositoryProvider);
    
    // Load form fields
    final loadedFields = await repository.getFormFields(widget.projectId);
    
    // If editing, load existing entry
    if (widget.entryId != null) {
      final entries = await repository.getProjectEntries(widget.projectId);
      existingEntry = entries.firstWhere((e) => e.entryId == widget.entryId);
      
      // Pre-fill values
      for (var fieldValue in existingEntry!.fieldValues) {
        _values[fieldValue.fieldId] = fieldValue.value;
      }
    }
    
    // Initialize controllers for text fields
    for (var field in loadedFields) {
      if (field.type == FieldType.text || field.type == FieldType.number) {
        _controllers[field.fieldId] = TextEditingController(
          text: _values[field.fieldId]?.toString() ?? '',
        );
      }
    }
    
    setState(() {
      fields = loadedFields;
      isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isSaving = true);

    try {
      final repository = ref.read(projectsRepositoryProvider);
      
      // Create or update entry
      if (widget.entryId != null) {
        // Update existing entry
        // Save field values for existing entry
        for (var field in fields) {
          dynamic value;
          
          if (field.type == FieldType.text || field.type == FieldType.number) {
            value = _controllers[field.fieldId]?.text ?? '';
          } else {
            value = _values[field.fieldId];
          }
          
          // Skip if value is null or empty
          if (value == null || value.toString().isEmpty) {
            continue;
          }
          
          await repository.saveFieldValue(
            entryId: widget.entryId!,
            fieldId: field.fieldId,
            textValue: value.toString(),
          );
        }
      } else {
        // Create new entry
        final entry = PatientEntryModel()
          ..entryId = const Uuid().v4()
          ..projectId = widget.projectId
          ..createdAt = DateTime.now();
        
        await repository.createPatientEntry(entry);
        
        // Save field values
        for (var field in fields) {
          dynamic value;
          
          if (field.type == FieldType.text || field.type == FieldType.number) {
            value = _controllers[field.fieldId]?.text ?? '';
          } else {
            value = _values[field.fieldId];
          }
          
          // Skip if value is null or empty
          if (value == null || value.toString().isEmpty) {
            continue;
          }
          
          await repository.saveFieldValue(
            entryId: entry.entryId,
            fieldId: field.fieldId,
            textValue: value.toString(),
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.entryId != null ? 'Entry updated' : 'Entry saved'),
          ),
        );
        Navigator.of(context).pop(true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _pickImage(String fieldId) async {
    final picker = ImagePicker();
    
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source != null) {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _values[fieldId] = image.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: isSaving ? null : _saveEntry,
              icon: isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              tooltip: 'Save Entry',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fields.isEmpty
              ? _buildNoFieldsState()
              : Column(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: fields.length,
                          itemBuilder: (context, index) {
                            final field = fields[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildFieldWidget(field),
                            );
                          },
                        ),
                      ),
                    ),
                    // Save button at bottom
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveEntry,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.entryId != null ? 'Update Entry' : 'Save Entry',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFieldWidget(FormFieldModel field) {
    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          controller: _controllers[field.fieldId],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          validator: field.isRequired
              ? (value) => value?.isEmpty ?? true ? 'Required' : null
              : null,
        );
        
      case FieldType.number:
        return TextFormField(
          controller: _controllers[field.fieldId],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: field.isRequired
              ? (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Enter valid number';
                  return null;
                }
              : null,
        );
        
      case FieldType.date:
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _values[field.fieldId] != null 
                  ? DateTime.parse(_values[field.fieldId])
                  : DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _values[field.fieldId] = date.toIso8601String();
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              _values[field.fieldId] != null
                  ? DateTime.parse(_values[field.fieldId]).toString().split(' ')[0]
                  : 'Select date',
              style: TextStyle(
                color: _values[field.fieldId] != null ? null : Colors.grey,
              ),
            ),
          ),
        );
        
      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          value: _values[field.fieldId],
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          items: field.options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _values[field.fieldId] = value;
            });
          },
          validator: field.isRequired
              ? (value) => value == null ? 'Required' : null
              : null,
        );
        
      case FieldType.boolean:
        return Card(
          child: SwitchListTile(
            title: Text(field.label),
            value: _values[field.fieldId] == 'true',
            onChanged: (value) {
              setState(() {
                _values[field.fieldId] = value.toString();
              });
            },
          ),
        );
        
      case FieldType.image:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_values[field.fieldId] != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_values[field.fieldId]),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _values[field.fieldId] = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(field.fieldId),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Image'),
                  ),
              ],
            ),
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNoFieldsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Form Fields',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please add fields to the form first',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
