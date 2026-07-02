#!/bin/bash
# ===================================================================
#  IUP macOS Cocoa Build - Single .dylib + .a (self-contained)
#
#  Builds ALL deps from source:
#    zlib, freetype, FTGL, pixman, glib, harfbuzz, fribidi, pango,
#    cairo, Scintilla 4.4.6 (Cocoa)
#
#  Requires: Xcode CLT, wget, meson, ninja
# ===================================================================
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

JOBS=${JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || echo 4)}
BUILD="$ROOT/build/obj_macos"
OUT="$ROOT/build/macos"
DEPS="$ROOT/build/deps_macos"
mkdir -p "$BUILD" "$OUT" "$DEPS"

CC=clang
CXX=clang++
PKG_CONFIG_PATH=""
export PKG_CONFIG_PATH

add_pkgpath() {
    PKG_CONFIG_PATH="$1/lib/pkgconfig:$1/share/pkgconfig:${PKG_CONFIG_PATH}"
    export PKG_CONFIG_PATH
}

# ===================================================================
# zlib
# ===================================================================
ZLIB_VER="1.3.1"
ZLIB_PREFIX="$DEPS/zlib"

if [ ! -f "$ZLIB_PREFIX/lib/libz.a" ]; then
    echo "=== Building zlib $ZLIB_VER ==="
    cd "$DEPS"
    wget -q "https://github.com/madler/zlib/releases/download/v$ZLIB_VER/zlib-$ZLIB_VER.tar.gz"
    tar xzf "zlib-$ZLIB_VER.tar.gz"; rm -f "zlib-$ZLIB_VER.tar.gz"
    cd "zlib-$ZLIB_VER"
    CC="$CC" CFLAGS="-fPIC -O2" ./configure --prefix="$ZLIB_PREFIX" --static
    make -j"$JOBS"; make install; cd "$ROOT"
fi
add_pkgpath "$ZLIB_PREFIX"

# ===================================================================
# freetype
# ===================================================================
FREETYPE_VER="2.13.2"
FREETYPE_PREFIX="$DEPS/freetype"

if [ ! -f "$FREETYPE_PREFIX/lib/libfreetype.a" ]; then
    echo "=== Building freetype $FREETYPE_VER ==="
    cd "$DEPS"
    wget -q "https://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE_VER.tar.xz"
    tar xJf "freetype-$FREETYPE_VER.tar.xz"; rm -f "freetype-$FREETYPE_VER.tar.xz"
    cd "freetype-$FREETYPE_VER"
    ./configure --prefix="$FREETYPE_PREFIX" --with-pic --enable-static --disable-shared \
        --without-harfbuzz --without-brotli --without-png --without-bzip2
    make -j"$JOBS"; make install; cd "$ROOT"
fi
add_pkgpath "$FREETYPE_PREFIX"

# ===================================================================
# Ensure Python distutils is available (removed in Python 3.12+,
# needed by glib gdbus-codegen)
# ===================================================================
if ! python3 -c "import distutils" 2>/dev/null; then
    echo "=== Installing setuptools (distutils shim) ==="
    pip3 install --break-system-packages setuptools
fi

# ===================================================================
# glib (meson) - needed by harfbuzz, pango
# ===================================================================
GLIB_VER="2.78.6"
GLIB_PREFIX="$DEPS/glib"

if [ ! -f "$GLIB_PREFIX/lib/libglib-2.0.a" ]; then
    echo "=== Building glib $GLIB_VER ==="
    cd "$DEPS"
    wget -q "https://download.gnome.org/sources/glib/${GLIB_VER%.*}/glib-${GLIB_VER}.tar.xz"
    tar xJf "glib-${GLIB_VER}.tar.xz"; rm -f "glib-${GLIB_VER}.tar.xz"
    cd "glib-${GLIB_VER}"
    meson setup _build --prefix="$GLIB_PREFIX" --default-library=static \
        -Dlibelf=disabled -Dselinux=disabled -Dxattr=false \
        -Dtests=false -Dnls=disabled -Doss_fuzz=disabled \
        -Dlibmount=disabled -Ddtrace=false -Dsystemtap=false \
        -Dsysprof=disabled \
        -Dman=false -Dgtk_doc=false
    ninja -C _build -j"$JOBS"
    ninja -C _build install
    cd "$ROOT"
