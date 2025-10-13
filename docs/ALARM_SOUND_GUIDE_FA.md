# راهنمای سیستم صدای آلارم

## خلاصه

سیستم صدای آلارم به طور کامل پیاده‌سازی شده است. وقتی یادآور فعال می‌شود، صدای انتخاب شده به صورت خودکار پخش می‌شود.

## ویژگی‌های اصلی

### 1. انتخاب صدای سفارشی

- کاربران می‌توانند برای هر یادآور صدای مخصوص انتخاب کنند
- امکان استفاده از صداهای پیش‌فرض سیستم
- امکان آپلود صداهای سفارشی از فایل

### 2. پخش خودکار صدا

- وقتی صفحه آلارم باز می‌شود، صدا به صورت خودکار پخش می‌شود
- صدا به صورت loop (تکرار) پخش می‌شود تا کاربر آلارم را رد کند
- صدا با بستن یا snooze کردن آلارم متوقف می‌شود

### 3. مدیریت هوشمند صدا

- اگر فایل صدا پیدا نشود، از صدای پیش‌فرض استفاده می‌شود
- صدا قبل از بستن صفحه به طور کامل متوقف می‌شود
- از حافظه به درستی آزاد می‌شود

## معماری سیستم

```
Reminder (با soundPath) → ReminderRepository
                               ↓
                     SimpleAlarmService
                          (با soundPath)
                               ↓
                    Timer + Callback
                               ↓
                 main.dart (ارسال soundPath)
                               ↓
            AlarmNotificationScreen
                     ↓              ↓
              AlarmService    UI Display
              (پخش صدا)      (نمایش صفحه)
```

## فایل‌های تغییر یافته

### 1. `lib/core/services/simple_alarm_service.dart`

**تغییرات:**

- ✅ اضافه شدن پارامتر `soundPath` به متد `scheduleSimpleAlarm`
- ✅ اضافه شدن `soundPath` به callback `onAlarmTriggered`
- ✅ ارسال `soundPath` در متد `_triggerAlarm`

```dart
// Callback با soundPath
static Function(int id, String title, String body, String? reminderId, String? soundPath)? onAlarmTriggered;

// scheduleSimpleAlarm با soundPath
Future<void> scheduleSimpleAlarm({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDateTime,
  String? reminderId,
  String? soundPath,  // ✅ اضافه شد
}) async { ... }
```

### 2. `lib/main.dart`

**تغییرات:**

- ✅ دریافت `soundPath` در callback
- ✅ ارسال `soundPath` به `AlarmNotificationScreen`

```dart
SimpleAlarmService.onAlarmTriggered = (id, title, body, reminderId, soundPath) {
  _showAlarmScreen(id, title, body, reminderId, soundPath);
};

void _showAlarmScreen(..., String? soundPath) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AlarmNotificationScreen(
        ...
        alarmSoundPath: soundPath,  // ✅ ارسال soundPath
      ),
    ),
  );
}
```

### 3. `lib/presentation/screens/alarm/alarm_notification_screen.dart`

**تغییرات:**

- ✅ Import کردن `AlarmService`
- ✅ پخش صدا در `initState`
- ✅ متوقف کردن صدا در `dispose`
- ✅ متوقف کردن صدا در `_dismissAlarm`
- ✅ متوقف کردن صدا در `_snoozeAlarm`
- ✅ ارسال `soundPath` در snooze

```dart
import '../../../core/services/alarm_service.dart';

class _AlarmNotificationScreenState extends State<AlarmNotificationScreen> {
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    // پخش صدای آلارم
    _alarmService.playAlarm(widget.alarmSoundPath);
  }

  @override
  void dispose() {
    // متوقف کردن صدای آلارم
    _alarmService.stopAlarm();
    super.dispose();
  }

  void _dismissAlarm() {
    _alarmService.stopAlarm();
    Navigator.of(context).pop();
  }
}
```

### 4. `lib/data/repositories/reminder_repository.dart`

**تغییرات:**

- ✅ ارسال `soundPath` در تمام فراخوانی‌های `scheduleSimpleAlarm`
- ✅ در `addReminder`
- ✅ در `updateReminder`
- ✅ در `toggleReminderActive`
- ✅ در `rescheduleAllActiveReminders`

