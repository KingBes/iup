/*
 * Self-contained FTGL C API implementation using freetype2 + OpenGL.
 *
 * No external FTGL library needed!  All font loading, glyph rendering,
 * and texture management is done directly via freetype2 and OpenGL.
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_GLYPH_H

#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#include "FTGL/ftgl.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* Per-font state */
struct iupFTGLfont {
    FT_Face    face;
    int        font_size;
    int        resolution;
    int        loaded;          /* has at least one glyph been rendered? */
    GLuint     tex_id;          /* shared texture for glyphs */
    int        tex_w, tex_h;    /* texture dimensions */
    int        cursor_x, cursor_y;
    int        max_row_h;
    int        nearest_filter;

    /* Glyph cache: simple linear lookup */
    struct {
        unsigned int index;
        float tx0, ty0, tx1, ty1;  /* texture coords */
        float w, h;                 /* glyph size in pixels */
        float advance_x;
        float bearing_x, bearing_y;
        int    stored;
    } glyph_cache[256];
};

/* ---- Internal helpers ---- */

static FT_Library g_ftlib = 0;

static void init_freetype(void)
{
    if (!g_ftlib)
        FT_Init_FreeType(&g_ftlib);
}

static int nearest_power2(int n)
{
    int p = 1;
    while (p < n) p <<= 1;
    return p > 4096 ? 4096 : p;
}

static int load_glyph(struct iupFTGLfont* f, unsigned int index)
{
    if (f->glyph_cache[index & 0xFF].stored &&
        f->glyph_cache[index & 0xFF].index == index)
        return 1;

    if (FT_Load_Glyph(f->face, index, FT_LOAD_DEFAULT))
        return 0;
    if (FT_Render_Glyph(f->face->glyph, FT_RENDER_MODE_NORMAL))
        return 0;

    FT_Bitmap* bmp = &f->face->glyph->bitmap;
    int gw = bmp->width;
    int gh = bmp->rows;
    if (gw == 0 || gh == 0) {
        /* Space or empty glyph */
        f->glyph_cache[index & 0xFF].index = index;
        f->glyph_cache[index & 0xFF].w = 0;
        f->glyph_cache[index & 0xFF].h = 0;
        f->glyph_cache[index & 0xFF].advance_x = f->face->glyph->advance.x / 64.0f;
        f->glyph_cache[index & 0xFF].bearing_x = f->face->glyph->bitmap_left * 1.0f;
        f->glyph_cache[index & 0xFF].bearing_y = f->face->glyph->bitmap_top * 1.0f;
        f->glyph_cache[index & 0xFF].stored = 1;
        return 1;
    }

    if (!f->tex_id) {
        f->tex_w = nearest_power2(gw * 16);
        f->tex_h = nearest_power2(gh * 16);
        glGenTextures(1, &f->tex_id);
        glBindTexture(GL_TEXTURE_2D, f->tex_id);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
            f->nearest_filter ? GL_NEAREST : GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
            f->nearest_filter ? GL_NEAREST : GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, f->tex_w, f->tex_h,
            0, GL_ALPHA, GL_UNSIGNED_BYTE, NULL);
    }

    if (f->cursor_x + gw + 2 > f->tex_w) {
        f->cursor_x = 0;
        f->cursor_y += f->max_row_h + 2;
        f->max_row_h = 0;
    }
    if (f->cursor_y + gh + 2 > f->tex_h) {
        f->cursor_x = f->cursor_y = 0;
        f->max_row_h = 0;
    }

    int x = f->cursor_x, y = f->cursor_y;

    glBindTexture(GL_TEXTURE_2D, f->tex_id);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, gw, gh,
        GL_ALPHA, GL_UNSIGNED_BYTE, bmp->buffer);

    int slot = index & 0xFF;
    f->glyph_cache[slot].index = index;
    f->glyph_cache[slot].tx0 = (float)x / f->tex_w;
    f->glyph_cache[slot].ty0 = (float)y / f->tex_h;
    f->glyph_cache[slot].tx1 = (float)(x + gw) / f->tex_w;
    f->glyph_cache[slot].ty1 = (float)(y + gh) / f->tex_h;
    f->glyph_cache[slot].w = (float)gw;
    f->glyph_cache[slot].h = (float)gh;
    f->glyph_cache[slot].advance_x = f->face->glyph->advance.x / 64.0f;
    f->glyph_cache[slot].bearing_x = f->face->glyph->bitmap_left * 1.0f;
    f->glyph_cache[slot].bearing_y = f->face->glyph->bitmap_top * 1.0f;
    f->glyph_cache[slot].stored = 1;

    f->cursor_x += gw + 2;
    if (gh > f->max_row_h) f->max_row_h = gh;

    return 1;
}

/* ---- Public C API ---- */

