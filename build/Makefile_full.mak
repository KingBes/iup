# ===================================================================
#  IUP Full Single DLL Build - MinGW64/MSYS2
#  包含: IUP + CD + IM + cdgl + cdcontextplus + Controls + Scintilla + 所有子模块
# ===================================================================
#  运行: mingw32-make -f build/Makefile_full.mak
# ===================================================================

CC       = gcc
CXX      = g++
WINDRES  = windres
OUTPUT   = build/iup
OBJDIR   = build/obj

# ===================================================================
# 编译定义
# ===================================================================
DEFINES  = -DIUP_BUILD_LIBRARY -DIUP_DLL \
           -D_WIN32_WINNT=0x0601 -DWINVER=0x0601 -D_WIN32_IE=0x0900 \
           -DCOBJMACROS -DUSE_NEW_DRAW \
           -DCD_NO_OLD_INTERFACE -D_NOTREEVIEW \
           -DFTGL_LIBRARY_STATIC -DMGL_STATIC_DEFINE -DMGL_SRC \
           -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE \
           -D_WIN32 -DWIN32 -DDISABLE_D2D -DNO_CXX11_REGEX \
           -DIUP_IMGLIB_LARGE_ICON -DOSC_HOST_LITTLE_ENDIAN \
           -DSCINTILLA_VERSION=\"3.11.2\" -D_USE_MATH_DEFINES

CFLAGS   = -fpermissive -Wall -O2 -m64 -pipe $(DEFINES) \
           -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast \
           -Wno-unused-function -Wno-missing-braces \
           -Wno-incompatible-pointer-types
CXXFLAGS = -Wall -O2 -m64 -pipe -std=c++11 $(DEFINES) \
           -Wno-int-to-pointer-cast -Wno-unused-function \
           -Wno-missing-braces -Wno-class-memaccess -Wno-reorder \
           -Wno-write-strings -Wno-stringop-truncation -Wno-unknown-pragmas \
           -Wno-misleading-indentation
LDFLAGS  = -shared -static-libgcc -static-libstdc++ -m64 \
           -Wl,--export-all-symbols,--out-implib=$(OUTPUT).a

SYSLIBS  = -lkernel32 -luser32 -lgdi32 -lcomdlg32 -ladvapi32 \
           -lshell32 -lole32 -loleaut32 -luuid -lcomctl32 \
           -lmsimg32 -limm32 -lws2_32 -lwinmm \
           -lshlwapi -lgdiplus -lwinspool

# 强制静态链接 MSYS2 库 (保留 __declspec(dllexport) 导出)
EXTLIBS  = -Wl,-Bstatic \
           -lfreetype -lftgl -lz -lbz2 -lpng16 -lharfbuzz \
           -lgraphite2 -lglib-2.0 -lpcre2-8 -lintl -liconv \
           -lbrotlidec -lbrotlicommon -lwinpthread \
           -Wl,-Bdynamic

# 系统库 (排在静态库之后解析传递依赖)
SYSLIBS_POST = -lgdi32 -lopengl32 -lglu32 -ldwrite -lusp10 -lrpcrt4

# ===================================================================
# 头文件路径
# ===================================================================
INCLUDES = -Iinclude -Isrc -Isrc/win -Isrc/win/wdl \
           -Isrcimglib -Isrcgl -Isrcglcontrols \
           -Isrcmglplot -Isrcmglplot/src \
           -Isrctuio -Isrctuio/tuio -Isrctuio/oscpack \
           -Isrcscintilla \
           -Isrcscintilla/scintilla3112/include \
           -Isrcscintilla/scintilla3112/src \
           -Isrcscintilla/scintilla3112/lexlib \
           -Isrcscintilla/scintilla3112/win32 \
           -Isrcscintilla/scintilla3112/lexers \
           -Isrcole \
           -Isrccd -Isrccontrols \
           -Icd/include -Icd/src -Icd/src/win32 -Icd/src/drv \
           -Icd/src/intcgm -Icd/src/sim -Icd/src/svg -Icd/src/minizip \
           -Icd/src/gdiplus \
           -Iim/include -Iim/src -Iim/src/libtiff -Iim/src/libjpeg \
           -Iim/src/libpng -Iim/src/liblzf -Iim/src/lz4 \
           -I$(MSYSTEM_PREFIX)/include/freetype2

