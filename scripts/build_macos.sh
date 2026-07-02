#!/bin/bash
# ===================================================================
#  IUP macOS Cocoa Build - Single .dylib + .a
#
#  Compiles IUP/CD/IM/Scintilla source into the library.
#  Third-party deps (glib, cairo, pango, freetype, etc.) are linked
#  dynamically from Homebrew system packages.
#
#  Requires: Xcode CLT, Homebrew, wget, meson, ninja
#  Install deps: brew install freetype glib harfbuzz pango cairo pixman
#                lzo gettext libffi pcre2
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

# ===================================================================
# Get cflags/libs from pkg-config for each dependency
# ===================================================================
pc_cflags() { pkg-config --cflags "$1" 2>/dev/null || echo ""; }
pc_libs()   { pkg-config --libs   "$1" 2>/dev/null || echo ""; }

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

# Collect cflags from all deps via pkg-config
DEPS_CFLAGS=$(pc_cflags freetype2)
DEPS_CFLAGS+=" $(pc_cflags glib-2.0)"
DEPS_CFLAGS+=" $(pc_cflags gobject-2.0)"
DEPS_CFLAGS+=" $(pc_cflags gthread-2.0)"
DEPS_CFLAGS+=" $(pc_cflags harfbuzz)"
DEPS_CFLAGS+=" $(pc_cflags pango)"
DEPS_CFLAGS+=" $(pc_cflags pangocairo)"
DEPS_CFLAGS+=" $(pc_cflags cairo)"
DEPS_CFLAGS+=" $(pc_cflags pixman-1)"
DEPS_CFLAGS+=" $(pc_cflags libpng)"
DEPS_CFLAGS+=" $(pc_cflags zlib)"
DEPS_CFLAGS+=" $(pc_cflags libffi)"
DEPS_CFLAGS+=" $(pc_cflags libpcre2-8)"
# gettext/libintl may not have a .pc file
GETTEXT_INC=$(brew --prefix gettext 2>/dev/null && echo "/include" || echo "")
[ -n "$GETTEXT_INC" ] && [ -d "$GETTEXT_INC" ] && DEPS_CFLAGS+=" -I$GETTEXT_INC"

# Collect libs from all deps via pkg-config
DEPS_LIBS=$(pc_libs cairo)
DEPS_LIBS+=" $(pc_libs pangocairo)"
DEPS_LIBS+=" $(pc_libs pango)"
DEPS_LIBS+=" $(pc_libs harfbuzz)"
DEPS_LIBS+=" $(pc_libs glib-2.0)"
DEPS_LIBS+=" $(pc_libs gobject-2.0)"
DEPS_LIBS+=" $(pc_libs gthread-2.0)"
DEPS_LIBS+=" $(pc_libs gmodule-2.0)"
DEPS_LIBS+=" $(pc_libs freetype2)"
DEPS_LIBS+=" $(pc_libs pixman-1)"
DEPS_LIBS+=" $(pc_libs zlib)"
DEPS_LIBS+=" $(pc_libs libpng)"
DEPS_LIBS+=" $(pc_libs libffi)"
DEPS_LIBS+=" $(pc_libs libpcre2-8)"
# gettext
GETTEXT_LIB=$(brew --prefix gettext 2>/dev/null)/lib
[ -d "$GETTEXT_LIB" ] && DEPS_LIBS+=" -L$GETTEXT_LIB -lintl"

SCINTILLA_VERSION="4.4.6"
SCI_INCLUDES="-I$SCI_SRC/include -I$SCI_SRC/src -I$SCI_SRC/lexlib -I$SCI_SRC/lexers -I$SCI_SRC/cocoa"

