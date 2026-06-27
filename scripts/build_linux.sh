#!/bin/bash
# ===================================================================
#  IUP Linux GTK3 Build — 单 .so + .a + headers
#  依赖: apt install libgtk-3-dev libfreetype-dev libftgl-dev
#        zlib1g-dev libglu1-mesa-dev libcairo2-dev
# ===================================================================
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

JOBS=${JOBS:-$(nproc)}
BUILD="$ROOT/build/obj_linux"
OUT="$ROOT/build/linux"
mkdir -p "$BUILD" "$OUT"

CC=gcc
CXX=g++

# ===== Common flags =====
DEFS="-DIUP_BUILD_LIBRARY -DCD_NO_OLD_INTERFACE -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE -DSCINTILLA_VERSION='\"3.11.2\"' -D_USE_MATH_DEFINES -DFTGL_LIBRARY_STATIC -DNO_CXX11_REGEX"
CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -Wno-incompatible-pointer-types -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast -Wno-missing-braces"
CXXFLAGS="-fPIC -Wall -O2 -std=c++11 -fpermissive -Wno-class-memaccess -Wno-reorder -Wno-write-strings -Wno-stringop-truncation -Wno-unknown-pragmas"

GTK_CFLAGS=$(pkg-config --cflags gtk+-3.0 2>/dev/null || echo "")
FREETYPE_CFLAGS=$(pkg-config --cflags freetype2 2>/dev/null || echo "")

INCLUDES="-Iinclude -Isrc -Isrc/gtk -Isrcimglib -Isrcgl -Isrcglcontrols -Isrcmglplot -Isrcmglplot/src -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack -Isrcscintilla -Isrcscintilla/scintilla3112/include -Isrcscintilla/scintilla3112/src -Isrcscintilla/scintilla3112/lexlib -Isrcscintilla/scintilla3112/win32 -Isrcscintilla/scintilla3112/lexers -Isrcole -Isrccd -Isrccontrols -Isrcplot -Isrcmglplot -Icd/include -Icd/src -Iim/include -Iim/src $GTK_CFLAGS $FREETYPE_CFLAGS"

echo "=== Linux GTK3 Build ==="
echo "Jobs: $JOBS"

# ===== Helper: compile C files =====
compile_c() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [CC] $src" >&2
    $CC -c $CFLAGS $DEFS $INCLUDES -o "$obj" "$src"
    echo "$obj"
}

compile_cxx() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [CXX] $src" >&2
    $CXX -c $CXXFLAGS $DEFS $INCLUDES -o "$obj" "$src"
    echo "$obj"
}

ALL_OBJ=""

# ===== IUP Core (platform-independent) =====
echo "[1/5] IUP Core"
for f in src/iup.c src/iup_*.c; do
    [[ "$f" == "src/iup_datepick.c" ]] && continue
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "iup/")"
done

# ===== IUP GTK Backend =====
echo "[2/5] IUP GTK Driver"
for f in src/gtk/iupgtk_*.c src/gtk/iupmac_help.c src/gtk/iupmac_info.c src/iup_datepick.c \
         src/mot/iupunix_info.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "gtk/")"
done

# ===== IUP Modules (same source, platform-independent) =====
echo "[3/5] IUP Modules"
for d in srccd srccontrols srcgl srcglcontrols srcim srcimglib srcplot srcmglplot srctuio srcole; do
    [ -d "$d" ] || continue
    for f in $(find "$d" -maxdepth 3 -name '*.c' -o -name '*.cpp' 2>/dev/null); do
        [[ "$f" == *dep/* ]] && continue
        [[ "$f" == *matrixex/* ]] && continue  # matrixex is complex C
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "mod/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "mod/")"
        fi
    done
done

# ===== CD Library (Linux/X11 backend) =====
echo "[4/5] CD + IM Libraries"
# CD common + X11
CD_X11="cd/src/x11/cdx11.c cd/src/x11/cdwinx11.c cd/src/x11/cdctx11.c cd/src/x11/cdprnx11.c"
for f in cd/src/*.c cd/src/drv/cd*.c cd/src/intcgm/*.c cd/src/sim/*.c \
         cd/src/svg/*.c cd/src/minizip/*.c $CD_X11; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "cd/")"
done
# CD C++ files
for f in cd/src/cdpp.cpp; do
    [ -f "$f" ] && ALL_OBJ+=" $(compile_cxx "$f" "cd/")"
done

# IM core (portable)
for f in im/src/*.cpp im/src/*.c; do
    [ -f "$f" ] || continue
    if [[ "$f" == *.cpp ]]; then
        ALL_OBJ+=" $(compile_cxx "$f" "im/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "im/")"
    fi
done
# IM format libs
for d in im/src/libtiff im/src/libjpeg im/src/libpng im/src/lzf im/src/lz4; do
    [ -d "$d" ] || continue
    for f in $(find "$d" -name '*.c' -o -name '*.cpp' 2>/dev/null); do
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "imfmt/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "imfmt/")"
        fi
    done
done

# ===== Scintilla (shared source with Windows) =====
echo "[5/5] Scintilla"
SCIBASE="srcscintilla/scintilla3112"
for f in $(find "$SCIBASE/src" "$SCIBASE/lexlib" "$SCIBASE/lexers" "$SCIBASE/win32" -name '*.cxx' 2>/dev/null); do
    [[ "$f" == *LexLPeg* ]] && continue
    ALL_OBJ+=" $(compile_cxx "$f" "sci/")"
done
# IUP Scintilla wrapper
for f in srcscintilla/iup_scintilla.c srcscintilla/iupsci_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "sciw/")"
done

# ===== Link Shared Library (.so) =====
echo ""
echo "=== Linking libiup.so ==="
GTK_LIBS=$(pkg-config --libs gtk+-3.0 2>/dev/null || echo "")
$CXX -shared -o "$OUT/libiup.so" $ALL_OBJ \
    $GTK_LIBS -lfreetype -lftgl -lz -lGL -lGLU -lX11 -lXrender -lm -lpthread -ldl

# ===== Static Library (.a) =====
echo "=== Creating libiup.a ==="
ar rcs "$OUT/libiup.a" $ALL_OBJ

# ===== Package Headers =====
echo "=== Packaging ==="
mkdir -p "$OUT/include"
cp -r include/* "$OUT/include/"

echo ""
echo "=== Linux Build Complete ==="
echo "  Shared: $OUT/libiup.so"
echo "  Static: $OUT/libiup.a"
echo "  Headers: $OUT/include/"
ls -lh "$OUT/libiup.so" "$OUT/libiup.a"
