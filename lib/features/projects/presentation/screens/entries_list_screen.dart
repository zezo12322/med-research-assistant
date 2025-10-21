import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/patient_entry_model.dart';
import '../../providers/projects_provider.dart';
import 'data_entry_screen.dart';

class EntriesListScreen extends ConsumerStatefulWidget {
  final String projectId;

  const EntriesListScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<EntriesListScreen> createState() => _EntriesListScreenState();
}

class _EntriesListScreenState extends ConsumerState<EntriesListScreen> {
  List<PatientEntryModel> entries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => isLoading = true);
    final repository = ref.read(projectsRepositoryProvider);
    final loadedEntries = await repository.getProjectEntries(widget.projectId);
    setState(() {
      entries = loadedEntries;
      isLoading = false;
    });
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This will permanently delete this patient entry and all its data.'),
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
      await repository.deletePatientEntry(entryId);
      await _loadEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
      }
    }
  }

  void _navigateToDataEntry({String? entryId}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DataEntryScreen(
          projectId: widget.projectId,
          entryId: entryId,
        ),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Entries'),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search feature coming soon')),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadEntries,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            'Entry ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('ID: ${entry.entryId.substring(0, 8)}...'),
                              Text('Created: ${DateFormat('MMM d, yyyy - HH:mm').format(entry.createdAt)}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToDataEntry(entryId: entry.entryId);
                              } else if (value == 'delete') {
                                _deleteEntry(entry.entryId);
                              }
                            },
                          ),
                          onTap: () => _navigateToDataEntry(entryId: entry.entryId),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToDataEntry(),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Entries Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first patient entry',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToDataEntry(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Entry'),
          ),
        ],
      ),
    );
  }
}
