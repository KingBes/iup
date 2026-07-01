#!/bin/bash
# ===================================================================
#  下载 CD + IM 库源码
#  运行: bash scripts/download_deps.sh
# ===================================================================
set -e

CD_VER="5.14"
IM_VER="3.15"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Downloading Canvas Draw $CD_VER ==="
if [ -d "$ROOT/cd" ]; then
    echo "cd/ already exists, skipping"
else
    wget -q --show-progress \
        "https://sourceforge.net/projects/canvasdraw/files/$CD_VER/Docs%20and%20Sources/cd-${CD_VER}_Sources.zip/download" \
        -O "$ROOT/cd-${CD_VER}.zip"
    unzip -q "$ROOT/cd-${CD_VER}.zip" -d "$ROOT/cd"
    rm "$ROOT/cd-${CD_VER}.zip"
    echo "CD $CD_VER extracted to cd/"
fi

echo ""
echo "=== Downloading IM Toolkit $IM_VER ==="
if [ -d "$ROOT/im" ]; then
    echo "im/ already exists, skipping"
else
    wget -q --show-progress \
        "https://sourceforge.net/projects/imtoolkit/files/$IM_VER/Docs%20and%20Sources/im-${IM_VER}_Sources.zip/download" \
        -O "$ROOT/im-${IM_VER}.zip"
    unzip -q "$ROOT/im-${IM_VER}.zip" -d "$ROOT/im"
    rm "$ROOT/im-${IM_VER}.zip"
    echo "IM $IM_VER extracted to im/"
fi

echo ""
echo "=== Done ==="
echo "Now run: mingw32-make -f build/Makefile_full.mak -j4"
