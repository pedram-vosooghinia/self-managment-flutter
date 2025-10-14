# 🔧 راهنمای رفع مشکلات آلارم

## مشکلات رایج و راه‌حل‌ها

---

## مشکل 1: صفحه آلارم باز نمی‌شود ❌

### علت‌های احتمالی:

#### 1. Callback تنظیم نشده

**بررسی:** لاگ‌های console را چک کنید:

```
Warning: onAlarmTriggered callback not set!
```

**راه‌حل:** مطمئن شوید برنامه به درستی راه‌اندازی شده است.

#### 2. برنامه بسته است

**راه‌حل:**

- برنامه را باز کنید
- دکمه Home بزنید (نبندید!)
- از Recent Apps پاک نکنید

#### 3. زمان آلارم در گذشته است

**بررسی:** تاریخ و ساعت گوشی را چک کنید

**راه‌حل:** آلارم را برای آینده تنظیم کنید

---

## مشکل 2: صدا پخش نمی‌شود 🔇

### علت‌های احتمالی:

#### 1. هیچ صدایی انتخاب نشده

اگر soundPath = `null` یا `'default'` باشد، صدایی پخش نمی‌شود.

**راه‌حل:**

1. به Settings > Alarm Sounds بروید
2. یک صدای سفارشی اضافه کنید
3. از File Picker یک فایل MP3 انتخاب کنید
4. هنگام ساخت Task/Goal، آن صدا را انتخاب کنید

#### 2. فایل صدا وجود ندارد

**بررسی لاگ‌ها:**

```
Sound file not found: /path/to/sound.mp3
```

**راه‌حل:**

- دوباره صدا را از Settings > Alarm Sounds اضافه کنید
- مطمئن شوید فایل در گوشی وجود دارد

#### 3. مجوز Audio

**راه‌حل:**

```
Settings > Apps > Self Management > Permissions
→ Storage: Allow
```

---

## مشکل 3: برنامه Crash می‌کند 💥

### سناریوهای Crash:

#### Crash 1: هنگام ایجاد یادآور

**لاگ console را بررسی کنید!**

**اگر خطا مربوط به soundPath باشد:**

```dart
// الان AlarmService از try-catch استفاده می‌کند
// crash نباید بیفتد
```

**راه‌حل:**

```bash
flutter clean
flutter pub get
flutter run
```

#### Crash 2: هنگام فعال شدن آلارم

**علت احتمالی:** مشکل در ReminderModel

**راه‌حل:**

1. به Settings > عیب‌یابی آلارم‌ها بروید
2. "بازنشانی همه آلارم‌ها" را بزنید
3. یک یادآور جدید بسازید

#### Crash 3: هنگام Snooze

**راه‌حل:** الان Snooze با SimpleAlarmService کار می‌کند، crash نباید بیفتد.

---

## مشکل 4: آلارم در Background کار نمی‌کند 🌙

### بررسی‌های لازم:

#### 1. مجوز Notification

**بررسی:**

```
Settings > Apps > Self Management > Permissions > Notifications
```

**باید:** ✅ Allowed

**اگر Denied است:**

```
Settings > Apps > Self Management > Notifications > Allow
```

#### 2. مجوز Alarms & Reminders (Android 12+)

**بررسی:**

```
Settings > Alarms & reminders
→ Self Management باید در لیست Allowed apps باشد
```

**اگر نیست:**

- برنامه را Uninstall کنید
- دوباره نصب کنید
- اولین بار که باز می‌کنید، مجوز را بدهید

#### 3. NotificationService initialize شده؟

**بررسی لاگ‌های startup:**

```
✅ سرویس نوتیفیکیشن راه‌اندازی شد
```

**اگر این لاگ نیست:**

- مشکل در initialization است
- `flutter clean` و `flutter pub get` را اجرا کنید

---

## مشکل 5: آلارم بعد از Restart کار نمی‌کند 🔄

### راه‌حل:

بعد از restart گوشی:

1. **برنامه را یک بار باز کنید** (reschedule اتفاق می‌افتد)
2. می‌توانید ببندید
3. آلارم‌ها دوباره زمان‌بندی شده‌اند

**لاگ مورد انتظار:**

```
آلارم‌های فعال با موفقیت بازنشانی شدند
```

---

## 🧪 تست گام به گام

### تست سیستم SimpleAlarm (Foreground):

```
1. برنامه را باز کنید
2. تب "تست" → "تست آلارم فوری"
3. انتظار:
   ✅ صفحه آلارم فوری باز شود
   ✅ بدون crash
   ⚠️ صدا نمی‌آید (چون soundPath = null)

4. اگر کار کرد:
   ✅ SimpleAlarmService سالم است

5. اگر کار نکرد:
   ❌ مشکل در callback است
   → لاگ‌ها را بررسی کنید
```

