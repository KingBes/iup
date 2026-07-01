#!/bin/bash
# ===================================================================
#  IUP macOS Cocoa Build — 单 .dylib + .a + headers
#  依赖: Xcode Command Line Tools (clang, frameworks)
# ===================================================================
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

JOBS=${JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || echo 4)}
BUILD="$ROOT/build/obj_macos"
OUT="$ROOT/build/macos"
mkdir -p "$BUILD" "$OUT"

CC=clang
CXX=clang++

# ===== Common flags =====
DEFS="-DIUP_BUILD_LIBRARY -DCD_NO_OLD_INTERFACE -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE -DSCINTILLA_VERSION='\"3.11.2\"' -D_USE_MATH_DEFINES -DFTGL_LIBRARY_STATIC"
CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -Wno-incompatible-pointer-types -Wno-missing-braces"
CXXFLAGS="-fPIC -Wall -O2 -std=c++11 -Wno-class-memaccess -Wno-reorder -Wno-write-strings -Wno-misleading-indentation"
OBJCFLAGS="-fobjc-arc -fPIC -Wall -O2"

INCLUDES="-Iinclude -Isrc -Isrc/cocoa -Isrcimglib -Isrcgl -Isrcglcontrols -Isrcmglplot -Isrcmglplot/src -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack -Isrcscintilla -Isrcscintilla/scintilla3112/include -Isrcscintilla/scintilla3112/src -Isrcscintilla/scintilla3112/lexlib -Isrcscintilla/scintilla3112/win32 -Isrcscintilla/scintilla3112/lexers -Isrcole -Isrccd -Isrccontrols -Isrcplot -Isrcmglplot -Icd/include -Icd/src -Iim/include -Iim/src"

echo "=== macOS Cocoa Build ==="
echo "Jobs: $JOBS"

compile_c() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [CC] $src" >&2
    $CC -c $CFLAGS $DEFS $INCLUDES -o "$obj" "$src"
    echo "$obj"
}

compile_m() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [M]  $src" >&2
    $CC -c $OBJCFLAGS $DEFS $INCLUDES -o "$obj" "$src"
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

# ===== IUP Core =====
echo "[1/5] IUP Core"
for f in src/iup.c src/iup_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "iup/")"
done

# ===== IUP Cocoa Backend =====
echo "[2/5] IUP Cocoa Driver"
for f in src/cocoa/*.m src/cocoa/*.c; do
    [ -f "$f" ] || continue
    if [[ "$f" == *.m ]]; then
        ALL_OBJ+=" $(compile_m "$f" "cocoa/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "cocoa/")"
    fi
done

# ===== IUP Modules =====
echo "[3/5] IUP Modules"
for d in srccd srccontrols srcgl srcglcontrols srcim srcimglib srcplot srcmglplot srctuio srcole; do
    [ -d "$d" ] || continue
    for f in $(find "$d" -maxdepth 3 -name '*.c' -o -name '*.cpp' 2>/dev/null); do
        [[ "$f" == *dep/* ]] && continue
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "mod/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "mod/")"
        fi
    done
done

# ===== CD + IM =====
echo "[4/5] CD + IM Libraries"
# CD — use Quartz or portable backends (skip win32, gdiplus, X11)
for f in cd/src/*.c cd/src/drv/cd*.c cd/src/intcgm/*.c cd/src/sim/*.c \
         cd/src/svg/*.c cd/src/minizip/*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "cd/")"
done

# IM core
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

# ===== Scintilla =====
echo "[5/5] Scintilla"
SCIBASE="srcscintilla/scintilla3112"
for f in $(find "$SCIBASE/src" "$SCIBASE/lexlib" "$SCIBASE/lexers" "$SCIBASE/win32" -name '*.cxx' 2>/dev/null); do
    [[ "$f" == *LexLPeg* ]] && continue
    ALL_OBJ+=" $(compile_cxx "$f" "sci/")"
done
for f in srcscintilla/iup_scintilla.c srcscintilla/iupsci_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "sciw/")"
done

# ===== Link =====
echo ""
echo "=== Linking libiup.dylib ==="
$CXX -dynamiclib -o "$OUT/libiup.dylib" $ALL_OBJ \
    -framework Cocoa -framework OpenGL -framework Carbon \
    -lz -lm -lpthread

echo "=== Creating libiup.a ==="
ar rcs "$OUT/libiup.a" $ALL_OBJ

# ===== Package =====
echo "=== Packaging ==="
mkdir -p "$OUT/include"
cp -r include/* "$OUT/include/"

echo ""
echo "=== macOS Build Complete ==="
echo "  Shared: $OUT/libiup.dylib"
echo "  Static: $OUT/libiup.a"
echo "  Headers: $OUT/include/"
ls -lh "$OUT/libiup.dylib" "$OUT/libiup.a"