extern "C" {

FTGLfont* ftglCreateTextureFont(const char* filename)
{
    init_freetype();
    if (!filename || !*filename) return nullptr;

    struct iupFTGLfont* f = (struct iupFTGLfont*)calloc(1, sizeof(*f));
    if (!f) return nullptr;

    if (FT_New_Face(g_ftlib, filename, 0, &f->face)) {
        /* Try with ttf extension */
        char alt[2048];
        snprintf(alt, sizeof(alt), "%s.ttf", filename);
        if (FT_New_Face(g_ftlib, alt, 0, &f->face)) {
            free(f);
            return nullptr;
        }
    }

    f->nearest_filter = 1;  /* crisp default */
    memset(f->glyph_cache, 0, sizeof(f->glyph_cache));
    return (FTGLfont*)f;
}

int ftglSetFontFaceSize(FTGLfont* font, int size, int res)
{
    if (!font) return 0;
    struct iupFTGLfont* f = (struct iupFTGLfont*)font;
    f->font_size = size;
    f->resolution = res;
    return FT_Set_Char_Size(f->face, 0, size * 64, res, res) ? 0 : 1;
}

void ftglDestroyFont(FTGLfont* font)
{
    if (!font) return;
    struct iupFTGLfont* f = (struct iupFTGLfont*)font;
    if (f->tex_id) glDeleteTextures(1, &f->tex_id);
    if (f->face) FT_Done_Face(f->face);
    free(f);
}

float ftglGetFontLineHeight(FTGLfont* font)
{
    if (!font) return 0.0f;
    return ((struct iupFTGLfont*)font)->face->size->metrics.height / 64.0f;
}

float ftglGetFontAdvance(FTGLfont* font, const char* string)
{
    if (!font || !string) return 0.0f;
    struct iupFTGLfont* f = (struct iupFTGLfont*)font;
    float advance = 0;
    for (const char* p = string; *p; p++) {
        unsigned int idx = FT_Get_Char_Index(f->face, *p);
        if (load_glyph(f, idx))
            advance += f->glyph_cache[idx & 0xFF].advance_x;
    }
    return advance;
}

float ftglGetFontAscender(FTGLfont* font)
{
    if (!font) return 0.0f;
    return ((struct iupFTGLfont*)font)->face->size->metrics.ascender / 64.0f;
}

float ftglGetFontDescender(FTGLfont* font)
{
    if (!font) return 0.0f;
    return ((struct iupFTGLfont*)font)->face->size->metrics.descender / 64.0f;
}

float ftglGetFontMaxWidth(FTGLfont* font)
{
    if (!font) return 0.0f;
    struct iupFTGLfont* f = (struct iupFTGLfont*)font;
    unsigned int idx = FT_Get_Char_Index(f->face, 'M');
    return load_glyph(f, idx) ? f->glyph_cache[idx & 0xFF].advance_x : 0.0f;
}

void ftglSetNearestFilter(FTGLfont* font, int nearest)
{
    if (!font) return;
    struct iupFTGLfont* f = (struct iupFTGLfont*)font;
    if (f->nearest_filter != nearest) {
        f->nearest_filter = nearest;
        if (f->tex_id) {
            glBindTexture(GL_TEXTURE_2D, f->tex_id);
            GLint filter = nearest ? GL_NEAREST : GL_LINEAR;
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
        }
    }
}

void ftglRenderFont(FTGLfont* font, const char* string, int mode)
{
    (void)mode;
    if (!font || !string || !*string) return;

    struct iupFTGLfont* f = (struct iupFTGLfont*)font;
    if (!f->tex_id) return;

    float pen_x = 0.0f, pen_y = 0.0f;

    glPushAttrib(GL_ENABLE_BIT | GL_TEXTURE_BIT | GL_COLOR_BUFFER_BIT);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBindTexture(GL_TEXTURE_2D, f->tex_id);

    for (const char* p = string; *p; p++) {
        unsigned int idx = FT_Get_Char_Index(f->face, *p);
        if (!load_glyph(f, idx)) continue;

        int slot = idx & 0xFF;
        float w = f->glyph_cache[slot].w;
        float h = f->glyph_cache[slot].h;
        if (w == 0 || h == 0) {
            pen_x += f->glyph_cache[slot].advance_x;
            continue;
        }

        float bx = f->glyph_cache[slot].bearing_x;
        float by = f->glyph_cache[slot].bearing_y;

        float x0 = pen_x + bx;
        float y0 = pen_y + by - h;
        float x1 = x0 + w;
        float y1 = y0 + h;

        glBegin(GL_QUADS);
        glTexCoord2f(f->glyph_cache[slot].tx0, f->glyph_cache[slot].ty1);
        glVertex2f(x0, y0);
        glTexCoord2f(f->glyph_cache[slot].tx1, f->glyph_cache[slot].ty1);
        glVertex2f(x1, y0);
        glTexCoord2f(f->glyph_cache[slot].tx1, f->glyph_cache[slot].ty0);
        glVertex2f(x1, y1);
        glTexCoord2f(f->glyph_cache[slot].tx0, f->glyph_cache[slot].ty0);
        glVertex2f(x0, y1);
        glEnd();

        pen_x += f->glyph_cache[slot].advance_x;
    }

    glPopAttrib();
}

} /* extern "C" */
