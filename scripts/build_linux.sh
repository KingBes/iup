#!/bin/bash
# ===================================================================
#  IUP Linux GTK3 Build - Single .so + .a (self-contained)
#  依赖: apt install libgtk-3-dev libglu1-mesa-dev libcairo2-dev
#        (freetype/zlib 从源码构建，无运行时依赖)
# ===================================================================
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

JOBS=${JOBS:-$(nproc)}
BUILD="$ROOT/build/obj_linux"
OUT="$ROOT/build/linux"
DEPS="$ROOT/build/deps_linux"
mkdir -p "$BUILD" "$OUT" "$DEPS"

CC=gcc
CXX=g++

# ===== Build freetype + zlib from source (with -fPIC) =====
FREETYPE_VER="2.13.2"
ZLIB_VER="1.3.1"
FREETYPE_PREFIX="$DEPS/freetype"
ZLIB_PREFIX="$DEPS/zlib"

if [ ! -f "$FREETYPE_PREFIX/lib/libfreetype.a" ]; then
    echo "=== Building freetype $FREETYPE_VER ==="
    cd "$DEPS"
    wget -q "https://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE_VER.tar.xz"
    tar xJf "freetype-$FREETYPE_VER.tar.xz"
    rm -f "freetype-$FREETYPE_VER.tar.xz"
    cd "freetype-$FREETYPE_VER"
    ./configure --prefix="$FREETYPE_PREFIX" --with-pic --enable-static --disable-shared --without-harfbuzz --without-brotli --without-png --without-bzip2 --without-brotli
    make -j"$JOBS"
    make install
    cd "$ROOT"
fi

if [ ! -f "$ZLIB_PREFIX/lib/libz.a" ]; then
    echo "=== Building zlib $ZLIB_VER ==="
    cd "$DEPS"
    wget -q "https://github.com/madler/zlib/releases/download/v$ZLIB_VER/zlib-$ZLIB_VER.tar.gz"
    tar xzf "zlib-$ZLIB_VER.tar.gz"
    rm -f "zlib-$ZLIB_VER.tar.gz"
    cd "zlib-$ZLIB_VER"
    CC="$CC" CFLAGS="-fPIC -O2" ./configure --prefix="$ZLIB_PREFIX" --static
    make -j"$JOBS"
    make install
    cd "$ROOT"
fi

DEPS_CFLAGS="-I$FREETYPE_PREFIX/include/freetype2 -I$FREETYPE_PREFIX/include -I$ZLIB_PREFIX/include"
DEPS_LIBS="$FREETYPE_PREFIX/lib/libfreetype.a $ZLIB_PREFIX/lib/libz.a"

# ===== Common flags =====
# 确保 tif_config.h 启用 HAVE_UNISTD_H
if grep -q '^#undef HAVE_UNISTD_H' "$ROOT/im/src/libtiff/tif_config.h" 2>/dev/null; then
    perl -pi -e 's/^#undef HAVE_UNISTD_H$/#define HAVE_UNISTD_H/' "$ROOT/im/src/libtiff/tif_config.h"
fi
DEFS="-DIUP_BUILD_LIBRARY -DCD_NO_OLD_INTERFACE -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE -DSCINTILLA_VERSION=\\\"3.11.2\\\" -D_USE_MATH_DEFINES -DFTGL_LIBRARY_STATIC -DNO_CXX11_REGEX -DMGL_STATIC_DEFINE -DMGL_SRC"
CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -Wno-incompatible-pointer-types -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast -Wno-missing-braces -Wno-error=deprecated-declarations"
CXXFLAGS="-fPIC -Wall -O2 -std=c++11 -fpermissive -Wno-class-memaccess -Wno-reorder -Wno-write-strings -Wno-stringop-truncation -Wno-unknown-pragmas -Wno-misleading-indentation -Wno-error=deprecated-declarations"

GTK_CFLAGS=$(pkg-config --cflags gtk+-3.0 2>/dev/null || echo "")

INCLUDES="-Iinclude -Isrc -Isrc/gtk -Isrcimglib -Isrcgl -Isrcglcontrols -Isrcmglplot -Isrcmglplot/src -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack -Isrcscintilla -Isrcscintilla/scintilla3112/include -Isrcscintilla/scintilla3112/src -Isrcscintilla/scintilla3112/lexlib -Isrcscintilla/scintilla3112/win32 -Isrcscintilla/scintilla3112/lexers -Isrcole -Isrccd -Isrccontrols -Isrcplot -Icd/include -Icd/src -Icd/src/sim -Icd/src/drv -Icd/src/intcgm -Icd/src/svg -Icd/src/minizip -Icd/src/x11 -Iim/include -Iim/src -Iim/src/libtiff -Iim/src/libjpeg -Iim/src/libpng -Iim/src/liblzf -Iim/src/lz4 $GTK_CFLAGS $DEPS_CFLAGS"

echo "=== Linux GTK3 Build ==="
echo "Jobs: $JOBS"

# ===== Helper: compile C files =====
compile_c() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [CC] $src" >&2
    $CC -c $CFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
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