# ===================================================================
# === IUP 核心 ===
# ===================================================================
IUP_CORE = \
	src/iup.c src/iup_attrib.c src/iup_array.c src/iup_assert.c \
	src/iup_backgroundbox.c src/iup_box.c src/iup_button.c \
	src/iup_callback.c src/iup_canvas.c src/iup_cbox.c \
	src/iup_childtree.c src/iup_class.c src/iup_classattrib.c \
	src/iup_classbase.c src/iup_classinfo.c src/iup_colorbar.c \
	src/iup_colorbrowser.c src/iup_colordlg.c src/iup_colorhsi.c \
	src/iup_config.c src/iup_detachbox.c \
	src/iup_dial.c src/iup_dialog.c src/iup_dlglist.c src/iup_draw.c \
	src/iup_dropbutton.c src/iup_elempropdlg.c src/iup_expander.c \
	src/iup_export.c src/iup_filedlg.c src/iup_fill.c \
	src/iup_flatbutton.c src/iup_flatframe.c src/iup_flatlabel.c \
	src/iup_flatlist.c src/iup_flatscrollbar.c src/iup_flatscrollbox.c \
	src/iup_flatseparator.c src/iup_flattabs.c src/iup_flattoggle.c \
	src/iup_flattree.c src/iup_flatval.c src/iup_focus.c src/iup_font.c \
	src/iup_fontdlg.c src/iup_frame.c src/iup_func.c src/iup_gauge.c \
	src/iup_getparam.c src/iup_globalattrib.c src/iup_globalsdlg.c \
	src/iup_gridbox.c src/iup_hbox.c src/iup_image.c src/iup_key.c \
	src/iup_label.c src/iup_layout.c src/iup_layoutdlg.c \
	src/iup_ledlex.c src/iup_ledparse.c src/iup_linefile.c \
	src/iup_link.c src/iup_list.c src/iup_loop.c src/iup_mask.c \
	src/iup_maskmatch.c src/iup_maskparse.c src/iup_menu.c \
	src/iup_messagedlg.c src/iup_multibox.c src/iup_names.c \
	src/iup_normalizer.c src/iup_object.c src/iup_open.c \
	src/iup_predialogs.c src/iup_progressbar.c src/iup_progressdlg.c \
	src/iup_radio.c src/iup_recplay.c src/iup_register.c \
	src/iup_sbox.c src/iup_scanf.c src/iup_scrollbox.c src/iup_show.c \
	src/iup_space.c src/iup_spin.c src/iup_split.c src/iup_str.c \
	src/iup_strmessage.c src/iup_table.c src/iup_tabs.c src/iup_text.c \
	src/iup_thread.c src/iup_timer.c src/iup_toggle.c src/iup_tree.c \
	src/iup_user.c src/iup_val.c src/iup_vbox.c src/iup_zbox.c \
	src/iup_animatedlabel.c

IUP_WIN = \
	src/win/iupwin_common.c src/win/iupwin_brush.c \
	src/win/iupwin_focus.c src/win/iupwin_font.c \
	src/win/iupwin_globalattrib.c src/win/iupwin_handle.c \
	src/win/iupwin_key.c src/win/iupwin_str.c \
	src/win/iupwin_loop.c src/win/iupwin_open.c \
	src/win/iupwin_tips.c src/win/iupwin_info.c \
	src/win/iupwin_dialog.c src/win/iupwin_messagedlg.c \
	src/win/iupwin_timer.c src/win/iupwin_image.c \
	src/win/iupwin_label.c src/win/iupwin_canvas.c \
	src/win/iupwin_frame.c src/win/iupwin_fontdlg.c \
	src/win/iupwin_filedlg.c src/win/iupwin_dragdrop.c \
	src/win/iupwin_button.c src/win/iupwin_draw.c \
	src/win/iupwin_toggle.c src/win/iupwin_clipboard.c \
	src/win/iupwin_progressbar.c src/win/iupwin_text.c \
	src/win/iupwin_val.c src/win/iupwin_touch.c \
	src/win/iupwin_tabs.c src/win/iupwin_menu.c \
	src/win/iupwin_list.c src/win/iupwin_tree.c \
	src/win/iupwin_calendar.c src/win/iupwin_datepick.c \
	src/win/iupwin_draw_wdl.c src/win/iupwin_draw_gdi.c \
	src/win/iupwin_image_wdl.c \
	src/win/iupwindows_main.c src/win/iupwindows_help.c \
	src/win/iupwindows_info.c

WDL = \
	src/win/wdl/backend-d2d.c src/win/wdl/backend-dwrite.c \
	src/win/wdl/backend-gdix.c src/win/wdl/backend-wic.c \
	src/win/wdl/bitblt.c src/win/wdl/brush.c \
	src/win/wdl/cachedimage.c src/win/wdl/canvas.c \
	src/win/wdl/draw.c src/win/wdl/fill.c src/win/wdl/font.c \
	src/win/wdl/image.c src/win/wdl/init.c src/win/wdl/memstream.c \
	src/win/wdl/misc.c src/win/wdl/path.c src/win/wdl/string.c \
	src/win/wdl/strokestyle.c

# ===================================================================
# === IUP 子模块 ===
# ===================================================================
IMGLIB = \
	srcimglib/iup_image_library.c srcimglib/iup_imglib_circleprogress.c \
	srcimglib/iup_imglib_basewin32x32.c srcimglib/iup_imglib_logos48x48.c \
	srcimglib/iup_imglib_logos32x32.c srcimglib/iup_imglib_iconswin48x48.c

IUPGL = srcgl/iup_glcanvas.c srcgl/iup_glcanvas_win.c

