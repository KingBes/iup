/*
 * CD macOS Stubs
 *
 * CD (Canvas Draw) has no native macOS backend. We provide stubs
 * for the platform-specific CD symbols so the library can link.
 * CD-based functionality (plotting, vector drawing) will be
 * non-functional on macOS unless a full CD backend is provided.
 */

#include <cd.h>
#include <cdnative.h>
#include <cddbuf.h>
#include <cdclipbd.h>
#include <cdcgm.h>
#include <cdgl.h>
#include <cd_private.h>

int cdBaseDriver(void)
{
  return 0;
}

cdContext* cdContextNativeWindow(void)
{
  return NULL;
}

cdContext* cdContextDBuffer(void)
{
  return NULL;
}

cdContext* cdContextClipboard(void)
{
  return NULL;
}

cdContext* cdContextCGM(void)
{
  return NULL;
}

cdContext* cdContextGL(void)
{
  return NULL;
}
