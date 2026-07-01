# ===================================================================
#  IUP Full Single DLL Build — MSVC (Visual Studio 2022)
#  用法: .\build\build_msvc_full.ps1
#  CI 中需要先运行: vcpkg install freetype zlib --triplet x64-windows-static
# ===================================================================
param(
    [string]$VcpkgRoot = $env:VCPKG_INSTALLATION_ROOT,
    [string]$Triplet = "x64-windows-static",
    [string]$OutputDir = "build",
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$script:Root = Split-Path -Parent $PSScriptRoot

# ===================================================================
# 1. 找到 MSVC
# ===================================================================
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    Write-Error "vswhere not found. Need Visual Studio 2022."
    exit 1
}
$vsPath = & $vswhere -latest -products * -property installationPath
$msvcPath = Get-ChildItem "$vsPath\VC\Tools\MSVC" -Directory | Sort-Object Name -Descending | Select-Object -First 1
$sdkPath = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\Include" -Directory | Sort-Object Name -Descending | Select-Object -First 1
$sdkLibPath = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\Lib" -Directory | Sort-Object Name -Descending | Select-Object -First 1

Write-Host "MSVC: $($msvcPath.FullName)" -ForegroundColor Cyan
Write-Host "SDK:  $($sdkPath.FullName)" -ForegroundColor Gray

$MsvcBin = "$($msvcPath.FullName)\bin\Hostx64\x64"
$MsvcInclude = "$($msvcPath.FullName)\include"
$MsvcLib = "$($msvcPath.FullName)\lib\x64"
$SdkInclude = "$($sdkPath.FullName)\ucrt;$($sdkPath.FullName)\um;$($sdkPath.FullName)\shared"
$SdkLib = "$($sdkLibPath.FullName)\um\x64;$($sdkLibPath.FullName)\ucrt\x64"

# 设置 MSVC 环境变量 (等同于 vcvars64.bat)
$env:PATH = "$MsvcBin;$env:PATH"
$env:INCLUDE = "$MsvcInclude;$SdkInclude"
$env:LIB = "$MsvcLib;$SdkLib"

# ===================================================================
# 2. vcpkg (freetype + zlib)
# ===================================================================
if (-not $VcpkgRoot) { $VcpkgRoot = "C:\vcpkg" }
$VcpkgInstalled = "$VcpkgRoot\installed\$Triplet"
if (Test-Path "$VcpkgInstalled\include\freetype2") {
    Write-Host "Vcpkg: $VcpkgInstalled" -ForegroundColor Cyan
} else {
    Write-Host "WARNING: Vcpkg packages not found at $VcpkgInstalled" -ForegroundColor Yellow
    Write-Host "  Run: vcpkg install freetype zlib --triplet $Triplet" -ForegroundColor Yellow
}

# ===================================================================
# 3. 编译配置
# ===================================================================
$ObjDir = "$Root\$OutputDir\obj_msvc"
$DllOut = "$Root\$OutputDir\iup.dll"
$LibOut = "$Root\$OutputDir\iup.lib"
New-Item -ItemType Directory -Force -Path $ObjDir | Out-Null

# 用 + 拼接数组避免嵌套 (ForEach 返回 Collection 需要展开)
$IncludeFlags = @(
    "/I$Root\include",
    "/I$Root\src", "/I$Root\src\win", "/I$Root\src\win\wdl",
    "/I$Root\srcimglib",
    "/I$Root\srcgl", "/I$Root\srcglcontrols",
    "/I$Root\srcmglplot", "/I$Root\srcmglplot\src",
    "/I$Root\srctuio", "/I$Root\srctuio\tuio", "/I$Root\srctuio\oscpack",
    "/I$Root\srcscintilla",
    "/I$Root\srcscintilla\scintilla3112\include",
    "/I$Root\srcscintilla\scintilla3112\src",
    "/I$Root\srcscintilla\scintilla3112\lexlib",
    "/I$Root\srcscintilla\scintilla3112\win32",
    "/I$Root\srcscintilla\scintilla3112\lexers",
    "/I$Root\srcole",
    "/I$Root\srccd", "/I$Root\srccontrols",
    "/I$Root\srcplot",
    "/I$Root\cd\include", "/I$Root\cd\src",
    "/I$Root\cd\src\win32", "/I$Root\cd\src\drv",
    "/I$Root\cd\src\intcgm", "/I$Root\cd\src\sim",
    "/I$Root\cd\src\svg", "/I$Root\cd\src\minizip",
    "/I$Root\cd\src\gdiplus",
    "/I$Root\im\include", "/I$Root\im\src",
    "/I$Root\im\src\libtiff", "/I$Root\im\src\libjpeg",
    "/I$Root\im\src\libpng", "/I$Root\im\src\liblzf",
    "/I$Root\im\src\lz4",
    "/I$VcpkgInstalled\include",
    "/I$VcpkgInstalled\include\freetype2",
    "/I$MsvcInclude"
) + ($SdkInclude -split ";" | ForEach-Object { "/I$_" })

