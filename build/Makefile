# ===================================================================
#  IUP Single DLL Build - MinGW64/MSYS2
#  将 IUP 所有可用模块编译为单个无依赖 DLL
# ===================================================================
#  依赖: MSYS2 MinGW64 (GCC 16.1+), freetype, ftgl, zlib
#  安装: pacman -S mingw-w64-x86_64-freetype mingw-w64-x86_64-ftgl mingw-w64-x86_64-zlib
#  运行: mingw32-make -f build/Makefile
# ===================================================================

# --- 编译器设置 ---
# 使用 MSYS2 mingw64 工具链，需确保 PATH 包含 /mingw64/bin
CC       = gcc
CXX      = g++
WINDRES  = windres
DLLTOOL  = dlltool

# --- 输出 ---
OUTPUT   = build/iup
OBJDIR   = build/obj

# --- 编译标志 ---
DEFINES  = -DIUP_BUILD_LIBRARY -DIUP_DLL \
           -D_WIN32_WINNT=0x0601 -DWINVER=0x0601 -D_WIN32_IE=0x0900 \
           -DUNICODE -D_UNICODE \
           -DCOBJMACROS -DUSE_NEW_DRAW \
           -DCD_NO_OLD_INTERFACE \
           -D_NOTREEVIEW \
           -DFTGL_LIBRARY_STATIC \
           -DMGL_STATIC_DEFINE -DMGL_SRC \
           -DSTATIC_BUILD -DSCI_LEXER -DSCI_NAMESPACE \
           -D_WIN32 -DWIN32 -DDISABLE_D2D -DNO_CXX11_REGEX \
           -DIUP_IMGLIB_LARGE_ICON \
           -DOSC_HOST_LITTLE_ENDIAN \
           -DSCINTILLA_VERSION='"3.11.2"' \
           -D_USE_MATH_DEFINES

CFLAGS   = -Wall -O2 -m64 -pipe $(DEFINES) \
           -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast \
           -Wno-unused-function -Wno-missing-braces
CXXFLAGS = -Wall -O2 -m64 -pipe -std=c++11 $(DEFINES) \
           -Wno-int-to-pointer-cast \
           -Wno-unused-function -Wno-missing-braces \
           -Wno-class-memaccess -Wno-reorder -Wno-write-strings \
           -Wno-stringop-truncation -Wno-unknown-pragmas
LDFLAGS  = -shared -static-libgcc -static-libstdc++ -m64 \
           -Wl,--out-implib=$(OUTPUT).a

# --- 系统库 ---
SYSLIBS  = -lkernel32 -luser32 -lgdi32 -lcomdlg32 -ladvapi32 \
           -lshell32 -lole32 -loleaut32 -luuid -lcomctl32 \
           -lmsimg32 -limm32 -lws2_32 -lwinmm -lopengl32 -lglu32 \
           -lshlwapi

# --- MSYS2 外部库 (静态链接) ---
EXTLIBS  = -lfreetype -lftgl -lz

# --- 头文件路径 ---
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
           -IC:/env/msys2/mingw64/include/freetype2

# ===================================================================
# 源文件列表
# ===================================================================

# --- IUP 核心 (纯 C) ---
IUP_CORE_C = \
	src/iup.c src/iup_attrib.c src/iup_array.c src/iup_assert.c \
	src/iup_backgroundbox.c src/iup_box.c src/iup_button.c \
	src/iup_callback.c src/iup_canvas.c src/iup_cbox.c \
	src/iup_childtree.c src/iup_class.c src/iup_classattrib.c \
	src/iup_classbase.c src/iup_classinfo.c src/iup_colorbar.c \
	src/iup_colorbrowser.c src/iup_colordlg.c src/iup_colorhsi.c \
	src/iup_config.c src/iup_datepick.c src/iup_detachbox.c \
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

# --- IUP Windows 驱动 ---
IUP_WIN_C = \
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

# --- WDL (Windows Draw Library) ---
IUP_WDL_C = \
	src/win/wdl/backend-d2d.c src/win/wdl/backend-dwrite.c \
	src/win/wdl/backend-gdix.c src/win/wdl/backend-wic.c \
	src/win/wdl/bitblt.c src/win/wdl/brush.c \
	src/win/wdl/cachedimage.c src/win/wdl/canvas.c \
	src/win/wdl/draw.c src/win/wdl/fill.c src/win/wdl/font.c \
	src/win/wdl/image.c src/win/wdl/init.c src/win/wdl/memstream.c \
	src/win/wdl/misc.c src/win/wdl/path.c src/win/wdl/string.c \
	src/win/wdl/strokestyle.c