fi
add_pkgpath "$GLIB_PREFIX"

# ===================================================================
# harfbuzz (meson) - needed by pango
# ===================================================================
HB_VER="8.5.0"
HB_PREFIX="$DEPS/harfbuzz"

if [ ! -f "$HB_PREFIX/lib/libharfbuzz.a" ]; then
    echo "=== Building harfbuzz $HB_VER ==="
    cd "$DEPS"
    wget -q "https://github.com/harfbuzz/harfbuzz/releases/download/${HB_VER}/harfbuzz-${HB_VER}.tar.xz"
    tar xJf "harfbuzz-${HB_VER}.tar.xz"; rm -f "harfbuzz-${HB_VER}.tar.xz"
    cd "harfbuzz-${HB_VER}"
    meson setup _build --prefix="$HB_PREFIX" --default-library=static \
        -Dtests=disabled -Ddocs=disabled -Dbenchmark=disabled \
        -Dicu=disabled -Dgraphite2=disabled \
        -Dfreetype=disabled -Dcairo=disabled -Dglib=enabled \
        -Dgobject=disabled \
        -Dcoretext=enabled
    ninja -C _build -j"$JOBS"
    ninja -C _build install
    cd "$ROOT"
fi
add_pkgpath "$HB_PREFIX"

# ===================================================================
# fribidi (autotools) - needed by pango
# ===================================================================
FRIBIDI_VER="1.0.13"
FRIBIDI_PREFIX="$DEPS/fribidi"

if [ ! -f "$FRIBIDI_PREFIX/lib/libfribidi.a" ]; then
    echo "=== Building fribidi $FRIBIDI_VER ==="
    cd "$DEPS"
    wget -q "https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VER}/fribidi-${FRIBIDI_VER}.tar.xz"
    tar xJf "fribidi-${FRIBIDI_VER}.tar.xz"; rm -f "fribidi-${FRIBIDI_VER}.tar.xz"
    cd "fribidi-${FRIBIDI_VER}"
    ./configure --prefix="$FRIBIDI_PREFIX" --enable-static --disable-shared --disable-docs
    make -j"$JOBS"; make install; cd "$ROOT"
fi
add_pkgpath "$FRIBIDI_PREFIX"

# ===================================================================
# pixman (meson) - needed by cairo
# ===================================================================
PIXMAN_VER="0.44.2"
PIXMAN_PREFIX="$DEPS/pixman"

if [ ! -f "$PIXMAN_PREFIX/lib/libpixman-1.a" ]; then
    echo "=== Building pixman $PIXMAN_VER ==="
    cd "$DEPS"
    wget -q "https://www.cairographics.org/releases/pixman-${PIXMAN_VER}.tar.gz"
    tar xzf "pixman-${PIXMAN_VER}.tar.gz"; rm -f "pixman-${PIXMAN_VER}.tar.gz"
    cd "pixman-${PIXMAN_VER}"
    meson setup _build --prefix="$PIXMAN_PREFIX" --default-library=static \
        -Dtests=disabled -Ddemos=disabled -Dgtk=disabled -Dlibpng=disabled
    ninja -C _build -j"$JOBS"
    ninja -C _build install
    cd "$ROOT"
fi
add_pkgpath "$PIXMAN_PREFIX"

# ===================================================================
# lzo - needed by cairo script interpreter
# Homebrew's lzo2.pc has a broken include path (appends /lzo to
# Cflags, causing #include <lzo/lzo2a.h> to fail).  We write a
# correct override .pc so cairo finds lzo with the right -I path.
# ===================================================================
LZO_OVERRIDE_DIR="$DEPS/lzo_override"
LZO_SYSTEM_PREFIX="$(brew --prefix lzo 2>/dev/null || echo /opt/homebrew/opt/lzo)"

