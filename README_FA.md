# 📱 برنامه مدیریت شخصی

برنامه‌ای زیبا و کامل برای مدیریت وظایف، اهداف، یادآورها و تمرینات ورزشی با پشتیبانی کامل از آلارم و نوتیفیکیشن.

## ✨ ویژگی‌ها

### 📋 مدیریت وظایف (Tasks)

- ✅ ایجاد، ویرایش و حذف وظایف
- ✅ تعیین اولویت برای هر وظیفه
- ✅ تنظیم تاریخ سررسید
- ✅ دسته‌بندی وظایف به: امروز، آینده، انجام شده، عقب افتاده
- ✅ تنظیم یادآور با آلارم برای هر وظیفه

### 🎯 مدیریت اهداف (Goals)

- ✅ ایجاد اهداف بلند مدت و کوتاه مدت
- ✅ پیگیری پیشرفت هر هدف
- ✅ تنظیم تاریخ هدف
- ✅ یادآورهای منظم برای اهداف

### ⏰ سیستم آلارم و یادآور پیشرفته

- ✅ آلارم‌های دقیق با پشتیبانی اندروید 12+
- ✅ صداهای سفارشی برای آلارم
- ✅ حفظ آلارم‌ها بعد از ری‌استارت گوشی
- ✅ نوتیفیکیشن با اولویت بالا
- ✅ صفحه عیب‌یابی آلارم برای تست و رفع مشکلات

### 💪 مدیریت تمرینات ورزشی (Workouts)

- ✅ ایجاد برنامه تمرینی
- ✅ ثبت تمرینات انجام شده
- ✅ پیگیری پیشرفت

### 🎨 رابط کاربری

- ✅ طراحی مدرن با Material Design 3
- ✅ پشتیبانی از تم روشن و تاریک
- ✅ **زبان فارسی و راست به چپ (RTL)**
- ✅ انیمیشن‌های روان
- ✅ کارت‌های زیبا و خوانا

## 📸 تصاویر

_(می‌توانید اسکرین‌شات‌های برنامه را اینجا اضافه کنید)_

## 🔧 فناوری‌های استفاده شده

### Frontend

- **Flutter 3.9+** - فریمورک اصلی
- **Provider** - مدیریت وضعیت
- **Material Design 3** - طراحی UI

### Backend (Local)

- **Hive** - پایگاه داده محلی NoSQL
- **Hive Generator** - تولید کد خودکار

### آلارم و نوتیفیکیشن

- **flutter_local_notifications** - نوتیفیکیشن محلی
- **timezone** - مدیریت زمان
- **permission_handler** - مدیریت مجوزها
- **audioplayers** - پخش صدای آلارم

### سایر

- **uuid** - تولید شناسه یکتا
- **intl** - فرمت‌دهی تاریخ و زمان
- **file_picker** - انتخاب فایل صدا

## 📋 پیش‌نیازها

- Flutter SDK نسخه 3.9 یا بالاتر
- Dart SDK نسخه 3.0 یا بالاتر
- Android Studio یا VS Code
- دستگاه اندروید یا شبیه‌ساز (Android 6.0+)

## 🚀 نصب و راه‌اندازی

### 1. کلون کردن پروژه

```bash
git clone <repository-url>
cd myapp-master2
```

### 2. نصب وابستگی‌ها

```bash
flutter pub get
```

### 3. تولید کدهای Hive

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. اجرای برنامه

```bash
flutter run
```

## 📱 ساخت نسخه نهایی (APK)

### نسخه Release

```bash
flutter build apk --release
```

### نسخه Split APK (کوچک‌تر)

```bash
flutter build apk --release --split-per-abi
```

فایل‌های APK در مسیر `build/app/outputs/flutter-apk/` قرار می‌گیرند.

## ⚙️ تنظیمات مهم

### تغییر تایم‌زون

اگر در خارج از ایران هستید، در فایل `lib/core/services/notification_service.dart` خط 23 را تغییر دهید:

```dart
tz.setLocalLocation(tz.getLocation('Asia/Tehran')); // تغییر دهید به timezone خود
```

لیست timezone ها: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

### مجوزهای اندروید

تمام مجوزهای لازم در `android/app/src/main/AndroidManifest.xml` تنظیم شده است:

