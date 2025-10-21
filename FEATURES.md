# Features Documentation / توثيق الميزات

<div dir="rtl">

## نظرة شاملة على ميزات التطبيق

</div>

---

## 🔐 Security & Authentication / الأمان والمصادقة

### PIN Authentication / مصادقة الرمز السري

**Status:** ✅ Implemented

<div dir="rtl">

#### الوصف
نظام حماية إلزامي باستخدام رمز PIN مكون من 4-6 أرقام لحماية بيانات المرضى الحساسة.

#### المميزات:
- إنشاء PIN عند أول استخدام
- التحقق من PIN عند كل فتح للتطبيق
- تخزين آمن باستخدام Flutter Secure Storage
- إمكانية تغيير PIN (مخطط)
- استعادة PIN (مخطط)

</div>

**Implementation:**
```dart
// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Set PIN
await ref.read(authProvider.notifier).setPin('123456');

// Verify PIN
final isValid = await ref.read(authProvider.notifier).verifyPin('123456');
```

**Screens:**
- `SetupPinScreen` - First time PIN creation
- `LockScreen` - PIN verification on app launch

---

### Biometric Authentication / المصادقة البيومترية

**Status:** ✅ Implemented

<div dir="rtl">

#### الوصف
دعم البصمة وFace ID للوصول السريع والآمن للتطبيق.

#### المميزات:
- كشف تلقائي لتوفر البيومتريك
- التحقق باستخدام local_auth
- خيار بديل لـ PIN

</div>

**Implementation:**
```dart
// Check if biometric is available
final hasBiometric = await _localAuth.canCheckBiometrics;

// Authenticate
final authenticated = await ref
    .read(authProvider.notifier)
    .authenticateWithBiometric();
```

**Supported Platforms:**
- ✅ Android: Fingerprint, Face Unlock
- ✅ iOS: Touch ID, Face ID

---

## 📁 Project Management / إدارة المشاريع

### Create Project / إنشاء مشروع

**Status:** ✅ Implemented

<div dir="rtl">

#### الوصف
إنشاء مشروع بحثي جديد مع اسم ووصف اختياري.

#### البيانات المطلوبة:
- اسم المشروع (إلزامي)
- الوصف (اختياري)

</div>

**Usage:**
```dart
final repository = ref.read(projectsRepositoryProvider);
final projectId = await repository.createProject(
  'Neurosurgery Study',
  'Research on neurosurgery outcomes',
);
```

**Screen:** `CreateProjectScreen`

---

### View Projects / عرض المشاريع

**Status:** ✅ Implemented

<div dir="rtl">

#### الوصف
عرض قائمة بجميع المشاريع البحثية مع معلومات أساسية.

#### المعلومات المعروضة:
- اسم المشروع
- الوصف
- عدد السجلات
- تاريخ الإنشاء

</div>

**Implementation:**
```dart
// Reactive stream provider
final projectsAsync = ref.watch(projectsProvider);

projectsAsync.when(
  data: (projects) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => ErrorWidget(),
);
```

**Screen:** `ProjectsListScreen`

---

### Project Details / تفاصيل المشروع

**Status:** ✅ Implemented

<div dir="rtl">

#### الوصف
شاشة تفصيلية لكل مشروع مع إحصائيات وخيارات الإجراءات.

#### الإجراءات المتاحة:
- عرض السجلات
- تصميم النموذج
- تصدير البيانات
- حذف المشروع

</div>

**Screen:** `ProjectDetailsScreen`

---

## 📝 Form Builder / بناء النماذج

### Dynamic Form Creation / إنشاء نماذج ديناميكية

**Status:** ⏳ Planned

<div dir="rtl">

#### الوصف
إنشاء نماذج مخصصة لجمع بيانات المرضى بأنواع حقول متعددة.

#### أنواع الحقول:

1. **Text / نص**
   - للنصوص العامة (Patient ID, Name, Notes)
   - دعم التحقق من الصحة
   - نص متعدد الأسطر (اختياري)

2. **Number / رقم**
   - للأرقام (Age, Weight, Height)
   - دعم الأرقام العشرية
   - حدود دنيا/عليا (اختياري)

3. **Date / تاريخ**
   - لاختيار التواريخ (Surgery Date, Birth Date)
   - Date picker interface
   - تنسيقات متعددة

4. **Dropdown / قائمة اختيار**
   - اختيار من قائمة محددة (Blood Type, Diagnosis)
   - تقليل الأخطاء الإملائية
   - خيارات مخصصة

5. **Boolean / نعم/لا**
   - للأسئلة الثنائية (Complications?, Smoker?)
   - واجهة Switch أو Checkbox

6. **Image / صورة**
   - لإرفاق صور (X-Rays, Scans, Documents)
   - التقاط من الكاميرا
   - اختيار من المعرض
   - ضغط تلقائي

</div>

**Planned Implementation:**

```dart
class FormFieldModel {
  String fieldId;
  String label;
  FieldType fieldType;
  bool isRequired;
  String? hint;
  List<String>? dropdownOptions;
  int order;
}

enum FieldType {
  text,
  number,
  date,
  dropdown,
  boolean,
  image,
}
```

**Planned Screen:** `FormBuilderScreen`

**Features:**
- Drag & drop field reordering
- Field validation rules
- Conditional fields (show/hide based on other fields)
- Field duplication
- Preview form

---

## ✍️ Data Entry / إدخال البيانات

### Patient Data Collection / جمع بيانات المرضى

**Status:** ⏳ Planned

<div dir="rtl">

#### الوصف
واجهة ديناميكية لإدخال بيانات المرضى بناءً على النموذج المصمم.

#### المميزات:
- عرض ديناميكي للحقول
- تحقق تلقائي من الصحة
- حفظ تلقائي (Draft)
- إرفاق صور متعددة
- واجهة سريعة ومحسّنة للأطباء

</div>

**Planned Implementation:**

```dart
class DataEntryScreen extends StatefulWidget {
  final String projectId;
  final String? entryId; // null for new entry
  
  @override
  Widget build(BuildContext context) {
    // 1. Load form fields for project
    // 2. Dynamically render widgets based on field type
    // 3. Handle validation
    // 4. Save to database
  }
}
```

**Field Widgets:**

```dart
// Text Field
TextFormField(
  decoration: InputDecoration(labelText: field.label),
  validator: field.isRequired 
      ? (v) => v?.isEmpty ?? true ? 'Required' : null
      : null,
);

// Number Field
TextFormField(
  keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
);

// Date Field
InkWell(
  onTap: () => _showDatePicker(context),
  child: InputDecorator(...),
);

// Dropdown
DropdownButtonFormField(
  items: field.options.map((o) => DropdownMenuItem(...)).toList(),
);

// Boolean
SwitchListTile(
  title: Text(field.label),
  value: value,
  onChanged: (v) => setState(() => value = v),
);

// Image
Column(
  children: [
    if (imagePath != null) Image.file(File(imagePath!)),
    Row(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.camera),
          label: Text('Camera'),
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.photo),
          label: Text('Gallery'),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    ),
  ],
);
```

**Planned Screen:** `DataEntryScreen`

---

### View Entries / عرض السجلات

**Status:** ⏳ Planned

<div dir="rtl">

#### الوصف
قائمة بجميع سجلات المرضى في المشروع.

#### المميزات:
- عرض معلومات أساسية لكل سجل
- بحث وفلترة
- تحرير السجلات
- حذف السجلات
- تصدير سجل واحد

</div>

**Planned Screen:** `EntriesListScreen`

---

## 📤 Data Export / تصدير البيانات

### CSV Export / تصدير CSV

**Status:** ⏳ Planned

<div dir="rtl">