mkdir -p "$LZO_OVERRIDE_DIR/lib/pkgconfig"
cat > "$LZO_OVERRIDE_DIR/lib/pkgconfig/lzo2.pc" << LZOEOF
prefix=${LZO_SYSTEM_PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: lzo2
Description: LZO real-time data compression library
Version: 2.10
Libs: -L\${libdir} -llzo2
Cflags: -I\${includedir}
LZOEOF
add_pkgpath "$LZO_OVERRIDE_DIR"

# ===================================================================
# cairo (meson) - depends on pixman, freetype, lzo
# Built BEFORE pango so that pango can find cairo and build pangocairo
# ===================================================================
# ===================================================================
CAIRO_VER="1.18.2"
CAIRO_PREFIX="$DEPS/cairo"

if [ ! -f "$CAIRO_PREFIX/lib/libcairo.a" ]; then
    echo "=== Building Cairo $CAIRO_VER ==="
    cd "$DEPS"
    wget -q "https://www.cairographics.org/releases/cairo-${CAIRO_VER}.tar.xz"
    tar xJf "cairo-${CAIRO_VER}.tar.xz"; rm -f "cairo-${CAIRO_VER}.tar.xz"
    cd "cairo-${CAIRO_VER}"
    meson setup _build --prefix="$CAIRO_PREFIX" --default-library=static \
        -Dtests=disabled \
        -Dquartz=enabled \
        -Dxlib=disabled -Dxcb=disabled
    ninja -C _build -j"$JOBS"
    ninja -C _build install
    cd "$ROOT"
fi
add_pkgpath "$CAIRO_PREFIX"

# ===================================================================
# pango (meson) - text layout for CD Cairo, built AFTER cairo so
# that pangocairo.h is available
# ===================================================================
PANGO_VER="1.52.2"
PANGO_PREFIX="$DEPS/pango"

if [ ! -f "$PANGO_PREFIX/lib/libpango-1.0.a" ]; then
    echo "=== Building pango $PANGO_VER ==="
    cd "$DEPS"
    wget -q "https://download.gnome.org/sources/pango/${PANGO_VER%.*}/pango-${PANGO_VER}.tar.xz"
    tar xJf "pango-${PANGO_VER}.tar.xz"; rm -f "pango-${PANGO_VER}.tar.xz"
    cd "pango-${PANGO_VER}"
    meson setup _build --prefix="$PANGO_PREFIX" --default-library=static \
        -Dfontconfig=disabled \
        -Dxft=disabled -Dcairo=enabled -Dlibthai=disabled \
        -Dgtk_doc=false -Dinstall-tests=false
    ninja -C _build -j"$JOBS"
    ninja -C _build install
    cd "$ROOT"
fi
add_pkgpath "$PANGO_PREFIX"

# ===================================================================
# Scintilla 4.4.6 (includes Cocoa backend + lexers)
# ===================================================================
SCI_DIR="$DEPS/scintilla446"

if [ ! -d "$SCI_DIR" ]; then
    echo "=== Downloading Scintilla 4.4.6 ==="
    cd "$DEPS"
    wget -q "https://www.scintilla.org/scintilla446.tgz" -O "scintilla446.tgz"
    tar xzf "scintilla446.tgz"; rm -f "scintilla446.tgz"
    [ -d "scintilla" ] && mv scintilla scintilla446
    cd "$ROOT"
fi
SCI_SRC="$SCI_DIR"

# ===================================================================
# Unified flags
# ===================================================================
if grep -q '^#undef HAVE_UNISTD_H' "$ROOT/im/src/libtiff/tif_config.h" 2>/dev/null; then
    perl -pi -e 's/^#undef HAVE_UNISTD_H$/#define HAVE_UNISTD_H/' "$ROOT/im/src/libtiff/tif_config.h"
fi

DEPS_CFLAGS="-I$FREETYPE_PREFIX/include/freetype2 -I$FREETYPE_PREFIX/include"
DEPS_CFLAGS+=" -I$GLIB_PREFIX/include/glib-2.0 -I$GLIB_PREFIX/lib/glib-2.0/include"
DEPS_CFLAGS+=" -I$HB_PREFIX/include/harfbuzz"
DEPS_CFLAGS+=" -I$FRIBIDI_PREFIX/include/fribidi"
DEPS_CFLAGS+=" -I$PANGO_PREFIX/include/pango-1.0"
DEPS_CFLAGS+=" -I$PIXMAN_PREFIX/include/pixman-1"
DEPS_CFLAGS+=" -I$CAIRO_PREFIX/include/cairo"
DEPS_CFLAGS+=" -I$ZLIB_PREFIX/include"

DEPS_LIBS="$CAIRO_PREFIX/lib/libcairo.a $PIXMAN_PREFIX/lib/libpixman-1.a"
DEPS_LIBS+=" $PANGO_PREFIX/lib/libpango-1.0.a $PANGO_PREFIX/lib/libpangocairo-1.0.a"
DEPS_LIBS+=" $HB_PREFIX/lib/libharfbuzz.a $FRIBIDI_PREFIX/lib/libfribidi.a"
DEPS_LIBS+=" $GLIB_PREFIX/lib/libglib-2.0.a $GLIB_PREFIX/lib/libgmodule-2.0.a $GLIB_PREFIX/lib/libgobject-2.0.a $GLIB_PREFIX/lib/libgio-2.0.a $GLIB_PREFIX/lib/libgthread-2.0.a"
DEPS_LIBS+=" $FREETYPE_PREFIX/lib/libfreetype.a $ZLIB_PREFIX/lib/libz.a"
DEPS_LIBS+=" -framework CoreFoundation -framework CoreGraphics -framework CoreText"

SCINTILLA_VERSION="4.4.6"
SCI_INCLUDES="-I$SCI_SRC/include -I$SCI_SRC/src -I$SCI_SRC/lexlib -I$SCI_SRC/lexers -I$SCI_SRC/cocoa"

DEFS="-DIUP_BUILD_LIBRARY -DCD_NO_OLD_INTERFACE -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE -DSCINTILLA_VERSION=\"$SCINTILLA_VERSION\" -D_USE_MATH_DEFINES -DFTGL_LIBRARY_STATIC -DMGL_STATIC_DEFINE -DMGL_SRC -DPNG_ARM_NEON_OPT=0 -DNO_FONTCONFIG -DGL_SILENCE_DEPRECATION"
CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -Wno-incompatible-pointer-types -Wno-missing-braces -Wno-error=deprecated-declarations"
CXXFLAGS="-fPIC -Wall -O2 -std=c++17 -Dregister= -Wno-reorder -Wno-write-strings -Wno-misleading-indentation -Wno-error=deprecated-declarations"
OBJCFLAGS="-fPIC -Wall -O2"
OBJCXXFLAGS="-fPIC -Wall -O2 -std=c++17 -Dregister= -Wno-error=deprecated-declarations"

INCLUDES="-Iinclude -Isrc -Isrc/cocoa -Isrcimglib -Isrcgl -Isrcglcontrols -Isrcmglplot -Isrcmglplot/src -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack -Isrcscintilla $SCI_INCLUDES -Isrcole -Isrccd -Isrccontrols -Isrcplot -Icd/include -Icd/src -Icd/src/cairo -Icd/src/sim -Icd/src/drv -Icd/src/intcgm -Icd/src/svg -Icd/src/minizip -Iim/include -Iim/src -Iim/src/libtiff -Iim/src/libjpeg -Iim/src/libpng -Iim/src/liblzf -Iim/src/lz4 -Ibuild $DEPS_CFLAGS"

echo "=== macOS Cocoa Build ==="
echo "Jobs: $JOBS"
echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"

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
    # -x objective-c forces ObjC mode for .c files that include Cocoa headers
    $CC -c -x objective-c $OBJCFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
    echo "$obj"
}

