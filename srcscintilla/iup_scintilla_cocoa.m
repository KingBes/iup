/*
 * IUP Scintilla Cocoa Driver
 *
 * Real Scintilla integration on macOS/Cocoa using
 * Scintilla 4.4.6's Cocoa backend (ScintillaView).
 */

#include <stdlib.h>
#include <string.h>

#include "Scintilla.h"
#include "SciLexer.h"

#import <Cocoa/Cocoa.h>
#import "ScintillaView.h"

#include "iup.h"
#include "iup_class.h"
#include "iup_object.h"
#include "iup_attrib.h"
#include "iup_str.h"
#include "iupsci.h"

void iupdrvScintillaOpen(void) {}

int idrvScintillaMap(Ihandle* ih)
{
  NSView* parent = (NSView*)IupGetAttribute(ih, "HWND");
  int w = ih->currentwidth;
  int h = ih->currentheight;
  if (w <= 0) w = 100;
  if (h <= 0) h = 100;

  NSRect frame = NSMakeRect(0, 0, w, h);
  ScintillaView* sciView = [[ScintillaView alloc] initWithFrame:frame];
  if (!sciView) return 0;

  if (parent) [parent addSubview:sciView];
  ih->handle = (InativeHandle*)sciView;
  return 1;
}

void iupdrvScintillaReleaseMethod(Iclass* ic) { (void)ic; }
void iupdrvScintillaRefreshCaret(Ihandle* ih) { (void)ih; }
int  iupdrvScintillaGetBorder(void) { return 2 * 5; }
int  iupdrvScintillaPrintAttrib(Ihandle* ih, const char* value) { (void)ih; (void)value; return 0; }

sptr_t IupScintillaSendMessage(Ihandle* ih, unsigned int iMessage,
                                uptr_t wParam, sptr_t lParam)
{
  ScintillaView* sciView = (ScintillaView*)ih->handle;
  if (!sciView) return 0;
  return [sciView message:iMessage wParam:wParam lParam:lParam];
}
