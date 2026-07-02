/*
 * FTGL Real Wrapper for macOS
 *
 * Wraps the real FTGL C++ library to implement the C API
 * declared in build/FTGL/ftgl.h.  Replaces ftgl_stub.cpp
 * when FTGL is built from source.
 *
 * Note: We forward-declare FTGLfont to avoid include-path
 * conflicts with the real FTGL's <FTGL/ftgl.h> header.
 */
#include <FTGL/FTFont.h>
#include <FTGL/FTTextureFont.h>
#include <FTGL/FTPoint.h>

struct _FTGLfont;
typedef struct _FTGLfont FTGLfont;

extern "C" {

/* ---- Core font functions ---- */

FTGLfont* ftglCreateTextureFont(const char* filename)
{
    if (!filename || !*filename)
        return nullptr;
    return reinterpret_cast<FTGLfont*>(new FTTextureFont(filename));
}

int ftglSetFontFaceSize(FTGLfont* font, int size, int res)
{
    if (!font) return 0;
    return reinterpret_cast<FTFont*>(font)->FaceSize(size, res) ? 1 : 0;
}

void ftglDestroyFont(FTGLfont* font)
{
    if (font)
        delete reinterpret_cast<FTFont*>(font);
}

/* ---- Measurement ---- */

float ftglGetFontLineHeight(FTGLfont* font)
{
    if (!font) return 0.0f;
    return reinterpret_cast<FTFont*>(font)->LineHeight();
}

float ftglGetFontAdvance(FTGLfont* font, const char* string)
{
    if (!font || !string) return 0.0f;
    return reinterpret_cast<FTFont*>(font)->Advance(string);
}

float ftglGetFontAscender(FTGLfont* font)
{
    if (!font) return 0.0f;
    return reinterpret_cast<FTFont*>(font)->Ascender();
}

float ftglGetFontDescender(FTGLfont* font)
{
    if (!font) return 0.0f;
    return reinterpret_cast<FTFont*>(font)->Descender();
}

/* ---- Rendering ---- */

void ftglRenderFont(FTGLfont* font, const char* string, int mode)
{
    if (!font || !string) return;
    reinterpret_cast<FTFont*>(font)->Render(string, -1,
        FTPoint(), FTPoint(), mode);
}

/* ---- Additional functions ---- */

float ftglGetFontMaxWidth(FTGLfont* font)
{
    if (!font) return 0.0f;
    return reinterpret_cast<FTFont*>(font)->Advance("M");
}

void ftglSetNearestFilter(FTGLfont* font, int nearest)
{
    (void)font;
    (void)nearest;
    /* Texture filtering is typically set during font creation in FTGL */
}

}
