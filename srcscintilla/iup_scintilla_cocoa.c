/*
 * Scintilla Cocoa Stub
 *
 * Provides platform stubs for macOS/Cocoa builds.
 * Scintilla 3.11.2 has no Cocoa backend (only gtk/ and win32/),
 * so the Scintilla editor control is non-functional on macOS.
 */

#include "Scintilla.h"

#include "iup.h"
#include "iup_class.h"
#include "iupsci.h"

void iupdrvScintillaReleaseMethod(Iclass* ic)
{
  (void)ic;
}

void iupdrvScintillaRefreshCaret(Ihandle* ih)
{
  (void)ih;
}

int iupdrvScintillaGetBorder(void)
{
  return 2 * 5;
}

void iupdrvScintillaOpen(void)
{
}

int iupdrvScintillaPrintAttrib(Ihandle* ih, const char* value)
{
  (void)ih;
  (void)value;
  return 0;
}

sptr_t IupScintillaSendMessage(Ihandle* ih, unsigned int iMessage, uptr_t wParam, sptr_t lParam)
{
  (void)ih;
  (void)iMessage;
  (void)wParam;
  (void)lParam;
  return 0;
}

int idrvScintillaMap(Ihandle* ih)
{
  (void)ih;
  return 0;
}
