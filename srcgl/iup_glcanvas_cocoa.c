/*
 * GL Canvas Cocoa Stub
 *
 * Provides platform stubs for macOS/Cocoa builds.
 */

#include "iup.h"
#include "iup_class.h"
#include "iupgl.h"

void iupdrvGlCanvasInitClass(Iclass* ic)
{
  (void)ic;
}

void IupGLMakeCurrent(Ihandle* ih)
{
  (void)ih;
}

int IupGLIsCurrent(Ihandle* ih)
{
  (void)ih;
  return 0;
}

void IupGLSwapBuffers(Ihandle* ih)
{
  (void)ih;
}