$Defines = @(
    "IUP_BUILD_LIBRARY", "IUP_DLL",
    "_WIN32_WINNT=0x0601", "WINVER=0x0601", "_WIN32_IE=0x0900",
    "COBJMACROS", "USE_NEW_DRAW",
    "CD_NO_OLD_INTERFACE", "_NOTREEVIEW",
    "FTGL_LIBRARY_STATIC", "MGL_STATIC_DEFINE", "MGL_SRC",
    "STATIC_BUILD", "SCI_LEXER", "SCI_NAMESPACE",
    "_WIN32", "WIN32", "DISABLE_D2D", "NO_CXX11_REGEX",
    "IUP_IMGLIB_LARGE_ICON", "OSC_HOST_LITTLE_ENDIAN",
    "SCINTILLA_VERSION=`"3.11.2`"", "_USE_MATH_DEFINES",
    "UNICODE", "_UNICODE", "_MBCS",
    "NDEBUG"
)

$IncludeStr = ($IncludeFlags -join " ")
$DefineStr = ($Defines | ForEach-Object { "/D$_" }) -join " "

# MSVC warning flags (suppress noisy third-party warnings)
$WarnSuppress = "/wd4100 /wd4189 /wd4244 /wd4267 /wd4302 /wd4311 /wd4312 /wd4389 /wd4456 /wd4457 /wd4458 /wd4459 /wd4505 /wd4702 /wd4996 /wd4068 /wd4477 /wd4090"

$CFlags = "/nologo /c /MT /O2 /utf-8 /GL $WarnSuppress $DefineStr $IncludeStr"
$CxxFlags = "/nologo /c /MT /O2 /utf-8 /EHsc /std:c++14 /GL $WarnSuppress /Zc:__cplusplus $DefineStr $IncludeStr"

# ===================================================================
# 4. 编译辅助函数 (cmd /c 确保参数正确拆分)
# ===================================================================
$script:TotalCompiled = 0

function Compile-C($src) {
    $obj = "$ObjDir\$($src -replace '[\\/]', '_').obj"
    $srcFull = "$Root\$src"
    if (Test-Path $srcFull) {
        Write-Host "  [CC] $src" -ForegroundColor Gray
        cmd /c "cl.exe $CFlags /Fo`"$obj`" `"$srcFull`" 2>&1" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            cmd /c "cl.exe $CFlags /Fo`"$obj`" `"$srcFull`""
            throw "Compilation failed: $src"
        }
        $script:TotalCompiled++
        return $obj
    }
    return $null
}

