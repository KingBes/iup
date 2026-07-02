/** \file
 * \brief Cairo Native Window Driver for macOS Cocoa
 *
 * Provides cdContextNativeWindow() using Cairo's Quartz backend
 * to render CD content directly to an NSView via CGContext.
 *
 * With Pango available, text rendering is fully supported.
 */

#include <stdlib.h>
#include <string.h>

#import <Cocoa/Cocoa.h>
#include <cairo.h>
#include <cairo-quartz.h>

#include <cd.h>
#include <cdnative.h>
#include "cdcairoctx.h"

static void cdkillcanvasNATIVEWINDOW(cdCairoCanvas* cd_canvas)
{
  NSView* view = (NSView*)cd_canvas->data;
  if (view) cd_canvas->data = NULL;
  (void)view;
}

static void cdcreatecanvasNATIVEWINDOW(cdCairoCanvas* cd_canvas, void* data)
{
  NSView* view = (NSView*)data;
  NSRect bounds;
  int w, h;

  if (!view) return;

  bounds = [view bounds];
  w = (int)bounds.size.width; if (w <= 0) w = 1;
  h = (int)bounds.size.height; if (h <= 0) h = 1;

  /* Create Cairo image surface as backing store */
  cd_canvas->surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h);
  cd_canvas->cr = cairo_create(cd_canvas->surface);
  cd_canvas->data = (void*)view;
}

static int cdactivateNATIVEWINDOW(cdCairoCanvas* cd_canvas)
{
  NSView* view = (NSView*)cd_canvas->data;
  NSRect bounds;
  int w, h;
  CGContextRef cgContext;

  if (!view) return 0;

  bounds = [view bounds];
  w = (int)bounds.size.width; if (w <= 0) w = 1;
  h = (int)bounds.size.height; if (h <= 0) h = 1;

  /* Resize backing surface if needed */
  if (cairo_image_surface_get_width(cd_canvas->surface) != w ||
      cairo_image_surface_get_height(cd_canvas->surface) != h)
  {
    cairo_destroy(cd_canvas->cr);
    cairo_surface_destroy(cd_canvas->surface);
    cd_canvas->surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h);
    cd_canvas->cr = cairo_create(cd_canvas->surface);
  }

  /* Blit to the view's CGContext via Cairo Quartz surface */
  cgContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
  if (cgContext)
  {
    cairo_surface_t* qs = cairo_quartz_surface_create_for_cg_context(cgContext, w, h);
    if (qs)
    {
      cairo_t* cr = cairo_create(qs);
      cairo_set_source_surface(cr, cd_canvas->surface, 0, 0);
      cairo_paint(cr);
      cairo_destroy(cr);
      cairo_surface_destroy(qs);
    }
  }
  return 1;
}

static int cddeactivateNATIVEWINDOW(cdCairoCanvas* cd_canvas)
{
  (void)cd_canvas;
  return 1;
}

static void cdinittableNATIVEWINDOW(cdCanvas* canvas)
{
  cdcairoInitTable(canvas);
}

static cdContext cdNativeWindowContext =
{
  CD_CAP_ALL & ~(CD_CAP_PLAY | CD_CAP_YAXIS | CD_CAP_FPRINT),
  CD_CTX_WINDOW,
  cdcreatecanvasNATIVEWINDOW,
  cdinittableNATIVEWINDOW,
  NULL,
  cdactivateNATIVEWINDOW,
  cddeactivateNATIVEWINDOW
};

cdContext* cdContextNativeWindow(void)
{
  return &cdNativeWindowContext;
}