GLCONTROLS = \
	srcglcontrols/iup_glcontrols.c srcglcontrols/iup_glcanvasbox.c \
	srcglcontrols/iup_glsubcanvas.c srcglcontrols/iup_gllabel.c \
	srcglcontrols/iup_glimage.c srcglcontrols/iup_glfont.c \
	srcglcontrols/iup_gldraw.c srcglcontrols/iup_glicon.c \
	srcglcontrols/iup_glseparator.c srcglcontrols/iup_glbutton.c \
	srcglcontrols/iup_gltoggle.c srcglcontrols/iup_gllink.c \
	srcglcontrols/iup_glprogressbar.c srcglcontrols/iup_glval.c \
	srcglcontrols/iup_glframe.c srcglcontrols/iup_glexpander.c \
	srcglcontrols/iup_glscrollbars.c srcglcontrols/iup_glscrollbox.c \
	srcglcontrols/iup_glsizebox.c srcglcontrols/iup_gltext.c

# IUP-CD 桥接
IUPCD = srccd/iup_cd.c srccd/iup_cdutil.c srccd/iup_draw_cd.c

# IUP-Controls
IUPCONTROLS = \
	srccontrols/iup_controls.c srccontrols/iup_cells.c \
	srccontrols/iup_matrixlist.c \
	srccontrols/matrix/iupmat_key.c srccontrols/matrix/iupmat_mark.c \
	srccontrols/matrix/iupmat_aux.c srccontrols/matrix/iupmat_mem.c \
	srccontrols/matrix/iupmat_mouse.c srccontrols/matrix/iupmat_numlc.c \
	srccontrols/matrix/iupmat_colres.c srccontrols/matrix/iupmat_draw.c \
	srccontrols/matrix/iupmat_getset.c srccontrols/matrix/iupmatrix.c \
	srccontrols/matrix/iupmat_scroll.c srccontrols/matrix/iupmat_edit.c \
	srccontrols/matrix/iupmat_ex.c \
	srccontrols/matrixex/iup_matrixex.c srccontrols/matrixex/iupmatex_clipboard.c \
	srccontrols/matrixex/iupmatex_busy.c srccontrols/matrixex/iupmatex_export.c \
	srccontrols/matrixex/iupmatex_visible.c srccontrols/matrixex/iupmatex_copy.c \
	srccontrols/matrixex/iupmatex_units.c srccontrols/matrixex/iupmatex_find.c \
	srccontrols/matrixex/iupmatex_undo.c srccontrols/matrixex/iupmatex_sort.c

# IUP-IM 桥接
IUPIM = srcim/iup_im.c

# IUP-Plot
IUPPLOT = srcplot/iup_plot_ctrl.cpp srcplot/iup_plot_attrib.cpp \
          srcplot/iupPlot.cpp srcplot/iupPlotCalc.cpp srcplot/iupPlotDraw.cpp \
          srcplot/iupPlotAxis.cpp srcplot/iupPlotData.cpp srcplot/iupPlotTick.cpp

# ===================================================================
# === CD 库 (Canvas Draw) ===
# ===================================================================
CD_COMM = \
	cd/src/cd.c cd/src/wd.c cd/src/wdhdcpy.c cd/src/rgb2map.c \
	cd/src/cd_vectortext.c cd/src/cd_active.c cd/src/cd_attributes.c \
	cd/src/cd_bitmap.c cd/src/cd_image.c cd/src/cd_primitives.c \
	cd/src/cd_text.c cd/src/cd_util.c

CD_WIN32 = \
	cd/src/win32/cdwclp.c cd/src/win32/cdwemf.c cd/src/win32/cdwimg.c \
	cd/src/win32/cdwin.c cd/src/win32/cdwnative.c cd/src/win32/cdwprn.c \
	cd/src/win32/cdwwmf.c cd/src/win32/wmf_emf.c cd/src/win32/cdwdbuf.c \
	cd/src/win32/cdwdib.c

CD_DRV = \
	cd/src/drv/cddgn.c cd/src/drv/cdcgm.c cd/src/drv/cgm.c \
	cd/src/drv/cddxf.c cd/src/drv/cdirgb.c cd/src/drv/cdmf.c \
	cd/src/drv/cdps.c cd/src/drv/cdpicture.c cd/src/drv/cddebug.c \
	cd/src/drv/cdpptx.c cd/src/drv/pptx.c

CD_SVG = cd/src/svg/base64.c cd/src/svg/lodepng.c cd/src/svg/cdsvg.c

CD_INTCGM = \
	cd/src/intcgm/cd_intcgm.c cd/src/intcgm/cgm_bin_get.c \
	cd/src/intcgm/cgm_bin_parse.c cd/src/intcgm/cgm_list.c \
	cd/src/intcgm/cgm_play.c cd/src/intcgm/cgm_sism.c \
	cd/src/intcgm/cgm_txt_get.c cd/src/intcgm/cgm_txt_parse.c

CD_SIM = \
	cd/src/sim/cdfontex.c cd/src/sim/sim.c cd/src/sim/cd_truetype.c \
	cd/src/sim/sim_primitives.c cd/src/sim/sim_text.c \
	cd/src/sim/sim_linepolyfill.c

CD_MINIZIP = \
	cd/src/minizip/ioapi.c cd/src/minizip/minizip.c cd/src/minizip/zip.c \
	cd/src/minizip/miniunzip.c cd/src/minizip/unzip.c

