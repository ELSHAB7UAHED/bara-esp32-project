#!/bin/bash

# سكريبت فحص السكريبتات

echo "فحص سكريبتات البناء..."
echo ""

# التحقق من وجود الملفات
FILES_OK=1

if [ -f "build.sh" ]; then
    echo "✓ build.sh موجود"
    if [ -x "build.sh" ]; then
        echo "  ✓ قابل للتنفيذ"
    else
        echo "  ✗ غير قابل للتنفيذ"
        FILES_OK=0
    fi
else
    echo "✗ build.sh غير موجود"
    FILES_OK=0
fi

if [ -f "build.bat" ]; then
    echo "✓ build.bat موجود"
else
    echo "✗ build.bat غير موجود"
    FILES_OK=0
fi

if [ -f "flash.sh" ]; then
    echo "✓ flash.sh موجود"
    if [ -x "flash.sh" ]; then
        echo "  ✓ قابل للتنفيذ"
    else
        echo "  ✗ غير قابل للتنفيذ"
        FILES_OK=0
    fi
else
    echo "✗ flash.sh غير موجود"
    FILES_OK=0
fi

if [ -f "flash.bat" ]; then
    echo "✓ flash.bat موجود"
else
    echo "✗ flash.bat غير موجود"
    FILES_OK=0
fi

echo ""

if [ $FILES_OK -eq 1 ]; then
    echo "✅ جميع السكريبتات جاهزة!"
    exit 0
else
    echo "❌ بعض السكريبتات غير جاهزة!"
    exit 1
fi
