import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/form_field_model.dart';
import '../../providers/projects_provider.dart';

class FormBuilderScreen extends ConsumerStatefulWidget {
  final String projectId;

  const FormBuilderScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends ConsumerState<FormBuilderScreen> {
  List<FormFieldModel> fields = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => isLoading = true);
    final repository = ref.read(projectsRepositoryProvider);
    final loadedFields = await repository.getProjectFields(widget.projectId);
    setState(() {
      fields = loadedFields;
      isLoading = false;
    });
  }

  Future<void> _showAddFieldDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddFieldDialog(),
    );

    if (result != null && mounted) {
      setState(() => isLoading = true);
      final repository = ref.read(projectsRepositoryProvider);
      
      await repository.createFormField(
        projectId: widget.projectId,
        label: result['label'],
        fieldType: result['fieldType'],
        dropdownOptions: result['dropdownOptions'],
        order: fields.length,
        isRequired: result['isRequired'] ?? false,
        hint: result['hint'],
      );

      await _loadFields();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field added successfully!')),
        );
      }
    }
  }

  Future<void> _deleteField(String fieldId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Field?'),
        content: const Text('Are you sure you want to delete this field?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repository = ref.read(projectsRepositoryProvider);
      await repository.deleteFormField(fieldId);
      await _loadFields();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Field deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Builder'),
        actions: [
          if (fields.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () {
                // Preview form
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${fields.length} fields configured')),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : fields.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: fields.length,
                  onReorder: (oldIndex, newIndex) async {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = fields.removeAt(oldIndex);
                      fields.insert(newIndex, item);
                    });
                    // Update order in database would go here
                  },
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return Card(
                      key: ValueKey(field.fieldId),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getFieldColor(field.fieldType).withOpacity(0.2),
                          child: Icon(
                            _getFieldIcon(field.fieldType),
                            color: _getFieldColor(field.fieldType),
                          ),
                        ),
                        title: Text(
                          field.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(FieldType.getDisplayName(field.fieldType)),
                            if (field.isRequired)
                              const Text(
                                'Required',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            if (field.dropdownOptions != null)
                              Text(
                                'Options: ${field.dropdownOptions}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.drag_handle, color: Colors.grey.shade400),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteField(field.fieldId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFieldDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Field'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Fields Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add fields to design your data collection form',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddFieldDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add First Field'),
          ),
        ],
      ),
    );
  }

  IconData _getFieldIcon(String fieldType) {
    switch (fieldType) {
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.number:
        return Icons.numbers;
      case FieldType.date:
        return Icons.calendar_today;
      case FieldType.dropdown:
        return Icons.arrow_drop_down_circle;
      case FieldType.boolean:
        return Icons.toggle_on;
      case FieldType.image:
        return Icons.image;
      default:
        return Icons.help_outline;
    }
  }

  Color _getFieldColor(String fieldType) {
    switch (fieldType) {
      case FieldType.text:
        return Colors.blue;
      case FieldType.number:
        return Colors.green;
      case FieldType.date:
        return Colors.orange;
      case FieldType.dropdown:
        return Colors.purple;
      case FieldType.boolean:
        return Colors.teal;
      case FieldType.image:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

class _AddFieldDialog extends StatefulWidget {
  @override
  State<_AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<_AddFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _hintController = TextEditingController();
  final _optionsController = TextEditingController();
  
  String _selectedType = FieldType.text;
  bool _isRequired = false;

  @override
  void dispose() {
    _labelController.dispose();
    _hintController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Field'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Field Label *',
                  hintText: 'e.g., Patient ID, Age, Blood Type',
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Field Type'),
                items: FieldType.all.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(FieldType.getDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hintController,
                decoration: const InputDecoration(
                  labelText: 'Hint (Optional)',
                  hintText: 'Helper text for this field',
                ),
              ),
              if (_selectedType == FieldType.dropdown) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Options (comma-separated) *',
                    hintText: 'A+,A-,B+,B-,O+,O-,AB+,AB-',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required for dropdown' : null,
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Required Field'),
                value: _isRequired,
                onChanged: (value) {
                  setState(() => _isRequired = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'label': _labelController.text.trim(),
                'fieldType': _selectedType,
                'hint': _hintController.text.trim(),
                'dropdownOptions': _selectedType == FieldType.dropdown
                    ? _optionsController.text.trim()
                    : null,
                'isRequired': _isRequired,
              });
            }
          },
          child: const Text('Add Field'),
        ),
      ],
    );
  }
}