DEFS="-DIUP_BUILD_LIBRARY -DCD_NO_OLD_INTERFACE -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE -DSCINTILLA_VERSION=\"$SCINTILLA_VERSION\" -D_USE_MATH_DEFINES -DFTGL_LIBRARY_STATIC -DMGL_STATIC_DEFINE -DMGL_SRC -DPNG_ARM_NEON_OPT=0 -DNO_FONTCONFIG -DGL_SILENCE_DEPRECATION"
CFLAGS="-fPIC -Wall -O2 -Wno-unused-function -Wno-incompatible-pointer-types -Wno-missing-braces -Wno-error=deprecated-declarations"
CXXFLAGS="-fPIC -Wall -O2 -std=c++17 -Dregister= -Wno-reorder -Wno-write-strings -Wno-misleading-indentation -Wno-error=deprecated-declarations"
OBJCFLAGS="-fPIC -Wall -O2"
OBJCXXFLAGS="-fPIC -Wall -O2 -std=c++17 -Dregister= -Wno-error=deprecated-declarations"

INCLUDES="-Iinclude -Isrc -Isrc/cocoa -Isrcimglib -Isrcgl -Isrcglcontrols -Isrcmglplot -Isrcmglplot/src -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack -Isrcscintilla $SCI_INCLUDES -Isrccd -Isrccontrols -Isrcplot -Icd/include -Icd/src -Icd/src/cairo -Icd/src/sim -Icd/src/drv -Icd/src/intcgm -Icd/src/svg -Icd/src/minizip -Iim/include -Iim/src -Iim/src/libtiff -Iim/src/libjpeg -Iim/src/libpng -Iim/src/liblzf -Iim/src/lz4 -Ibuild $DEPS_CFLAGS"

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
    $CC -c -x objective-c $OBJCFLAGS $DEFS $INCLUDES -o "$obj" "$src" || { echo "  FAILED: $src" >&2; return 1; }
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

for f in cd/src/*.c cd/src/drv/cd*.c cd/src/drv/pptx.c \
         cd/src/sim/*.c cd/src/svg/*.c cd/src/minizip/*.c; do
    [ -f "$f" ] || continue
    [[ "$f" == *cdpdf* || "$f" == *cddgn* || "$f" == *cddxf* ]] && continue
    ALL_OBJ+=" $(compile_c "$f" "cd/")"
done

# CD cgm library (in drv/)
[ -f "cd/src/drv/cgm.c" ] && ALL_OBJ+=" $(compile_c "cd/src/drv/cgm.c" "cd/")"

# CD Cairo backend
for f in cd/src/cairo/*.c cd/src/cairo/*.m; do
    [ -f "$f" ] || continue
    [[ "$f" == *win32* || "$f" == *Win32* ]] && continue
    [[ "$f" == *gtk* || "$f" == *gdk* ]] && continue
    [[ "$f" == *x11* || "$f" == *X11* ]] && continue
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
    ALL_OBJ+=" $(compile_c "$f" "cdintcgm/")"
done

# CD stub
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
_sci_cocoa_obj="$BUILD/sciw/iup_scintilla_cocoa.o"
mkdir -p "$(dirname "$_sci_cocoa_obj")"
echo "  [M+ARC] srcscintilla/iup_scintilla_cocoa.m" >&2
$CC -c -x objective-c $OBJCFLAGS -fobjc-arc $DEFS $INCLUDES \
    -o "$_sci_cocoa_obj" "srcscintilla/iup_scintilla_cocoa.m" \
    || { echo "  FAILED: srcscintilla/iup_scintilla_cocoa.m" >&2; exit 1; }
ALL_OBJ+=" $_sci_cocoa_obj"
ALL_OBJ+=" $(compile_c "srcscintilla/iup_scilladlg.c" "sciw/")"
for f in srcscintilla/iupsci_*.c; do
    [ -f "$f" ] || continue
    ALL_OBJ+=" $(compile_c "$f" "sciw/")"
done
ALL_OBJ+=" $(compile_c "srcgl/iup_glcanvas_cocoa.c" "gl/")"

# ===== Link =====
echo ""
echo "=== Linking libiup.dylib ==="
$CXX -dynamiclib -o "$OUT/libiup.dylib" $ALL_OBJ \
    $DEPS_LIBS \
    -framework Cocoa -framework OpenGL -framework QuartzCore -framework SystemConfiguration \
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
