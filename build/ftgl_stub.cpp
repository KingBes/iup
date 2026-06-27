/* Stub implementations for FTGL functions not available in MSYS2 MinGW64 ftgl */
#include <FTGL/ftgl.h>

extern "C" {
float ftglGetFontMaxWidth(void* font) {
    (void)font;
    return 0.0f;
}

void ftglSetNearestFilter(void* font, int nearest) {
    (void)font;
    (void)nearest;
}
}
