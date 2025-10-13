# پیاده‌سازی قابلیت تسک‌های تکراری روزانه

## خلاصه تغییرات

این سند شامل تمام تغییراتی است که برای پیاده‌سازی قابلیت تسک‌های تکراری روزانه انجام شده است.

## 1. تغییرات در مدل‌ها (Models)

### TaskModel (`lib/data/models/task_model.dart`)

فیلدهای جدید اضافه شده:

- `@HiveField(8) bool isRecurring` - مشخص می‌کند که آیا تسک تکراری است یا خیر
- `@HiveField(9) DateTime? recurringTime` - ساعت تکرار روزانه (فقط hour و minute مهم است)

متد `copyWith` به‌روزرسانی شده تا فیلدهای جدید را پشتیبانی کند.

### ReminderModel (`lib/data/models/reminder_model.dart`)

فیلد جدید اضافه شده:

- `@HiveField(9) bool isRecurring` - مشخص می‌کند که آیا یادآور تکراری است یا خیر

## 2. سرویس جدید

### RecurringTaskService (`lib/core/services/recurring_task_service.dart`)

سرویس جدیدی برای مدیریت تسک‌های تکراری ایجاد شد با قابلیت‌های زیر:

#### متدهای اصلی:

- `scheduleDailyReminders()` - زمان‌بندی یادآورهای روزانه برای تمام تسک‌های تکراری
- `scheduleReminderForTask(TaskModel task)` - زمان‌بندی یادآور برای یک تسک خاص
- `removeRecurringRemindersForTask(String taskId)` - حذف یادآورهای تکراری یک تسک
- `_cleanUpOldRecurringReminders()` - پاک کردن یادآورهای قدیمی (قدیمی‌تر از دیروز)

#### منطق کار:

1. تمام تسک‌های تکراری را از دیتابیس می‌خواند
2. برای هر تسک، یادآور روزانه ایجاد می‌کند
3. اگر ساعت تنظیم شده گذشته باشد، برای فردا زمان‌بندی می‌کند
4. یادآورهای تکراری قدیمی را حذف می‌کند

## 3. بروزرسانی Provider

### TaskProvider (`lib/presentation/providers/task_provider.dart`)

تغییرات:

- افزودن `AlarmSoundRepository` به constructor
- افزودن `RecurringTaskService` به عنوان یک فیلد
- بروزرسانی `addTask()` برای پشتیبانی از پارامترهای `isRecurring` و `recurringTime`
- بروزرسانی `updateTask()` برای مدیریت یادآورهای تکراری
- بروزرسانی `deleteTask()` برای حذف یادآورهای تکراری

## 4. بروزرسانی رابط کاربری

### AddEditTaskScreen (`lib/presentation/screens/tasks/add_edit_task_screen.dart`)

تغییرات UI:

#### فیلدهای جدید State:

- `bool _isRecurring` - وضعیت سوئیچ تکرار
- `TimeOfDay? _recurringTime` - ساعت انتخاب شده برای تکرار

#### اجزای UI جدید:

1. **SwitchListTile** برای فعال/غیرفعال کردن تکرار روزانه
2. **ListTile** برای انتخاب ساعت تکرار (فقط در حالت تکراری نمایش داده می‌شود)
3. **ListTile** برای انتخاب صدای آلارم (فقط در حالت تکراری نمایش داده می‌شود)
4. یادآور معمولی فقط زمانی نمایش داده می‌شود که تسک تکراری نباشد

#### متدهای جدید:

- `_pickRecurringTime()` - نمایش TimePicker برای انتخاب ساعت تکرار

#### اعتبارسنجی:

- بررسی انتخاب ساعت برای تسک‌های تکراری
- بررسی انتخاب صدای آلارم برای تسک‌های تکراری

## 5. بروزرسانی main.dart

### تغییرات در `main()`:

افزودن کد زمان‌بندی یادآورهای تکراری در هنگام شروع برنامه:

```dart
// زمان‌بندی یادآورهای تکراری روزانه
try {
  final taskRepository = TaskRepository();
  final reminderRepository = ReminderRepository();
  final alarmSoundRepository = AlarmSoundRepository();

  final recurringTaskService = RecurringTaskService(
    taskRepository: taskRepository,
    reminderRepository: reminderRepository,
    alarmSoundRepository: alarmSoundRepository,
  );

  await recurringTaskService.scheduleDailyReminders();
} catch (e) {
  debugPrint('خطا در زمان‌بندی یادآورهای تکراری: $e');
}
```