- نوتیفیکیشن (Android 13+)
- آلارم دقیق (Android 12+)
- بوت اتوماتیک
- لرزش
- Wake Lock

## 🐛 رفع مشکلات آلارم

### آلارم کار نمی‌کند

1. **مجوزها را بررسی کنید:**

   - Settings > Apps > مدیریت شخصی > Permissions
   - همه مجوزها را فعال کنید

2. **تنظیمات باتری:**

   - Settings > Apps > مدیریت شخصی > Battery
   - گزینه "Unrestricted" یا "بدون محدودیت" را انتخاب کنید

3. **استفاده از صفحه عیب‌یابی:**

   - به تنظیمات بروید
   - روی "عیب‌یابی آلارم‌ها" کلیک کنید
   - آلارم تستی ایجاد کنید
   - وضعیت مجوزها و آلارم‌ها را بررسی کنید

4. **Autostart (گوشی‌های Xiaomi, Huawei, etc.):**
   - Settings > Apps > مدیریت شخصی
   - گزینه Autostart را فعال کنید

### آلارم بعد از ری‌استارت حذف می‌شود

برنامه به صورت خودکار آلارم‌ها را بعد از ری‌استارت بازنشانی می‌کند. اگر این مشکل وجود دارد:

- Settings > Apps > مدیریت شخصی
- "Autostart" یا "اجرای خودکار" را فعال کنید

## 📁 ساختار پروژه

```
lib/
├── core/                          # هسته برنامه
│   └── services/                  # سرویس‌های اصلی
│       ├── alarm_service.dart     # سرویس پخش صدای آلارم
│       ├── hive_service.dart      # راه‌اندازی پایگاه داده
│       ├── notification_service.dart  # مدیریت نوتیفیکیشن
│       └── alarm_debug_helper.dart    # کمک‌کننده debug آلارم
│
├── data/                          # لایه داده
│   ├── models/                    # مدل‌های داده
│   │   ├── task_model.dart        # مدل وظیفه
│   │   ├── goal_model.dart        # مدل هدف
│   │   ├── reminder_model.dart    # مدل یادآور
│   │   ├── workout_model.dart     # مدل تمرین
│   │   └── alarm_sound_model.dart # مدل صدای آلارم
│   │
│   └── repositories/              # مخزن‌های داده
│       ├── task_repository.dart
│       ├── goal_repository.dart
│       ├── reminder_repository.dart
│       ├── workout_repository.dart
│       └── alarm_sound_repository.dart
│
├── presentation/                  # لایه نمایش
│   ├── providers/                 # مدیریت وضعیت
│   │   ├── task_provider.dart
│   │   ├── goal_provider.dart
│   │   ├── reminder_provider.dart
│   │   ├── workout_provider.dart
│   │   └── alarm_sound_provider.dart
│   │
│   ├── screens/                   # صفحات برنامه
│   │   ├── home_screen.dart       # صفحه اصلی
│   │   ├── tasks/                 # صفحات مربوط به وظایف
│   │   ├── goals/                 # صفحات مربوط به اهداف
│   │   ├── workouts/              # صفحات مربوط به تمرینات
│   │   ├── settings/              # صفحه تنظیمات
│   │   ├── alarm_sounds/          # مدیریت صداهای آلارم
│   │   └── debug/                 # صفحه عیب‌یابی آلارم
│   │
│   └── widgets/                   # ویجت‌های قابل استفاده مجدد
│       ├── task_card.dart
│       └── goal_card.dart
│
└── main.dart                      # نقطه شروع برنامه
```

## 🔍 توضیحات کدها

### فایل اصلی (main.dart)

```dart
// راه‌اندازی اولیه برنامه
void main() async {
  // آماده‌سازی Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // راه‌اندازی پایگاه داده Hive
  await HiveService.initialize();

  // راه‌اندازی سرویس نوتیفیکیشن
  await NotificationService().initialize();

  // بازنشانی آلارم‌ها (مهم برای بعد از ری‌استارت)
  final reminderRepository = ReminderRepository();
  await reminderRepository.rescheduleAllActiveReminders();

  // اجرای برنامه
  runApp(const MyApp());
}
```

### کلاس اصلی برنامه