# cdgl (C)
CDGL_C = cd/src/drv/cdgl.c

# cdcontextplus (Windows GDI+)
CDCTXPLUS_CPP = \
	cd/src/gdiplus/cdwemfp.cpp cd/src/gdiplus/cdwimgp.cpp \
	cd/src/gdiplus/cdwinp.cpp cd/src/gdiplus/cdwnativep.cpp \
	cd/src/gdiplus/cdwprnp.cpp cd/src/gdiplus/cdwdbufp.cpp \
	cd/src/gdiplus/cdwclpp.cpp

CDCTXPLUS_C = cd/src/gdiplus/cdwgdiplus.c

# ===================================================================
# === IM 库 (Imaging Toolkit) ===
# ===================================================================
IM_CORE_CPP = \
	im/src/im_attrib.cpp im/src/im_format.cpp im/src/im_format_tga.cpp \
	im/src/im_filebuffer.cpp im/src/im_bin.cpp im/src/im_format_all.cpp \
	im/src/im_format_raw.cpp im/src/im_convertopengl.cpp \
	im/src/im_binfile.cpp im/src/im_format_sgi.cpp im/src/im_datatype.cpp \
	im/src/im_format_pcx.cpp im/src/im_colorhsi.cpp im/src/im_format_bmp.cpp \
	im/src/im_image.cpp im/src/im_rgb2map.cpp im/src/im_colormode.cpp \
	im/src/im_format_gif.cpp im/src/im_lib.cpp im/src/im_format_pnm.cpp \
	im/src/im_colorutil.cpp im/src/im_format_ico.cpp im/src/im_palette.cpp \
	im/src/im_format_ras.cpp im/src/im_convertbitmap.cpp \
	im/src/im_format_led.cpp im/src/im_counter.cpp im/src/im_str.cpp \
	im/src/im_convertcolor.cpp im/src/im_fileraw.cpp im/src/im_format_krn.cpp \
	im/src/im_compress.cpp im/src/im_file.cpp im/src/im_old.cpp \
	im/src/im_format_pfm.cpp \
	im/src/im_converttype.cpp im/src/im_format_tiff.cpp \
	im/src/im_format_png.cpp im/src/im_format_jpeg.cpp \
	im/src/im_sysfile_win32.cpp im/src/im_dib.cpp im/src/im_dibxbitmap.cpp

IM_CORE_C = im/src/im_oldcolor.c im/src/im_oldresize.c

IM_LIBTIFF = \
	im/src/libtiff/tif_aux.c im/src/libtiff/tif_dirwrite.c \
	im/src/libtiff/tif_jpeg.c im/src/libtiff/tif_print.c \
	im/src/libtiff/tif_close.c im/src/libtiff/tif_dumpmode.c \
	im/src/libtiff/tif_luv.c im/src/libtiff/tif_read.c \
	im/src/libtiff/tif_codec.c im/src/libtiff/tif_error.c \
	im/src/libtiff/tif_lzw.c im/src/libtiff/tif_strip.c \
	im/src/libtiff/tif_color.c im/src/libtiff/tif_extension.c \
	im/src/libtiff/tif_next.c im/src/libtiff/tif_swab.c \
	im/src/libtiff/tif_compress.c im/src/libtiff/tif_fax3.c \
	im/src/libtiff/tif_open.c im/src/libtiff/tif_thunder.c \
	im/src/libtiff/tif_dir.c im/src/libtiff/tif_fax3sm.c \
	im/src/libtiff/tif_packbits.c im/src/libtiff/tif_tile.c \
	im/src/libtiff/tif_dirinfo.c im/src/libtiff/tif_flush.c \
	im/src/libtiff/tif_pixarlog.c im/src/libtiff/tif_zip.c \
	im/src/libtiff/tif_dirread.c im/src/libtiff/tif_getimage.c \
	im/src/libtiff/tif_predict.c im/src/libtiff/tif_version.c \
	im/src/libtiff/tif_write.c im/src/libtiff/tif_warning.c \
	im/src/libtiff/tif_ojpeg.c im/src/libtiff/tif_lzma.c \
	im/src/libtiff/tif_jbig.c im/src/tiff_binfile.c

