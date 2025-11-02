@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM سكريبت فلاش مشروع bara ESP32
REM يقوم بفلاش ملفات BIN على ESP32

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║       سكريبت فلاش bara ESP32 WiFi Scanner            ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM التحقق من وجود مجلد firmware
if not exist firmware (
    echo ✗ خطأ: مجلد firmware غير موجود!
    echo الرجاء تشغيل: build.bat أولاً
    pause
    exit /b 1
)

REM التحقق من وجود الملفات
set FILES_MISSING=0
if not exist firmware\bootloader.bin (
    echo ✗ ملف bootloader.bin غير موجود
    set FILES_MISSING=1
)
if not exist firmware\partitions.bin (
    echo ✗ ملف partitions.bin غير موجود
    set FILES_MISSING=1
)
if not exist firmware\firmware.bin (
    echo ✗ ملف firmware.bin غير موجود
    set FILES_MISSING=1
)

if !FILES_MISSING! equ 1 (
    echo الرجاء تشغيل: build.bat أولاً
    pause
    exit /b 1
)

REM تحديد المنفذ
if "%1"=="" (
    echo ⚠ لم يتم تحديد المنفذ!
    echo.
    echo الاستخدام: flash.bat [PORT]
    echo مثال: flash.bat COM3
    echo.
    echo المنافذ المتاحة في نظامك:
    echo.
    wmic path Win32_SerialPort get DeviceID,Description 2>nul || echo لم يتم العثور على أجهزة متصلة
    echo.
    pause
    exit /b 1
)

set PORT=%1

REM التحقق من وجود esptool
python -m esptool version >nul 2>&1
if errorlevel 1 (
    echo ⚠ esptool غير مثبت!
    echo جاري التثبيت...
    pip install esptool
)

echo 📡 المنفذ: !PORT!
echo ⏳ جاري الفلاش...
echo.

REM فلاش الملفات
python -m esptool --chip esp32 --port !PORT! --baud 921600 ^
    --before default_reset --after hard_reset write_flash ^
    -z --flash_mode dio --flash_freq 40m --flash_size detect ^
    0x1000 firmware\bootloader.bin ^
    0x8000 firmware\partitions.bin ^
    0x10000 firmware\firmware.bin

if errorlevel 1 (
    echo.
    echo ╔════════════════════════════════════════════════════════╗
    echo ║              ✗ فشل الفلاش!                           ║
    echo ╚════════════════════════════════════════════════════════╝
    echo.
    echo نصائح لحل المشكلة:
    echo    1. تأكد من توصيل ESP32 بالكمبيوتر
    echo    2. تأكد من صحة المنفذ: !PORT!
    echo    3. اضغط على زر BOOT في ESP32 أثناء الفلاش
    echo    4. جرب منفذ USB آخر
    echo    5. تحقق من التعريفات ^(drivers^)
    echo    6. أغلق برامج Serial Monitor المفتوحة
    echo.
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║           ✓ اكتمل الفلاش بنجاح!                      ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 🎉 ESP32 جاهز الآن!
echo.
echo 📱 خطوات التشغيل:
echo    1. أعد تشغيل ESP32
echo    2. افتح Serial Monitor على: 115200 baud
echo    3. اتصل بشبكة WiFi: bara
echo    4. افتح المتصفح: 192.168.4.1
echo.
pause
