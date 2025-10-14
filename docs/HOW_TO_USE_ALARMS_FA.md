# 📱 راهنمای استفاده از آلارم‌ها

## ⚠️ نکته مهم

**آلارم‌ها فقط وقتی برنامه باز است کار می‌کنند!**

برنامه می‌تواند در background باشد، اما نباید force close شود.

---

## ✅ نحوه صحیح استفاده

### مرحله 1: ایجاد یادآور

#### برای Task (وظیفه):

1. به تب **"تسک‌ها"** بروید
2. دکمه **+** را بزنید
3. عنوان و توضیحات task را وارد کنید
4. روی **"افزودن یادآور"** کلیک کنید
5. تاریخ و ساعت را انتخاب کنید
6. (اختیاری) صدای آلارم را انتخاب کنید
7. **"ذخیره"** را بزنید

#### برای Goal (هدف):

1. به تب **"اهداف"** بروید
2. دکمه **+** را بزنید
3. عنوان و توضیحات هدف را وارد کنید
4. روی **"افزودن یادآور"** کلیک کنید
5. تاریخ و ساعت را انتخاب کنید
6. (اختیاری) صدای آلارم را انتخاب کنید
7. **"ذخیره"** را بزنید

### مرحله 2: نگه داشتن برنامه باز

**⚠️ مهم‌ترین مرحله!**

#### گزینه A: برنامه در Background (توصیه می‌شود ✅)

```
1. یادآور را بسازید
2. دکمه Home را بزنید
3. از Recent Apps پاک نکنید!
4. برنامه در پس‌زمینه باقی می‌ماند
5. ✅ آلارم فعال می‌شود
```

#### گزینه B: برنامه باز روی صفحه

```
1. یادآور را بسازید
2. برنامه را باز نگه دارید
3. می‌توانید صفحه قفل کنید
4. ✅ آلارم فعال می‌شود
```

#### ❌ اشتباه رایج:

```
1. یادآور را بسازید
2. برنامه را force close می‌کنید
   (Settings > Apps > Force Stop)
3. یا از Recent Apps پاک می‌کنید
4. ❌ آلارم فعال نمی‌شود!
```

### مرحله 3: صبر کنید

- زمان آلارم برسد
- صفحه تمام‌صفحه آلارم باز می‌شود
- صدا پخش می‌شود
- دکمه **"بستن آلارم"** یا **"به تعویق انداختن"**

---

## 🔧 تنظیمات مهم گوشی

برای اطمینان از کار کردن آلارم‌ها:

### تمام گوشی‌ها:

#### 1. Battery Optimization

```
Settings > Battery > App battery usage
→ Self Management
→ Unrestricted ✅
```

#### 2. Lock in Recent Apps

```
Recent Apps (دکمه square)
→ روی آیکون برنامه swipe down کنید
→ آیکون قفل ظاهر می‌شود
→ کلیک کنید ✅
```

### Xiaomi (MIUI):

```
Settings > Apps > Manage apps > Self Management

1. Autostart: Enabled ✅
2. Battery saver: No restrictions ✅
3. Display pop-up windows while running in background: Allow ✅
4. Other permissions: Allow all ✅
```

**نکته Xiaomi:** این گوشی‌ها خیلی aggressive هستند!

### Huawei (EMUI):

```
Settings > Battery > App launch > Self Management

Manage manually:
1. Auto-launch: ON ✅
2. Secondary launch: ON ✅
3. Run in background: ON ✅
```

### Samsung (One UI):

```
Settings > Apps > Self Management

1. Battery: Unrestricted ✅
2. Sleeping apps: حذف کنید از لیست ✅
3. Deep sleeping apps: حذف کنید از لیست ✅
```

### OPPO/Realme (ColorOS):

```
Settings > Battery > App Battery Management > Self Management

1. Background freeze: Don't freeze ✅
2. Abnormal apps optimization: Don't optimize ✅

Settings > Privacy > App permissions > Autostart
→ Self Management: Enable ✅
```

### OnePlus (OxygenOS):

```
Settings > Battery > Battery optimization
→ Self Management: Don't optimize ✅

Settings > Apps > Self Management > Battery
→ Advanced optimization: OFF ✅
```

---

## 🧪 تست آلارم

### تست سریع (2 دقیقه):

```
1. به تب "تست" بروید
2. دکمه "تست آلارم ۵ ثانیه بعد" را بزنید
3. دکمه Home را بزنید (برنامه را نبندید!)
4. 5 ثانیه صبر کنید
5. ✅ صفحه آلارم باید باز شود
```

### تست واقعی (15 دقیقه):

```
1. یک Task با یادآور 15 دقیقه بعد بسازید
2. صدای آلارم را انتخاب کنید
3. ذخیره کنید
4. دکمه Home را بزنید
5. از گوشی استفاده عادی کنید
6. بعد از 15 دقیقه ✅ آلارم فعال می‌شود
```

---

## ❗ هشدارها

### 🔴 برنامه را Close نکنید!

- در Recent Apps نگه دارید
- Force Stop نزنید
- Clear All نزنید

### 🟡 تنظیمات Battery مهم است!

- Unrestricted battery
- Don't optimize
- Autostart enabled

### 🟢 Lock کردن در Recent Apps

- از kill شدن جلوگیری می‌کند
- بسیار توصیه می‌شود!

---

## 💬 پشتیبانی

### اگر آلارم کار نکرد:

1. **برنامه باز است؟**

   - Recent Apps را چک کنید
   - آیا برنامه در لیست هست؟

2. **تنظیمات Battery?**

   - Unrestricted است؟
   - Autostart فعال است؟

3. **Test کنید:**

   - به تب "تست" بروید
   - آلارم 5 ثانیه‌ای تست کنید
   - اگر کار کرد، مشکل از تنظیمات battery است

4. **Debug Info:**
   - Settings > عیب‌یابی آلارم‌ها
   - تعداد آلارم‌های فعال را ببینید

---

## 🎯 نتیجه‌گیری

این سیستم آلارم برای **یادآوری‌های کوتاه‌مدت** بسیار عالی است:

✨ **مزایا:**

- بدون نیاز به مجوز نوتیفیکیشن
- تجربه کاربری فوق‌العاده
- صفحه تمام‌صفحه زیبا
- پخش صدای سفارشی
- سریع و بدون تاخیر

⚠️ **محدودیت:**

- برنامه باید باز باشد (background OK، closed NO)

**برای استفاده بهینه:** برنامه را در background نگه دارید و از Recent Apps پاک نکنید! 🚀

---

**نسخه:** 1.0  
**تاریخ:** اکتبر 2025