function Compile-Cxx($src) {
    $obj = "$ObjDir\$($src -replace '[\\/]', '_').obj"
    $srcFull = "$Root\$src"
    if (Test-Path $srcFull) {
        Write-Host "  [CXX] $src" -ForegroundColor Gray
        cmd /c "cl.exe $CxxFlags /Fo`"$obj`" `"$srcFull`" 2>&1" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            cmd /c "cl.exe $CxxFlags /Fo`"$obj`" `"$srcFull`""
            throw "Compilation failed: $src"
        }
        $script:TotalCompiled++
        return $obj
    }
    return $null
}

# ===================================================================
# 5. IUP Core
# ===================================================================
Write-Host "`n[1/8] IUP Core" -ForegroundColor Yellow
$IupCore = @(
    "src/iup.c", "src/iup_attrib.c", "src/iup_array.c", "src/iup_assert.c",
    "src/iup_backgroundbox.c", "src/iup_box.c", "src/iup_button.c",
    "src/iup_callback.c", "src/iup_canvas.c", "src/iup_cbox.c",
    "src/iup_childtree.c", "src/iup_class.c", "src/iup_classattrib.c",
    "src/iup_classbase.c", "src/iup_classinfo.c", "src/iup_colorbar.c",
    "src/iup_colorbrowser.c", "src/iup_colordlg.c", "src/iup_colorhsi.c",
    "src/iup_config.c", "src/iup_detachbox.c",
    "src/iup_dial.c", "src/iup_dialog.c", "src/iup_dlglist.c", "src/iup_draw.c",
    "src/iup_dropbutton.c", "src/iup_elempropdlg.c", "src/iup_expander.c",
    "src/iup_export.c", "src/iup_filedlg.c", "src/iup_fill.c",
    "src/iup_flatbutton.c", "src/iup_flatframe.c", "src/iup_flatlabel.c",
    "src/iup_flatlist.c", "src/iup_flatscrollbar.c", "src/iup_flatscrollbox.c",
    "src/iup_flatseparator.c", "src/iup_flattabs.c", "src/iup_flattoggle.c",
    "src/iup_flattree.c", "src/iup_flatval.c", "src/iup_focus.c", "src/iup_font.c",
    "src/iup_fontdlg.c", "src/iup_frame.c", "src/iup_func.c", "src/iup_gauge.c",
    "src/iup_getparam.c", "src/iup_globalattrib.c", "src/iup_globalsdlg.c",
    "src/iup_gridbox.c", "src/iup_hbox.c", "src/iup_image.c", "src/iup_key.c",
    "src/iup_label.c", "src/iup_layout.c", "src/iup_layoutdlg.c",
    "src/iup_ledlex.c", "src/iup_ledparse.c", "src/iup_linefile.c",
    "src/iup_link.c", "src/iup_list.c", "src/iup_loop.c", "src/iup_mask.c",
    "src/iup_maskmatch.c", "src/iup_maskparse.c", "src/iup_menu.c",
    "src/iup_messagedlg.c", "src/iup_multibox.c", "src/iup_names.c",
    "src/iup_normalizer.c", "src/iup_object.c", "src/iup_open.c",
    "src/iup_predialogs.c", "src/iup_progressbar.c", "src/iup_progressdlg.c",
    "src/iup_radio.c", "src/iup_recplay.c", "src/iup_register.c",
    "src/iup_sbox.c", "src/iup_scanf.c", "src/iup_scrollbox.c", "src/iup_show.c",
    "src/iup_space.c", "src/iup_spin.c", "src/iup_split.c", "src/iup_str.c",
    "src/iup_strmessage.c", "src/iup_table.c", "src/iup_tabs.c", "src/iup_text.c",
    "src/iup_thread.c", "src/iup_timer.c", "src/iup_toggle.c", "src/iup_tree.c",
    "src/iup_user.c", "src/iup_val.c", "src/iup_vbox.c", "src/iup_zbox.c",
    "src/iup_animatedlabel.c"
)

$IupWin = @(
    "src/win/iupwin_common.c", "src/win/iupwin_brush.c",
    "src/win/iupwin_focus.c", "src/win/iupwin_font.c",
    "src/win/iupwin_globalattrib.c", "src/win/iupwin_handle.c",
    "src/win/iupwin_key.c", "src/win/iupwin_str.c",
    "src/win/iupwin_loop.c", "src/win/iupwin_open.c",
    "src/win/iupwin_tips.c", "src/win/iupwin_info.c",
    "src/win/iupwin_dialog.c", "src/win/iupwin_messagedlg.c",
    "src/win/iupwin_timer.c", "src/win/iupwin_image.c",
    "src/win/iupwin_label.c", "src/win/iupwin_canvas.c",
    "src/win/iupwin_frame.c", "src/win/iupwin_fontdlg.c",
    "src/win/iupwin_filedlg.c", "src/win/iupwin_dragdrop.c",
    "src/win/iupwin_button.c", "src/win/iupwin_draw.c",
    "src/win/iupwin_toggle.c", "src/win/iupwin_clipboard.c",
    "src/win/iupwin_progressbar.c", "src/win/iupwin_text.c",
    "src/win/iupwin_val.c", "src/win/iupwin_touch.c",
    "src/win/iupwin_tabs.c", "src/win/iupwin_menu.c",
    "src/win/iupwin_list.c", "src/win/iupwin_tree.c",
    "src/win/iupwin_calendar.c", "src/win/iupwin_datepick.c",
    "src/win/iupwin_draw_wdl.c", "src/win/iupwin_draw_gdi.c",
    "src/win/iupwin_image_wdl.c",
    "src/win/iupwindows_main.c", "src/win/iupwindows_help.c",
    "src/win/iupwindows_info.c"
)

$Wdl = @(
    "src/win/wdl/backend-d2d.c", "src/win/wdl/backend-dwrite.c",
    "src/win/wdl/backend-gdix.c", "src/win/wdl/backend-wic.c",
    "src/win/wdl/bitblt.c", "src/win/wdl/brush.c",
    "src/win/wdl/cachedimage.c", "src/win/wdl/canvas.c",
    "src/win/wdl/draw.c", "src/win/wdl/fill.c", "src/win/wdl/font.c",
    "src/win/wdl/image.c", "src/win/wdl/init.c", "src/win/wdl/memstream.c",
    "src/win/wdl/misc.c", "src/win/wdl/path.c", "src/win/wdl/string.c",
    "src/win/wdl/strokestyle.c"
)

$AllObjs = @()
foreach ($s in ($IupCore + $IupWin + $Wdl)) {
    $o = Compile-C $s
    if ($o) { $AllObjs += $o }
}

# ===================================================================
# 6. IUP Submodules
# ===================================================================
Write-Host "`n[2/8] IUP Submodules (ImageLib, GL, CD-bridge, Controls, IM-bridge)" -ForegroundColor Yellow

$ImgLib = @(
    "srcimglib/iup_image_library.c", "srcimglib/iup_imglib_circleprogress.c",
    "srcimglib/iup_imglib_basewin32x32.c", "srcimglib/iup_imglib_logos48x48.c",
    "srcimglib/iup_imglib_logos32x32.c", "srcimglib/iup_imglib_iconswin48x48.c"
)
$IupGl = @("srcgl/iup_glcanvas.c", "srcgl/iup_glcanvas_win.c")
$GlControls = @(
    "srcglcontrols/iup_glcontrols.c", "srcglcontrols/iup_glcanvasbox.c",
    "srcglcontrols/iup_glsubcanvas.c", "srcglcontrols/iup_gllabel.c",
    "srcglcontrols/iup_glimage.c", "srcglcontrols/iup_glfont.c",
    "srcglcontrols/iup_gldraw.c", "srcglcontrols/iup_glicon.c",
    "srcglcontrols/iup_glseparator.c", "srcglcontrols/iup_glbutton.c",
    "srcglcontrols/iup_gltoggle.c", "srcglcontrols/iup_gllink.c",
    "srcglcontrols/iup_glprogressbar.c", "srcglcontrols/iup_glval.c",
    "srcglcontrols/iup_glframe.c", "srcglcontrols/iup_glexpander.c",
    "srcglcontrols/iup_glscrollbars.c", "srcglcontrols/iup_glscrollbox.c",
    "srcglcontrols/iup_glsizebox.c", "srcglcontrols/iup_gltext.c"
)
$IupCd = @("srccd/iup_cd.c", "srccd/iup_cdutil.c", "srccd/iup_draw_cd.c")
$IupControls = @(
    "srccontrols/iup_controls.c", "srccontrols/iup_cells.c",
    "srccontrols/iup_matrixlist.c",
    "srccontrols/matrix/iupmat_key.c", "srccontrols/matrix/iupmat_mark.c",
    "srccontrols/matrix/iupmat_aux.c", "srccontrols/matrix/iupmat_mem.c",
    "srccontrols/matrix/iupmat_mouse.c", "srccontrols/matrix/iupmat_numlc.c",
    "srccontrols/matrix/iupmat_colres.c", "srccontrols/matrix/iupmat_draw.c",
    "srccontrols/matrix/iupmat_getset.c", "srccontrols/matrix/iupmatrix.c",
    "srccontrols/matrix/iupmat_scroll.c", "srccontrols/matrix/iupmat_edit.c",
    "srccontrols/matrix/iupmat_ex.c",
    "srccontrols/matrixex/iup_matrixex.c", "srccontrols/matrixex/iupmatex_clipboard.c",
    "srccontrols/matrixex/iupmatex_busy.c", "srccontrols/matrixex/iupmatex_export.c",
    "srccontrols/matrixex/iupmatex_visible.c", "srccontrols/matrixex/iupmatex_copy.c",
    "srccontrols/matrixex/iupmatex_units.c", "srccontrols/matrixex/iupmatex_find.c",
    "srccontrols/matrixex/iupmatex_undo.c", "srccontrols/matrixex/iupmatex_sort.c"
)
$IupIm = @("srcim/iup_im.c")

foreach ($s in ($ImgLib + $IupGl + $GlControls + $IupCd + $IupControls + $IupIm)) {
    $o = Compile-C $s
    if ($o) { $AllObjs += $o }
}

# ===================================================================
# 7. CD / IM / Plot / TUIO / OLE / MglPlot (C++ modules)
# ===================================================================
Write-Host "`n[3/8] IUP C++ Modules (Plot, TUIO, MglPlot, OLE)" -ForegroundColor Yellow

$IupPlot = @(
    "srcplot/iup_plot_ctrl.cpp", "srcplot/iup_plot_attrib.cpp",
    "srcplot/iupPlot.cpp", "srcplot/iupPlotCalc.cpp", "srcplot/iupPlotDraw.cpp",
    "srcplot/iupPlotAxis.cpp", "srcplot/iupPlotData.cpp", "srcplot/iupPlotTick.cpp"
)

$Tuio = @(
    "srctuio/iup_tuio.cpp",
    "srctuio/tuio/FlashSender.cpp", "srctuio/tuio/TcpReceiver.cpp",
    "srctuio/tuio/TuioClient.cpp", "srctuio/tuio/TuioDispatcher.cpp",
    "srctuio/tuio/TuioPoint.cpp", "srctuio/tuio/UdpReceiver.cpp",
    "srctuio/tuio/OneEuroFilter.cpp", "srctuio/tuio/TcpSender.cpp",
    "srctuio/tuio/TuioContainer.cpp", "srctuio/tuio/TuioManager.cpp",
    "srctuio/tuio/TuioServer.cpp", "srctuio/tuio/UdpSender.cpp",
    "srctuio/tuio/OscReceiver.cpp", "srctuio/tuio/TuioBlob.cpp",
    "srctuio/tuio/TuioCursor.cpp", "srctuio/tuio/TuioObject.cpp",
    "srctuio/tuio/TuioTime.cpp", "srctuio/tuio/WebSockSender.cpp",
    "srctuio/oscpack/ip/IpEndpointName.cpp",
    "srctuio/oscpack/ip/win32/NetworkingUtils.cpp",
    "srctuio/oscpack/ip/win32/UdpSocket.cpp",
    "srctuio/oscpack/osc/OscTypes.cpp",
    "srctuio/oscpack/osc/OscOutboundPacketStream.cpp",
    "srctuio/oscpack/osc/OscReceivedElements.cpp",
    "srctuio/oscpack/osc/OscPrintReceivedElements.cpp"
)

$MglPlot = @(
    "srcmglplot/iup_mglplot.cpp",
    "srcmglplot/src/addon.cpp", "srcmglplot/src/complex.cpp",
    "srcmglplot/src/data_gr.cpp", "srcmglplot/src/evalp.cpp",
    "srcmglplot/src/fit.cpp", "srcmglplot/src/pde.cpp", "srcmglplot/src/vect.cpp",
    "srcmglplot/src/axis.cpp", "srcmglplot/src/complex_io.cpp",
    "srcmglplot/src/data_io.cpp", "srcmglplot/src/exec.cpp",
    "srcmglplot/src/font.cpp", "srcmglplot/src/pixel.cpp",
    "srcmglplot/src/volume.cpp", "srcmglplot/src/base.cpp",
    "srcmglplot/src/cont.cpp", "srcmglplot/src/data_png.cpp",
    "srcmglplot/src/export.cpp", "srcmglplot/src/obj.cpp",
    "srcmglplot/src/plot.cpp", "srcmglplot/src/window.cpp",
    "srcmglplot/src/base_cf.cpp", "srcmglplot/src/crust.cpp",
    "srcmglplot/src/export_2d.cpp", "srcmglplot/src/opengl.cpp",
    "srcmglplot/src/prim.cpp", "srcmglplot/src/canvas.cpp",
    "srcmglplot/src/data.cpp", "srcmglplot/src/eval.cpp",
    "srcmglplot/src/export_3d.cpp", "srcmglplot/src/other.cpp",
    "srcmglplot/src/surf.cpp", "srcmglplot/src/canvas_cf.cpp",
    "srcmglplot/src/data_ex.cpp", "srcmglplot/src/evalc.cpp",
    "srcmglplot/src/fft.cpp", "srcmglplot/src/parser.cpp",
    "srcmglplot/src/complex_ex.cpp", "srcmglplot/src/fractal.cpp",
    "srcmglplot/src/s_hull/s_hull_pro.cpp"
)

$Ole = @(
    "srcole/iup_olecontrol.cpp", "srcole/tLegacy.cpp",
    "srcole/tAmbientProperties.cpp", "srcole/tDispatch.cpp",
    "srcole/tOleClientSite.cpp", "srcole/tOleControlSite.cpp",
    "srcole/tOleHandler.cpp", "srcole/tOleInPlaceFrame.cpp",
    "srcole/tOleInPlaceSite.cpp"
)

foreach ($s in ($IupPlot + $Tuio + $MglPlot + $Ole)) {
    $o = Compile-Cxx $s
    if ($o) { $AllObjs += $o }
}

# ===================================================================
# 8. CD Library
# ===================================================================
Write-Host "`n[4/8] CD Library (Canvas Draw)" -ForegroundColor Yellow

$CdCommon = @(
    "cd/src/cd.c", "cd/src/wd.c", "cd/src/wdhdcpy.c", "cd/src/rgb2map.c",
    "cd/src/cd_vectortext.c", "cd/src/cd_active.c", "cd/src/cd_attributes.c",
    "cd/src/cd_bitmap.c", "cd/src/cd_image.c", "cd/src/cd_primitives.c",
    "cd/src/cd_text.c", "cd/src/cd_util.c"
)
$CdWin32 = @(
    "cd/src/win32/cdwclp.c", "cd/src/win32/cdwemf.c", "cd/src/win32/cdwimg.c",
    "cd/src/win32/cdwin.c", "cd/src/win32/cdwnative.c", "cd/src/win32/cdwprn.c",
    "cd/src/win32/cdwwmf.c", "cd/src/win32/wmf_emf.c", "cd/src/win32/cdwdbuf.c",
    "cd/src/win32/cdwdib.c"
)
$CdDrv = @(
    "cd/src/drv/cddgn.c", "cd/src/drv/cdcgm.c", "cd/src/drv/cgm.c",
    "cd/src/drv/cddxf.c", "cd/src/drv/cdirgb.c", "cd/src/drv/cdmf.c",
    "cd/src/drv/cdps.c", "cd/src/drv/cdpicture.c", "cd/src/drv/cddebug.c",
    "cd/src/drv/cdpptx.c", "cd/src/drv/pptx.c"
)
$CdSvg = @("cd/src/svg/base64.c", "cd/src/svg/lodepng.c", "cd/src/svg/cdsvg.c")
$CdIntCgm = @(
    "cd/src/intcgm/cd_intcgm.c", "cd/src/intcgm/cgm_bin_get.c",
    "cd/src/intcgm/cgm_bin_parse.c", "cd/src/intcgm/cgm_list.c",
    "cd/src/intcgm/cgm_play.c", "cd/src/intcgm/cgm_sism.c",
    "cd/src/intcgm/cgm_txt_get.c", "cd/src/intcgm/cgm_txt_parse.c"
)
$CdSim = @(
    "cd/src/sim/cdfontex.c", "cd/src/sim/sim.c", "cd/src/sim/cd_truetype.c",
    "cd/src/sim/sim_primitives.c", "cd/src/sim/sim_text.c",
    "cd/src/sim/sim_linepolyfill.c"
)
$CdMiniZip = @(
    "cd/src/minizip/ioapi.c", "cd/src/minizip/minizip.c", "cd/src/minizip/zip.c",
    "cd/src/minizip/miniunzip.c", "cd/src/minizip/unzip.c"
)
$CdGL = @("cd/src/drv/cdgl.c")

foreach ($s in ($CdCommon + $CdWin32 + $CdDrv + $CdSvg + $CdIntCgm + $CdSim + $CdMiniZip + $CdGL)) {
    $o = Compile-C $s
    if ($o) { $AllObjs += $o }
}

# CD contextplus (GDI+)
$CdCtxPlusCpp = @(
    "cd/src/gdiplus/cdwemfp.cpp", "cd/src/gdiplus/cdwimgp.cpp",
    "cd/src/gdiplus/cdwinp.cpp", "cd/src/gdiplus/cdwnativep.cpp",
    "cd/src/gdiplus/cdwprnp.cpp", "cd/src/gdiplus/cdwdbufp.cpp",
    "cd/src/gdiplus/cdwclpp.cpp"
)
$CdCtxPlusC = @("cd/src/gdiplus/cdwgdiplus.c")

foreach ($s in ($CdCtxPlusCpp + $CdCtxPlusC)) {
    if ($s -match "\.cpp$") {
        $o = Compile-Cxx $s
    } else {
        $o = Compile-C $s
    }
    if ($o) { $AllObjs += $o }
}

# ===================================================================
# 9. IM Library
# ===================================================================
Write-Host "`n[5/8] IM Library (Imaging)" -ForegroundColor Yellow

$ImCoreCpp = @(
    "im/src/im_attrib.cpp", "im/src/im_format.cpp", "im/src/im_format_tga.cpp",
    "im/src/im_filebuffer.cpp", "im/src/im_bin.cpp", "im/src/im_format_all.cpp",
    "im/src/im_format_raw.cpp", "im/src/im_convertopengl.cpp",
    "im/src/im_binfile.cpp", "im/src/im_format_sgi.cpp", "im/src/im_datatype.cpp",
    "im/src/im_format_pcx.cpp", "im/src/im_colorhsi.cpp", "im/src/im_format_bmp.cpp",
    "im/src/im_image.cpp", "im/src/im_rgb2map.cpp", "im/src/im_colormode.cpp",
    "im/src/im_format_gif.cpp", "im/src/im_lib.cpp", "im/src/im_format_pnm.cpp",
    "im/src/im_colorutil.cpp", "im/src/im_format_ico.cpp", "im/src/im_palette.cpp",
    "im/src/im_format_ras.cpp", "im/src/im_convertbitmap.cpp",
    "im/src/im_format_led.cpp", "im/src/im_counter.cpp", "im/src/im_str.cpp",
    "im/src/im_convertcolor.cpp", "im/src/im_fileraw.cpp",
    "im/src/im_format_krn.cpp", "im/src/im_compress.cpp", "im/src/im_file.cpp",
    "im/src/im_old.cpp", "im/src/im_format_pfm.cpp",
    "im/src/im_converttype.cpp", "im/src/im_format_tiff.cpp",
    "im/src/im_format_png.cpp", "im/src/im_format_jpeg.cpp",
    "im/src/im_sysfile_win32.cpp", "im/src/im_dib.cpp", "im/src/im_dibxbitmap.cpp"
)
$ImCoreC = @("im/src/im_oldcolor.c", "im/src/im_oldresize.c")

$ImLibTiff = @(
    "im/src/libtiff/tif_aux.c", "im/src/libtiff/tif_dirwrite.c",
    "im/src/libtiff/tif_jpeg.c", "im/src/libtiff/tif_print.c",
    "im/src/libtiff/tif_close.c", "im/src/libtiff/tif_dumpmode.c",
    "im/src/libtiff/tif_luv.c", "im/src/libtiff/tif_read.c",
    "im/src/libtiff/tif_codec.c", "im/src/libtiff/tif_error.c",
    "im/src/libtiff/tif_lzw.c", "im/src/libtiff/tif_strip.c",
    "im/src/libtiff/tif_color.c", "im/src/libtiff/tif_extension.c",
    "im/src/libtiff/tif_next.c", "im/src/libtiff/tif_swab.c",
    "im/src/libtiff/tif_compress.c", "im/src/libtiff/tif_fax3.c",
    "im/src/libtiff/tif_open.c", "im/src/libtiff/tif_thunder.c",
    "im/src/libtiff/tif_dir.c", "im/src/libtiff/tif_fax3sm.c",
    "im/src/libtiff/tif_packbits.c", "im/src/libtiff/tif_tile.c",
    "im/src/libtiff/tif_dirinfo.c", "im/src/libtiff/tif_flush.c",
    "im/src/libtiff/tif_pixarlog.c", "im/src/libtiff/tif_zip.c",
    "im/src/libtiff/tif_dirread.c", "im/src/libtiff/tif_getimage.c",
    "im/src/libtiff/tif_predict.c", "im/src/libtiff/tif_version.c",
    "im/src/libtiff/tif_write.c", "im/src/libtiff/tif_warning.c",
    "im/src/libtiff/tif_ojpeg.c", "im/src/libtiff/tif_lzma.c",
    "im/src/libtiff/tif_jbig.c", "im/src/tiff_binfile.c"
)

$ImLibJpeg = @(
    "im/src/libjpeg/jcapimin.c", "im/src/libjpeg/jcmarker.c",
    "im/src/libjpeg/jdapimin.c", "im/src/libjpeg/jdinput.c",
    "im/src/libjpeg/jdtrans.c", "im/src/libjpeg/jcapistd.c",
    "im/src/libjpeg/jcmaster.c", "im/src/libjpeg/jdapistd.c",
    "im/src/libjpeg/jdmainct.c", "im/src/libjpeg/jerror.c",
    "im/src/libjpeg/jmemmgr.c", "im/src/libjpeg/jccoefct.c",
    "im/src/libjpeg/jcomapi.c", "im/src/libjpeg/jdatadst.c",
    "im/src/libjpeg/jdmarker.c", "im/src/libjpeg/jfdctflt.c",
    "im/src/libjpeg/jmemnobs.c", "im/src/libjpeg/jccolor.c",
    "im/src/libjpeg/jcparam.c", "im/src/libjpeg/jdatasrc.c",
    "im/src/libjpeg/jdmaster.c", "im/src/libjpeg/jfdctfst.c",
    "im/src/libjpeg/jquant1.c", "im/src/libjpeg/jcdctmgr.c",
    "im/src/libjpeg/jdcoefct.c", "im/src/libjpeg/jdmerge.c",
    "im/src/libjpeg/jfdctint.c", "im/src/libjpeg/jquant2.c",
    "im/src/libjpeg/jchuff.c", "im/src/libjpeg/jcprepct.c",
    "im/src/libjpeg/jdcolor.c", "im/src/libjpeg/jidctflt.c",
    "im/src/libjpeg/jutils.c", "im/src/libjpeg/jdarith.c",
    "im/src/libjpeg/jcinit.c", "im/src/libjpeg/jcsample.c",
    "im/src/libjpeg/jddctmgr.c", "im/src/libjpeg/jdpostct.c",
    "im/src/libjpeg/jidctfst.c", "im/src/libjpeg/jaricom.c",
    "im/src/libjpeg/jcmainct.c", "im/src/libjpeg/jctrans.c",
    "im/src/libjpeg/jdhuff.c", "im/src/libjpeg/jdsample.c",
    "im/src/libjpeg/jidctint.c", "im/src/libjpeg/jcarith.c"
)

$ImLibPng = @(
    "im/src/libpng/png.c", "im/src/libpng/pngget.c", "im/src/libpng/pngread.c",
    "im/src/libpng/pngrutil.c", "im/src/libpng/pngwtran.c", "im/src/libpng/pngerror.c",
    "im/src/libpng/pngmem.c", "im/src/libpng/pngrio.c", "im/src/libpng/pngset.c",
    "im/src/libpng/pngwio.c", "im/src/libpng/pngpread.c", "im/src/libpng/pngrtran.c",
    "im/src/libpng/pngtrans.c", "im/src/libpng/pngwrite.c", "im/src/libpng/pngwutil.c"
)
$ImLzf = @("im/src/liblzf/lzf_c.c", "im/src/liblzf/lzf_d.c")
$ImLz4 = @("im/src/lz4/lz4.c")

foreach ($s in ($ImCoreCpp + $ImCoreC + $ImLibTiff + $ImLibJpeg + $ImLibPng + $ImLzf + $ImLz4)) {
    if ($s -match "\.cpp$") {
        $o = Compile-Cxx $s
    } else {
        $o = Compile-C $s
    }
    if ($o) { $AllObjs += $o }
}

# ===================================================================
# 10. Scintilla
# ===================================================================
Write-Host "`n[6/8] Scintilla" -ForegroundColor Yellow

$SciBase = "srcscintilla/scintilla3112"
$SciC = @(
    "srcscintilla/iup_scintilla.c", "srcscintilla/iup_scintilladlg.c",
    "srcscintilla/iup_scintilla_win.c", "srcscintilla/iupsci_clipboard.c",
    "srcscintilla/iupsci_folding.c", "srcscintilla/iupsci_lexer.c",
    "srcscintilla/iupsci_margin.c", "srcscintilla/iupsci_overtype.c",
    "srcscintilla/iupsci_scrolling.c", "srcscintilla/iupsci_selection.c",
    "srcscintilla/iupsci_style.c", "srcscintilla/iupsci_tab.c",
    "srcscintilla/iupsci_text.c", "srcscintilla/iupsci_wordwrap.c",
    "srcscintilla/iupsci_markers.c", "srcscintilla/iupsci_bracelight.c",
    "srcscintilla/iupsci_cursor.c", "srcscintilla/iupsci_whitespace.c",
    "srcscintilla/iupsci_annotation.c", "srcscintilla/iupsci_autocompletion.c",
    "srcscintilla/iupsci_searching.c", "srcscintilla/iupsci_print.c",
    "srcscintilla/iupsci_indicator.c"
)

$SciSrc = @(
    "$SciBase/src/AutoComplete.cxx", "$SciBase/src/CallTip.cxx",
    "$SciBase/src/Catalogue.cxx", "$SciBase/src/CellBuffer.cxx",
    "$SciBase/src/CharClassify.cxx", "$SciBase/src/ContractionState.cxx",
    "$SciBase/src/Decoration.cxx", "$SciBase/src/Document.cxx",
    "$SciBase/src/Editor.cxx", "$SciBase/src/ExternalLexer.cxx",
    "$SciBase/src/Indicator.cxx", "$SciBase/src/KeyMap.cxx",
    "$SciBase/src/LineMarker.cxx", "$SciBase/src/PerLine.cxx",
    "$SciBase/src/PositionCache.cxx", "$SciBase/src/RESearch.cxx",
    "$SciBase/src/RunStyles.cxx", "$SciBase/src/ScintillaBase.cxx",
    "$SciBase/src/Selection.cxx", "$SciBase/src/Style.cxx",
    "$SciBase/src/UniConversion.cxx", "$SciBase/src/ViewStyle.cxx",
    "$SciBase/src/XPM.cxx", "$SciBase/src/CaseConvert.cxx",
    "$SciBase/src/CaseFolder.cxx", "$SciBase/src/EditModel.cxx",
    "$SciBase/src/EditView.cxx", "$SciBase/src/MarginView.cxx",
    "$SciBase/src/DBCS.cxx", "$SciBase/src/UniqueString.cxx",
    "$SciBase/win32/PlatWin.cxx", "$SciBase/win32/ScintillaWin.cxx",
    "$SciBase/win32/HanjaDic.cxx",
    "$SciBase/lexlib/Accessor.cxx", "$SciBase/lexlib/CharacterSet.cxx",
    "$SciBase/lexlib/LexerBase.cxx", "$SciBase/lexlib/LexerModule.cxx",
    "$SciBase/lexlib/LexerNoExceptions.cxx",
    "$SciBase/lexlib/LexerSimple.cxx", "$SciBase/lexlib/PropSetSimple.cxx",
    "$SciBase/lexlib/StyleContext.cxx", "$SciBase/lexlib/WordList.cxx",
    "$SciBase/lexlib/CharacterCategory.cxx", "$SciBase/lexlib/DefaultLexer.cxx"
)

$SciLexers = @(
    "$SciBase/lexers/LexLPeg.cxx",
    "$SciBase/lexers/LexA68k.cxx", "$SciBase/lexers/LexAbaqus.cxx",
    "$SciBase/lexers/LexAda.cxx", "$SciBase/lexers/LexAPDL.cxx",
    "$SciBase/lexers/LexAsn1.cxx", "$SciBase/lexers/LexASY.cxx",
    "$SciBase/lexers/LexAU3.cxx", "$SciBase/lexers/LexAVE.cxx",
    "$SciBase/lexers/LexAVS.cxx", "$SciBase/lexers/LexBaan.cxx",
    "$SciBase/lexers/LexBash.cxx", "$SciBase/lexers/LexBasic.cxx",
    "$SciBase/lexers/LexBullant.cxx", "$SciBase/lexers/LexCaml.cxx",
    "$SciBase/lexers/LexCLW.cxx", "$SciBase/lexers/LexCmake.cxx",
    "$SciBase/lexers/LexCOBOL.cxx", "$SciBase/lexers/LexCoffeeScript.cxx",
    "$SciBase/lexers/LexConf.cxx", "$SciBase/lexers/LexCPP.cxx",
    "$SciBase/lexers/LexCrontab.cxx", "$SciBase/lexers/LexCsound.cxx",
    "$SciBase/lexers/LexCSS.cxx", "$SciBase/lexers/LexD.cxx",
    "$SciBase/lexers/LexECL.cxx", "$SciBase/lexers/LexEiffel.cxx",
    "$SciBase/lexers/LexErlang.cxx", "$SciBase/lexers/LexEScript.cxx",
    "$SciBase/lexers/LexFlagship.cxx", "$SciBase/lexers/LexForth.cxx",
    "$SciBase/lexers/LexFortran.cxx", "$SciBase/lexers/LexGAP.cxx",
    "$SciBase/lexers/LexGui4Cli.cxx", "$SciBase/lexers/LexHaskell.cxx",
    "$SciBase/lexers/LexHTML.cxx", "$SciBase/lexers/LexInno.cxx",
    "$SciBase/lexers/LexKix.cxx", "$SciBase/lexers/LexLisp.cxx",
    "$SciBase/lexers/LexLout.cxx", "$SciBase/lexers/LexLua.cxx",
    "$SciBase/lexers/LexMagik.cxx", "$SciBase/lexers/LexMarkdown.cxx",
    "$SciBase/lexers/LexMatlab.cxx", "$SciBase/lexers/LexMetapost.cxx",
    "$SciBase/lexers/LexMMIXAL.cxx", "$SciBase/lexers/LexModula.cxx",
    "$SciBase/lexers/LexMPT.cxx", "$SciBase/lexers/LexMSSQL.cxx",
    "$SciBase/lexers/LexMySQL.cxx", "$SciBase/lexers/LexNimrod.cxx",
    "$SciBase/lexers/LexNsis.cxx", "$SciBase/lexers/LexOpal.cxx",
    "$SciBase/lexers/LexOScript.cxx", "$SciBase/lexers/LexPascal.cxx",
    "$SciBase/lexers/LexPB.cxx", "$SciBase/lexers/LexPerl.cxx",
    "$SciBase/lexers/LexPLM.cxx", "$SciBase/lexers/LexPO.cxx",
    "$SciBase/lexers/LexPOV.cxx", "$SciBase/lexers/LexPowerPro.cxx",
    "$SciBase/lexers/LexPowerShell.cxx", "$SciBase/lexers/LexProgress.cxx",
    "$SciBase/lexers/LexPS.cxx", "$SciBase/lexers/LexPython.cxx",
    "$SciBase/lexers/LexR.cxx", "$SciBase/lexers/LexRebol.cxx",
    "$SciBase/lexers/LexRuby.cxx", "$SciBase/lexers/LexScriptol.cxx",
    "$SciBase/lexers/LexSmalltalk.cxx", "$SciBase/lexers/LexSML.cxx",
    "$SciBase/lexers/LexSorcus.cxx", "$SciBase/lexers/LexSpecman.cxx",
    "$SciBase/lexers/LexSpice.cxx", "$SciBase/lexers/LexSQL.cxx",
    "$SciBase/lexers/LexTACL.cxx", "$SciBase/lexers/LexTADS3.cxx",
    "$SciBase/lexers/LexTAL.cxx", "$SciBase/lexers/LexTCL.cxx",
    "$SciBase/lexers/LexTCMD.cxx", "$SciBase/lexers/LexTeX.cxx",
    "$SciBase/lexers/LexTxt2tags.cxx", "$SciBase/lexers/LexVB.cxx",
    "$SciBase/lexers/LexVerilog.cxx", "$SciBase/lexers/LexVHDL.cxx",
    "$SciBase/lexers/LexVisualProlog.cxx", "$SciBase/lexers/LexYAML.cxx",
    "$SciBase/lexers/LexKVIrc.cxx", "$SciBase/lexers/LexLaTeX.cxx",
    "$SciBase/lexers/LexSTTXT.cxx", "$SciBase/lexers/LexRust.cxx",
    "$SciBase/lexers/LexDMAP.cxx", "$SciBase/lexers/LexDMIS.cxx",
    "$SciBase/lexers/LexBibTeX.cxx", "$SciBase/lexers/LexHex.cxx",
    "$SciBase/lexers/LexAsm.cxx", "$SciBase/lexers/LexRegistry.cxx",
    "$SciBase/lexers/LexLed.cxx", "$SciBase/lexers/LexBatch.cxx",
    "$SciBase/lexers/LexDiff.cxx", "$SciBase/lexers/LexErrorList.cxx",
    "$SciBase/lexers/LexMake.cxx", "$SciBase/lexers/LexNull.cxx",
    "$SciBase/lexers/LexProps.cxx", "$SciBase/lexers/LexJSON.cxx",
    "$SciBase/lexers/LexEDIFACT.cxx", "$SciBase/lexers/LexIndent.cxx",
    "$SciBase/lexers/LexCIL.cxx", "$SciBase/lexers/LexDataflex.cxx",
    "$SciBase/lexers/LexHollywood.cxx", "$SciBase/lexers/LexMaxima.cxx",
    "$SciBase/lexers/LexNim.cxx", "$SciBase/lexers/LexSAS.cxx",
    "$SciBase/lexers/LexStata.cxx", "$SciBase/lexers/LexX12.cxx"
)

foreach ($s in $SciC) {
    $o = Compile-C $s
    if ($o) { $AllObjs += $o }
}
foreach ($s in ($SciSrc + $SciLexers)) {
    $o = Compile-Cxx $s
    if ($o) { $AllObjs += $o }
}

# ===================================================================
# 11. ftgl stub
# ===================================================================
Write-Host "`n[7/8] FTGL Stub" -ForegroundColor Yellow
$ftglObj = Compile-Cxx "build/ftgl_stub.cpp"
if ($ftglObj) { $AllObjs += $ftglObj }

# ===================================================================
# 12. Link DLL
# ===================================================================
Write-Host "`n[8/8] Linking iup.dll" -ForegroundColor Yellow

# Write response file (avoid command-line length limit)
$rspFile = "$ObjDir\link.rsp"
$AllObjs | ForEach-Object { "`"$_`"" } | Out-File -FilePath $rspFile -Encoding ascii

$SysLibs = @(
    "kernel32.lib", "user32.lib", "gdi32.lib", "comdlg32.lib", "advapi32.lib",
    "shell32.lib", "ole32.lib", "oleaut32.lib", "uuid.lib", "comctl32.lib",
    "msimg32.lib", "imm32.lib", "ws2_32.lib", "winmm.lib",
    "shlwapi.lib", "gdiplus.lib", "winspool.lib",
    "opengl32.lib", "glu32.lib"
)
$VcpkgLibs = @("freetype.lib", "zlib.lib")

$LibPaths = @(
    "/LIBPATH:`"$MsvcPath\lib\x64`"",
    "/LIBPATH:`"$SdkLibPath\um\x64`"",
    "/LIBPATH:`"$SdkLibPath\ucrt\x64`"",
    "/LIBPATH:`"$VcpkgInstalled\lib`""
)

$LinkLibs = ($SysLibs + $VcpkgLibs | ForEach-Object { "`"$_`"" }) -join " "
$LinkPaths = ($LibPaths -join " ")
$ObjList = $AllObjs -join " "

Write-Host "  Objects: $($AllObjs.Count)" -ForegroundColor Gray
Write-Host "  Output:  $DllOut" -ForegroundColor Gray

# Link: 使用 __declspec(dllexport) 自动导出，不需要 .def
$linkCmd = "link.exe /NOLOGO /DLL /MACHINE:X64 /LTCG /OPT:REF /OPT:ICF /IMPLIB:`"$LibOut`" /OUT:`"$DllOut`" $LinkPaths $LinkLibs @`"$rspFile`""
Write-Host "  Linking..." -ForegroundColor Gray
$result = cmd /c $linkCmd 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host $result -ForegroundColor Red
    throw "Link failed!"
}

# Verify output
$dllInfo = Get-Item $DllOut -ErrorAction SilentlyContinue
$libInfo = Get-Item $LibOut -ErrorAction SilentlyContinue

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "  MSVC BUILD SUCCESS!" -ForegroundColor Green
if ($dllInfo) { Write-Host "  DLL: $DllOut ($([math]::Round($dllInfo.Length/1MB, 2)) MB)" -ForegroundColor Green }
if ($libInfo) { Write-Host "  LIB: $LibOut" -ForegroundColor Green }
Write-Host "  Compiled: $script:TotalCompiled objects" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Green
