# دستورالعمل Build و نصب اپلیکیشن

## مراحل اجرا

### 1. پاک کردن فایل‌های قبلی و دریافت وابستگی‌ها

```bash
flutter clean
flutter pub get
```

### 2. Build کردن اپلیکیشن برای اندروید

#### برای تست (Debug Mode):

```bash
flutter run
```

#### برای استفاده واقعی (Release Mode):

```bash
flutter build apk --release
```

فایل APK در مسیر زیر ساخته می‌شود:

```
build/app/outputs/flutter-apk/app-release.apk
```

### 3. نصب APK روی گوشی

#### نصب مستقیم از طریق USB:

```bash
flutter install
```

#### یا کپی فایل APK روی گوشی:

فایل `app-release.apk` را از پوشه `build/app/outputs/flutter-apk/` به گوشی منتقل کرده و نصب کنید.

## نکات مهم

### ⚠️ حتماً باید اپلیکیشن را مجدداً نصب کنید

تغییرات در `AndroidManifest.xml` فقط با نصب مجدد (uninstall + install) اعمال می‌شود.

### مراحل نصب مجدد:

1. **پاک کردن نسخه قبلی:**

   - روی گوشی: Settings > Apps > Self Management > Uninstall
   - یا از طریق USB: `adb uninstall com.example.self_management`

2. **نصب نسخه جدید:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## تست آلارم

### 1. بررسی مجوزها

بعد از نصب اپلیکیشن:

1. به صفحه Settings بروید
2. روی "Debug Alarms" کلیک کنید
3. مجوزها را بررسی کنید (باید همه فعال باشند)

### 2. تست سریع

1. در صفحه "Debug Alarms":
2. روی دکمه "تنظیم آلارم تستی (۱ دقیقه)" کلیک کنید
3. اپلیکیشن را ببندید (به صفحه اصلی بروید)
4. یک دقیقه صبر کنید
5. باید نوتیفیکیشن و صدای آلارم نمایش داده شود

### 3. بررسی آلارم‌های فعال

در صفحه "Debug Alarms" می‌توانید ببینید:

- چند آلارم زمان‌بندی شده است
- چند یادآور فعال دارید
- لیست همه آلارم‌های pending

## رفع مشکل

### اگر آلارم کار نکرد:

1. **مجوزها را بررسی کنید:**

   - Settings > Apps > Self Management > Permissions
   - همه مجوزها را فعال کنید

2. **تنظیمات باتری:**

   - Settings > Apps > Self Management > Battery
   - "Unrestricted" را انتخاب کنید

3. **Autostart (برای Xiaomi, Huawei, etc.):**

   - Settings > Apps > Self Management
   - گزینه Autostart را فعال کنید

4. **بررسی لاگ‌ها:**
   ```bash
   flutter run
   adb logcat -s AlarmDebug NotificationService
   ```

## ساخت نسخه نهایی

برای ساخت نسخه نهایی برای انتشار:

```bash
flutter build apk --release --split-per-abi
```

این دستور سه فایل APK می‌سازد (یکی برای هر معماری):

- `app-armeabi-v7a-release.apk` (گوشی‌های قدیمی‌تر)
- `app-arm64-v8a-release.apk` (اکثر گوشی‌های جدید)
- `app-x86_64-release.apk` (شبیه‌ساز)

برای نصب روی اکثر گوشی‌ها از `app-arm64-v8a-release.apk` استفاده کنید.

## بررسی نسخه اندروید

برای اطمینان از سازگاری با گوشی خود:

```bash
adb shell getprop ro.build.version.sdk
```

- SDK 31+ = Android 12+
- SDK 33+ = Android 13+

## دستورات مفید

### پاک کردن همه داده‌های اپلیکیشن:

```bash
adb shell pm clear com.example.self_management
```

### بررسی آلارم‌های زمان‌بندی شده:

```bash
adb shell dumpsys alarm | grep self_management
```

### مشاهده لاگ‌های آلارم:

```bash
adb logcat | grep -E "AlarmDebug|NotificationService"
```

## پشتیبانی

اگر بعد از انجام تمام مراحل هنوز مشکل دارید:

1. فایل `ALARM_GUIDE.md` را مطالعه کنید
2. لاگ‌های اپلیکیشن را بررسی کنید
3. مدل و نسخه اندروید گوشی خود را اطلاع دهید