compile_mm() {
    local src="$1" dir="$2"
    local obj="$BUILD/${dir}${src##*/}.o"
    mkdir -p "$(dirname "$obj")"
    echo "  [MM] $src" >&2
    $CXX -c $OBJCXXFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
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
echo "[1/7] IUP Core"
for f in src/iup.c src/iup_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "iup/")"
done

# ===== IUP Cocoa Backend =====
echo "[2/7] IUP Cocoa Driver"
for f in src/cocoa/*.m src/cocoa/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *iupmac_info.m ]] && continue
    if [[ "$f" == *.m ]]; then
        ALL_OBJ+=" $(compile_m "$f" "cocoa/")"
    elif [[ "$f" == *iupcocoa_str.c ]]; then
        ALL_OBJ+=" $(compile_m "$f" "cocoa/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "cocoa/")"
    fi
done

# ===== IUP Modules =====
echo "[3/7] IUP Modules"
for d in srccd srccontrols srcgl srcglcontrols srcim srcimglib srcplot srcmglplot srctuio; do
    [ -d "$d" ] || continue
    for f in $(find "$d" -maxdepth 3 \( -name '*.c' -o -name '*.cpp' \) 2>/dev/null); do
        [[ "$f" == *dep/* ]] && continue
        [[ "$f" == *win32* || "$f" == *Win32* || "$f" == *_win32* || "$f" == *_win.c || "$f" == *_win.cpp ]] && continue
        [[ "$f" == *gtk* || "$f" == *cocoa* || "$f" == *haiku* ]] && continue
        [[ "$f" == *_x.c || "$f" == *_x11* || "$f" == *x11* ]] && continue
        [[ "$f" == *cdgl.c ]] && continue
        [[ "$f" == *dx* || "$f" == *DX* || "$f" == *avi* || "$f" == *wmv* || "$f" == *jp2* || "$f" == *ecw* ]] && continue
        [[ "$f" == *jas_* ]] && continue
        if [[ "$f" == *.cpp ]]; then
            ALL_OBJ+=" $(compile_cxx "$f" "mod/")"
        else
            ALL_OBJ+=" $(compile_c "$f" "mod/")"
        fi
    done
done

# ===== FTGL wrapper =====
echo "  [CXX] build/ftgl_real.cpp" >&2
mkdir -p "$BUILD/stub"
$CXX -c $CXXFLAGS $DEFS $INCLUDES \
    -o "$BUILD/stub/ftgl_real.cpp.o" "build/ftgl_real.cpp" \
    || { echo "  FAILED: build/ftgl_real.cpp" >&2; exit 1; }
ALL_OBJ+=" $BUILD/stub/ftgl_real.cpp.o"

# ===== Oscpack POSIX (TUIO) =====
for f in srctuio/oscpack/ip/posix/*.cpp; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_cxx "$f" "oscpack/")"
done

# ===== CD + IM =====
echo "[4/7] CD + IM"

# CD core + drivers (incl. cdgl.c)
for f in cd/src/*.c cd/src/drv/cd*.c cd/src/drv/pptx.c \
         cd/src/sim/*.c cd/src/svg/*.c cd/src/minizip/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *cdpdf* || "$f" == *cddgn* || "$f" == *cddxf* || "$f" == *cdcgm* ]] && continue
    ALL_OBJ+=" $(compile_c "$f" "cd/")"
done

# CD Cairo backend (with Pango, now available!)
for f in cd/src/cairo/*.c cd/src/cairo/*.m; do
    [ -f "$f" ] || continue
    [[ "$f" == *win32* || "$f" == *Win32* ]] && continue
    [[ "$f" == *gtk* ]] && continue
    [[ "$f" == *x11* || "$f" == *X11* ]] && continue
    [[ "$f" == *gdk* ]] && continue
    [[ "$f" == *emf* ]] && continue
    if [[ "$f" == *.m ]]; then
        ALL_OBJ+=" $(compile_m "$f" "cdcairo/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "cdcairo/")"
    fi
done

# CD intcgm
for f in cd/src/intcgm/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *cgm* ]] && continue
    ALL_OBJ+=" $(compile_c "$f" "cdintcgm/")"
done

# CD stub (only cdContextClipboard remains)
ALL_OBJ+=" $(compile_c "build/cd_stub_cocoa.c" "cdstub/")"

# IM
for f in im/src/*.cpp im/src/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *im_dib* || "$f" == *im_sysfile_win32* || "$f" == *im_capture_dx* || "$f" == *im_format_avi* || "$f" == *im_format_wmv* || "$f" == *im_format_ecw* || "$f" == *im_format_jp2* || "$f" == *jas_* ]] && continue
    [[ "$f" == *tiff_binfile* ]] && continue
    if [[ "$f" == *.cpp ]]; then
        ALL_OBJ+=" $(compile_cxx "$f" "im/")"
    else
        ALL_OBJ+=" $(compile_c "$f" "im/")"
    fi
done
for d in im/src/libtiff im/src/libjpeg im/src/libpng im/src/liblzf im/src/lz4; do
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

# ===== Scintilla 4.4.6 (Cocoa) =====
echo "[5/7] Scintilla $SCINTILLA_VERSION Core"
for f in "$SCI_SRC"/src/*.cxx; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_cxx "$f" "sci/")"
done

echo "[6/7] Scintilla Lexers + Cocoa Platform"
for f in "$SCI_SRC"/lexlib/*.cxx "$SCI_SRC"/lexers/*.cxx; do
    [ -f "$f" ] || continue
    [[ "$f" == *ExternalLexer* || "$f" == *LexLPeg* ]] && continue
    ALL_OBJ+=" $(compile_cxx "$f" "scilex/")"
done
for f in "$SCI_SRC"/cocoa/*.cxx "$SCI_SRC"/cocoa/*.mm; do
    [ -f "$f" ] || continue
    if [[ "$f" == *.mm ]]; then
        # Scintilla Cocoa uses __weak references which require ARC
        _obj="$BUILD/scicocoa/${f##*/}.o"
        mkdir -p "$(dirname "$_obj")"
        echo "  [MM+ARC] $f" >&2
        $CXX -c $OBJCXXFLAGS -fobjc-arc $DEFS $INCLUDES -o "$_obj" "$f" \
            || { echo "  FAILED: $f" >&2; exit 1; }
        ALL_OBJ+=" $_obj"
    else
        ALL_OBJ+=" $(compile_cxx "$f" "scicocoa/")"
    fi
