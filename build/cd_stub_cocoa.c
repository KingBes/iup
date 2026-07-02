/*
 * CD macOS Stub
 *
 * Stubs for CD contexts that have no macOS implementation:
 * - cdContextClipboard: not provided by Cairo backend
 * - cdContextCairoPrinter: only available on Win32/GTK
 */

#include <stddef.h>
#include <cd.h>
#include <cdclipbd.h>

cdContext* cdContextClipboard(void)    { return NULL; }
cdContext* cdContextCairoPrinter(void) { return NULL; }
