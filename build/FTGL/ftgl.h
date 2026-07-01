/*
 * Minimal FTGL stub header for MSVC builds.
 * Provides type declarations and inline stubs so that IUP's GL font
 * code compiles without the real FTGL library installed.
 */
#ifndef FTGL_H_STUB_H
#define FTGL_H_STUB_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void FTGLfont;

#define FTGL_RENDER_ALL 0
#define FTGL_RENDER_FRONT 1
#define FTGL_RENDER_BACK 2
#define FTGL_RENDER_SIDE 3

FTGLfont* ftglCreateTextureFont(const char* filename);
int       ftglSetFontFaceSize(FTGLfont* font, int size, int res);
float     ftglGetFontLineHeight(FTGLfont* font);
float     ftglGetFontAdvance(FTGLfont* font, const char* string);
float     ftglGetFontAscender(FTGLfont* font);
float     ftglGetFontDescender(FTGLfont* font);
void      ftglRenderFont(FTGLfont* font, const char* string, int mode);
void      ftglDestroyFont(FTGLfont* font);

float     ftglGetFontMaxWidth(void* font);
void      ftglSetNearestFilter(void* font, int nearest);

#ifdef __cplusplus
}
#endif

#endif /* FTGL_H_STUB_H */
