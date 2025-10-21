# Setup & Installation Guide
# دليل الإعداد والتثبيت

## Quick Start Guide / البدء السريع

### Step 1: Install Dependencies / الخطوة 1: تثبيت المكتبات

```bash
flutter pub get
```

### Step 2: Generate Code / الخطوة 2: توليد الكود

```bash
# Generate Isar database schemas and Riverpod providers
flutter pub run build_runner build --delete-conflicting-outputs

# Or use watch mode during development
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Step 3: Run the App / الخطوة 3: تشغيل التطبيق

```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices  # List all devices
flutter run -d <device-id>

# Run in release mode (recommended for testing performance)
flutter run --release
```

---

## Platform-Specific Configuration / الإعدادات الخاصة بكل منصة

### Android Configuration

#### 1. Update `android/app/src/main/AndroidManifest.xml`

Add permissions inside the `<manifest>` tag:

```xml
<!-- Required Permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

<!-- Android 13+ permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

#### 2. Update `android/app/build.gradle`

Ensure minimum SDK version:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for local_auth
        targetSdkVersion 33
    }
}
```

#### 3. Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (production)
flutter build apk --release

# Install on connected device
flutter install
```

---

### iOS Configuration

#### 1. Update `ios/Runner/Info.plist`

Add these keys:

```xml
<!-- Face ID / Touch ID -->
<key>NSFaceIDUsageDescription</key>
<string>Authenticate to access secure medical research data</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Take photos of medical documents and X-rays</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Select medical images from your library</string>

<!-- Photo Library Add -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save captured medical images</string>
```

#### 2. Update iOS Deployment Target

In `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

#### 3. Install CocoaPods

```bash
cd ios
pod install
cd ..
```

#### 4. Build iOS

```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Or build from command line
flutter build ios --release
```

---

## Development Setup / إعداد بيئة التطوير

### VS Code Extensions (Recommended)

1. **Flutter** (Dart-Code.flutter)
2. **Dart** (Dart-Code.dart-code)
3. **Flutter Riverpod Snippets**
4. **Error Lens** (for better error visibility)

### VS Code Settings

Create `.vscode/settings.json`:

```json
{
  "dart.lineLength": 100,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

---

## Code Generation Commands / أوامر توليد الكود

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (recommended during development)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

---

## Database Management / إدارة قاعدة البيانات

### View Database (Development)

Use Isar Inspector in debug mode:

```bash
flutter run --debug
```

Then open: http://localhost:9090 (or check console for URL)

### Reset Database

To clear all data during development:

```dart
// In your code
await IsarService.clearAllData();
```

---

## Common Issues & Solutions / المشاكل الشائعة والحلول

### Issue 1: Build Runner Errors

```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue 2: Isar Not Found

```bash
# Make sure you have generated the schema files
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue 3: Local Auth Not Working (Android)

**Solution:** Ensure you have:
- Added USE_BIOMETRIC permission in AndroidManifest.xml
- minSdkVersion 21 or higher
- Physical device with fingerprint/face unlock set up

### Issue 4: Camera Permission Denied (iOS)

**Solution:** 
- Check Info.plist has all required keys
- Uninstall app and reinstall (permissions reset)
- Check iOS Settings > Privacy > Camera

### Issue 5: CSV Export Not Working

**Solution:**
- Check storage permissions in AndroidManifest.xml
- For Android 11+, add in AndroidManifest.xml:

```xml
<application
    android:requestLegacyExternalStorage="true">
```

---

## Testing / الاختبار

### Run Unit Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

### Check Code Quality

```bash
# Analyze code
flutter analyze

# Check formatting
flutter format --set-exit-if-changed lib/

# Fix formatting
flutter format lib/
```

---

## Build for Production / البناء للإنتاج

### Android (APK)

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (IPA)

```bash
# Build release iOS
flutter build ios --release

# Then archive in Xcode:
# 1. Open ios/Runner.xcworkspace in Xcode
# 2. Product > Archive
# 3. Distribute App
```

---

## Performance Optimization / تحسين الأداء

### 1. Enable Code Obfuscation

```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### 2. Reduce APK Size

```bash
# Build separate APKs per architecture
flutter build apk --split-per-abi --release
```

### 3. Profile Performance

```bash
flutter run --profile
```

Then use Flutter DevTools.

---

## Deployment Checklist / قائمة التحقق قبل النشر

### Before Release:

- [ ] Test on multiple devices (Android & iOS)
- [ ] Test all authentication flows (PIN + Biometric)
- [ ] Test database encryption
- [ ] Test CSV export functionality
- [ ] Test image capture and storage
- [ ] Test offline functionality
- [ ] Check app permissions
- [ ] Update version in pubspec.yaml
- [ ] Test on different Android API levels (21-33)
- [ ] Test on different iOS versions (12+)
- [ ] Remove all debug prints
- [ ] Run `flutter analyze` with no errors
- [ ] Test app icon and splash screen
- [ ] Verify app name and bundle identifier

---

## Maintenance / الصيانة

### Update Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update to latest compatible versions
flutter pub upgrade

# Update to latest (including breaking changes)
flutter pub upgrade --major-versions
```

### Flutter Upgrade

```bash
flutter upgrade
flutter doctor -v
```

---

## Support & Resources / الدعم والموارد

### Official Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Isar Database](https://isar.dev)
- [Riverpod Documentation](https://riverpod.dev)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)

---

## License

This project is licensed under the MIT License.

---

**Good Luck! / بالتوفيق!** 🚀
