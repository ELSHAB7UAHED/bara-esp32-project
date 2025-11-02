#!/bin/bash

# سكريبت البناء المحلي لمشروع bara ESP32
# يقوم بتثبيت PlatformIO، بناء المشروع، ونسخ ملفات BIN

set -e  # إيقاف عند أي خطأ

# ألوان للرسائل
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # بدون لون

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  سكريبت بناء مشروع bara ESP32 WiFi Scanner          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# الخطوة 1: التحقق من Python
echo -e "${YELLOW}[1/6] التحقق من Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ خطأ: Python3 غير مثبت!${NC}"
    echo -e "${YELLOW}الرجاء تثبيت Python3 من: https://www.python.org/downloads/${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo -e "${GREEN}✓ تم العثور على: $PYTHON_VERSION${NC}"

# الخطوة 2: التحقق من pip
echo -e "${YELLOW}[2/6] التحقق من pip...${NC}"
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}✗ خطأ: pip3 غير مثبت!${NC}"
    echo -e "${YELLOW}تثبيت pip...${NC}"
    python3 -m ensurepip --upgrade
fi
echo -e "${GREEN}✓ pip3 جاهز${NC}"

# الخطوة 3: تثبيت/تحديث PlatformIO
echo -e "${YELLOW}[3/6] تثبيت/تحديث PlatformIO...${NC}"
if command -v pio &> /dev/null; then
    echo -e "${GREEN}✓ PlatformIO مثبت مسبقاً${NC}"
    echo -e "${BLUE}  جاري التحديث...${NC}"
    pip3 install --upgrade platformio
else
    echo -e "${BLUE}  جاري التثبيت...${NC}"
    pip3 install platformio
fi
echo -e "${GREEN}✓ PlatformIO جاهز${NC}"

# الخطوة 4: إنشاء مجلد firmware
echo -e "${YELLOW}[4/6] إنشاء مجلد firmware...${NC}"
mkdir -p firmware
echo -e "${GREEN}✓ تم إنشاء مجلد firmware/${NC}"

# الخطوة 5: بناء المشروع
echo -e "${YELLOW}[5/6] بناء المشروع...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
pio run
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ اكتمل البناء بنجاح!${NC}"

# الخطوة 6: نسخ ملفات BIN
echo -e "${YELLOW}[6/6] نسخ ملفات BIN...${NC}"

BUILD_DIR=".pio/build/esp32dev"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}✗ خطأ: مجلد البناء غير موجود!${NC}"
    exit 1
fi

# نسخ الملفات
cp -v "$BUILD_DIR/firmware.bin" firmware/ || echo -e "${RED}✗ فشل نسخ firmware.bin${NC}"
cp -v "$BUILD_DIR/bootloader.bin" firmware/ || echo -e "${RED}✗ فشل نسخ bootloader.bin${NC}"
cp -v "$BUILD_DIR/partitions.bin" firmware/ || echo -e "${RED}✗ فشل نسخ partitions.bin${NC}"

echo -e "${GREEN}✓ تم نسخ جميع ملفات BIN${NC}"

# إنشاء ملف معلومات
cat > firmware/INFO.txt << EOF
معلومات البناء - bara ESP32 WiFi Scanner
==========================================

تاريخ البناء: $(date '+%Y-%m-%d %H:%M:%S')
المنصة: ESP32
إطار العمل: Arduino

ملفات BIN:
-----------
1. bootloader.bin - العنوان: 0x1000
2. partitions.bin - العنوان: 0x8000
3. firmware.bin   - العنوان: 0x10000

كيفية الفلاش:
-------------
Linux/Mac:  ./flash.sh [PORT]
Windows:    flash.bat [PORT]

أو يدوياً:
esptool.py --chip esp32 --port [PORT] --baud 921600 write_flash \\
  0x1000 bootloader.bin \\
  0x8000 partitions.bin \\
  0x10000 firmware.bin

ملاحظة: استبدل [PORT] بـ:
- Linux/Mac: /dev/ttyUSB0 أو /dev/ttyACM0
- Windows: COM3 أو COM4 (حسب الجهاز)

EOF

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✓ اكتمل البناء بنجاح!                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📁 الملفات الناتجة:${NC}"
echo -e "   ${GREEN}→${NC} firmware/bootloader.bin"
echo -e "   ${GREEN}→${NC} firmware/partitions.bin"
echo -e "   ${GREEN}→${NC} firmware/firmware.bin"
echo -e "   ${GREEN}→${NC} firmware/INFO.txt"
echo ""
echo -e "${BLUE}🔥 لفلاش ESP32:${NC}"
echo -e "   ${GREEN}→${NC} ./flash.sh /dev/ttyUSB0"
echo ""
echo -e "${YELLOW}💡 نصيحة: راجع firmware/INFO.txt للتفاصيل${NC}"
echo ""
