/*
 * IUP Cocoa String Utilities
 *
 * Provides platform-specific string conversion for macOS/Cocoa.
 * On macOS, UTF-8 is the native encoding, so the conversion
 * is straightforward.
 */

#include <stdlib.h>
#include <string.h>

#include "iup.h"
#include "iup_str.h"

static char* iupCocoaCheckUtf8Buffer(char* utf8_buffer, int *utf8_buffer_max, int len)
{
  if (!utf8_buffer)
  {
    utf8_buffer = malloc(len + 1);
    *utf8_buffer_max = len;
  }
  else if (*utf8_buffer_max < len)
  {
    utf8_buffer = realloc(utf8_buffer, len + 1);
    *utf8_buffer_max = len;
  }
  return utf8_buffer;
}

static char* iupStrCopyToUtf8Buffer(const char* str, int len, char* utf8_buffer, int *utf8_buffer_max)
{
  utf8_buffer = iupCocoaCheckUtf8Buffer(utf8_buffer, utf8_buffer_max, len);
  memcpy(utf8_buffer, str, len);
  utf8_buffer[len] = 0;
  return utf8_buffer;
}

/* Used in glfont */
IUP_SDK_API char* iupStrConvertToUTF8(const char* str, int len, char* utf8_buffer, int *utf8_buffer_max, int utf8mode)
{
  /* On macOS, Cocoa uses UTF-8 natively. Most strings passed to this
     function are already UTF-8 or ASCII. Just copy to the buffer. */
  (void)utf8mode;
  return iupStrCopyToUtf8Buffer(str, len, utf8_buffer, utf8_buffer_max);
}
