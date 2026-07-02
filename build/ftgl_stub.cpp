/* Stub implementations for FTGL functions — no ftgl header dependency */
struct _FTGLfont;
typedef struct _FTGLfont FTGLfont;

extern "C" {

/* Core font functions */
FTGLfont* ftglCreateTextureFont(const char* filename) {
    (void)filename;
    return nullptr;
}

int ftglSetFontFaceSize(FTGLfont* font, int size, int res) {
    (void)font; (void)size; (void)res;
    return 0;
}

void ftglDestroyFont(FTGLfont* font) {
    (void)font;
}

/* Measurement functions */
float ftglGetFontLineHeight(FTGLfont* font) {
    (void)font;
    return 0.0f;
}

float ftglGetFontAdvance(FTGLfont* font, const char* string) {
    (void)font; (void)string;
    return 0.0f;
}

float ftglGetFontAscender(FTGLfont* font) {
    (void)font;
    return 0.0f;
}

float ftglGetFontDescender(FTGLfont* font) {
    (void)font;
    return 0.0f;
}

/* Render function */
void ftglRenderFont(FTGLfont* font, const char* string, int mode) {
    (void)font; (void)string; (void)mode;
}

/* Additional functions used by IUP */
float ftglGetFontMaxWidth(FTGLfont* font) {
    (void)font;
    return 0.0f;
}

void ftglSetNearestFilter(FTGLfont* font, int nearest) {
    (void)font; (void)nearest;
}

}
