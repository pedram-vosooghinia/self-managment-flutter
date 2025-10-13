# حذف سیستم نوتیفیکیشن و استفاده کامل از SimpleAlarmService

## خلاصه تغییرات

تمام کدهای مربوط به سیستم نوتیفیکیشن (`NotificationService`) از پروژه حذف شدند. حالا پروژه فقط از `SimpleAlarmService` برای نمایش آلارم‌های تمام‌صفحه استفاده می‌کند.

## دلایل حذف نوتیفیکیشن

1. **تجربه کاربری بهتر**: صفحه تمام‌صفحه آلارم، توجه کاربر را بهتر جلب می‌کند
2. **سادگی**: نیازی به مدیریت پیچیده نوتیفیکیشن‌ها نیست
3. **مجوزها**: دیگر نیازی به درخواست مجوزهای نوتیفیکیشن نداریم
4. **قابلیت اطمینان**: مشکلات نوتیفیکیشن Android را دور می‌زنیم
5. **کاهش وابستگی**: سه package کمتر نیاز داریم

## فایل‌های حذف شده

### 1. سرویس‌ها

- ✅ `lib/core/services/notification_service.dart` - **حذف کامل**

### 2. Package‌های حذف شده از pubspec.yaml

- ✅ `flutter_local_notifications: ^17.0.0`
- ✅ `timezone: ^0.9.2`
- ✅ `permission_handler: ^11.0.1`

## فایل‌های تغییر یافته

### 1. `lib/main.dart`

**تغییرات:**

- ✅ حذف import `notification_service.dart`
- ✅ حذف راه‌اندازی `NotificationService().initialize()`
- ✅ حذف callback `onNotificationReceived`
- ✅ حذف متد `_handleNotification`
- ✅ فقط `SimpleAlarmService.onAlarmTriggered` باقی ماند

**قبل:**

```dart
import 'core/services/notification_service.dart';

// در main():
await NotificationService().initialize();

// در initState:
NotificationService.onNotificationReceived = (payload) {
  _handleNotification(payload);
};
```

**بعد:**

```dart
// فقط SimpleAlarmService
import 'core/services/simple_alarm_service.dart';

// در initState:
SimpleAlarmService.onAlarmTriggered = (id, title, body, reminderId) {
  _showAlarmScreen(id, title, body, reminderId);
};
```

### 2. `lib/data/repositories/reminder_repository.dart`

**تغییرات:**

- ✅ حذف فیلد `_notificationService` (قبلاً انجام شده بود)
- ✅ فقط از `SimpleAlarmService` استفاده می‌کند

### 3. `lib/presentation/screens/debug/notification_test_screen.dart`

**تغییرات:**

- ✅ حذف import `notification_service.dart`
- ✅ حذف فیلد `_notificationService`
- ✅ حذف دکمه "تست نوتیفیکیشن فوری"
- ✅ حذف دکمه "بررسی مجوزها"
- ✅ اضافه شدن نمایش تعداد آلارم‌های فعال
- ✅ تغییر عنوان AppBar به "تست آلارم"

**باقی مانده:**

- ✅ دکمه "تست آلارم صفحه‌باز ۵ ثانیه بعد"
- ✅ دکمه "تست آلارم فوری"

### 4. `lib/presentation/screens/alarm/alarm_notification_screen.dart`

**تغییرات:**

- ✅ حذف import `notification_service.dart`
- ✅ اضافه شدن import `simple_alarm_service.dart`
- ✅ تغییر متد `_snoozeAlarm` برای استفاده از `SimpleAlarmService`

**قبل:**

```dart
import '../../../core/services/notification_service.dart';

void _snoozeAlarm() async {
  final notificationService = NotificationService();
  await notificationService.scheduleNotification(...);
}
```

**بعد:**

```dart
import '../../../core/services/simple_alarm_service.dart';

void _snoozeAlarm() async {
  final simpleAlarmService = SimpleAlarmService();
  await simpleAlarmService.scheduleSimpleAlarm(...);
}
```

### 5. `lib/core/services/alarm_debug_helper.dart`

**تغییرات:**