# ===== IUP Core (platform-independent) =====
echo "[1/5] IUP Core"
for f in src/iup.c src/iup_*.c; do
    [[ "$f" == "src/iup_datepick.c" ]] && continue
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "iup/")"
done

# ===== IUP GTK Backend =====
echo "[2/5] IUP GTK Driver"
for f in src/gtk/iupgtk_*.c src/iup_datepick.c \
         src/mot/iupunix_info.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *iupgtk_draw_gdk.c ]] && continue  # GTK2 API, not compatible with GTK3
    ALL_OBJ+=" $(compile_c "$f" "gtk/")"
done

# ===== IUP Modules (鎺掗櫎 Windows 涓撴湁鏂囦欢) =====
echo "[3/5] IUP Modules"
for d in srccd srccontrols srcgl srcglcontrols srcim srcimglib srcplot srcmglplot srctuio; do
    [ -d "$d" ] || continue
    for f in $(find "$d" -maxdepth 3 \( -name '*.c' -o -name '*.cpp' \) 2>/dev/null); do
        [[ "$f" == *dep/* ]] && continue
        [[ "$f" == *matrixex/* ]] && continue
        [[ "$f" == *win32* || "$f" == *Win32* || "$f" == *_win32* || "$f" == *_win.c || "$f" == *_win.cpp ]] && continue
        [[ "$f" == *gtk* || "$f" == *cocoa* || "$f" == *haiku* ]] && continue
        [[ "$f" == *dx* || "$f" == *DX* || "$f" == *avi* || "$f" == *wmv* || "$f" == *jp2* || "$f" == *ecw* ]] && continue
        [[ "$f" == *jas_* ]] && continue
        [[ "$f" == *iup_glfont.c ]] && continue  # ftgl 依赖已用 stub 替代
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "mod/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "mod/")"
        fi
    done
done

# ===== CD Library (Linux/X11 backend) =====
echo "[4/5] CD + IM Libraries"
# CD common + X11 (瀹為檯瀛樺湪鐨勬枃浠跺垪琛?
CD_X11="cd/src/x11/cdx11.c cd/src/x11/cdxclp.c cd/src/x11/cdxdbuf.c cd/src/x11/cdximg.c cd/src/x11/cdxnative.c cd/src/x11/xvertex.c"
for f in cd/src/*.c cd/src/drv/cd*.c cd/src/intcgm/*.c cd/src/sim/*.c \
         cd/src/svg/*.c cd/src/minizip/*.c $CD_X11; do
    [ -f "$f" ] || continue
    [[ "$f" == *cdpdf* || "$f" == *cddgn* || "$f" == *cddxf* || "$f" == *cdgl* || "$f" == *cgm* ]] && continue
    ALL_OBJ+=" $(compile_c "$f" "cd/")"
done
# CD C++ files
for f in cd/src/cdpp.cpp; do
    [ -f "$f" ] && ALL_OBJ+=" $(compile_cxx "$f" "cd/")"
done

# IM core (portable 鈥?鎺掗櫎 Win32 涓撳睘鏂囦欢)
for f in im/src/*.cpp im/src/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *im_dib* || "$f" == *im_sysfile_win32* || "$f" == *im_capture_dx* || "$f" == *im_format_avi* || "$f" == *im_format_wmv* || "$f" == *im_format_ecw* || "$f" == *im_format_jp2* || "$f" == *jas_* ]] && continue
    [[ "$f" == *tiff_binfile* ]] && continue  # tif_unix.c already provides these on Linux
    if [[ "$f" == *.cpp ]]; then
        ALL_OBJ+=" $(compile_cxx "$f" "im/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "im/")"
    fi
done
# IM format libs (排除 Win32 专属)
for d in im/src/libtiff im/src/libjpeg im/src/libpng im/src/lzf im/src/lz4; do
    [ -d "$d" ] || continue
    for f in $(find "$d" \( -name '*.c' -o -name '*.cpp' \) 2>/dev/null); do
        [[ "$f" == *win32* || "$f" == *Win32* || "$f" == *tif_win32* ]] && continue
        [[ "$f" == *jas_* || "$f" == *im_capture* || "$f" == *im_format_avi* || "$f" == *im_format_wmv* || "$f" == *im_format_ecw* || "$f" == *im_format_jp2* ]] && continue
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
# IUP Scintilla wrapper
for f in srcscintilla/iup_scintilla.c srcscintilla/iupsci_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "sciw/")"
done

# ===== Link Single Shared Library (.so) =====
echo ""
echo "=== Linking libiup.so (self-contained) ==="
GTK_LIBS=$(pkg-config --libs gtk+-3.0 2>/dev/null || echo "")
# freetype/z 用本地构建的静态库；GTK3/GL/X11 为系统依赖
$CXX -shared -o "$OUT/libiup.so" $ALL_OBJ \
    $DEPS_LIBS -lGLU \
    $GTK_LIBS -lGL -lX11 -lXrender -lm -lpthread -ldl

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
