#!/bin/bash
# ===================================================================
#  IUP macOS Cocoa Build 鈥?鍗?.dylib + .a + headers (闆跺閮ㄤ緷璧?
#  渚濊禆: Xcode CLT + Homebrew freetype (闈欐€侀摼鎺?
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

# Finder Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [ -d "/opt/homebrew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
elif [ -d "/usr/local/Homebrew" ]; then
    HOMEBREW_PREFIX="/usr/local"
else
    HOMEBREW_PREFIX=""
fi

# 濡傛灉鏈?Homebrew freetype锛堝彧鐢ㄥ姩鎬?.dylib锛孒omebrew bottles 涓嶅惈 .a锛?
FREETYPE_INC=""
FREETYPE_LIB=""
if [ -n "$HOMEBREW_PREFIX" ] && [ -f "$HOMEBREW_PREFIX/include/ft2build.h" ]; then
    FREETYPE_INC="-I$HOMEBREW_PREFIX/include/freetype2 -I$HOMEBREW_PREFIX/include"
    FREETYPE_LIB="-L$HOMEBREW_PREFIX/lib -lfreetype"
    echo "Freetype: $HOMEBREW_PREFIX"
else
    echo "WARNING: freetype not found, building without CD SIM font support"
fi

# ===== Common flags =====
DEFS="-DIUP_BUILD_LIBRARY -DCD_NO_OLD_INTERFACE -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE -DSCINTILLA_VERSION='\"3.11.2\"' -D_USE_MATH_DEFINES -DFTGL_LIBRARY_STATIC -DMGL_STATIC_DEFINE -DMGL_SRC"
CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -Wno-incompatible-pointer-types -Wno-missing-braces -Wno-error=deprecated-declarations"
CXXFLAGS="-fPIC -Wall -O2 -std=c++11 -Wno-reorder -Wno-write-strings -Wno-misleading-indentation -Wno-error=deprecated-declarations"
OBJCFLAGS="-fPIC -Wall -O2"

INCLUDES="-Iinclude -Isrc -Isrc/cocoa -Isrcimglib -Isrcgl -Isrcglcontrols -Isrcmglplot -Isrcmglplot/src -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack -Isrcscintilla -Isrcscintilla/scintilla3112/include -Isrcscintilla/scintilla3112/src -Isrcscintilla/scintilla3112/lexlib -Isrcscintilla/scintilla3112/win32 -Isrcscintilla/scintilla3112/lexers -Isrcole -Isrccd -Isrccontrols -Isrcplot -Icd/include -Icd/src -Icd/src/sim -Icd/src/drv -Icd/src/intcgm -Icd/src/svg -Icd/src/minizip -Iim/include -Iim/src -Iim/src/libtiff -Iim/src/libjpeg -Iim/src/libpng -Iim/src/liblzf -Iim/src/lz4 $FREETYPE_INC"

echo "=== macOS Cocoa Build ==="
echo "Jobs: $JOBS"

compile_c() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [CC] $src" >&2
    $CC -c $CFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
    echo "$obj"
}

compile_m() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [M]  $src" >&2
    $CC -c $OBJCFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
    echo "$obj"
}

compile_cxx() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [CXX] $src" >&2
    $CXX -c $CXXFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
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

# ===== IUP Modules (鎺掗櫎 Windows 涓撴湁鏂囦欢) =====
echo "[3/5] IUP Modules"
for d in srccd srccontrols srcgl srcglcontrols srcim srcimglib srcplot srcmglplot srctuio; do
    [ -d "$d" ] || continue
    for f in $(find "$d" -maxdepth 3 \( -name '*.c' -o -name '*.cpp' \) 2>/dev/null); do
        [[ "$f" == *dep/* ]] && continue
        [[ "$f" == *win32* || "$f" == *Win32* || "$f" == *_win32* || "$f" == *_win.c || "$f" == *_win.cpp ]] && continue
        [[ "$f" == *gtk* || "$f" == *cocoa* || "$f" == *haiku* ]] && continue
        [[ "$f" == *_x.c || "$f" == *_x11* || "$f" == *x11* ]] && continue  # X11/Linux backend, not for macOS
        [[ "$f" == *iup_glfont.c || "$f" == *cdgl.c ]] && continue
        [[ "$f" == *dx* || "$f" == *DX* || "$f" == *avi* || "$f" == *wmv* || "$f" == *jp2* || "$f" == *ecw* ]] && continue
        [[ "$f" == *jas_* ]] && continue
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "mod/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "mod/")"
        fi
    done
done

# ===== CD + IM =====
echo "[4/5] CD + IM Libraries"
# CD 鈥?浣跨敤渚挎惡鍚庣 (璺宠繃 win32/gdiplus/X11, 浠ュ強闇€瑕?FTGL 鐨?cdgl)
for f in cd/src/*.c cd/src/drv/cd*.c cd/src/intcgm/*.c cd/src/sim/*.c \
         cd/src/svg/*.c cd/src/minizip/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *cdgl.c || "$f" == *cdpdf* || "$f" == *cddgn* || "$f" == *cddxf* || "$f" == *cgm* ]] && continue
    ALL_OBJ+=" $(compile_c "$f" "cd/")"
done

# IM core (portable 鈥?鎺掗櫎 Win32 涓撳睘鏂囦欢)
for f in im/src/*.cpp im/src/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *im_dib* || "$f" == *im_sysfile_win32* || "$f" == *im_capture_dx* || "$f" == *im_format_avi* || "$f" == *im_format_wmv* || "$f" == *im_format_ecw* || "$f" == *im_format_jp2* || "$f" == *jas_* ]] && continue
    [[ "$f" == *tiff_binfile* ]] && continue  # tif_unix.c already provides these on macOS
    if [[ "$f" == *.cpp ]]; then
        ALL_OBJ+=" $(compile_cxx "$f" "im/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "im/")"
    fi
done
# IM format libs
for d in im/src/libtiff im/src/libjpeg im/src/libpng im/src/lzf im/src/lz4; do
    [ -d "$d" ] || continue
    for f in $(find "$d" \( -name '*.c' -o -name '*.cpp' \) 2>/dev/null); do
        [[ "$f" == *win32* || "$f" == *Win32* || "$f" == *tif_win32* ]] && continue
        [[ "$f" == *jas_* ]] && continue
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "imfmt/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "imfmt/")"
        fi
    done
done

# ===== Scintilla (鎺掗櫎 win32 骞冲彴灞? =====
echo "[5/5] Scintilla"
SCIBASE="srcscintilla/scintilla3112"
for f in "$SCIBASE"/src/*.cxx "$SCIBASE"/lexlib/*.cxx "$SCIBASE"/lexers/*.cxx; do
    [ -f "$f" ] || continue
    [[ "$f" == *LexLPeg* ]] && continue
    [[ "$f" == *ExternalLexer* ]] && continue
    ALL_OBJ+=" $(compile_cxx "$f" "sci/")"
done
for f in srcscintilla/iup_scintilla.c srcscintilla/iupsci_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "sciw/")"
done

# ===== Link Single Dynamic Library (.dylib) 鈥?闆跺閮ㄤ緷璧?=====
echo ""
echo "=== Linking libiup.dylib (self-contained) ==="
# 闈欐€侀摼鎺?freetype/bz2/png锛屾鏋跺拰绯荤粺搴撲繚鎸佸姩鎬?
$CXX -dynamiclib -o "$OUT/libiup.dylib" $ALL_OBJ \
    $FREETYPE_LIB \
    -framework Cocoa -framework OpenGL \
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
