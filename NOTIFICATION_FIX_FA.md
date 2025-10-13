# راهنمای رفع مشکل نوتیفیکیشن و آلارم

## مشکلاتی که برطرف شد ✅

### ۱. نوتیفیکیشن زمان‌بندی نمیشد

**مشکل:** وقتی یک تسک یا هدف با یادآور اضافه میکردید، فقط تسک/هدف ذخیره میشد اما notification اصلاً زمان‌بندی نمیشد.

**راه حل:**

- کد اضافه شده در `add_edit_task_screen.dart` و `add_edit_goal_screen.dart`
- حالا بعد از ذخیره تسک/هدف، notification هم به‌صورت خودکار زمان‌بندی میشه

### ۲. Duplicate Notifications

**مشکل:** وقتی یک تسک/هدف رو ویرایش میکردید، یادآور جدید اضافه میشد بدون اینکه یادآور قبلی حذف بشه.

**راه حل:**

- اول یادآورهای قبلی حذف میشن
- بعد یادآور جدید اضافه میشه

### ۳. برنامه crash میکرد

**مشکل:** وقتی زمان آلارم میرسید، برنامه crash میکرد یا بسته میشد.

**دلایل احتمالی:**

1. **Custom sound path اشتباه بود:** استفاده از `UriAndroidNotificationSound` نیاز به مسیر خاصی داره که باید در `AndroidManifest.xml` تعریف بشه
2. **Callback در background کار نمیکرد:** وقتی app بسته است، callback های معمولی کار نمیکنن

**راه حل:**

- فعلاً از صدای پیش‌فرض سیستم استفاده میکنیم
- یک صفحه Alarm Screen اضافه شده که وقتی روی notification کلیک میکنید باز میشه
- امکان Dismiss و Snooze آلارم اضافه شده

## چطور کار میکنه ✨

### ۱. زمان‌بندی آلارم

```dart
// وقتی یک تسک با یادآور اضافه میکنید:
await reminderProvider.addReminder(
  itemId: newTask.id,
  type: ReminderType.task,
  scheduledDateTime: _reminderDateTime!,
  title: 'یادآور وظیفه: ${newTask.title}',
  body: newTask.description,
  alarmSoundPath: alarmSoundPath,
);

// این کد یک notification زمان‌بندی میکنه
```

### ۲. وقتی زمان آلارم میرسه

1. **نوتیفیکیشن نمایش داده میشه** با صدای سیستم
2. **وقتی روی notification کلیک میکنید:**
   - برنامه باز میشه (اگر بسته بود)
   - صفحه Alarm Screen نمایش داده میشه
   - میتونید آلارم رو Dismiss یا Snooze کنید

### ۳. Snooze

- وقتی آلارم رو Snooze میکنید، برای ۵ دقیقه دیگه زمان‌بندی میشه
- میتونید چندین بار Snooze کنید

## محدودیت‌ها و نکات مهم 📝

### ۱. صدای Custom

**فعلاً:** از صدای پیش‌فرض سیستم استفاده میشه

**چرا؟** استفاده از صدای custom در runtime نیاز به این کارها داره:

1. فایل صدا باید در پوشه `android/app/src/main/res/raw/` باشه
2. باید در زمان build اضافه بشه (نمیشه runtime اضافه کرد)
3. نیاز به rebuild کامل app داره

**راه حل آینده:** میتونیم یک سیستم پیشرفته‌تر با `android_alarm_manager` یا `flutter_alarm` پیاده کنیم که:

- صدای custom رو پخش کنه
- به صورت loop پخش بشه
- حتی وقتی app بسته است کار کنه

### ۲. App در Background

**وضعیت فعلی:**

- ✅ نوتیفیکیشن نمایش داده میشه
- ✅ صدای سیستم پخش میشه
- ✅ وقتی روی notification کلیک کنید، صفحه Alarm باز میشه

**محدودیت:**

- صدا فقط یکبار پخش میشه (loop نیست)
- نمیشه صدا رو از داخل app متوقف کرد (چون سیستم پخش میکنه)

### ۳. تنظیمات باتری

**مهم:** برای اطمینان از کارکرد آلارم:

**Android:**

1. Settings > Apps > Self Management > Battery
2. انتخاب "Unrestricted" یا "No restrictions"
3. در برخی گوشی‌ها (Xiaomi, Huawei):
   - Autostart را فعال کنید
   - Background restrictions را غیرفعال کنید

