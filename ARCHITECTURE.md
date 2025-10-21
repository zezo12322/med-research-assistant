# Project Architecture / بنية المشروع

## Overview / نظرة عامة

<div dir="rtl">

يتبع هذا المشروع معمارية **Clean Architecture** مع **Feature-First Organization**، مما يجعل الكود منظمًا، قابلاً للصيانة، وسهل الاختبار.

</div>

---

## Directory Structure / هيكل المجلدات

```
med_research_assistant/
│
├── lib/
│   ├── main.dart                          # Entry point
│   │
│   ├── core/                              # Core functionality
│   │   ├── database/
│   │   │   └── isar_service.dart         # Database singleton
│   │   ├── theme/
│   │   │   └── app_theme.dart            # App-wide theme
│   │   └── utils/                         # Utility functions
│   │
│   └── features/                          # Feature modules
│       │
│       ├── auth/                          # Authentication feature
│       │   ├── providers/
│       │   │   └── auth_provider.dart    # Auth state management
│       │   └── presentation/
│       │       └── screens/
│       │           ├── lock_screen.dart
│       │           └── setup_pin_screen.dart
│       │
│       ├── projects/                      # Projects feature
│       │   ├── data/
│       │   │   ├── models/               # Data models (Isar)
│       │   │   │   ├── project_model.dart
│       │   │   │   ├── form_field_model.dart
│       │   │   │   ├── patient_entry_model.dart
│       │   │   │   └── field_value_model.dart
│       │   │   └── repositories/         # Data access layer
│       │   │       └── projects_repository.dart
│       │   ├── providers/
│       │   │   └── projects_provider.dart
│       │   └── presentation/
│       │       └── screens/
│       │           ├── projects_list_screen.dart
│       │           ├── create_project_screen.dart
│       │           ├── project_details_screen.dart
│       │           ├── form_builder_screen.dart
│       │           ├── data_entry_screen.dart
│       │           └── entries_list_screen.dart
│       │
│       └── export/                        # Export feature
│           ├── services/
│           │   └── csv_export_service.dart
│           └── presentation/
│               └── screens/
│                   └── export_screen.dart
│
├── assets/
│   ├── images/                            # Image assets
│   └── icons/                             # Icon assets
│
├── test/                                   # Unit & Widget tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── android/                                # Android configuration
├── ios/                                    # iOS configuration
│
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Linter rules
├── README.md                              # Main documentation
├── SETUP.md                               # Setup guide
├── QUICKSTART.md                          # Quick start guide
├── CONTRIBUTING.md                        # Contribution guidelines
├── CHANGELOG.md                           # Version history
├── TODO.md                                # Task list
└── LICENSE                                # MIT License
```

---

## Layer Architecture / طبقات المعمارية

### 1. Presentation Layer / طبقة العرض
```
presentation/
├── screens/          # Full page screens
├── widgets/          # Reusable widgets
└── providers/        # State management (Riverpod)
```

**Responsibility:** UI and user interaction

### 2. Domain Layer / طبقة المنطق
```
domain/
├── entities/         # Business objects
├── repositories/     # Abstract interfaces
└── use_cases/        # Business logic
```

**Responsibility:** Business rules (currently minimal)

### 3. Data Layer / طبقة البيانات
```
data/
├── models/           # Data models (Isar collections)
├── repositories/     # Repository implementations
└── services/         # External services
```

**Responsibility:** Data persistence and retrieval

---

## Design Patterns / أنماط التصميم

### 1. Repository Pattern
```dart
// Abstract interface (if needed in future)
abstract class ProjectsRepositoryInterface {
  Future<String> createProject(String name, String? description);
  Stream<List<ProjectModel>> watchAllProjects();
}

// Concrete implementation
class ProjectsRepository implements ProjectsRepositoryInterface {
  final Isar _isar = IsarService.instance;
  // Implementation...
}
```

### 2. Provider Pattern (Riverpod)
```dart
// Provider
final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository();
});

// StreamProvider
final projectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final repository = ref.watch(projectsRepositoryProvider);
  return repository.watchAllProjects();
});
```

### 3. Singleton Pattern
```dart
class IsarService {
  static late Isar _isar;
  static Isar get instance => _isar;
  
  static Future<void> initialize() async {
    // Initialize once
  }
}
```

---

## State Management / إدارة الحالة

### Riverpod Providers

```dart
// Simple Provider
final repositoryProvider = Provider((ref) => Repository());

// StateNotifier Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// StreamProvider (reactive)
final projectsProvider = StreamProvider<List<Project>>((ref) {
  return repository.watchProjects();
});

// FutureProvider
final projectProvider = FutureProvider.family<Project, String>((ref, id) {
  return repository.getProject(id);
});
```

---

## Database Schema / مخطط قاعدة البيانات

### Entities

