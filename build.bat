@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM سكريبت البناء المحلي لمشروع bara ESP32
REM يقوم بتثبيت PlatformIO، بناء المشروع، ونسخ ملفات BIN

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║  سكريبت بناء مشروع bara ESP32 WiFi Scanner          ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM الخطوة 1: التحقق من Python
echo [1/6] التحقق من Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ✗ خطأ: Python غير مثبت!
    echo الرجاء تثبيت Python من: https://www.python.org/downloads/
    pause
    exit /b 1
)
for /f "tokens=*" %%a in ('python --version') do set PYTHON_VERSION=%%a
echo ✓ تم العثور على: !PYTHON_VERSION!

REM الخطوة 2: التحقق من pip
echo [2/6] التحقق من pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo ✗ خطأ: pip غير مثبت!
    echo   جاري تثبيت pip...
    python -m ensurepip --upgrade
)
echo ✓ pip جاهز

REM الخطوة 3: تثبيت/تحديث PlatformIO
echo [3/6] تثبيت/تحديث PlatformIO...
pio --version >nul 2>&1
if errorlevel 1 (
    echo   جاري التثبيت...
    pip install platformio
) else (
    echo ✓ PlatformIO مثبت مسبقاً
    echo   جاري التحديث...
    pip install --upgrade platformio
)
echo ✓ PlatformIO جاهز

REM الخطوة 4: إنشاء مجلد firmware
echo [4/6] إنشاء مجلد firmware...
if not exist firmware mkdir firmware
echo ✓ تم إنشاء مجلد firmware\

REM الخطوة 5: بناء المشروع
echo [5/6] بناء المشروع...
echo ═══════════════════════════════════════════════════════
pio run
if errorlevel 1 (
    echo.
    echo ✗ فشل البناء!
    pause
    exit /b 1
)
echo ═══════════════════════════════════════════════════════
echo ✓ اكتمل البناء بنجاح!

REM الخطوة 6: نسخ ملفات BIN
echo [6/6] نسخ ملفات BIN...

set BUILD_DIR=.pio\build\esp32dev

if not exist "%BUILD_DIR%" (
    echo ✗ خطأ: مجلد البناء غير موجود!
    pause
    exit /b 1
)

REM نسخ الملفات
copy /Y "%BUILD_DIR%\firmware.bin" firmware\ >nul || echo ✗ فشل نسخ firmware.bin
copy /Y "%BUILD_DIR%\bootloader.bin" firmware\ >nul || echo ✗ فشل نسخ bootloader.bin
copy /Y "%BUILD_DIR%\partitions.bin" firmware\ >nul || echo ✗ فشل نسخ partitions.bin

echo ✓ تم نسخ جميع ملفات BIN

REM إنشاء ملف معلومات
(
echo معلومات البناء - bara ESP32 WiFi Scanner
echo ==========================================
echo.
echo تاريخ البناء: %date% %time%
echo المنصة: ESP32
echo إطار العمل: Arduino
echo.
echo ملفات BIN:
echo -----------
echo 1. bootloader.bin - العنوان: 0x1000
echo 2. partitions.bin - العنوان: 0x8000
echo 3. firmware.bin   - العنوان: 0x10000
echo.
echo كيفية الفلاش:
echo -------------
echo Windows:    flash.bat [PORT]
echo Linux/Mac:  ./flash.sh [PORT]
echo.
echo أو يدوياً:
echo esptool.py --chip esp32 --port [PORT] --baud 921600 write_flash ^
echo   0x1000 bootloader.bin ^
echo   0x8000 partitions.bin ^
echo   0x10000 firmware.bin
echo.
echo ملاحظة: استبدل [PORT] بـ:
echo - Windows: COM3 أو COM4 ^(حسب الجهاز^)
echo - Linux/Mac: /dev/ttyUSB0 أو /dev/ttyACM0
echo.
) > firmware\INFO.txt

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║           ✓ اكتمل البناء بنجاح!                      ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 📁 الملفات الناتجة:
echo    → firmware\bootloader.bin
echo    → firmware\partitions.bin
echo    → firmware\firmware.bin
echo    → firmware\INFO.txt
echo.
echo 🔥 لفلاش ESP32:
echo    → flash.bat COM3
echo.
echo 💡 نصيحة: راجع firmware\INFO.txt للتفاصيل
echo.
pause
