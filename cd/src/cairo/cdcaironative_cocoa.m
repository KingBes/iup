/** \file
 * \brief Cairo Native Window Driver for macOS Cocoa
 *
 * Provides cdContextNativeWindow() using Cairo's Quartz backend
 * to render CD content directly to an NSView via CGContext.
 */

#include <stdlib.h>
#include <string.h>

#import <Cocoa/Cocoa.h>
#include <cairo.h>
#include <cairo-quartz.h>

#include "cd.h"
#include "cd_private.h"
#include "cdnative.h"
#include "cdcairoctx.h"

static cairo_t* cdcairoNativeCreateContext(cdCanvas* canvas, NSView* view)
{
  int w = canvas->w;
  int h = canvas->h;
  CGContextRef cgContext;

  if (w <= 0) w = 1;
  if (h <= 0) h = 1;

  cgContext = (CGContextRef)[[NSGraphicsContext currentContext] CGContext];
  if (cgContext)
  {
    cairo_surface_t* surface = cairo_quartz_surface_create_for_cg_context(cgContext, w, h);
    if (surface)
    {
      cairo_t* cr = cairo_create(surface);
      cairo_surface_destroy(surface);
      return cr;
    }
  }

  /* Fallback: image surface (won't display on screen) */
  return cairo_create(cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h));
}

static int cdactivate(cdCtxCanvas *ctxcanvas)
{
  cdCanvas* canvas = ctxcanvas->canvas;
  NSView* view = (NSView*)ctxcanvas->window;
  int old_w = canvas->w;
  int old_h = canvas->h;

  if (!view) return CD_ERROR;

  NSRect bounds = [view bounds];
  canvas->w = (int)bounds.size.width;
  canvas->h = (int)bounds.size.height;
  if (canvas->w <= 0) canvas->w = 1;
  if (canvas->h <= 0) canvas->h = 1;

  canvas->w_mm = ((double)canvas->w) / canvas->xres;
  canvas->h_mm = ((double)canvas->h) / canvas->yres;

  if (old_w != canvas->w || old_h != canvas->h)
  {
    cairo_destroy(ctxcanvas->cr);
    ctxcanvas->cr = cdcairoNativeCreateContext(canvas, view);

    ctxcanvas->last_source = -1;

    cairo_save(ctxcanvas->cr);
    cairo_set_operator(ctxcanvas->cr, CAIRO_OPERATOR_OVER);

    canvas->cxForeground(ctxcanvas, canvas->foreground);
    canvas->cxLineStyle(ctxcanvas, canvas->line_style);
    canvas->cxLineWidth(ctxcanvas, canvas->line_width);
    canvas->cxLineCap(ctxcanvas, canvas->line_cap);
    canvas->cxLineJoin(ctxcanvas, canvas->line_join);
    canvas->cxInteriorStyle(ctxcanvas, canvas->interior_style);
    if (canvas->clip_mode != CD_CLIPOFF) canvas->cxClip(ctxcanvas, canvas->clip_mode);
    if (canvas->use_matrix) canvas->cxTransform(ctxcanvas, canvas->matrix);
  }

  return CD_OK;
}

static void cdcreatecanvas(cdCanvas* canvas, void *data)
{
  cdCtxCanvas *ctxcanvas;
  cairo_t* cr;
  NSView* view = (NSView*)data;

  if (!view) return;

  NSRect bounds = [view bounds];
  canvas->w = (int)bounds.size.width;
  canvas->h = (int)bounds.size.height;
  if (canvas->w <= 0) canvas->w = 1;
  if (canvas->h <= 0) canvas->h = 1;

  /* Approximate screen resolution */
  canvas->xres = 96.0 / 25.4;  /* ~3.78 pixels/mm */
  canvas->yres = canvas->xres;
  canvas->w_mm = ((double)canvas->w) / canvas->xres;
  canvas->h_mm = ((double)canvas->h) / canvas->yres;

  cr = cdcairoNativeCreateContext(canvas, view);
  if (!cr) return;

  ctxcanvas = cdcairoCreateCanvas(canvas, cr);
  if (!ctxcanvas) return;

  ctxcanvas->window = view;
}

static void cdinittable(cdCanvas* canvas)
{
  cdcairoInitTable(canvas);
  canvas->cxKillCanvas = cdcairoKillCanvas;
  canvas->cxActivate = cdactivate;
}

static cdContext cdNativeWindowContext =
{
  CD_CAP_ALL & ~(CD_CAP_PLAY | CD_CAP_YAXIS | CD_CAP_REGION | CD_CAP_WRITEMODE | CD_CAP_PALETTE),
  CD_CTX_WINDOW,
  cdcreatecanvas,
  cdinittable,
  NULL,
  NULL,
};

cdContext* cdContextNativeWindow(void)
{
  return &cdNativeWindowContext;
}
