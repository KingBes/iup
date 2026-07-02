/*
 * Scintilla Cocoa Stub
 *
 * Provides platform stubs for macOS/Cocoa builds.
 */

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
