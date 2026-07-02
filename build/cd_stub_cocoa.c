/*
 * CD macOS Stub
 *
 * The only remaining CD stub is cdContextClipboard because
 * CD's Cairo backend does not provide a clipboard context.
 * All other contexts (NativeWindow, DBuffer, GL, Image, SVG,
 * PS, etc.) are provided by real Cairo + cdgl implementations.
 */

#include <stddef.h>
#include <cd.h>
#include <cdclipbd.h>

cdContext* cdContextClipboard(void)
{
  return NULL;
}