IM_LIBJPEG = \
	im/src/libjpeg/jcapimin.c im/src/libjpeg/jcmarker.c \
	im/src/libjpeg/jdapimin.c im/src/libjpeg/jdinput.c \
	im/src/libjpeg/jdtrans.c im/src/libjpeg/jcapistd.c \
	im/src/libjpeg/jcmaster.c im/src/libjpeg/jdapistd.c \
	im/src/libjpeg/jdmainct.c im/src/libjpeg/jerror.c \
	im/src/libjpeg/jmemmgr.c im/src/libjpeg/jccoefct.c \
	im/src/libjpeg/jcomapi.c im/src/libjpeg/jdatadst.c \
	im/src/libjpeg/jdmarker.c im/src/libjpeg/jfdctflt.c \
	im/src/libjpeg/jmemnobs.c im/src/libjpeg/jccolor.c \
	im/src/libjpeg/jcparam.c im/src/libjpeg/jdatasrc.c \
	im/src/libjpeg/jdmaster.c im/src/libjpeg/jfdctfst.c \
	im/src/libjpeg/jquant1.c im/src/libjpeg/jcdctmgr.c \
	im/src/libjpeg/jdcoefct.c im/src/libjpeg/jdmerge.c \
	im/src/libjpeg/jfdctint.c im/src/libjpeg/jquant2.c \
	im/src/libjpeg/jchuff.c im/src/libjpeg/jcprepct.c \
	im/src/libjpeg/jdcolor.c im/src/libjpeg/jidctflt.c \
	im/src/libjpeg/jutils.c im/src/libjpeg/jdarith.c \
	im/src/libjpeg/jcinit.c im/src/libjpeg/jcsample.c \
	im/src/libjpeg/jddctmgr.c im/src/libjpeg/jdpostct.c \
	im/src/libjpeg/jidctfst.c im/src/libjpeg/jaricom.c \
	im/src/libjpeg/jcmainct.c im/src/libjpeg/jctrans.c \
	im/src/libjpeg/jdhuff.c im/src/libjpeg/jdsample.c \
	im/src/libjpeg/jidctint.c im/src/libjpeg/jcarith.c

IM_LIBPNG = \
	im/src/libpng/png.c im/src/libpng/pngget.c im/src/libpng/pngread.c \
	im/src/libpng/pngrutil.c im/src/libpng/pngwtran.c im/src/libpng/pngerror.c \
	im/src/libpng/pngmem.c im/src/libpng/pngrio.c im/src/libpng/pngset.c \
	im/src/libpng/pngwio.c im/src/libpng/pngpread.c im/src/libpng/pngrtran.c \
	im/src/libpng/pngtrans.c im/src/libpng/pngwrite.c im/src/libpng/pngwutil.c

IM_LZF  = im/src/liblzf/lzf_c.c im/src/liblzf/lzf_d.c
IM_LZ4  = im/src/lz4/lz4.c

# ===================================================================
# === IUP TUIO, MglPlot, OLE ===
# ===================================================================
TUIO = \
	srctuio/iup_tuio.cpp \
	srctuio/tuio/FlashSender.cpp srctuio/tuio/TcpReceiver.cpp \
	srctuio/tuio/TuioClient.cpp srctuio/tuio/TuioDispatcher.cpp \
	srctuio/tuio/TuioPoint.cpp srctuio/tuio/UdpReceiver.cpp \
	srctuio/tuio/OneEuroFilter.cpp srctuio/tuio/TcpSender.cpp \
	srctuio/tuio/TuioContainer.cpp srctuio/tuio/TuioManager.cpp \
	srctuio/tuio/TuioServer.cpp srctuio/tuio/UdpSender.cpp \
	srctuio/tuio/OscReceiver.cpp srctuio/tuio/TuioBlob.cpp \
	srctuio/tuio/TuioCursor.cpp srctuio/tuio/TuioObject.cpp \
	srctuio/tuio/TuioTime.cpp srctuio/tuio/WebSockSender.cpp \
	srctuio/oscpack/ip/IpEndpointName.cpp \
	srctuio/oscpack/ip/win32/NetworkingUtils.cpp \
	srctuio/oscpack/ip/win32/UdpSocket.cpp \
	srctuio/oscpack/osc/OscTypes.cpp \
	srctuio/oscpack/osc/OscOutboundPacketStream.cpp \
	srctuio/oscpack/osc/OscReceivedElements.cpp \
	srctuio/oscpack/osc/OscPrintReceivedElements.cpp

MGLPLOT = \
	srcmglplot/iup_mglplot.cpp \
	srcmglplot/src/addon.cpp srcmglplot/src/complex.cpp \
	srcmglplot/src/data_gr.cpp srcmglplot/src/evalp.cpp \
	srcmglplot/src/fit.cpp srcmglplot/src/pde.cpp srcmglplot/src/vect.cpp \
	srcmglplot/src/axis.cpp srcmglplot/src/complex_io.cpp \
	srcmglplot/src/data_io.cpp srcmglplot/src/exec.cpp \
	srcmglplot/src/font.cpp srcmglplot/src/pixel.cpp \
	srcmglplot/src/volume.cpp srcmglplot/src/base.cpp \
	srcmglplot/src/cont.cpp srcmglplot/src/data_png.cpp \
	srcmglplot/src/export.cpp srcmglplot/src/obj.cpp \
	srcmglplot/src/plot.cpp srcmglplot/src/window.cpp \
	srcmglplot/src/base_cf.cpp srcmglplot/src/crust.cpp \
	srcmglplot/src/export_2d.cpp srcmglplot/src/opengl.cpp \
	srcmglplot/src/prim.cpp srcmglplot/src/canvas.cpp \
	srcmglplot/src/data.cpp srcmglplot/src/eval.cpp \
	srcmglplot/src/export_3d.cpp srcmglplot/src/other.cpp \
	srcmglplot/src/surf.cpp srcmglplot/src/canvas_cf.cpp \
	srcmglplot/src/data_ex.cpp srcmglplot/src/evalc.cpp \
	srcmglplot/src/fft.cpp srcmglplot/src/parser.cpp \
	srcmglplot/src/complex_ex.cpp srcmglplot/src/fractal.cpp \
	srcmglplot/src/s_hull/s_hull_pro.cpp