done

# ===== IUP Scintilla wrapper + GL canvas =====
echo "[7/7] IUP Scintilla + GL"
ALL_OBJ+=" $(compile_c "srcscintilla/iup_scintilla.c" "sciw/")"
# ScintillaView is ARC-managed, so this wrapper needs ARC too
_sci_cocoa_obj="$BUILD/sciw/iup_scintilla_cocoa.o"
mkdir -p "$(dirname "$_sci_cocoa_obj")"
echo "  [M+ARC] srcscintilla/iup_scintilla_cocoa.m" >&2
$CC -c -x objective-c $OBJCFLAGS -fobjc-arc $DEFS $INCLUDES \
    -o "$_sci_cocoa_obj" "srcscintilla/iup_scintilla_cocoa.m" \
    || { echo "  FAILED: srcscintilla/iup_scintilla_cocoa.m" >&2; exit 1; }
ALL_OBJ+=" $_sci_cocoa_obj"
ALL_OBJ+=" $(compile_c "srcscintilla/iup_scintilladlg.c" "sciw/")"
for f in srcscintilla/iupsci_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "sciw/")"
done
ALL_OBJ+=" $(compile_c "srcgl/iup_glcanvas_cocoa.c" "gl/")"

# ===== Link =====
echo ""
echo "=== Linking libiup.dylib (self-contained) ==="
$CXX -dynamiclib -o "$OUT/libiup.dylib" $ALL_OBJ \
    $DEPS_LIBS \
    -framework Cocoa -framework OpenGL -framework QuartzCore -framework SystemConfiguration \
    $(pkg-config --libs libffi 2>/dev/null || echo "-lffi") \
    $(pkg-config --libs libpcre2-8 2>/dev/null || echo "-lpcre2-8") \
    $(pkg-config --libs intl 2>/dev/null || echo "-L$(brew --prefix gettext 2>/dev/null || echo /opt/homebrew/opt/gettext)/lib -lintl") \
    -liconv -lm -lpthread

echo "=== Creating libiup.a ==="
ar rcs "$OUT/libiup.a" $ALL_OBJ

echo "=== Packaging ==="
mkdir -p "$OUT/include"
cp -r include/* "$OUT/include/"

echo ""
echo "=== macOS Build Complete ==="
echo "  Shared: $OUT/libiup.dylib"
echo "  Static: $OUT/libiup.a"
ls -lh "$OUT/libiup.dylib" "$OUT/libiup.a"