- **تنظیم Locale**: برنامه به زبان فارسی و با جهت راست به چپ اجرا می‌شود
- **Providers**: تمام مدیریت وضعیت‌ها با Provider انجام می‌شود
- **تم**: پشتیبانی از تم روشن و تاریک

### سرویس نوتیفیکیشن

- **Timezone**: تنظیم دقیق زمان برای آلارم‌ها
- **مجوزها**: درخواست خودکار مجوزهای لازم
- **آلارم دقیق**: استفاده از `exactAllowWhileIdle` برای آلارم‌های دقیق
- **لاگ‌گذاری**: ثبت تمام عملیات برای debug

### مخزن یادآورها (Reminder Repository)

- **ذخیره‌سازی**: ذخیره یادآورها در Hive
- **زمان‌بندی**: زمان‌بندی خودکار نوتیفیکیشن
- **بازنشانی**: بازنشانی آلارم‌ها بعد از ری‌استارت

## 🛠️ ابزارهای Debug

### صفحه عیب‌یابی آلارم

برای دسترسی: تنظیمات → عیب‌یابی آلارم‌ها

**امکانات:**

- ✅ نمایش تعداد آلارم‌های فعال
- ✅ بررسی وضعیت مجوزها
- ✅ تنظیم آلارم تستی (1 دقیقه)
- ✅ لیست تمام آلارم‌های pending
- ✅ بازنشانی دستی تمام آلارم‌ها

### لاگ‌های Debug

برای مشاهده لاگ‌ها:

```bash
flutter run
# یا
adb logcat | grep -E "AlarmDebug|NotificationService"
```

## 📝 مستندات اضافی

### راهنماهای فنی

- [راهنمای کامل آلارم](docs/ALARM_GUIDE.md) - راهنمای جامع رفع مشکلات آلارم
- [راهنمای صفحه آلارم تمام‌صفحه](docs/ALARM_SCREEN_GUIDE_FA.md) - سیستم آلارم جدید
- [راهنمای سیستم صدای آلارم](docs/ALARM_SOUND_GUIDE_FA.md) - پخش صدای آلارم
- [دستورالعمل Build](docs/BUILD_INSTRUCTIONS.md) - نحوه ساخت و نصب برنامه

### مستندات داخلی

- [حذف سیستم نوتیفیکیشن](docs/NOTIFICATION_REMOVAL_FA.md) - تغییرات معماری
- [رفع مشکل نوتیفیکیشن](docs/NOTIFICATION_FIX_FA.md) - تاریخچه رفع باگ‌ها
- [راهنمای وظایف تکرارشونده](docs/RECURRING_TASKS_GUIDE_FA.md) - استفاده از تسک‌های تکراری
- [پیاده‌سازی تسک‌های تکرارشونده](docs/RECURRING_TASKS_IMPLEMENTATION.md) - جزئیات فنی
- [راهنمای Export به Excel](docs/EXCEL_EXPORT_GUIDE_FA.md) - خروجی گرفتن از داده‌ها
- [بررسی دیتابیس](docs/DATABASE_REVIEW_FA.md) - ساختار Hive
- [تغییرات نسخه](docs/CHANGELOG_FA.md) - لیست تغییرات
- [خلاصه پروژه](docs/SUMMARY_FA.md) - نمای کلی
- [یادداشت‌های Gemini](docs/GEMINI.md) - نکات AI

## 🤝 مشارکت

اگر می‌خواهید در توسعه این پروژه مشارکت کنید:

1. Fork کنید
2. یک Branch جدید بسازید (`git checkout -b feature/AmazingFeature`)
3. تغییرات خود را Commit کنید (`git commit -m 'Add some AmazingFeature'`)
4. به Branch خود Push کنید (`git push origin feature/AmazingFeature`)
5. یک Pull Request باز کنید

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

## 📞 پشتیبانی

اگر سوال یا مشکلی دارید:

- Issue باز کنید در GitHub
- به مستندات مراجعه کنید
- از صفحه Debug استفاده کنید

## 🎉 تشکر

از تمام کسانی که در توسعه Flutter و پکیج‌های استفاده شده مشارکت داشته‌اند، تشکر می‌کنیم.

---

**ساخته شده با ❤️ با Flutter**