```
ProjectModel
├── id (Id)
├── projectId (String, UUID)
├── name (String)
├── description (String?)
├── createdAt (DateTime)
├── updatedAt (DateTime?)
├── entryCount (int)
└── isArchived (bool)

FormFieldModel
├── id (Id)
├── fieldId (String, UUID)
├── projectId (String, FK)
├── label (String)
├── fieldType (String)
├── dropdownOptions (String?)
├── order (int)
├── isRequired (bool)
├── hint (String?)
└── createdAt (DateTime)

PatientEntryModel
├── id (Id)
├── entryId (String, UUID)
├── projectId (String, FK)
├── createdAt (DateTime)
└── updatedAt (DateTime?)

FieldValueModel
├── id (Id)
├── entryId (String, FK)
├── fieldId (String, FK)
├── textValue (String?)
├── imagePath (String?)
├── createdAt (DateTime)
└── updatedAt (DateTime?)
```

### Relationships

```
Project 1:N FormField
Project 1:N PatientEntry
PatientEntry 1:N FieldValue
FormField 1:N FieldValue
```

---

## Navigation Flow / تدفق التنقل

```
App Start
  ↓
LockScreen (PIN/Biometric)
  ↓
[Authenticated]
  ↓
ProjectsListScreen
  ├── CreateProjectScreen
  └── ProjectDetailsScreen
        ├── FormBuilderScreen
        ├── EntriesListScreen
        │     └── DataEntryScreen
        └── ExportScreen
```

---

## Security Architecture / معمارية الأمان

```
┌─────────────────────────────────────┐
│   App Entry Point                   │
│   - Splash Screen                   │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│   Lock Screen                       │
│   - PIN Input                       │
│   - Biometric Auth                  │
└────────────┬────────────────────────┘
             │
             ↓ [Authenticated]
┌─────────────────────────────────────┐
│   Main App                          │
│   - Encrypted Database (Isar)      │
│   - Secure Storage (Credentials)   │
│   - Offline First                  │
└─────────────────────────────────────┘
```

---

## Data Flow / تدفق البيانات

### Create Project Flow

```
User Input → CreateProjectScreen
           ↓
    ProjectsRepository.createProject()
           ↓
    Isar.writeTxn()
           ↓
    ProjectModel saved to DB
           ↓
    Stream updates (projectsProvider)
           ↓
    UI refreshes automatically
```

### Read Projects Flow

```
ProjectsListScreen
      ↓
ref.watch(projectsProvider)
      ↓
ProjectsRepository.watchAllProjects()
      ↓
Isar.watch() [Reactive Stream]
      ↓
Auto-updates on DB changes
```

---

## Error Handling / معالجة الأخطاء

```dart
// Repository Level
try {
  await _isar.writeTxn(() async {
    // Database operations
  });
} catch (e) {
  // Log error
  rethrow; // Let UI handle it
}

// UI Level
projectsAsync.when(
  data: (projects) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

---

## Testing Strategy / استراتيجية الاختبار

```
test/
├── unit/
│   ├── repositories/     # Test data access
│   ├── providers/        # Test state management
│   └── models/          # Test data models
│
├── widget/
│   └── screens/         # Test UI components
│
└── integration/
    └── flows/           # Test complete flows
```

---

## Performance Considerations / اعتبارات الأداء

1. **Database Indexing**
   - Indexed fields for fast queries
   - Composite indexes for complex queries

2. **Lazy Loading**
   - Load data on-demand
   - Pagination for large lists

3. **Image Optimization**
   - Compress images before storage
   - Thumbnail generation

4. **State Management**
   - Minimal rebuilds with Riverpod
   - Selective widget rebuilds

---

## Security Best Practices / أفضل ممارسات الأمان

1. **Authentication**
   - Mandatory PIN/Biometric
   - Session timeout (planned)

2. **Data Encryption**
   - Encrypted Isar database
   - Secure storage for credentials

3. **Offline First**
   - No network calls with sensitive data
   - All data stays on device

4. **Code Obfuscation**
   - Enable for production builds

---

## Future Architecture Plans / خطط المعمارية المستقبلية

1. **Clean Architecture Layers**
   - Separate domain layer
   - Use cases for business logic

2. **Dependency Injection**
   - More testable code
   - Easier to mock dependencies

3. **Multi-Module**
   - Separate packages for features
   - Better separation of concerns

4. **BLoC Pattern** (optional)
   - Alternative to Riverpod
   - More boilerplate but explicit

---

<div dir="rtl">

## الخلاصة

المشروع يستخدم معمارية نظيفة وحديثة تجعله:
- 📦 **قابل للصيانة**: كود منظم وواضح
- 🧪 **قابل للاختبار**: فصل المسؤوليات
- 🔄 **قابل للتوسع**: سهل إضافة ميزات جديدة
- 🔒 **آمن**: تشفير وحماية البيانات

</div>

---

**Last Updated:** 2024