#### الوصف
تصدير جميع بيانات المشروع إلى ملف CSV جاهز للتحليل في Excel أو SPSS.

#### المميزات:
- تنسيق CSV قياسي
- ترويسات واضحة (أسماء الحقول)
- معالجة أنواع البيانات المختلفة
- حفظ مباشر
- مشاركة عبر share_plus

</div>

**Planned Implementation:**

```dart
class CSVExportService {
  Future<String> exportProject(String projectId) async {
    // 1. Get project fields
    final fields = await repository.getProjectFields(projectId);
    
    // 2. Get all entries
    final entries = await repository.getProjectEntries(projectId);
    
    // 3. Create CSV header
    List<List<dynamic>> rows = [
      ['Entry ID', 'Created At', ...fields.map((f) => f.label)],
    ];
    
    // 4. Add data rows
    for (final entry in entries) {
      final values = await repository.getEntryValues(entry.entryId);
      rows.add([
        entry.entryId,
        entry.createdAt.toIso8601String(),
        ...fields.map((f) => values[f.fieldId]?.textValue ?? ''),
      ]);
    }
    
    // 5. Convert to CSV string
    final csvString = const ListToCsvConverter().convert(rows);
    
    // 6. Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/project_${projectId}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvString);
    
    return file.path;
  }
}
```

**CSV Format Example:**

```csv
Entry ID,Created At,Patient ID,Age,Blood Type,Surgery Date,Complications
e123...,2024-01-15T10:30:00,P001,45,A+,2024-01-10,No
e456...,2024-01-16T14:20:00,P002,32,O-,2024-01-12,Yes
```

**Export Options:**
- Export all data
- Export selected fields
- Export date range
- Include images (as separate files)

**Planned Screen:** `ExportScreen`

---

## 🎨 UI/UX Features / ميزات الواجهة

### Material Design 3

**Status:** ✅ Implemented

- Modern card-based design
- Consistent color scheme (Medical Blue)
- Clear typography hierarchy
- Proper spacing and padding
- Accessible touch targets

### Loading States

**Status:** ✅ Implemented

- Circular progress indicators
- Shimmer effects (planned)
- Skeleton screens (planned)

### Error Handling

**Status:** ✅ Implemented

- User-friendly error messages
- Retry mechanisms
- Fallback UI states

### Animations

**Status:** ⏳ Planned

- Page transitions
- List item animations
- Button feedback
- Micro-interactions

---

## 🔄 Offline Features / الميزات دون اتصال

### Offline-First Architecture

**Status:** ✅ Implemented

<div dir="rtl">

#### الوصف
التطبيق يعمل بكامل وظائفه بدون إنترنت.

#### المميزات:
- جميع البيانات محلية
- لا يوجد اعتماد على الشبكة
- أداء سريع
- خصوصية كاملة

</div>

---

## 🔮 Planned Features / ميزات مخططة

### Multi-language Support

**Status:** 📝 Planned

- Arabic (RTL support)
- English
- Easy to add more languages

### Dark Mode

**Status:** 📝 Planned

- System-based theme switching
- Manual theme selection
- Consistent dark color scheme

### Cloud Sync (Optional)

**Status:** 📝 Planned

- End-to-end encryption
- Firebase/Supabase backend
- Selective sync
- Conflict resolution

### Advanced Analytics

**Status:** 📝 Planned

- Charts and graphs
- Statistical summaries
- Data visualization
- Export reports

---

<div dir="rtl">

## الخلاصة

التطبيق يوفر حلاً شاملاً لجمع وإدارة بيانات المرضى بشكل آمن ومنظم، مع التركيز على:
- ✅ **الأمان**: تشفير وحماية البيانات
- ✅ **السهولة**: واجهة بسيطة وسريعة
- ✅ **المرونة**: نماذج قابلة للتخصيص
- ✅ **الموثوقية**: عمل بدون انترنت

</div>

---

**Last Updated:** 2024