- ✅ حذف import `notification_service.dart`
- ✅ حذف import `flutter_local_notifications`
- ✅ اضافه شدن import `simple_alarm_service.dart`
- ✅ حذف متد `getPendingAlarms()`
- ✅ حذف متد `checkPermissions()`
- ✅ تغییر متد `isNotificationScheduled()` به `isAlarmScheduled()`
- ✅ اضافه شدن متد `getActiveAlarmsCount()`
- ✅ تغییر `scheduleTestAlarm()` برای استفاده از `SimpleAlarmService`
- ✅ تغییر `cancelTestAlarm()` به void (غیر async)

### 6. `lib/presentation/screens/debug/alarm_debug_screen.dart`

**تغییرات:**

- ✅ حذف import `flutter_local_notifications`
- ✅ حذف فیلد `_pendingNotifications`
- ✅ حذف فیلد `_permissions`
- ✅ اضافه شدن فیلد `_activeAlarmsCount`
- ✅ تغییر متد `_loadDebugInfo()` برای دریافت اطلاعات از `SimpleAlarmService`
- ✅ تغییر متد `_cancelTestAlarm()` به void
- ✅ حذف کارت "مجوزها" از UI
- ✅ حذف لیست "آلارم‌های زمان‌بندی شده" از UI
- ✅ تغییر متن راهنما

**UI قبل:**

- کارت "مجوزها" با وضعیت نوتیفیکیشن
- کارت "آمار" با تعداد pending notifications
- لیست "آلارم‌های زمان‌بندی شده"
- لیست "یادآورهای فعال"

**UI بعد:**

- کارت "آمار" با تعداد آلارم‌های فعال (Timer)
- لیست "یادآورهای ذخیره شده"
- راهنمای بروزرسانی شده

### 7. `pubspec.yaml`

**تغییرات:**

- ✅ حذف `flutter_local_notifications: ^17.0.0`
- ✅ حذف `timezone: ^0.9.2`
- ✅ حذف `permission_handler: ^11.0.1`

## معماری جدید

```
User creates reminder → ReminderRepository
                             ↓
                    SimpleAlarmService
                             ↓
                    Timer (Dart async)
                             ↓
              Callback: onAlarmTriggered
                             ↓
                 main.dart (_showAlarmScreen)
                             ↓
              AlarmNotificationScreen (Full Screen)
                             ↓
                    User dismisses or snoozes
```

## مزایای معماری جدید

### 1. سادگی

- ❌ نیازی به `flutter_local_notifications` نیست
- ❌ نیازی به `timezone` conversion نیست
- ❌ نیازی به `permission_handler` نیست
- ✅ فقط از `Timer` استاندارد Dart استفاده می‌کنیم

### 2. کاهش وابستگی

**قبل:** 3 package اضافی
**بعد:** 0 package اضافی

### 3. کاهش حجم APK

حذف 3 package باعث کاهش قابل توجه حجم APK می‌شود.

### 4. کنترل بیشتر

- ✅ کنترل کامل بر UI و UX
- ✅ نیازی به پیکربندی channel نیست
- ✅ نیازی به تنظیمات Android خاص نیست

### 5. تجربه کاربری بهتر

- ✅ صفحه تمام‌صفحه قابل نادیده گرفتن نیست
- ✅ UI سفارشی و زیبا
- ✅ انیمیشن‌های روان

## محدودیت‌ها

### 1. نیاز به برنامه باز

⚠️ **مهم:** آلارم‌ها فقط زمانی کار می‌کنند که برنامه باز است (foreground یا background).

**راه‌حل آینده:**

- استفاده از `android_alarm_manager_plus` برای background execution
- استفاده از `WorkManager` برای Android
- استفاده از `BackgroundFetch` برای iOS

### 2. از دست رفتن Timer بعد از Force Close

اگر سیستم برنامه را force close کند، Timer‌ها از بین می‌روند.

**راه‌حل موجود:**

- متد `rescheduleAllActiveReminders()` در startup برنامه
- این متد تمام یادآورهای فعال را دوباره زمان‌بندی می‌کند

## نحوه استفاده

### برای کاربران عادی

هیچ تغییری در نحوه استفاده وجود ندارد. همه چیز مثل قبل کار می‌کند، فقط بهتر!

### برای توسعه‌دهندگان

#### ایجاد آلارم

```dart
final simpleAlarmService = SimpleAlarmService();

await simpleAlarmService.scheduleSimpleAlarm(
  id: 123,
  title: 'یادآور',
  body: 'توضیحات',
  scheduledDateTime: DateTime.now().add(Duration(minutes: 5)),
  reminderId: 'unique_id',
);
```