# --- IUP Image Library ---
IUP_IMGLIB_C = \
	srcimglib/iup_image_library.c \
	srcimglib/iup_imglib_circleprogress.c \
	srcimglib/iup_imglib_basewin32x32.c \
	srcimglib/iup_imglib_logos48x48.c \
	srcimglib/iup_imglib_logos32x32.c \
	srcimglib/iup_imglib_iconswin48x48.c

# --- IUP OpenGL ---
IUP_GL_C = \
	srcgl/iup_glcanvas.c srcgl/iup_glcanvas_win.c

# --- IUP OpenGL Controls ---
IUP_GLCONTROLS_C = \
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

# --- IUP TUIO (C++) ---
IUP_TUIO_CPP = \
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

# --- IUP MglPlot (C++) ---
IUP_MGLPLOT_CPP = \
	srcmglplot/iup_mglplot.cpp \
	srcmglplot/src/addon.cpp srcmglplot/src/complex.cpp \
	srcmglplot/src/data_gr.cpp srcmglplot/src/evalp.cpp \
	srcmglplot/src/fit.cpp srcmglplot/src/pde.cpp \
	srcmglplot/src/vect.cpp srcmglplot/src/axis.cpp \
	srcmglplot/src/complex_io.cpp srcmglplot/src/data_io.cpp \
	srcmglplot/src/exec.cpp srcmglplot/src/font.cpp \
	srcmglplot/src/pixel.cpp srcmglplot/src/volume.cpp \
	srcmglplot/src/base.cpp srcmglplot/src/cont.cpp \
	srcmglplot/src/data_png.cpp srcmglplot/src/export.cpp \
	srcmglplot/src/obj.cpp srcmglplot/src/plot.cpp \
	srcmglplot/src/window.cpp srcmglplot/src/base_cf.cpp \
	srcmglplot/src/crust.cpp srcmglplot/src/export_2d.cpp \
	srcmglplot/src/opengl.cpp srcmglplot/src/prim.cpp \
	srcmglplot/src/canvas.cpp srcmglplot/src/data.cpp \
	srcmglplot/src/eval.cpp srcmglplot/src/export_3d.cpp \
	srcmglplot/src/other.cpp srcmglplot/src/surf.cpp \
	srcmglplot/src/canvas_cf.cpp srcmglplot/src/data_ex.cpp \
	srcmglplot/src/evalc.cpp srcmglplot/src/fft.cpp \
	srcmglplot/src/parser.cpp srcmglplot/src/complex_ex.cpp \
	srcmglplot/src/fractal.cpp srcmglplot/src/s_hull/s_hull_pro.cpp

# --- IUP Scintilla (C + C++) ---
IUP_SCINTILLA_C = \
	srcscintilla/iup_scintilla.c srcscintilla/iup_scintilladlg.c \
	srcscintilla/iup_scintilla_win.c srcscintilla/iupsci_clipboard.c \
	srcscintilla/iupsci_folding.c srcscintilla/iupsci_lexer.c \
	srcscintilla/iupsci_margin.c srcscintilla/iupsci_overtype.c \
	srcscintilla/iupsci_scrolling.c srcscintilla/iupsci_selection.c \
	srcscintilla/iupsci_style.c srcscintilla/iupsci_tab.c \
	srcscintilla/iupsci_text.c srcscintilla/iupsci_wordwrap.c \
	srcscintilla/iupsci_markers.c srcscintilla/iupsci_bracelight.c \
	srcscintilla/iupsci_cursor.c srcscintilla/iupsci_whitespace.c \
	srcscintilla/iupsci_annotation.c \
	srcscintilla/iupsci_autocompletion.c \
	srcscintilla/iupsci_searching.c srcscintilla/iupsci_print.c \
	srcscintilla/iupsci_indicator.c

# --- IUP OLE (C++) ---
IUP_OLE_CPP = \
	srcole/iup_olecontrol.cpp srcole/tLegacy.cpp \
	srcole/tAmbientProperties.cpp srcole/tDispatch.cpp \
	srcole/tOleClientSite.cpp srcole/tOleControlSite.cpp \
	srcole/tOleHandler.cpp srcole/tOleInPlaceFrame.cpp \
	srcole/tOleInPlaceSite.cpp

# ===================================================================
# Scintilla 源码 (C++) - 内嵌
# ===================================================================
SCIBASE = srcscintilla/scintilla3112
SCI_SRC_CXX = \
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
	$(SCIBASE)/lexlib/CharacterCategory.cxx \
	$(SCIBASE)/lexlib/DefaultLexer.cxx