### تست سیستم Notification (Background):

```
1. یک یادآور برای 2 دقیقه بعد بسازید
2. Settings > Apps > Self Management > Force Stop
3. 2 دقیقه صبر کنید
4. انتظار:
   ✅ نوتیفیکیشن نمایش داده شود

5. روی نوتیفیکیشن کلیک کنید:
   ✅ برنامه باز شود
   ✅ صفحه آلارم نمایش داده شود

6. اگر نوتیفیکیشن نیامد:
   ❌ مجوز Notification داده نشده
   ❌ یا NotificationService initialize نشده
```

---

## 🔍 لاگ‌های مفید

برای debugging، این لاگ‌ها را دنبال کنید:

### هنگام Schedule:

```
[SimpleAlarmService] Scheduling alarm for X seconds from now
[SimpleAlarmService] Alarm scheduled successfully (ID: Y)
[NotificationService] Background notification scheduled for ...
```

### هنگام Trigger:

```
[SimpleAlarmService] Alarm triggered - opening screen (ID: X) with sound: ...
```

### هنگام پخش صدا:

```
[AlarmService] Playing custom alarm sound: /path/to/sound.mp3
```

یا

```
[AlarmService] Default sound selected - alarm will be silent
```

### خطاها:

```
[AlarmService] Error playing alarm sound: ...
[AlarmService] Sound file not found: ...
```

---

## 📝 Checklist کامل

قبل از گزارش مشکل، این موارد را بررسی کنید:

### برای Foreground (برنامه باز):

- [ ] برنامه باز است؟
- [ ] به تب "تست" رفتید؟
- [ ] "تست آلارم فوری" کار کرد؟
- [ ] لاگ "Alarm triggered" آمد؟

### برای صدا:

- [ ] soundPath چیست؟ (null, 'default', یا مسیر فایل)
- [ ] اگر مسیر فایل: فایل وجود دارد؟
- [ ] مجوز Storage داده شده؟
- [ ] لاگ "Playing custom alarm sound" آمد؟

### برای Background:

- [ ] مجوز Notification داده شده؟
- [ ] مجوز Alarms & Reminders داده شده؟
- [ ] لاگ "Notification service initialized" آمد؟
- [ ] لاگ "Background notification scheduled" آمد؟
- [ ] Battery optimization: Unrestricted?
- [ ] Autostart: Enabled? (Xiaomi/Huawei)

---

## 🚑 راه‌حل‌های سریع

### اگر هیچ چیز کار نمی‌کند:

```bash
# 1. پاک کردن کامل
flutter clean

# 2. حذف build folder
rm -rf build

# 3. دریافت مجدد packages
flutter pub get

# 4. Uninstall برنامه از گوشی
# Settings > Apps > Self Management > Uninstall

# 5. Build و نصب مجدد
flutter build apk --release

# 6. نصب APK جدید
# اولین بار: مجوزها را بدهید!
```

---

## 📱 تنظیمات گوشی‌های خاص

### Xiaomi (MIUI) - بسیار مهم! 🔴

```
Settings > Apps > Manage apps > Self Management

1. Permissions:
   ✅ Notifications: Allowed
   ✅ Display pop-up windows while running in background: Allow
   ✅ Display pop-up window: Allow

2. Battery saver:
   ✅ No restrictions

3. Autostart:
   ✅ Enabled

4. Other permissions:
   ✅ Start in background: Allow
```

### Huawei (EMUI):

```
Settings > Battery > App launch > Self Management

✅ Manage manually (NOT automatic)
✅ Auto-launch: ON
✅ Secondary launch: ON
✅ Run in background: ON
```

### Samsung:

```
Settings > Apps > Self Management > Battery
→ Unrestricted ✅

Settings > Apps > Self Management
→ Remove from "Sleeping apps" list ✅
→ Remove from "Deep sleeping apps" list ✅
```

---

## 📞 اگر هنوز مشکل دارید

### اطلاعات مورد نیاز برای گزارش مشکل:

1. **مدل گوشی:** (مثلاً Xiaomi Redmi Note 10)
2. **نسخه Android:** (مثلاً Android 13)
3. **حالت تست:**
   - [ ] Foreground (برنامه باز)
   - [ ] Background (Home زده)
   - [ ] Closed (Force Stop)
4. **لاگ‌های Console:** (اگر در debug mode هستید)
5. **مجوزها:** (Notification: Yes/No, Alarms: Yes/No)
6. **تنظیمات Battery:** (Restricted/Unrestricted)

---

**با این راهنما باید بتوانید 99% مشکلات را حل کنید!** 🎯
