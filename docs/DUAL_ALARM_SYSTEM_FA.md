# 🎯 سیستم دوگانه آلارم (Dual Alarm System)

## ✅ حل مشکل Background!

حالا آلارم‌ها **در هر شرایطی** کار می‌کنند:

- ✅ برنامه باز است
- ✅ برنامه در background است
- ✅ برنامه بسته است
- ✅ گوشی قفل است
- ✅ بعد از restart گوشی

## چطور کار می‌کند؟

### سیستم دوگانه (Dual System)

هر آلارم با **دو سیستم مختلف همزمان** زمان‌بندی می‌شود:

```
         یک Reminder ایجاد می‌شود
                    ↓
         ┌──────────┴──────────┐
         ↓                     ↓
  SimpleAlarmService    NotificationService
  (Timer در Dart)      (Android Alarm Manager)
         ↓                     ↓
  فقط در foreground    در هر شرایطی
```

### سناریو 1: برنامه باز است 🟢

```
Timer در SimpleAlarmService فعال می‌شود (سریع‌تر!)
         ↓
صفحه آلارم فوراً باز می‌شود
         ↓
🎵 صدا پخش می‌شود
```

**مزایا:**

- ⚡ بدون تاخیر (instant)
- 🎨 تجربه کاربری بهتر
- 🔇 بدون نوتیفیکیشن اضافی

### سناریو 2: برنامه بسته است 🔴

```
Android Alarm Manager فعال می‌شود
         ↓
نوتیفیکیشن با fullScreenIntent نمایش داده می‌شود
         ↓
کاربر روی نوتیفیکیشن کلیک می‌کند
         ↓
برنامه باز می‌شود
         ↓
صفحه آلارم نمایش داده می‌شود
         ↓
🎵 صدا پخش می‌شود
```

**مزایا:**

- ✅ حتی در deep sleep کار می‌کند
- ✅ بعد از restart هم کار می‌کند
- ✅ قابل اطمینان 100%

---

## 🔧 مراحل نصب

### 1. نصب Dependencies

```bash
flutter clean
flutter pub get
```

### 2. Uninstall نسخه قبلی

**مهم!** باید نسخه قبلی را حذف کنید:

```
Settings > Apps > Self Management > Uninstall
```

### 3. Build و نصب

```bash
flutter build apk --release
```

سپس APK از مسیر `build/app/outputs/flutter-apk/app-release.apk` را نصب کنید.

---

## 🎯 مجوزهای لازم

اولین بار که برنامه را باز می‌کنید، این مجوزها درخواست می‌شود:

### 1. مجوز Notification (Android 13+)

```
"Allow Self Management to send you notifications?"
→ Allow ✅
```

### 2. مجوز Alarms & Reminders (Android 12+)

```
"Allow Self Management to schedule exact alarms?"
→ Allow ✅
```

اگر مجوزها را ندهید:

- ⚠️ آلارم در background کار نمی‌کند
- ⚠️ فقط در foreground کار می‌کند

---

## 🧪 تست کامل

### تست 1: Foreground (برنامه باز) ⚡

```
1. برنامه را باز کنید
2. به تب "تست" بروید
3. "تست آلارم فوری" را بزنید
4. ✅ صفحه فوراً باز می‌شود + صدا
```

### تست 2: Background (دکمه Home) 🏠

```
1. یادآور برای 2 دقیقه بعد بسازید
2. دکمه Home را بزنید
3. Instagram یا هر برنامه دیگری باز کنید
4. بعد از 2 دقیقه:
   - اگر برنامه هنوز در Recent Apps است:
     ✅ صفحه آلارم باز می‌شود (SimpleAlarm)
   - اگر برنامه kill شده:
     ✅ نوتیفیکیشن می‌آید (Notification)
```

### تست 3: Closed (برنامه بسته) 🔒

```
1. یادآور برای 3 دقیقه بعد بسازید
2. Settings > Apps > Self Management > Force Stop
3. گوشی را قفل کنید
4. بعد از 3 دقیقه:
   ✅ نوتیفیکیشن روی lock screen نمایش داده می‌شود
   ✅ کلیک → برنامه باز می‌شود → صفحه آلارم + صدا
```

### تست 4: After Reboot 🔄

```
1. یادآور برای 10 دقیقه بعد بسازید
2. گوشی را restart کنید
3. بعد از روشن شدن:
   - یک بار برنامه را باز کنید (برای reschedule)
   - می‌توانید ببندید
4. بعد از 10 دقیقه:
   ✅ آلارم فعال می‌شود
```

---

## 📊 مقایسه حالت‌های مختلف

| وضعیت برنامه             | سیستم فعال   | نحوه نمایش        | سرعت       |
| ------------------------ | ------------ | ----------------- | ---------- |
| 🟢 Foreground (باز)      | SimpleAlarm  | صفحه فوری         | ⚡ Instant |
| 🔵 Background (Home زده) | SimpleAlarm  | صفحه فوری         | ⚡ Instant |
| 🟡 Background (Kill شده) | Notification | نوتیفیکیشن → صفحه | 1-2 ثانیه  |
| 🔴 Closed (Force Stop)   | Notification | نوتیفیکیشن → صفحه | 1-2 ثانیه  |
| 🟣 Lock Screen           | Notification | روی صفحه قفل      | 1-2 ثانیه  |

---

## ⚠️ نکات مهم

### 1. مجوزها را بدهید!

بدون مجوز notification، سیستم backup کار نمی‌کند.

### 2. Uninstall قبلی ضروری است!

برای اعمال تنظیمات AndroidManifest، باید uninstall کنید.

### 3. تنظیمات Battery

برای بهترین نتیجه:

```
Settings > Battery > App battery usage
→ Self Management → Unrestricted
```

### 4. Autostart (Xiaomi, Huawei)

```
Settings > Apps > Autostart
→ Self Management → Enable
```

---

## 🎉 خلاصه

**قبل:**

- ❌ فقط در foreground کار می‌کرد
- ❌ وقتی برنامه بسته بود، آلارم نمی‌آمد

**بعد:**

- ✅ در foreground: صفحه فوری + صدا (SimpleAlarm)
- ✅ در background/closed: نوتیفیکیشن → صفحه + صدا (Notification)
- ✅ 100% reliable!

**حالا می‌توانید برنامه را ببندید و آلارم باز هم کار می‌کند!** 🎊

---

**نکته:** اولین بار که آلارم را تست می‌کنید، مجوزها را بدهید تا سیستم backup فعال شود! 🔔