OLE = \
	srcole/iup_olecontrol.cpp srcole/tLegacy.cpp \
	srcole/tAmbientProperties.cpp srcole/tDispatch.cpp \
	srcole/tOleClientSite.cpp srcole/tOleControlSite.cpp \
	srcole/tOleHandler.cpp srcole/tOleInPlaceFrame.cpp \
	srcole/tOleInPlaceSite.cpp

# ===================================================================
# === Scintilla ===
# ===================================================================
SCIBASE = srcscintilla/scintilla3112
SCI_C = \
	srcscintilla/iup_scintilla.c srcscintilla/iup_scintilladlg.c \
	srcscintilla/iup_scintilla_win.c srcscintilla/iupsci_clipboard.c \
	srcscintilla/iupsci_folding.c srcscintilla/iupsci_lexer.c \
	srcscintilla/iupsci_margin.c srcscintilla/iupsci_overtype.c \
	srcscintilla/iupsci_scrolling.c srcscintilla/iupsci_selection.c \
	srcscintilla/iupsci_style.c srcscintilla/iupsci_tab.c \
	srcscintilla/iupsci_text.c srcscintilla/iupsci_wordwrap.c \
	srcscintilla/iupsci_markers.c srcscintilla/iupsci_bracelight.c \
	srcscintilla/iupsci_cursor.c srcscintilla/iupsci_whitespace.c \
	srcscintilla/iupsci_annotation.c srcscintilla/iupsci_autocompletion.c \
	srcscintilla/iupsci_searching.c srcscintilla/iupsci_print.c \
	srcscintilla/iupsci_indicator.c

SCI_SRC = \
	$(SCIBASE)/src/AutoComplete.cxx $(SCIBASE)/src/CallTip.cxx \
	$(SCIBASE)/src/Catalogue.cxx $(SCIBASE)/src/CellBuffer.cxx \
	$(SCIBASE)/src/CharClassify.cxx $(SCIBASE)/src/ContractionState.cxx \
	$(SCIBASE)/src/Decoration.cxx $(SCIBASE)/src/Document.cxx \
	$(SCIBASE)/src/Editor.cxx $(SCIBASE)/src/ExternalLexer.cxx \
	$(SCIBASE)/src/Indicator.cxx $(SCIBASE)/src/KeyMap.cxx \
	$(SCIBASE)/src/LineMarker.cxx $(SCIBASE)/src/PerLine.cxx \
	$(SCIBASE)/src/PositionCache.cxx $(SCIBASE)/src/RESearch.cxx \
	$(SCIBASE)/src/RunStyles.cxx $(SCIBASE)/src/ScintillaBase.cxx \
	$(SCIBASE)/src/Selection.cxx $(SCIBASE)/src/Style.cxx \
	$(SCIBASE)/src/UniConversion.cxx $(SCIBASE)/src/ViewStyle.cxx \
	$(SCIBASE)/src/XPM.cxx $(SCIBASE)/src/CaseConvert.cxx \
	$(SCIBASE)/src/CaseFolder.cxx $(SCIBASE)/src/EditModel.cxx \
	$(SCIBASE)/src/EditView.cxx $(SCIBASE)/src/MarginView.cxx \
	$(SCIBASE)/src/DBCS.cxx $(SCIBASE)/src/UniqueString.cxx \
	$(SCIBASE)/win32/PlatWin.cxx $(SCIBASE)/win32/ScintillaWin.cxx \
	$(SCIBASE)/win32/HanjaDic.cxx \
	$(SCIBASE)/lexlib/Accessor.cxx $(SCIBASE)/lexlib/CharacterSet.cxx \
	$(SCIBASE)/lexlib/LexerBase.cxx $(SCIBASE)/lexlib/LexerModule.cxx \
	$(SCIBASE)/lexlib/LexerNoExceptions.cxx \
	$(SCIBASE)/lexlib/LexerSimple.cxx $(SCIBASE)/lexlib/PropSetSimple.cxx \
	$(SCIBASE)/lexlib/StyleContext.cxx $(SCIBASE)/lexlib/WordList.cxx \
	$(SCIBASE)/lexlib/CharacterCategory.cxx $(SCIBASE)/lexlib/DefaultLexer.cxx

