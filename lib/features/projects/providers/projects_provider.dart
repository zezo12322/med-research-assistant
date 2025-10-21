import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/projects_repository.dart';
import '../data/models/project_model.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository();
});

final projectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final repository = ref.watch(projectsRepositoryProvider);
  return repository.watchAllProjects();
});

final projectProvider = StreamProvider.family<ProjectModel?, String>((ref, projectId) {
  final repository = ref.watch(projectsRepositoryProvider);
  return repository.watchProject(projectId);
});
