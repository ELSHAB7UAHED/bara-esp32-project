# دليل الحصول على ملفات BIN للمشروع

## طرق الحصول على ملفات BIN الجاهزة

### الطريقة 1: من GitHub Releases (موصى بها)

1. انتقل إلى صفحة المشروع على GitHub:
   ```
   https://github.com/ELSHAB7UAHED/bara-esp32-project
   ```

2. اضغط على **Releases** في الجانب الأيمن من الصفحة

3. حمّل أحدث إصدار (Release)

4. ستجد ملفات BIN الجاهزة:
   - `firmware.bin` - الملف الرئيسي
   - `bootloader.bin` - ملف التشغيل
   - `partitions.bin` - جدول التقسيمات
   - `flash.sh` - سكريبت رفع تلقائي (Linux/Mac)
   - `flash.bat` - سكريبت رفع تلقائي (Windows)

### الطريقة 2: من GitHub Actions Artifacts

1. انتقل إلى صفحة المشروع على GitHub

2. اضغط على تبويب **Actions** في الأعلى

3. ستجد قائمة بعمليات البناء (Workflows)

4. اختر آخر workflow باللون الأخضر ✅ (يعني ناجح)

5. انزل للأسفل حتى قسم **Artifacts**

6. حمّل ملف `esp32-firmware.zip`

7. فك الضغط وستجد جميع الملفات المطلوبة

### الطريقة 3: بناء المشروع محلياً

إذا أردت بناء المشروع بنفسك على حاسوبك:

#### باستخدام PlatformIO:

```bash
# 1. استنسخ المشروع
git clone https://github.com/ELSHAB7UAHED/bara-esp32-project.git
cd bara-esp32-project

# 2. قم بتثبيت PlatformIO (إذا لم يكن مثبتاً)
pip install platformio

# 3. ابنِ المشروع
pio run

# 4. ستجد ملفات BIN في:
# .pio/build/esp32dev/firmware.bin
# .pio/build/esp32dev/bootloader.bin
# .pio/build/esp32dev/partitions.bin
```

#### باستخدام Arduino IDE:

Arduino IDE لا ينتج ملفات BIN منفصلة بشكل مباشر، لكن يمكنك:

1. بعد رفع الكود على ESP32 من Arduino IDE
2. اذهب إلى مجلد الـ temporary build
3. في Windows عادة يكون في:
   ```
   C:\Users\[اسمك]\AppData\Local\Temp\arduino_build_*\
   ```

## رفع ملفات BIN على ESP32

بعد الحصول على الملفات، استخدم إحدى الطرق التالية:

### طريقة 1: استخدام سكريبت التثبيت الجاهز

**Linux/Mac:**
```bash
chmod +x flash.sh
./flash.sh /dev/ttyUSB0
```

**Windows:**
```cmd
flash.bat COM3
```

### طريقة 2: استخدام esptool يدوياً

```bash
# 1. ثبّت esptool
pip install esptool

# 2. تأكد من توصيل ESP32

# 3. نفّذ الأمر التالي
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 \
  --before default_reset --after hard_reset write_flash -z \
  --flash_mode dio --flash_freq 40m --flash_size detect \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

**ملاحظات:**
- استبدل `/dev/ttyUSB0` بالمنفذ الصحيح:
  - Windows: `COM3`, `COM4`, إلخ
  - Linux: `/dev/ttyUSB0`, `/dev/ttyACM0`
  - Mac: `/dev/cu.usbserial-*`

### طريقة 3: استخدام ESP Flash Download Tool (Windows)

1. حمّل [ESP32 Flash Download Tool](https://www.espressif.com/en/support/download/other-tools)

2. افتح البرنامج واختر **ESP32 DownloadTool**

3. أضف الملفات التالية:

   | الملف | العنوان (Address) |
   |-------|-------------------|
   | bootloader.bin | 0x1000 |
   | partitions.bin | 0x8000 |
   | firmware.bin | 0x10000 |

4. اختر الإعدادات:
   - SPI SPEED: 40MHz
   - SPI MODE: DIO
   - COM Port: اختر المنفذ المناسب

5. اضغط **START**

## التحقق من نجاح التثبيت

1. افصل ESP32 وأعد توصيله (أو اضغط زر Reset)

2. افتح Serial Monitor:
   ```bash
   pio device monitor -b 115200
   # أو
   screen /dev/ttyUSB0 115200
   ```

3. يجب أن تظهر رسائل مثل:
   ```
   Access Point started:
   SSID: bara
   IP: 192.168.4.1
   Web server started.
   ```

4. إذا ظهرت هذه الرسائل، التثبيت ناجح! ✅

## حل المشاكل

### المشكلة: "Failed to connect to ESP32"

**الحل:**
```bash
# جرب بسرعة أبطأ
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 115200 \
  --before default_reset --after hard_reset write_flash -z \
  --flash_mode dio --flash_freq 40m --flash_size detect \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

### المشكلة: "Port not found"

**الحل:**
- تأكد من توصيل ESP32 بالحاسوب
- ثبّت driver CH340 أو CP2102
- جرب منفذ USB آخر

### المشكلة: "Timed out waiting for packet header"

**الحل:**
- اضغط مع الاستمرار على زر BOOT في ESP32
- ابدأ عملية الرفع
- حرر زر BOOT بعد بدء الرفع

## بناء ملفات BIN تلقائياً

المشروع مُعد لبناء ملفات BIN تلقائياً عند كل Push إلى GitHub باستخدام GitHub Actions.

**كيف يعمل؟**
1. عند Push أي تغيير إلى branch main
2. يبدأ GitHub Actions تلقائياً
3. يتم بناء المشروع باستخدام PlatformIO
4. يتم حفظ ملفات BIN في Artifacts
5. يمكنك تحميلها من صفحة Actions

**متابعة عملية البناء:**
1. اذهب إلى صفحة المشروع على GitHub
2. اضغط على **Actions**
3. ستجد آخر عمليات البناء
4. اللون الأخضر ✅ = بناء ناجح
5. اللون الأحمر ❌ = فشل البناء

## خيارات متقدمة

### تغيير عنوان البرنامج (للأجهزة المختلفة)

بعض لوحات ESP32 تستخدم عناوين مختلفة:

```bash
# للوحات ESP32 القديمة
esptool.py ... write_flash \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0xe000 boot_app0.bin \
  0x10000 firmware.bin

# للوحات ESP32-C3
esptool.py --chip esp32c3 ... write_flash \
  0x0 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin
```

### إنشاء صورة واحدة (Single Binary)

لدمج جميع الملفات في ملف واحد:

```bash
esptool.py --chip esp32 merge_bin \
  -o merged_firmware.bin \
  --flash_mode dio \
  --flash_freq 40m \
  --flash_size 4MB \
  0x1000 bootloader.bin \
  0x8000 partitions.bin \
  0x10000 firmware.bin

# ثم رفعها
esptool.py --chip esp32 --port /dev/ttyUSB0 \
  write_flash 0x0 merged_firmware.bin
```

## الدعم

إذا واجهت أي مشكلة في الحصول على ملفات BIN أو رفعها:

1. تحقق من [Issues](https://github.com/ELSHAB7UAHED/bara-esp32-project/issues)
2. افتح Issue جديد مع وصف المشكلة
3. أرفق أي رسائل خطأ تظهر لك

---

**المشروع:** bara - ESP32 WiFi Scanner & Deauth Tool  
**المطور:** Ahmed Nour Ahmed 🇪🇬  
**المستودع:** https://github.com/ELSHAB7UAHED/bara-esp32-project
