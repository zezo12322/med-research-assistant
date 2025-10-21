# Contributing to Med Research Assistant
# المساهمة في مساعد الباحث الطبي

Thank you for considering contributing to this project! / شكراً لاهتمامك بالمساهمة في هذا المشروع!

## How to Contribute / كيفية المساهمة

### 1. Fork the Repository

1. Click the "Fork" button on GitHub
2. Clone your fork locally:
```bash
git clone https://github.com/your-username/med-research-assistant.git
cd med-research-assistant
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 3. Make Your Changes

- Write clean, readable code
- Follow the existing code style
- Add comments where necessary
- Update documentation if needed

### 4. Test Your Changes

```bash
flutter test
flutter analyze
flutter format lib/
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "feat: Add your feature description"
```

**Commit Message Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Code Style Guidelines / إرشادات نمط الكود

### Dart/Flutter Style

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good
class ProjectModel {
  final String projectId;
  final String name;
  
  ProjectModel({
    required this.projectId,
    required this.name,
  });
}

// ❌ Bad
class project_model {
  String project_id;
  String Name;
}
```

### File Naming

- Use `snake_case` for file names: `project_model.dart`
- Use `PascalCase` for class names: `ProjectModel`
- Use `camelCase` for variables: `projectId`

### Code Organization

```dart
// 1. Imports (organized)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_file.dart';

// 2. Class definition
class MyWidget extends ConsumerWidget {
  // 3. Constructor
  const MyWidget({super.key});
  
  // 4. Build method
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation
  }
  
  // 5. Helper methods
  void _helperMethod() {
    // Implementation
  }
}
```

---

## Areas That Need Help / المجالات التي تحتاج مساعدة

### 🔴 High Priority

1. **Form Builder Screen** - Complete implementation
2. **Data Entry Screen** - Dynamic form rendering
3. **CSV Export** - Full implementation with all field types
4. **Testing** - Unit and widget tests

### 🟡 Medium Priority

1. **UI/UX Improvements** - Animations, transitions
2. **Arabic Localization** - RTL support
3. **Image Compression** - Reduce storage size
4. **Documentation** - More examples and guides

### 🟢 Low Priority

1. **Dark Mode** - Complete theme implementation
2. **Cloud Sync** - Optional backup feature
3. **Advanced Features** - Charts, statistics

---

## Reporting Bugs / الإبلاغ عن الأخطاء

When reporting bugs, please include:

1. **Description** - What happened?
2. **Steps to Reproduce** - How can we reproduce it?
3. **Expected Behavior** - What should happen?
4. **Actual Behavior** - What actually happened?
5. **Screenshots** - If applicable
6. **Environment**:
   - Flutter version: `flutter --version`
   - Device/Emulator
   - OS (Android/iOS version)

**Example:**

```markdown
## Bug: App crashes when adding image

**Steps to Reproduce:**
1. Open a project
2. Add new entry
3. Click on image field
4. App crashes

**Expected:** Image picker should open
**Actual:** App crashes with error: [error message]

**Environment:**
- Flutter 3.16.0
- Android 13
- Physical device: Samsung Galaxy S21
```

---

## Feature Requests / طلبات الميزات

When requesting features:

1. **Use Case** - Why do you need this feature?
2. **Description** - What should it do?
3. **Mockups/Examples** - Visual representation (if applicable)
4. **Priority** - How important is this?

---

## Development Setup / إعداد بيئة التطوير

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- VS Code or Android Studio
- Git

### Setup Steps

```bash
# 1. Clone repository
git clone https://github.com/yourusername/med-research-assistant.git
cd med-research-assistant

# 2. Install dependencies
flutter pub get

# 3. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

### Recommended VS Code Extensions

- Flutter
- Dart
- Flutter Riverpod Snippets
- Error Lens
- GitLens

---

## Pull Request Guidelines / إرشادات طلبات السحب

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] Tests pass: `flutter test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Code is formatted: `flutter format lib/`
- [ ] Documentation is updated
- [ ] Commit messages are clear

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How was this tested?

## Screenshots (if applicable)
[Add screenshots]

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have tested my changes
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
```

---

## Review Process / عملية المراجعة

1. **Submission** - You submit a PR
2. **Review** - Maintainers review your code
3. **Feedback** - Address any requested changes
4. **Approval** - PR is approved
5. **Merge** - Changes are merged into main branch

---

## Code of Conduct / قواعد السلوك

### Our Standards

✅ **Do:**
- Be respectful and professional
- Provide constructive feedback
- Welcome newcomers
- Focus on what is best for the community

❌ **Don't:**
- Use inappropriate language
- Harass or discriminate
- Publish others' private information
- Engage in trolling or inflammatory behavior

---

## Questions? / أسئلة؟

- **GitHub Issues** - For bugs and features
- **GitHub Discussions** - For general questions
- **Email** - your.email@example.com

---

## Recognition / التقدير

Contributors will be added to the README.md file.

Thank you for contributing! / شكراً للمساهمة! 🙏

---

**Happy Contributing! / مساهمة سعيدة!** 🚀
