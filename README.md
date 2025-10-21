# Med Research Assistant 🏥

A professional Flutter application for secure medical research data collection with advanced features and comprehensive data management.

[![Flutter](https://img.shields.io/badge/Flutter-3.35.6-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Overview

Med Research Assistant is an offline-first mobile application designed for medical professionals and researchers to collect, manage, and export patient data securely. Built with Flutter and following Clean Architecture principles.

## ✨ Key Features

### 🔒 **Security First - الأمان أولاً**
- **PIN & Biometric Authentication**: شاشة قفل إلزامية مع دعم البصمة/Face ID
- **Encrypted Local Database**: قاعدة بيانات مشفرة محليًا باستخدام Isar
- **Secure Storage**: تخزين آمن للبيانات الحساسة باستخدام Flutter Secure Storage
- **Offline-First**: جميع البيانات محفوظة محليًا بدون الحاجة للإنترنت

### 📊 **Dynamic Form Builder - بناء النماذج الديناميكية**
- Create custom research forms with multiple field types
- إنشاء نماذج بحثية مخصصة مع أنواع حقول متعددة:
  - **Text** - نصوص (مثل: Patient ID)
  - **Number** - أرقام (مثل: Age, Weight)
  - **Date** - تواريخ (مثل: Surgery Date)
  - **Dropdown** - قوائم اختيار (مثل: Blood Type)
  - **Yes/No** - نعم/لا (مثل: Complications?)
  - **Image** - صور (مثل: X-Rays, Scans)

### 📁 **Projects Management - إدارة المشاريع**
- Create multiple research projects
- Track patient entries per project
- Archive/manage completed studies
- Visual project dashboard

### 📝 **Fast Data Entry - إدخال بيانات سريع**
- Dynamic forms based on your custom fields
- Large buttons optimized for busy doctors
- Camera & gallery integration for medical images
- Validation to prevent data entry errors

### 📤 **CSV Export - التصدير لملفات Excel**
- **One-click CSV export** ready for SPSS/Excel analysis
- Export all project data with proper formatting
- Share exported files directly from the app
- Preserves data structure for statistical analysis

## 🏗️ Architecture / البنية المعمارية

```
lib/
├── core/
│   ├── database/
│   │   └── isar_service.dart          # Encrypted database service
│   └── theme/
│       └── app_theme.dart             # Material Design 3 theme
│
├── features/
│   ├── auth/                          # Authentication & Security
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── lock_screen.dart
│   │           └── setup_pin_screen.dart
│   │
│   ├── projects/                      # Research Projects
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── project_model.dart
│   │   │   │   ├── form_field_model.dart
│   │   │   │   ├── patient_entry_model.dart
│   │   │   │   └── field_value_model.dart
│   │   │   └── repositories/
│   │   │       └── projects_repository.dart
│   │   ├── providers/
│   │   │   └── projects_provider.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── projects_list_screen.dart
│   │           ├── create_project_screen.dart
│   │           ├── project_details_screen.dart
│   │           ├── form_builder_screen.dart
│   │           ├── data_entry_screen.dart
│   │           └── entries_list_screen.dart
│   │
│   └── export/                        # CSV Export Feature
│       ├── services/
│       │   └── csv_export_service.dart
│       └── providers/
│           └── export_provider.dart
│
└── main.dart
```

## 🚀 Getting Started / البدء

### Prerequisites / المتطلبات

```bash
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0
```

### Installation / التثبيت

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/med-research-assistant.git
cd med-research-assistant
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate code (for Isar database):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app:**
```bash
flutter run
```

### Platform-Specific Setup

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- For Biometric Authentication -->
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>

<!-- For Camera Access -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- For Storage -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<!-- Face ID -->
<key>NSFaceIDUsageDescription</key>
<string>Authenticate to access medical research data</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Take photos of medical documents</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Select medical images</string>
```

## 📦 Key Dependencies / المكتبات الأساسية

```yaml
# State Management
flutter_riverpod: ^2.5.1

# Local Database (Encrypted)
isar: ^3.1.0+1
isar_flutter_libs: ^3.1.0+1

# Security & Authentication
local_auth: ^2.2.0
flutter_secure_storage: ^9.2.2

# Image Handling
image_picker: ^1.1.2
camera: ^0.10.6

# Data Export
csv: ^6.0.0
share_plus: ^9.0.0

# UI/UX
google_fonts: ^6.2.1
intl: ^0.19.0
```

## 🎯 Usage Guide / دليل الاستخدام

<div dir="rtl">

### 1. الإعداد الأولي

- عند فتح التطبيق لأول مرة، ستظهر لك شاشة إنشاء PIN
- أدخل رمز PIN مكون من 4-6 أرقام
- يمكنك استخدام البصمة أو Face ID إذا كان جهازك يدعمها

### 2. إنشاء مشروع بحثي جديد

1. اضغط على زر "New Project" في الشاشة الرئيسية
2. أدخل اسم المشروع (مثل: "دراسة جراحة الأعصاب - بني سويف")
3. أضف وصفًا اختياريًا للمشروع
4. اضغط "Create"

### 3. تصميم النموذج (Form Builder)

1. افتح المشروع واضغط "Design Form"
2. أضف الحقول التي تحتاجها:
   - **Patient ID** (Text)
   - **Age** (Number)
   - **Surgery Date** (Date)
   - **Blood Type** (Dropdown: A, B, O, AB)
   - **Complications** (Yes/No)
   - **X-Ray Image** (Image)
3. رتب الحقول بالترتيب المطلوب
4. احفظ النموذج

### 4. إدخال بيانات المرضى

1. افتح المشروع واضغط "Add Entry"
2. املأ جميع الحقول المطلوبة
3. أضف الصور من الكاميرا أو المعرض
4. احفظ البيانات

### 5. تصدير البيانات لـ Excel/SPSS

1. افتح المشروع
2. اضغط على زر "Export to CSV"
3. اختر مكان الحفظ أو شارك الملف مباشرة
4. افتح الملف في Excel أو SPSS للتحليل

</div>

## 🔐 Security Features / مزايا الأمان

- ✅ **Mandatory PIN/Biometric lock** on app launch
- ✅ **Encrypted local database** (Isar)
- ✅ **Secure storage** for sensitive credentials
- ✅ **No internet required** - all data stays on device
- ✅ **Data isolation** - each project is separate
- ✅ **No cloud sync** - complete privacy

## 📱 UI/UX Inspiration

This app is inspired by:
- **Airtable Mobile**: Dynamic form rendering & data views
- **Google Forms**: Simple form builder UX
- **Notion Databases**: Structured data display

## 🎨 Design Principles

1. **Trust & Security**: Lock screen is the first impression
2. **Speed**: Large buttons, dropdowns over text input
3. **Offline-First**: Works 100% without internet
4. **Clear Export CTA**: One-tap CSV export button

## 🐛 Known Issues / المشاكل المعروفة

- Image compression not yet implemented (large image files)
- Multi-language support (Arabic RTL) coming soon
- Cloud backup feature planned for future release

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍⚕️ Made for Doctors, By Developers

Built with ❤️ for medical researchers who deserve better tools than Excel spreadsheets on mobile phones.

---

<div dir="rtl">

## 💡 نصائح للاستخدام الأمثل

### للباحثين الطبيين:

1. **استخدم Dropdowns بدلاً من النصوص**: لتقليل الأخطاء الإملائية في التشخيص
2. **أضف حقول مطلوبة (Required)**: لضمان اكتمال البيانات
3. **صور الأشعة**: احفظها بجودة جيدة للرجوع إليها لاحقًا
4. **Export بشكل دوري**: احتفظ بنسخ احتياطية من ملفات CSV

### للطلاب والمقيمين:

هذا المشروع مثالي للتعلم:
- Clean Architecture في Flutter
- State Management مع Riverpod
- Local Database (Isar)
- Authentication & Security
- Dynamic Forms
- File Export & Sharing

</div>

## 📞 Contact / التواصل

For questions or support:
- Email: zeyadelshreef9@gmail.com
- GitHub Issues: [Create an issue](https://github.com/yourusername/med-research-assistant/issues)

---

**⚕️ Disclaimer**: This app is for research data collection only. Always comply with your institution's ethics committee guidelines and patient privacy regulations (HIPAA, GDPR, etc.)