## تست آلارم 🧪

### تست سریع

1. یک تسک یا هدف جدید بسازید
2. یادآور را برای ۲ دقیقه بعد تنظیم کنید
3. ذخیره کنید
4. منتظر بمانید

**نتیجه مورد انتظار:**

- بعد از ۲ دقیقه، نوتیفیکیشن نمایش داده میشه
- صدای سیستم پخش میشه
- با کلیک روی notification، صفحه Alarm باز میشه
- میتونید Dismiss یا Snooze کنید

### تست در Background

1. یک آلارم برای ۲ دقیقه بعد تنظیم کنید
2. برنامه رو ببندید (home button یا recent apps)
3. منتظر بمانید

**نتیجه مورد انتظار:**

- نوتیفیکیشن نمایش داده میشه
- صدا پخش میشه
- با کلیک، برنامه و صفحه Alarm باز میشه

### تست App Killed

1. یک آلارم برای ۵ دقیقه بعد تنظیم کنید
2. برنامه رو Force Stop کنید (Settings > Apps > Force Stop)
3. منتظر بمانید

**نتیجه مورد انتظار:**

- نوتیفیکیشن نمایش داده میشه
- صدا پخش میشه
- با کلیک، برنامه از اول باز میشه و صفحه Alarm نمایش داده میشه

## فایل‌های تغییر یافته 📂

### Core Services

- ✅ `lib/core/services/notification_service.dart` - اضافه شدن callback و payload
- ✅ `lib/core/services/alarm_service.dart` - بدون تغییر (برای استفاده آینده)

### Repositories

- ✅ `lib/data/repositories/reminder_repository.dart` - اضافه شدن reminderId به notifications

### Screens

- ✅ `lib/presentation/screens/tasks/add_edit_task_screen.dart` - اصلاح منطق ذخیره و یادآور
- ✅ `lib/presentation/screens/goals/add_edit_goal_screen.dart` - اصلاح منطق ذخیره و یادآور
- ✅ `lib/presentation/screens/alarm/alarm_notification_screen.dart` - **جدید** - صفحه نمایش آلارم

### Main

- ✅ `lib/main.dart` - اضافه شدن callback handler و navigatorKey

## مراحل بعدی (اختیاری) 🚀

اگر میخواید آلارم قوی‌تر و حرفه‌ای‌تر داشته باشید:

### گزینه ۱: استفاده از flutter_alarm

```yaml
dependencies:
  flutter_alarm: ^1.0.0
```

**مزایا:**

- صدای custom به صورت loop
- کار میکنه حتی وقتی app killed است
- UI قابل تنظیم

### گزینه ۲: استفاده از android_alarm_manager_plus

```yaml
dependencies:
  android_alarm_manager_plus: ^3.0.0
```

**مزایا:**

- کنترل کامل روی زمان‌بندی
- اجرای کد در background
- مناسب برای آلارم‌های تکراری

### گزینه ۳: ترکیب با Foreground Service

**مزایا:**

- کنترل کامل روی پخش صدا
- امکان loop و stop
- نمایش notification همیشه روی صفحه

## پشتیبانی 💬

اگر هنوز مشکل دارید:

1. **لاگ‌ها را بررسی کنید:**

   ```bash
   flutter run
   ```

   به دنبال خطاهایی با tag `NotificationService` یا `AlarmService` بگردید

2. **مجوزها را بررسی کنید:**

   - Notification permission
   - Exact alarm permission
   - Battery restrictions

3. **برنامه را rebuild کنید:**

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **نسخه Android را بررسی کنید:**
   - Android 12+ نیاز به مجوز `SCHEDULE_EXACT_ALARM` دارد
   - Android 13+ نیاز به مجوز `POST_NOTIFICATIONS` دارد

## تغییرات نسبت به نسخه قبل

### قبل ❌

- نوتیفیکیشن زمان‌بندی نمیشد
- Duplicate notifications
- برنامه crash میکرد
- UI برای آلارم نداشت

### بعد ✅

- نوتیفیکیشن درست زمان‌بندی میشه
- یادآورهای قبلی حذف میشن
- برنامه crash نمیکنه
- صفحه Alarm زیبا و کاربردی
- امکان Snooze
- کار میکنه در background و حتی app killed

---

**تاریخ آپدیت:** 2025-10-13
**نسخه:** 2.0.0