SCI_LEXERS = \
	$(SCIBASE)/lexers/LexLPeg.cxx \
	$(SCIBASE)/lexers/LexA68k.cxx $(SCIBASE)/lexers/LexAbaqus.cxx \
	$(SCIBASE)/lexers/LexAda.cxx $(SCIBASE)/lexers/LexAPDL.cxx \
	$(SCIBASE)/lexers/LexAsn1.cxx $(SCIBASE)/lexers/LexASY.cxx \
	$(SCIBASE)/lexers/LexAU3.cxx $(SCIBASE)/lexers/LexAVE.cxx \
	$(SCIBASE)/lexers/LexAVS.cxx $(SCIBASE)/lexers/LexBaan.cxx \
	$(SCIBASE)/lexers/LexBash.cxx $(SCIBASE)/lexers/LexBasic.cxx \
	$(SCIBASE)/lexers/LexBullant.cxx $(SCIBASE)/lexers/LexCaml.cxx \
	$(SCIBASE)/lexers/LexCLW.cxx $(SCIBASE)/lexers/LexCmake.cxx \
	$(SCIBASE)/lexers/LexCOBOL.cxx $(SCIBASE)/lexers/LexCoffeeScript.cxx \
	$(SCIBASE)/lexers/LexConf.cxx $(SCIBASE)/lexers/LexCPP.cxx \
	$(SCIBASE)/lexers/LexCrontab.cxx $(SCIBASE)/lexers/LexCsound.cxx \
	$(SCIBASE)/lexers/LexCSS.cxx $(SCIBASE)/lexers/LexD.cxx \
	$(SCIBASE)/lexers/LexECL.cxx $(SCIBASE)/lexers/LexEiffel.cxx \
	$(SCIBASE)/lexers/LexErlang.cxx $(SCIBASE)/lexers/LexEScript.cxx \
	$(SCIBASE)/lexers/LexFlagship.cxx $(SCIBASE)/lexers/LexForth.cxx \
	$(SCIBASE)/lexers/LexFortran.cxx $(SCIBASE)/lexers/LexGAP.cxx \
	$(SCIBASE)/lexers/LexGui4Cli.cxx $(SCIBASE)/lexers/LexHaskell.cxx \
	$(SCIBASE)/lexers/LexHTML.cxx $(SCIBASE)/lexers/LexInno.cxx \
	$(SCIBASE)/lexers/LexKix.cxx $(SCIBASE)/lexers/LexLisp.cxx \
	$(SCIBASE)/lexers/LexLout.cxx $(SCIBASE)/lexers/LexLua.cxx \
	$(SCIBASE)/lexers/LexMagik.cxx $(SCIBASE)/lexers/LexMarkdown.cxx \
	$(SCIBASE)/lexers/LexMatlab.cxx $(SCIBASE)/lexers/LexMetapost.cxx \
	$(SCIBASE)/lexers/LexMMIXAL.cxx $(SCIBASE)/lexers/LexModula.cxx \
	$(SCIBASE)/lexers/LexMPT.cxx $(SCIBASE)/lexers/LexMSSQL.cxx \
	$(SCIBASE)/lexers/LexMySQL.cxx $(SCIBASE)/lexers/LexNimrod.cxx \
	$(SCIBASE)/lexers/LexNsis.cxx $(SCIBASE)/lexers/LexOpal.cxx \
	$(SCIBASE)/lexers/LexOScript.cxx $(SCIBASE)/lexers/LexPascal.cxx \
	$(SCIBASE)/lexers/LexPB.cxx $(SCIBASE)/lexers/LexPerl.cxx \
	$(SCIBASE)/lexers/LexPLM.cxx $(SCIBASE)/lexers/LexPO.cxx \
	$(SCIBASE)/lexers/LexPOV.cxx $(SCIBASE)/lexers/LexPowerPro.cxx \
	$(SCIBASE)/lexers/LexPowerShell.cxx $(SCIBASE)/lexers/LexProgress.cxx \
	$(SCIBASE)/lexers/LexPS.cxx $(SCIBASE)/lexers/LexPython.cxx \
	$(SCIBASE)/lexers/LexR.cxx $(SCIBASE)/lexers/LexRebol.cxx \
	$(SCIBASE)/lexers/LexRuby.cxx $(SCIBASE)/lexers/LexScriptol.cxx \
	$(SCIBASE)/lexers/LexSmalltalk.cxx $(SCIBASE)/lexers/LexSML.cxx \
	$(SCIBASE)/lexers/LexSorcus.cxx $(SCIBASE)/lexers/LexSpecman.cxx \
	$(SCIBASE)/lexers/LexSpice.cxx $(SCIBASE)/lexers/LexSQL.cxx \
	$(SCIBASE)/lexers/LexTACL.cxx $(SCIBASE)/lexers/LexTADS3.cxx \
	$(SCIBASE)/lexers/LexTAL.cxx $(SCIBASE)/lexers/LexTCL.cxx \
	$(SCIBASE)/lexers/LexTCMD.cxx $(SCIBASE)/lexers/LexTeX.cxx \
	$(SCIBASE)/lexers/LexTxt2tags.cxx $(SCIBASE)/lexers/LexVB.cxx \
	$(SCIBASE)/lexers/LexVerilog.cxx $(SCIBASE)/lexers/LexVHDL.cxx \
	$(SCIBASE)/lexers/LexVisualProlog.cxx $(SCIBASE)/lexers/LexYAML.cxx \
	$(SCIBASE)/lexers/LexKVIrc.cxx $(SCIBASE)/lexers/LexLaTeX.cxx \
	$(SCIBASE)/lexers/LexSTTXT.cxx $(SCIBASE)/lexers/LexRust.cxx \
	$(SCIBASE)/lexers/LexDMAP.cxx $(SCIBASE)/lexers/LexDMIS.cxx \
	$(SCIBASE)/lexers/LexBibTeX.cxx $(SCIBASE)/lexers/LexHex.cxx \
	$(SCIBASE)/lexers/LexAsm.cxx $(SCIBASE)/lexers/LexRegistry.cxx \
	$(SCIBASE)/lexers/LexLed.cxx $(SCIBASE)/lexers/LexBatch.cxx \
	$(SCIBASE)/lexers/LexDiff.cxx $(SCIBASE)/lexers/LexErrorList.cxx \
	$(SCIBASE)/lexers/LexMake.cxx $(SCIBASE)/lexers/LexNull.cxx \
	$(SCIBASE)/lexers/LexProps.cxx $(SCIBASE)/lexers/LexJSON.cxx \
	$(SCIBASE)/lexers/LexEDIFACT.cxx $(SCIBASE)/lexers/LexIndent.cxx \
	$(SCIBASE)/lexers/LexCIL.cxx $(SCIBASE)/lexers/LexDataflex.cxx \
	$(SCIBASE)/lexers/LexHollywood.cxx $(SCIBASE)/lexers/LexMaxima.cxx \
	$(SCIBASE)/lexers/LexNim.cxx $(SCIBASE)/lexers/LexSAS.cxx \
	$(SCIBASE)/lexers/LexStata.cxx $(SCIBASE)/lexers/LexX12.cxx

