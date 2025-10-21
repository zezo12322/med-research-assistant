import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import '../../../projects/providers/projects_provider.dart';
import '../../../projects/data/models/form_field_model.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ExportScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool isExporting = false;
  String? exportedFilePath;
  int totalEntries = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final repository = ref.read(projectsRepositoryProvider);
    final entries = await repository.getProjectEntries(widget.projectId);
    if (mounted) {
      setState(() {
        totalEntries = entries.length;
      });
    }
  }

  Future<void> _exportToCSV() async {
    if (totalEntries == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
      }
      return;
    }

    setState(() => isExporting = true);

    try {
      final repository = ref.read(projectsRepositoryProvider);
      
      // Get project details
      final project = await repository.getProjectById(widget.projectId);
      if (project == null) throw Exception('Project not found');
      
      // Get all entries
      final entries = await repository.getProjectEntries(widget.projectId);
      if (entries.isEmpty) throw Exception('No entries to export');
      
      // Get form fields
      final fields = await repository.getFormFields(widget.projectId);
      if (fields.isEmpty) throw Exception('No form fields defined');
      
      // Sort fields by order
      fields.sort((a, b) => a.order.compareTo(b.order));
      
      // Build CSV data
      List<List<dynamic>> csvData = [];
      
      // Header row
      List<String> headers = ['Entry ID', 'Created Date'];
      headers.addAll(fields.map((f) => f.label));
      csvData.add(headers);
      
      // Data rows
      for (var entry in entries) {
        List<dynamic> row = [
          entry.entryId.substring(0, 8), // Short ID
          entry.createdAt.toString().split('.')[0], // Remove milliseconds
        ];
        
        // Add field values in order
        for (var field in fields) {
          final fieldValue = entry.fieldValues.where(
            (fv) => fv.fieldId == field.fieldId,
          ).firstOrNull;
          
          String value = '';
          if (fieldValue != null) {
            value = fieldValue.value;
            
            // Handle different field types
            if (field.type == FieldType.date && value.isNotEmpty) {
              try {
                final date = DateTime.parse(value);
                value = date.toString().split(' ')[0]; // Date only
              } catch (_) {}
            } else if (field.type == FieldType.image) {
              value = value.isNotEmpty ? '[Image]' : '';
            }
          }
          
          row.add(value);
        }
        
        csvData.add(row);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${project.name.replaceAll(' ', '_')}_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv);
      
      if (mounted) {
        setState(() {
          exportedFilePath = file.path;
          isExporting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    if (exportedFilePath == null) return;
    
    try {
      await Share.shareXFiles(
        [XFile(exportedFilePath!)],
        subject: 'Medical Research Data Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.file_download,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export to CSV',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total entries: $totalEntries',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: isExporting ? null : _exportToCSV,
                      icon: isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download),
                      label: Text(isExporting ? 'Exporting...' : 'Export CSV'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (exportedFilePath != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'Export Successful!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File saved to:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        exportedFilePath!,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _shareFile,
                        icon: const Icon(Icons.share),
                        label: const Text('Share File'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'CSV Export Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Exports all patient entries'),
                    const Text('• Includes all form fields'),
                    const Text('• Compatible with Excel, Google Sheets'),
                    const Text('• Images are marked as [Image]'),
                    const Text('• File is saved locally for sharing'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
