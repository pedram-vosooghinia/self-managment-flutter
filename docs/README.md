# 📚 مستندات پروژه مدیریت شخصی

این فولدر شامل تمام مستندات فنی و راهنماهای استفاده از پروژه است.

## 📋 فهرست مستندات

### 🔔 راهنماهای آلارم و نوتیفیکیشن

#### [ALARM_GUIDE.md](ALARM_GUIDE.md)

راهنمای جامع برای رفع مشکلات آلارم و تنظیمات مربوطه:

- مجوزهای لازم Android
- تنظیمات timezone
- بازگردانی آلارم‌ها بعد از restart
- رفع مشکلات رایج (Xiaomi, Huawei و...)

#### [ALARM_SCREEN_GUIDE_FA.md](ALARM_SCREEN_GUIDE_FA.md)

راهنمای سیستم جدید صفحه آلارم تمام‌صفحه:

- معماری جدید SimpleAlarmService
- نحوه کار callback system
- تست و debugging
- مزایا و محدودیت‌ها

#### [ALARM_SOUND_GUIDE_FA.md](ALARM_SOUND_GUIDE_FA.md)

راهنمای کامل سیستم صدای آلارم:

- نحوه انتخاب و پخش صدا
- مدیریت AudioPlayer
- انواع صدا (default, custom, system)
- خطایابی مشکلات صدا

#### [NOTIFICATION_FIX_FA.md](NOTIFICATION_FIX_FA.md)

تاریخچه رفع باگ‌ها و مشکلات نوتیفیکیشن

#### [NOTIFICATION_REMOVAL_FA.md](NOTIFICATION_REMOVAL_FA.md)

مستندات حذف کامل سیستم نوتیفیکیشن و جایگزینی با SimpleAlarmService:

- دلایل تغییر معماری
- فایل‌های تغییر یافته
- Package‌های حذف شده
- مهاجرت از نسخه قبلی

---

### 🏗️ راهنماهای توسعه

#### [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)

دستورالعمل‌های build و deployment:

- نحوه build APK
- تنظیمات Gradle
- پیکربندی release

#### [DATABASE_REVIEW_FA.md](DATABASE_REVIEW_FA.md)

بررسی کامل ساختار دیتابیس Hive:

- مدل‌های داده
- TypeAdapter ها
- بهینه‌سازی‌ها

---

### 🔄 ویژگی‌های خاص

#### [RECURRING_TASKS_GUIDE_FA.md](RECURRING_TASKS_GUIDE_FA.md)

راهنمای استفاده از وظایف تکرارشونده:

- نحوه ایجاد task تکراری
- انواع تکرار (روزانه، هفتگی، ماهانه)
- مدیریت تکرارها

#### [RECURRING_TASKS_IMPLEMENTATION.md](RECURRING_TASKS_IMPLEMENTATION.md)

جزئیات فنی پیاده‌سازی تسک‌های تکراری:

- معماری
- الگوریتم‌ها
- کد منبع

#### [EXCEL_EXPORT_GUIDE_FA.md](EXCEL_EXPORT_GUIDE_FA.md)

راهنمای export داده‌ها به Excel:

- نحوه خروجی گرفتن
- فرمت فایل Excel
- اشتراک‌گذاری

---

### 📊 مستندات عمومی

#### [SUMMARY_FA.md](SUMMARY_FA.md)

خلاصه و نمای کلی پروژه:

- معماری کلی
- تکنولوژی‌های استفاده شده
- ویژگی‌های اصلی

#### [CHANGELOG_FA.md](CHANGELOG_FA.md)

تاریخچه تغییرات و نسخه‌های مختلف

#### [GEMINI.md](GEMINI.md)

یادداشت‌ها و نکات AI مربوط به توسعه

---

## 🗂️ دسته‌بندی بر اساس موضوع

### برای کاربران نهایی

- [ALARM_GUIDE.md](ALARM_GUIDE.md) - رفع مشکلات آلارم
- [RECURRING_TASKS_GUIDE_FA.md](RECURRING_TASKS_GUIDE_FA.md) - استفاده از تسک‌های تکراری
- [EXCEL_EXPORT_GUIDE_FA.md](EXCEL_EXPORT_GUIDE_FA.md) - خروجی Excel

### برای توسعه‌دهندگان

- [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) - ساخت پروژه
- [DATABASE_REVIEW_FA.md](DATABASE_REVIEW_FA.md) - ساختار دیتابیس
- [RECURRING_TASKS_IMPLEMENTATION.md](RECURRING_TASKS_IMPLEMENTATION.md) - پیاده‌سازی تسک‌ها
- [ALARM_SCREEN_GUIDE_FA.md](ALARM_SCREEN_GUIDE_FA.md) - معماری آلارم
- [ALARM_SOUND_GUIDE_FA.md](ALARM_SOUND_GUIDE_FA.md) - سیستم صدا
- [NOTIFICATION_REMOVAL_FA.md](NOTIFICATION_REMOVAL_FA.md) - تغییرات معماری

### تاریخچه و تغییرات

- [CHANGELOG_FA.md](CHANGELOG_FA.md) - لیست تغییرات
- [NOTIFICATION_FIX_FA.md](NOTIFICATION_FIX_FA.md) - تاریخچه باگ‌ها
- [SUMMARY_FA.md](SUMMARY_FA.md) - خلاصه پروژه

---

## 🔍 جستجو در مستندات

### مشکل با آلارم؟

→ [ALARM_GUIDE.md](ALARM_GUIDE.md)

### می‌خواهید صفحه آلارم سفارشی بسازید؟

→ [ALARM_SCREEN_GUIDE_FA.md](ALARM_SCREEN_GUIDE_FA.md)

### مشکل با پخش صدا؟

→ [ALARM_SOUND_GUIDE_FA.md](ALARM_SOUND_GUIDE_FA.md)

### می‌خواهید build کنید؟

→ [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)

### می‌خواهید ساختار دیتابیس را بفهمید؟

→ [DATABASE_REVIEW_FA.md](DATABASE_REVIEW_FA.md)

### تسک‌های تکراری می‌خواهید؟

→ [RECURRING_TASKS_GUIDE_FA.md](RECURRING_TASKS_GUIDE_FA.md)

### خروجی Excel می‌خواهید؟

→ [EXCEL_EXPORT_GUIDE_FA.md](EXCEL_EXPORT_GUIDE_FA.md)

---

## 📝 یادداشت

این مستندات به صورت مداوم به‌روزرسانی می‌شوند. اگر سوالی دارید که در مستندات پوشش داده نشده، لطفاً یک Issue در GitHub ایجاد کنید.

---

**آخرین بروزرسانی:** اکتبر 2025
