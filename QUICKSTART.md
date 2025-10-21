# Quick Start Guide / دليل البدء السريع

<div dir="rtl">

## ⚡ البدء في 3 خطوات

### 1️⃣ تثبيت المكتبات
</div>

```bash
flutter pub get
```

<div dir="rtl">

### 2️⃣ توليد ملفات قاعدة البيانات
</div>

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

<div dir="rtl">

### 3️⃣ تشغيل التطبيق
</div>

```bash
flutter run
```

---

<div dir="rtl">

## 📱 أول استخدام للتطبيق

### عند فتح التطبيق لأول مرة:

1. **إنشاء PIN أمان** (4-6 أرقام)
   - هذا الرمز يحمي بيانات المرضى
   - احفظه في مكان آمن

2. **إنشاء مشروع بحثي**
   - اضغط "New Project"
   - أدخل اسم المشروع (مثال: "دراسة جراحة الأعصاب")
   - أضف وصف اختياري

3. **تصميم النموذج**
   - افتح المشروع → "Design Form"
   - أضف الحقول المطلوبة:
     - Patient ID (نص)
     - Age (رقم)
     - Surgery Date (تاريخ)
     - Blood Type (قائمة اختيار)
     - Complications (نعم/لا)
     - X-Ray (صورة)

4. **إدخال البيانات**
   - "Add Entry" → املأ النموذج
   - احفظ البيانات

5. **التصدير**
   - "Export to CSV"
   - شارك الملف مع حاسوبك
   - افتحه في Excel أو SPSS

</div>

---

## 🔧 Common Commands / الأوامر الشائعة

```bash
# Check Flutter installation
flutter doctor -v

# List connected devices
flutter devices

# Run app
flutter run

# Build APK (Android)
flutter build apk --release

# Clean project
flutter clean

# Format code
flutter format lib/

# Analyze code
flutter analyze

# Generate code (Isar)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on save)
flutter pub run build_runner watch
```

---

## 🆘 Troubleshooting / حل المشاكل

<div dir="rtl">

### مشكلة: الأكواد لا تعمل (errors everywhere)

**الحل:**
</div>

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

<div dir="rtl">

### مشكلة: البصمة لا تعمل (Android)

**الحل:**
- تأكد من إضافة الإذن في `AndroidManifest.xml`
- استخدم جهاز حقيقي (ليس محاكي)
- تأكد من تفعيل البصمة في إعدادات الجهاز

### مشكلة: التطبيق لا يفتح الكاميرا

**الحل:**
- تأكد من إضافة الأذونات في:
  - Android: `AndroidManifest.xml`
  - iOS: `Info.plist`
- امسح التطبيق وثبته مرة أخرى

### مشكلة: لا يمكن حفظ ملف CSV

**الحل (Android 11+):**
</div>

Add to `AndroidManifest.xml`:
```xml
<application
    android:requestLegacyExternalStorage="true">
```

---

## 📂 Project Structure / هيكل المشروع

```
lib/
├── main.dart                   # Entry point
├── core/
│   ├── database/              # Isar database
│   └── theme/                 # App theme
└── features/
    ├── auth/                  # PIN & Biometric
    ├── projects/              # Projects management
    └── export/                # CSV export
```

---

## 🎯 Next Steps / الخطوات التالية

<div dir="rtl">

### للمطورين:

1. تطبيق شاشة Form Builder الكاملة
2. إضافة وظيفة تحرير الحقول
3. تطبيق شاشة Data Entry الديناميكية
4. إضافة وظيفة CSV Export
5. تحسين التصميم والـ UX

### للباحثين:

1. اختبر التطبيق مع مشروع بحثي حقيقي صغير
2. جرب جميع أنواع الحقول
3. صدّر البيانات وتحقق من التوافق مع Excel
4. شارك ملاحظاتك لتحسين التطبيق

</div>

---

## 📞 Need Help? / هل تحتاج مساعدة؟

- 📖 Read full documentation: [README.md](README.md)
- 🔧 Setup guide: [SETUP.md](SETUP.md)
- 🐛 Report issues on GitHub
- 💬 Join Flutter community on Discord

---

**Happy Coding! / برمجة سعيدة!** 🚀

