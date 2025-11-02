# 🚀 دليل البدء السريع - bara ESP32

## ⏱️ 5 دقائق من التثبيت إلى التشغيل!

### الطريقة 1: استخدام ملفات BIN جاهزة (الأسهل)

#### الخطوة 1: حمّل الملفات

انتقل إلى أحد المصدرين:

**خيار A: من GitHub Actions**
1. افتح https://github.com/ELSHAB7UAHED/bara-esp32-project/actions
2. اختر آخر workflow ناجح (باللون الأخضر ✅)
3. حمّل `esp32-firmware.zip` من Artifacts
4. فك الضغط

**خيار B: ابنِ محلياً**
```bash
git clone https://github.com/ELSHAB7UAHED/bara-esp32-project.git
cd bara-esp32-project
pip install platformio
pio run
# الملفات في: .pio/build/esp32dev/
```

#### الخطوة 2: ثبّت esptool

```bash
pip install esptool
```

#### الخطوة 3: ارفع على ESP32

**Linux/Mac:**
```bash
# استبدل /dev/ttyUSB0 بالمنفذ الصحيح
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 \
  --before default_reset --after hard_reset write_flash -z \
  --flash_mode dio --flash_freq 40m --flash_size detect \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

**Windows:**
```cmd
REM استبدل COM3 بالمنفذ الصحيح
esptool.py --chip esp32 --port COM3 --baud 921600 ^
  --before default_reset --after hard_reset write_flash -z ^
  --flash_mode dio --flash_freq 40m --flash_size detect ^
  0x1000 bootloader.bin ^
  0x8000 partitions.bin ^
  0x10000 firmware.bin
```

**أو استخدم السكريبت الجاهز:**
```bash
# Linux/Mac
./flash.sh /dev/ttyUSB0

# Windows
flash.bat COM3
```

### الطريقة 2: من المصدر مباشرة (للمطورين)

```bash
# 1. استنسخ المشروع
git clone https://github.com/ELSHAB7UAHED/bara-esp32-project.git
cd bara-esp32-project

# 2. ثبّت PlatformIO
pip install platformio

# 3. ارفع مباشرة
pio run --target upload
```

---

## 🎯 الاستخدام

### بعد التثبيت:

1. **افصل ESP32 وأعد توصيله** (أو اضغط زر Reset)

2. **ابحث عن شبكة WiFi:**
   - الاسم: `bara`
   - كلمة المرور: `A7med@Elshab7`

3. **اتصل بالشبكة**

4. **افتح المتصفح:**
   ```
   http://192.168.4.1
   ```

5. **ابدأ الفحص:**
   - اضغط **SCAN NETWORKS**
   - ستظهر جميع الشبكات المحيطة
   - يمكنك تنفيذ Deauth على أي شبكة

---

## 🔧 معرفة المنفذ (Port)

### Windows:
1. Device Manager
2. Ports (COM & LPT)
3. ستجد مثل: `Silicon Labs CP210x (COM3)`
4. استخدم `COM3`

### Linux:
```bash
ls /dev/ttyUSB*
# عادة: /dev/ttyUSB0
```

### Mac:
```bash
ls /dev/cu.*
# عادة: /dev/cu.usbserial-*
```

---

## ❗ حل المشاكل السريع

### لا يتم اكتشاف ESP32
- جرب كابل USB آخر
- ثبّت [CH340 Driver](http://www.wch.cn/downloads/CH341SER_EXE.html)

### فشل الرفع
- اضغط زر BOOT أثناء بدء الرفع
- جرب بسرعة أبطأ: `--baud 115200`

### لا يفتح الموقع
- تأكد من الاتصال بشبكة `bara`
- جرب `http://192.168.4.1` (مع http://)
- عطّل بيانات الهاتف إذا كنت تستخدم موبايل

---

## 📚 مزيد من المعلومات

- **[INSTALLATION.md](INSTALLATION.md)** - دليل مفصل
- **[BIN_GUIDE.md](BIN_GUIDE.md)** - دليل ملفات BIN
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - ملخص كامل

---

## ⚠️ تذكير مهم

**استخدم هذه الأداة فقط على شبكاتك الخاصة!**

الاستخدام غير المصرح به قد يكون غير قانوني في بلدك. هذا المشروع للأغراض التعليمية فقط.

---

**المشروع:** bara WiFi Scanner & Deauth Tool  
**المطور:** Ahmed Nour Ahmed 🇪🇬  
**المستودع:** https://github.com/ELSHAB7UAHED/bara-esp32-project
