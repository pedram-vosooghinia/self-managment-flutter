# راهنمای سیستم آلارم کامل

## ویژگی‌های پیاده‌سازی شده

### ✅ **آلارم کامل مثل گوشی پیش‌فرض:**

- **کار در حالت Background/Terminated**: آلارم حتی وقتی اپ بسته است کار می‌کند
- **کار در حالت Doze/Sleep**: آلارم در حالت خواب گوشی هم فعال می‌ماند
- **صفحه آلارم تمام‌صفحه**: هنگام فعال شدن آلارم، صفحه کامل نمایش داده می‌شود
- **صدا و ویبره**: صدای آلارم با تکرار و ویبره فعال است
- **دکمه‌های کنترل**: دکمه‌های "قطع" و "چرت (5 دقیقه)" در دسترس است

### ✅ **مجوزهای Android:**

- `SCHEDULE_EXACT_ALARM` - برای آلارم دقیق
- `USE_EXACT_ALARM` - برای استفاده از آلارم دقیق
- `POST_NOTIFICATIONS` - برای ارسال نوتیفیکیشن
- `VIBRATE` - برای ویبره
- `WAKE_LOCK` - برای بیدار نگه داشتن گوشی
- `RECEIVE_BOOT_COMPLETED` - برای راه‌اندازی مجدد پس از ریبوت
- `USE_FULL_SCREEN_INTENT` - برای نمایش تمام‌صفحه

### ✅ **فایل‌های ایجاد شده:**

- `lib/core/services/notification_service.dart` - سرویس اصلی آلارم
- `lib/core/services/alarm_manager.dart` - مدیریت باز کردن صفحه آلارم
- `lib/presentation/screens/alarm/alarm_screen.dart` - صفحه آلارم تمام‌صفحه
- `android/app/src/main/res/drawable/ic_close.xml` - آیکون قطع
- `android/app/src/main/res/drawable/ic_snooze.xml` - آیکون چرت
- `android/app/src/main/res/raw/alarm_sound.mp3` - فایل صدای آلارم

## نحوه استفاده

### 1. **تست سیستم آلارم:**

- در صفحه تسک‌ها، روی آیکون آلارم در AppBar کلیک کنید
- آلارم برای 10 ثانیه بعد تنظیم می‌شود

### 2. **ایجاد تسک با آلارم:**

```dart
await context.read<TaskProvider>().addTask(
  title: 'عنوان تسک',
  reminderDateTime: DateTime.now().add(Duration(minutes: 30)),
);
```

### 3. **مدیریت آلارم‌ها:**

```dart
// لغو آلارم
await NotificationService.cancelNotification(taskId);

// دریافت لیست آلارم‌های فعال
final activeAlarms = await NotificationService.getActiveNotifications();

// لغو تمام آلارم‌ها
await NotificationService.cancelAllNotifications();
```

## ویژگی‌های صفحه آلارم

### **انیمیشن‌ها:**

- **پالس (نبض)**: آیکون آلارم با انیمیشن پالس نمایش داده می‌شود
- **تکان خوردن**: آیکون آلارم تکان می‌خورد
- **زمان فعلی**: زمان فعلی در بالای صفحه نمایش داده می‌شود

### **دکمه‌های کنترل:**

- **قطع**: آلارم را کاملاً متوقف می‌کند
- **چرت (5 دقیقه)**: آلارم را برای 5 دقیقه بعد تنظیم می‌کند

### **صدا:**

- صدای آلارم با تکرار پخش می‌شود
- تا زمانی که کاربر عملی انجام ندهد ادامه دارد

## تنظیمات پیشرفته

### **تغییر صدای آلارم:**

```dart
await NotificationService.showNotification(
  id: 'custom_alarm',
  title: 'آلارم سفارشی',
  scheduledDate: DateTime.now().add(Duration(minutes: 5)),
  sound: 'custom_sound', // نام فایل صوتی در پوشه raw
);
```

### **تنظیم آلارم تکراری:**

```dart
// در TaskProvider، برای تسک‌های تکراری می‌توانید
// آلارم‌های متعدد تنظیم کنید
```

## نکات مهم

1. **مجوزها**: اپ باید مجوزهای لازم را از کاربر دریافت کند
2. **فایل صوتی**: فایل `alarm_sound.mp3` باید در پوشه `android/app/src/main/res/raw/` موجود باشد
3. **تست**: همیشه سیستم را در حالت واقعی تست کنید، نه فقط در شبیه‌ساز
4. **بهینه‌سازی باتری**: سیستم از `AndroidScheduleMode.exactAllowWhileIdle` استفاده می‌کند

## عیب‌یابی

### **آلارم کار نمی‌کند:**

- مجوزهای لازم را بررسی کنید
- فایل صدای آلارم موجود باشد
- در حالت واقعی تست کنید (نه شبیه‌ساز)

### **صفحه آلارم باز نمی‌شود:**

- `AlarmManager.navigatorKey` درست تنظیم شده باشد
- `main.dart` درست کانفیگ شده باشد

### **صدا پخش نمی‌شود:**

- فایل صوتی در مسیر درست باشد
- مجوزهای صوتی فعال باشد
- حجم صدا در گوشی بالا باشد