SCI_LEXERS_CXX = \
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
	$(SCIBASE)/lexers/LexLed.cxx \
	$(SCIBASE)/lexers/LexBatch.cxx $(SCIBASE)/lexers/LexDiff.cxx \
	$(SCIBASE)/lexers/LexErrorList.cxx $(SCIBASE)/lexers/LexMake.cxx \
	$(SCIBASE)/lexers/LexNull.cxx $(SCIBASE)/lexers/LexProps.cxx \
	$(SCIBASE)/lexers/LexJSON.cxx \
	$(SCIBASE)/lexers/LexEDIFACT.cxx $(SCIBASE)/lexers/LexIndent.cxx \
	$(SCIBASE)/lexers/LexCIL.cxx $(SCIBASE)/lexers/LexDataflex.cxx \
	$(SCIBASE)/lexers/LexHollywood.cxx $(SCIBASE)/lexers/LexMaxima.cxx \
	$(SCIBASE)/lexers/LexNim.cxx $(SCIBASE)/lexers/LexSAS.cxx \
	$(SCIBASE)/lexers/LexStata.cxx $(SCIBASE)/lexers/LexX12.cxx

# ===================================================================
# 聚合所有源文件
# ===================================================================
ALL_C   = $(filter-out src/iup_datepick.c, $(IUP_CORE_C)) $(IUP_WIN_C) $(IUP_WDL_C) \
          $(IUP_IMGLIB_C) $(IUP_GL_C) $(IUP_GLCONTROLS_C) \
          $(IUP_SCINTILLA_C)
ALL_CPP = $(IUP_TUIO_CPP) $(IUP_MGLPLOT_CPP) $(IUP_OLE_CPP) \
          $(SCI_SRC_CXX) $(SCI_LEXERS_CXX)

ALL_OBJ = $(addprefix $(OBJDIR)/, $(ALL_C:.c=.o) $(ALL_CPP:.cpp=.o) $(ALL_CPP:.cxx=.o))

# Quick build: 跳过 Scintilla (约250个源文件)，包含其他所有模块
QUICK_CPP = $(IUP_TUIO_CPP) $(IUP_MGLPLOT_CPP) $(IUP_OLE_CPP)
QUICK_CPP_OBJ = $(addprefix $(OBJDIR)/, $(QUICK_CPP:.cpp=.o))
# Windows 平台不需要 iup_datepick.c (由 iupwin_datepick.c 替代)
QUICK_C = $(filter-out src/iup_datepick.c, $(IUP_CORE_C)) $(IUP_WIN_C) $(IUP_WDL_C) \
          $(IUP_IMGLIB_C) $(IUP_GL_C) $(IUP_GLCONTROLS_C)
ALL_C_OBJ     = $(addprefix $(OBJDIR)/, $(QUICK_C:.c=.o))
QUICK_ALL_OBJ = $(ALL_C_OBJ) $(QUICK_CPP_OBJ)

# ===================================================================
# 构建目标
# ===================================================================
.PHONY: all quick clean

all: $(OUTPUT).dll
	@echo ============================================================
	@echo  BUILD SUCCESS: $(OUTPUT).dll
	@echo  Import library: $(OUTPUT).a
	@echo ============================================================

quick: quick_dll
	@echo ============================================================
	@echo  QUICK BUILD SUCCESS: $(OUTPUT).dll
	@echo  Modules: IUP core, GL, GLControls, TUIO, OLE, MglPlot, ImageLib
	@echo  Skipped: Scintilla - use 'all' target for full build
	@echo ============================================================

$(OUTPUT).dll: $(ALL_OBJ)
	@echo [LINK] $@
	@$(CXX) $(LDFLAGS) -o $@ $(ALL_OBJ) $(SYSLIBS) $(EXTLIBS)

quick_dll: $(QUICK_ALL_OBJ)
	@echo [LINK] $@
	@$(CXX) $(LDFLAGS) -o $(OUTPUT).dll $(QUICK_ALL_OBJ) $(SYSLIBS) $(EXTLIBS)

# --- C 文件编译规则 ---
$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CC] $<
	@$(CC) -c $(CFLAGS) $(INCLUDES) -o $@ $<

# --- C++ 文件编译规则 ---
$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CXX] $<
	@$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

$(OBJDIR)/%.o: %.cxx
	@mkdir -p $(dir $@) 2>/dev/null || true
	@echo [CXX] $<
	@$(CXX) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

# --- 资源文件 ---
$(OBJDIR)/iup_res.o: etc/iup.rc etc/tecgraf.ico
	@echo [RC] $<
	@$(WINDRES) -i $< -o $@

# --- 清理 ---
clean:
	@rm -rf $(OBJDIR) $(OUTPUT).dll $(OUTPUT).a
	@echo Cleaned.
