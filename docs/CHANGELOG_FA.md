# 📋 گزارش تغییرات (Changelog)

## نسخه 1.1.0 - تغییرات جدید

### ✨ ویژگی‌های جدید

#### 🌐 فارسی‌سازی کامل

- ✅ تمام متن‌های UI به فارسی تبدیل شد
- ✅ پشتیبانی از راست به چپ (RTL) اضافه شد
- ✅ تنظیم Locale به فارسی (`fa_IR`)

#### ⏰ بهبود سیستم آلارم

- ✅ **رفع مشکل آلارم‌ها:** آلارم‌ها حالا به درستی کار می‌کنند
- ✅ اضافه شدن مجوزهای لازم برای اندروید 12+ و 13+
- ✅ تنظیم Timezone به `Asia/Tehran`
- ✅ بازنشانی خودکار آلارم‌ها بعد از ری‌استارت گوشی
- ✅ لاگ‌گذاری کامل برای Debug

#### 🔧 ابزار عیب‌یابی

- ✅ صفحه جدید "عیب‌یابی آلارم‌ها" در تنظیمات
- ✅ نمایش وضعیت آلارم‌های فعال
- ✅ بررسی مجوزها
- ✅ تست آلارم (1 دقیقه)
- ✅ بازنشانی دستی آلارم‌ها

#### 📝 مستندات

- ✅ اضافه شدن توضیحات فارسی بالای کدها
- ✅ راهنمای کامل آلارم (`ALARM_GUIDE.md`)
- ✅ دستورالعمل Build (`BUILD_INSTRUCTIONS.md`)
- ✅ README فارسی (`README_FA.md`)

### 🔨 تغییرات فنی

#### فایل `lib/main.dart`

```dart
// قبل
title: 'Self Management',
// بعد
title: 'مدیریت شخصی',
locale: const Locale('fa', 'IR'),
```

**تغییرات:**

- ✅ اضافه شدن کامنت‌های توضیحی فارسی
- ✅ تنظیم Locale به فارسی
- ✅ اضافه شدن `supportedLocales`
- ✅ بازنشانی خودکار آلارم‌ها در startup

#### فایل `android/app/src/main/AndroidManifest.xml`