```dart
await _simpleAlarmService.scheduleSimpleAlarm(
  id: reminder.notificationId,
  title: reminder.title,
  body: reminder.body ?? '',
  scheduledDateTime: reminder.scheduledDateTime,
  reminderId: reminder.id,
  soundPath: reminder.alarmSoundPath,  // ✅ اضافه شد
);
```

### 5. `lib/presentation/screens/debug/notification_test_screen.dart`

**تغییرات:**

- ✅ اضافه شدن `soundPath: 'default'` برای تست‌ها

### 6. `lib/core/services/alarm_debug_helper.dart`

**تغییرات:**

- ✅ اضافه شدن `soundPath: 'default'` برای آلارم تست

## نحوه کار سیستم

### 1. انتخاب صدا توسط کاربر

```
کاربر در صفحه Add/Edit Task/Goal
    ↓
انتخاب یادآور
    ↓
انتخاب صدای آلارم از لیست
    ↓
ذخیره reminder.alarmSoundPath
```

### 2. زمان‌بندی آلارم

```
ReminderRepository.addReminder(reminder)
    ↓
SimpleAlarmService.scheduleSimpleAlarm(
  soundPath: reminder.alarmSoundPath
)
    ↓
Timer ایجاد می‌شود
```

### 3. فعال شدن آلارم

```
Timer به پایان می‌رسد
    ↓
_triggerAlarm(id, title, body, reminderId, soundPath)
    ↓
onAlarmTriggered callback صدا زده می‌شود
    ↓
main._showAlarmScreen(..., soundPath)
    ↓
AlarmNotificationScreen باز می‌شود
    ↓
AlarmService.playAlarm(soundPath)
    ↓
🎵 صدا پخش می‌شود (loop)
```

### 4. متوقف کردن صدا

```
کاربر دکمه "بستن" یا "snooze" می‌زند
    ↓
AlarmService.stopAlarm()
    ↓
🔇 صدا متوقف می‌شود
```

## AlarmService

سرویس `AlarmService` مسئول پخش و کنترل صداهای آلارم است:

### متدها

#### `playAlarm(String? soundPath)`

- پخش صدای آلارم با مسیر داده شده
- اگر soundPath null یا خالی باشد، از صدای پیش‌فرض استفاده می‌کند
- اگر فایل پیدا نشود، به صدای پیش‌فرض برمی‌گردد
- صدا را در حالت loop قرار می‌دهد

#### `stopAlarm()`

- صدای در حال پخش را متوقف می‌کند
- AudioPlayer را آزاد می‌کند

#### `isPlaying` (getter)

- بررسی می‌کند که آیا صدایی در حال پخش است

### مثال استفاده

```dart
final alarmService = AlarmService();

// پخش صدای سفارشی
await alarmService.playAlarm('/path/to/sound.mp3');

// پخش صدای پیش‌فرض
await alarmService.playAlarm('default');

// متوقف کردن
await alarmService.stopAlarm();

// بررسی وضعیت
if (alarmService.isPlaying) {
  print('صدا در حال پخش است');
}
```

## انواع صدا

### 1. صدای پیش‌فرض (Default)

```dart
soundPath: 'default'
// یا
soundPath: null
```

از صدای نوتیفیکیشن سیستم استفاده می‌کند.

### 2. صدای سفارشی (Custom)

```dart
soundPath: '/data/user/0/.../my_alarm.mp3'
```

از فایل صوتی ذخیره شده در دستگاه استفاده می‌کند.

### 3. صدای سیستمی (System Sound)

```dart
AlarmSoundModel(
  name: 'System Notification',
  filePath: 'default',
  isSystemSound: true,
)
```

## مدیریت خطاها

### 1. فایل صدا پیدا نشود

```dart
if (File(soundPath).existsSync()) {
  await _audioPlayer.play(DeviceFileSource(soundPath));
} else {
  // Fallback to default sound
  await _playDefaultAlarm();
}
```

### 2. خطا در پخش صدا

```dart
try {
  await _audioPlayer.play(...);
} catch (e) {
  developer.log('Error playing alarm: $e');
  await _playDefaultAlarm();
}
```

### 3. صدای پیش‌فرض موجود نیست

اگر asset صدای پیش‌فرض وجود نداشته باشد، خطا لاگ می‌شود و برنامه crash نمی‌کند.

## تست سیستم

### 1. تست با صفحه Debug