### تغییرات در TaskProvider initialization:

افزودن `alarmSoundRepository` به constructor:

```dart
ChangeNotifierProvider(
  create: (_) => TaskProvider(
    taskRepository: taskRepository,
    reminderRepository: reminderRepository,
    alarmSoundRepository: alarmSoundRepository,
  ),
),
```

## 6. فایل‌های تولید شده

فایل‌های زیر با `build_runner` بازتولید شدند:

- `lib/data/models/task_model.g.dart`
- `lib/data/models/reminder_model.g.dart`

## نحوه عملکرد سیستم

### 1. ایجاد تسک تکراری جدید:

```
کاربر → AddEditTaskScreen → TaskProvider.addTask() →
RecurringTaskService.scheduleReminderForTask() →
ایجاد ReminderModel → ReminderRepository → NotificationService
```

### 2. شروع برنامه:

```
main() → RecurringTaskService.scheduleDailyReminders() →
بررسی تمام تسک‌های تکراری →
ایجاد یادآورهای روزانه →
پاک کردن یادآورهای قدیمی
```

### 3. ویرایش تسک تکراری:

```
کاربر → AddEditTaskScreen → TaskProvider.updateTask() →
بررسی isRecurring →
RecurringTaskService.scheduleReminderForTask() یا
RecurringTaskService.removeRecurringRemindersForTask()
```

## بهینه‌سازی‌های انجام شده

1. **جلوگیری از ایجاد یادآورهای تکراری:**

   - قبل از ایجاد یادآور جدید، بررسی می‌شود که آیا قبلاً برای همان زمان یادآور وجود دارد یا خیر

2. **مدیریت حافظه:**

   - یادآورهای قدیمی‌تر از دیروز به صورت خودکار حذف می‌شوند

3. **مقاوم در برابر خطا:**
   - تمام عملیات در بلوک‌های try-catch قرار دارند
   - خطاها به صورت مناسب log می‌شوند

## تست‌های پیشنهادی

### تست‌های دستی:

1. ✅ ایجاد تسک تکراری با ساعت آینده
2. ✅ ایجاد تسک تکراری با ساعت گذشته (باید برای فردا تنظیم شود)
3. ✅ ویرایش ساعت تسک تکراری
4. ✅ تبدیل تسک عادی به تکراری
5. ✅ تبدیل تسک تکراری به عادی
6. ✅ حذف تسک تکراری
7. ✅ بستن و باز کردن مجدد برنامه (بررسی بازیابی یادآورها)

## ملاحظات آینده

### پیشنهادات برای نسخه‌های بعدی:

1. پشتیبانی از روزهای هفته خاص (مثلاً فقط شنبه تا چهارشنبه)
2. تکرار با فواصل زمانی دلخواه (هر 2 ساعت، هر 3 روز و...)
3. تاریخ شروع و پایان برای تسک‌های تکراری
4. آمار تکمیل تسک‌های تکراری
5. گزارش‌گیری از عملکرد تسک‌های تکراری
6. یادآوری چندگانه در روز (مثلاً 3 بار در روز دارو بخور)

## وابستگی‌ها

هیچ پکیج جدیدی به پروژه اضافه نشده است. از پکیج‌های موجود استفاده شده:

- `hive` - برای ذخیره‌سازی داده
- `flutter_local_notifications` - برای نمایش نوتیفیکیشن‌ها
- `provider` - برای مدیریت state
- `uuid` - برای تولید ID یکتا

## خلاصه فایل‌های تغییر یافته

```
lib/
├── data/
│   └── models/
│       ├── task_model.dart (بروزرسانی)
│       ├── task_model.g.dart (تولید مجدد)
│       ├── reminder_model.dart (بروزرسانی)
│       └── reminder_model.g.dart (تولید مجدد)
├── core/
│   └── services/
│       └── recurring_task_service.dart (جدید)
├── presentation/
│   ├── providers/
│   │   └── task_provider.dart (بروزرسانی)
│   └── screens/
│       └── tasks/
│           └── add_edit_task_screen.dart (بروزرسانی)
└── main.dart (بروزرسانی)

سایر:
├── RECURRING_TASKS_GUIDE_FA.md (جدید - راهنمای کاربر)
└── RECURRING_TASKS_IMPLEMENTATION.md (جدید - این فایل)
```

---

**تاریخ پیاده‌سازی:** اکتبر 2025
**نسخه:** 1.0.0