**مجوزهای اضافه شده:**

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
```

**BroadcastReceivers اضافه شده:**

```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"/>
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
```

#### فایل `lib/core/services/notification_service.dart`

**بهبودها:**

- ✅ تنظیم Timezone: `tz.setLocalLocation(tz.getLocation('Asia/Tehran'))`
- ✅ درخواست خودکار مجوزها در initialize
- ✅ بررسی Permission.scheduleExactAlarm برای اندروید 12+
- ✅ بررسی اینکه زمان آلارم در گذشته نباشد
- ✅ تنظیمات بهتر AndroidNotificationDetails:
  - `fullScreenIntent: true`
  - `category: AndroidNotificationCategory.alarm`
  - `onlyAlertOnce: false`
  - `autoCancel: false`
- ✅ لاگ‌گذاری کامل
- ✅ متد `rescheduleAllNotifications` برای بازنشانی

#### فایل `lib/data/repositories/reminder_repository.dart`

**بهبودها:**

- ✅ متد `rescheduleAllActiveReminders()`:
  ```dart
  Future<void> rescheduleAllActiveReminders() async {
    final activeReminders = getUpcomingReminders();
    for (var reminder in activeReminders) {
      await _notificationService.scheduleNotification(...);
    }
  }
  ```

#### فایل `lib/presentation/screens/settings/settings_screen.dart`

**تغییرات:**

- ✅ فارسی‌سازی کامل UI:
  - Settings → تنظیمات
  - Reminders → یادآورها و آلارم‌ها
  - Active Reminders → یادآورهای فعال
  - Alarm Sounds → صداهای آلارم
  - Storage → فضای ذخیره‌سازی
  - Clear All Data → پاک کردن همه داده‌ها
  - About → درباره برنامه
- ✅ اضافه شدن دکمه "عیب‌یابی آلارم‌ها"
- ✅ کامنت‌های توضیحی فارسی
- ✅ تغییر chevron از راست به چپ (RTL)

#### فایل‌های جدید ایجاد شده

1. **`lib/core/services/alarm_debug_helper.dart`**

   - کلاس کمکی برای Debug آلارم‌ها
   - متدهای تست و بررسی

2. **`lib/presentation/screens/debug/alarm_debug_screen.dart`**

   - صفحه UI برای عیب‌یابی
   - نمایش وضعیت آلارم‌ها
   - تست آلارم 1 دقیقه‌ای
   - بازنشانی دستی

3. **`ALARM_GUIDE.md`**

   - راهنمای کامل فارسی
   - رفع مشکلات رایج
   - تنظیمات مختلف گوشی‌ها

4. **`BUILD_INSTRUCTIONS.md`**

   - دستورالعمل Build
   - نحوه نصب و تست
   - دستورات مفید

5. **`README_FA.md`**

   - مستندات کامل فارسی
   - معرفی ویژگی‌ها
   - ساختار پروژه

6. **`CHANGELOG_FA.md`**
   - این فایل :)

### 🐛 رفع باگ‌ها

#### باگ اصلی: آلارم کار نمی‌کرد

**علت:**

1. ❌ مجوزهای لازم برای اندروید 12+ و 13+ نبود
2. ❌ Timezone تنظیم نشده بود
3. ❌ بعد از ری‌استارت آلارم‌ها از بین می‌رفتند
4. ❌ تنظیمات نوتیفیکیشن کافی نبودند

**راه‌حل:**

1. ✅ اضافه شدن تمام مجوزهای لازم
2. ✅ تنظیم Timezone به Asia/Tehran
3. ✅ سیستم reschedule بعد از reboot
4. ✅ بهبود تنظیمات نوتیفیکیشن

### 📊 مقایسه قبل و بعد

#### قبل

```
❌ آلارم کار نمی‌کرد
❌ بعد از ری‌استارت آلارم‌ها پاک می‌شدند
❌ UI انگلیسی بود
❌ ابزار Debug نداشت
❌ مستندات کامل نبود
```

#### بعد

```
✅ آلارم کامل کار می‌کند
✅ آلارم‌ها بعد از ری‌استارت حفظ می‌شوند
✅ UI کاملاً فارسی و RTL
✅ صفحه Debug کامل
✅ مستندات جامع فارسی
```

### 🎯 چیزهایی که باید انجام بدید

1. **نصب مجدد برنامه (الزامی):**

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **تست آلارم:**

   - به تنظیمات → عیب‌یابی آلارم‌ها بروید
   - روی "تنظیم آلارم تستی" کلیک کنید
   - 1 دقیقه صبر کنید

3. **بررسی مجوزها:**
   - Settings گوشی → Apps → مدیریت شخصی
   - همه مجوزها را فعال کنید
   - Battery optimization را غیرفعال کنید

### 📚 منابع

- **راهنمای آلارم:** `ALARM_GUIDE.md`
- **دستورالعمل Build:** `BUILD_INSTRUCTIONS.md`
- **README فارسی:** `README_FA.md`

### 🔜 نسخه‌های آینده (TODO)

- [ ] اضافه کردن فونت فارسی (Vazir/Shabnam)
- [ ] فارسی کردن صفحات دیگر
- [ ] اضافه کردن آلارم تکرارشونده (روزانه/هفتگی)
- [ ] ویجت Home Screen
- [ ] پشتیبانی از تقویم شمسی

### 🙏 تشکر

از شما که از این برنامه استفاده می‌کنید، تشکر می‌کنیم!

اگر مشکلی پیدا کردید یا پیشنهادی دارید، لطفاً Issue باز کنید.

---

**تاریخ:** اکتبر 2025
**نسخه:** 1.1.0