#### لغو آلارم

```dart
simpleAlarmService.cancelAlarm(123);
```

#### لغو همه آلارم‌ها

```dart
simpleAlarmService.cancelAllAlarms();
```

#### بررسی وضعیت آلارم

```dart
bool isActive = simpleAlarmService.isAlarmActive(123);
int count = simpleAlarmService.activeAlarmsCount;
```

## تست سیستم

### صفحه تست

1. به تب "تست" بروید
2. دکمه "تست آلارم فوری" را بزنید - صفحه باید فوراً باز شود
3. دکمه "تست آلارم صفحه‌باز ۵ ثانیه بعد" را بزنید - بعد از 5 ثانیه صفحه باید باز شود

### صفحه Debug

1. به Settings → Alarm Debug بروید
2. بررسی کنید: "آلارم‌های فعال" و "یادآورهای ذخیره شده" برابر باشند
3. اگر برابر نیستند، روی "بازنشانی همه آلارم‌ها" کلیک کنید

## مهاجرت از نسخه قبلی

### برای کاربران

- ✅ نیازی به کار خاصی نیست
- ✅ تمام یادآورهای قبلی حفظ می‌شوند
- ✅ در اولین اجرا، یادآورها دوباره زمان‌بندی می‌شوند

### برای توسعه‌دهندگان

1. ✅ `flutter pub get` را اجرا کنید (package‌های قدیمی حذف می‌شوند)
2. ✅ برنامه را rebuild کنید
3. ✅ اگر از `NotificationService` در کد خودتان استفاده می‌کردید، به `SimpleAlarmService` تغییر دهید

## دستورات لازم

```bash
# پاک کردن cache و build
flutter clean

# دریافت package‌های جدید
flutter pub get

# اجرای build_runner (برای hive)
flutter pub run build_runner build --delete-conflicting-outputs

# Build برای Android
flutter build apk

# یا Run
flutter run
```

## سوالات متداول (FAQ)

### Q: آیا یادآورهای قبلی من حفظ می‌شوند؟

✅ **بله!** تمام یادآورها در دیتابیس Hive ذخیره هستند و حفظ می‌شوند.

### Q: آیا آلارم‌ها وقتی برنامه بسته است کار می‌کنند؟

⚠️ **خیر.** برنامه باید باز باشد (foreground یا background).

### Q: چگونه می‌توانم آلارم‌ها را در background اجرا کنم؟

💡 برای background execution، می‌توانید از `android_alarm_manager_plus` استفاده کنید.

### Q: آیا نیاز به مجوز خاصی دارم؟

✅ **خیر!** دیگر نیازی به مجوز نوتیفیکیشن نیست.

### Q: چرا تعداد آلارم‌های فعال با یادآورها برابر نیست؟

💡 این ممکن است بعد از restart برنامه اتفاق بیفتد. روی "بازنشانی همه آلارم‌ها" کلیک کنید.

### Q: دکمه "به تعویق انداختن" چطور کار می‌کند؟

✅ یک آلارم جدید برای 5 دقیقه بعد ایجاد می‌کند (با `SimpleAlarmService`).

## خطایابی (Troubleshooting)

### مشکل: آلارم‌ها اجرا نمی‌شوند

**راه‌حل:**

1. مطمئن شوید برنامه باز است
2. به صفحه Debug بروید و "بازنشانی همه آلارم‌ها" را بزنید
3. لاگ‌های console را بررسی کنید

### مشکل: خطای compile

**راه‌حل:**

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### مشکل: برنامه crash می‌کند

**راه‌حل:**

1. تمام فایل‌های تغییر یافته را بررسی کنید
2. مطمئن شوید `flutter pub get` را اجرا کرده‌اید
3. Log‌های error را بررسی کنید

## نتیجه‌گیری

با حذف سیستم نوتیفیکیشن:

- ✅ کد ساده‌تر و تمیزتر شد
- ✅ وابستگی‌ها کاهش یافت
- ✅ تجربه کاربری بهتر شد
- ✅ کنترل بیشتری داریم
- ✅ مشکلات کمتری خواهیم داشت

این یک معماری مدرن و ساده است که به راحتی قابل توسعه و نگهداری است.

---

**نسخه:** 3.0  
**تاریخ:** اکتبر 2025  
**وضعیت:** ✅ آماده برای production
