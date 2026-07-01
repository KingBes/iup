# ===================================================================
#  IUP Web + FileDlg MSVC Build
#  将 iupweb + iupfiledlg 编译为单独的 .obj，链接到 iup.dll
#  用法: .\build\build_msvc.ps1
# ===================================================================

$ErrorActionPreference = "Stop"

# 查找 MSVC
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    Write-Host "ERROR: vswhere not found. Need Visual Studio." -ForegroundColor Red
    exit 1
}
$vsPath = & $vswhere -latest -products * -property installationPath
$msvcPath = Get-ChildItem "$vsPath\VC\Tools\MSVC" -Directory | Sort-Object Name -Descending | Select-Object -First 1
Write-Host "MSVC: $($msvcPath.FullName)" -ForegroundColor Cyan

# 启动 Developer Command Prompt 环境
$env:Path = "$($msvcPath.FullName)\bin\Hostx64\x64;$env:Path"

$INCLUDES = @(
    "include", "src", "src/win", "src/win/wdl",
    "srccd", "cd/include", "cd/src",
    "im/include", "im/src"
)

$DEFINES = @(
    "IUP_BUILD_LIBRARY", "IUP_DLL",
    "_WIN32_WINNT=0x0601", "WINVER=0x0601",
    "UNICODE", "_UNICODE",
    "COBJMACROS", "USE_NEW_DRAW",
    "_MBCS"
)

$INCLUDE_FLAGS = ($INCLUDES | ForEach-Object { "/I$_" }) -join " "
$DEFINE_FLAGS = ($DEFINES | ForEach-Object { "/D$_" }) -join " "

Write-Host ""
Write-Host "=== Building iupweb.obj ===" -ForegroundColor Yellow
& cl.exe /nologo /c /O2 /MD /EHsc $DEFINE_FLAGS $INCLUDE_FLAGS /Fo"build/obj/iupwin_webbrowser.obj" "srcweb/iupwin_webbrowser.cpp" "srcweb/iup_webbrowser.c"
if ($LASTEXITCODE -ne 0) { throw "iupweb build failed" }

Write-Host ""
Write-Host "=== Building iupfiledlg.obj ===" -ForegroundColor Yellow
& cl.exe /nologo /c /O2 /MD /EHsc $DEFINE_FLAGS $INCLUDE_FLAGS /Fo"build/obj/iupwin_newfiledlg.obj" "srcfiledlg/iupwin_newfiledlg.cpp"
if ($LASTEXITCODE -ne 0) { throw "iupfiledlg build failed" }

Write-Host ""
Write-Host "=== Building iupweb_full.obj ===" -ForegroundColor Yellow
& cl.exe /nologo /c /O2 /MD /EHsc $DEFINE_FLAGS $INCLUDE_FLAGS /Fo"build/obj/iupweb_full.obj" "srcweb/iup_webbrowser.c" "srcweb/iupwin_webbrowser.cpp"
if ($LASTEXITCODE -ne 0) { throw "iupweb_full build failed" }

Write-Host ""
Write-Host "BUILD SUCCESS - .obj files ready" -ForegroundColor Green
Write-Host "To link: add build/obj/iupwin_webbrowser.obj build/obj/iupwin_newfiledlg.obj to DLL link line" -ForegroundColor Gray
Write-Host "Additional libs: comsuppw.lib shlwapi.lib" -ForegroundColor Gray