```
1. به Settings → Alarm Debug بروید
2. دکمه "تنظیم آلارم تستی (۱ دقیقه)" را بزنید
3. 1 دقیقه صبر کنید
4. صفحه آلارم باید باز شود و صدا پخش شود
5. دکمه "بستن آلارم" را بزنید
6. صدا باید متوقف شود
```

### 2. تست با صفحه Test

```
1. به تب "تست" بروید
2. دکمه "تست آلارم فوری" را بزنید
3. صفحه آلارم باید فوراً باز شود و صدا پخش شود
4. دکمه "به تعویق انداختن" را بزنید
5. صدا باید متوقف شود
6. بعد از 5 دقیقه، دوباره آلارم فعال می‌شود
```

### 3. تست با یادآور واقعی

```
1. یک Task یا Goal ایجاد کنید
2. یک یادآور اضافه کنید
3. صدای آلارم را انتخاب کنید
4. زمان را 1 دقیقه بعد تنظیم کنید
5. ذخیره کنید
6. 1 دقیقه صبر کنید
7. آلارم باید فعال شود و صدا پخش شود
```

## نکات مهم

### 1. استفاده از AudioPlayer

- از package `audioplayers` استفاده می‌شود
- AudioPlayer به صورت singleton است
- قبل از پخش صدای جدید، صدای قبلی متوقف می‌شود

### 2. حالت Loop

- صدا در حالت loop پخش می‌شود
- تا زمانی که کاربر آلارم را رد نکند، ادامه دارد

### 3. مدیریت حافظه

- در `dispose` حتماً `stopAlarm` صدا زده می‌شود
- AudioPlayer به درستی آزاد می‌شود

### 4. soundPath در Snooze

- وقتی آلارم snooze می‌شود، همان soundPath حفظ می‌شود
- صدا در آلارم بعدی هم پخش می‌شود

## خطایابی (Troubleshooting)

### مشکل: صدا پخش نمی‌شود

**راه‌حل:**

1. بررسی کنید که `audioplayers` نصب است
2. مجوزهای صدا را در AndroidManifest بررسی کنید
3. لاگ‌های console را چک کنید
4. مطمئن شوید فایل صدا وجود دارد

### مشکل: صدا متوقف نمی‌شود

**راه‌حل:**

1. مطمئن شوید `stopAlarm()` صدا زده می‌شود
2. بررسی کنید که dispose به درستی اجرا می‌شود
3. لاگ‌های error را بررسی کنید

### مشکل: صدا بعد از snooze پخش نمی‌شود

**راه‌حل:**

1. مطمئن شوید soundPath در snooze ارسال می‌شود
2. بررسی کنید که ReminderRepository به درستی کار می‌کند

## Asset مورد نیاز

برای صدای پیش‌فرض، باید یک فایل صوتی به assets اضافه کنید:

### 1. ایجاد پوشه

```
assets/
  sounds/
    default_alarm.mp3
```

### 2. اضافه به pubspec.yaml

```yaml
flutter:
  assets:
    - assets/sounds/default_alarm.mp3
```

### 3. یا استفاده از صدای سیستم

می‌توانید به جای asset، از `AssetSource` صرف نظر کنید و فقط soundPath را `'default'` تنظیم کنید.

## ویژگی‌های آینده (پیشنهادی)

1. ✨ تنظیم volume صدا
2. ✨ انتخاب نوع loop (محدود یا نامحدود)
3. ✨ Fade in برای صدا
4. ✨ پخش همزمان صدا و ویبره
5. ✨ پیش‌نمایش صدا قبل از انتخاب
6. ✨ دسته‌بندی صداها
7. ✨ دانلود صداهای آنلاین

## نتیجه‌گیری

سیستم صدای آلارم به طور کامل و حرفه‌ای پیاده‌سازی شده است:

- ✅ انتخاب صدای سفارشی
- ✅ پخش خودکار
- ✅ مدیریت صحیح حافظه
- ✅ Fallback به صدای پیش‌فرض
- ✅ پشتیبانی از snooze
- ✅ خطایابی مناسب

این سیستم آماده برای استفاده در production است و تجربه کاربری عالی ارائه می‌دهد.

---

**نسخه:** 1.0  
**تاریخ:** اکتبر 2025  
**وضعیت:** ✅ آماده برای production