# ===================================================================
# 聚合
# ===================================================================
ALL_C = $(IUP_CORE) $(IUP_WIN) $(WDL) $(IMGLIB) $(IUPGL) $(GLCONTROLS) \
        $(IUPCD) $(IUPCONTROLS) $(IUPIM) $(SCI_C) \
        $(CD_COMM) $(CD_WIN32) $(CD_DRV) $(CD_SVG) $(CD_INTCGM) $(CD_SIM) $(CD_MINIZIP) $(CDCTXPLUS_C) $(CDGL_C) \
        $(IM_LIBTIFF) $(IM_LIBJPEG) $(IM_LIBPNG) $(IM_LZF) $(IM_LZ4) $(IM_CORE_C)

FTGL_STUB_OBJ = $(OBJDIR)/build/ftgl_stub.o

ALL_CPP = $(IUPPLOT) $(TUIO) $(MGLPLOT) $(OLE) \
          $(CDCTXPLUS_CPP) \
          $(IM_CORE_CPP) \
          $(SCI_SRC) $(SCI_LEXERS)

ALL_CPP = $(IUPPLOT) $(TUIO) $(MGLPLOT) $(OLE) \
          $(CDCTXPLUS_CPP) \
          $(IM_CORE_CPP) \
          $(SCI_SRC) $(SCI_LEXERS)

ALL_C_OBJ  = $(addprefix $(OBJDIR)/, $(ALL_C:.c=.o))
# Separate .cpp and .cxx to avoid .cxx appearing as target name
ALL_CPP_ONLY = $(filter %.cpp, $(ALL_CPP))
ALL_CXX_ONLY = $(filter %.cxx, $(ALL_CPP))
ALL_CPP_OBJ = $(addprefix $(OBJDIR)/, $(ALL_CPP_ONLY:.cpp=.o))
ALL_CXX_OBJ = $(addprefix $(OBJDIR)/, $(ALL_CXX_ONLY:.cxx=.o))
ALL_OBJ = $(ALL_C_OBJ) $(ALL_CPP_OBJ) $(ALL_CXX_OBJ) $(FTGL_STUB_OBJ)

# ===================================================================
# 目标
# ===================================================================
.PHONY: all clean

all: $(OUTPUT).dll
	@echo ============================================================
	@echo  FULL BUILD SUCCESS: $(OUTPUT).dll
	@echo  Modules: IUP + CD + IM + cdgl + Controls + Plot + Scintilla + ...
	@echo ============================================================

$(OUTPUT).dll: $(ALL_OBJ)
	@echo [LINK] $@
	@$(CXX) $(LDFLAGS) -o $@ $(ALL_OBJ) $(SYSLIBS) $(EXTLIBS) $(SYSLIBS_POST)
	@gendef $@ 2>/dev/null && dlltool -d $(OUTPUT).def -l $(OUTPUT).a 2>/dev/null
	@echo  Import library rebuilt: $(OUTPUT).a

# --- C 编译 ---
$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CC] $<
	@$(CC) -c $(CFLAGS) $(INCLUDES) -o $@ $<

# --- C++ 编译 ---
$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CXX] $<
	@$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

$(FTGL_STUB_OBJ): build/ftgl_stub.cpp
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CXX] $<
	@$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

$(OBJDIR)/%.o: %.cxx
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CXX] $<
	@$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

# Explicit targets for Scintilla cxx files
$(OBJDIR)/srcscintilla/scintilla3112/%.o: srcscintilla/scintilla3112/%.cxx
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CXX] $<
	@$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

# --- 清理 ---
clean:
	@rm -rf $(OBJDIR) $(OUTPUT).dll $(OUTPUT).a
	@echo Cleaned.
