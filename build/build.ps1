# ===================================================================
#  IUP Single DLL Build Script
#  Windows MSYS2 MinGW64
#  用法: .\build\build.ps1
# ===================================================================

param(
    [switch]$Clean,
    [switch]$Quick  # 跳过 Scintilla 加速编译
)

$ErrorActionPreference = "Stop"
$MSYS2 = "C:\env\msys2"

# 检查 MSYS2
if (-not (Test-Path "$MSYS2\mingw64\bin\gcc.exe")) {
    Write-Host "ERROR: MSYS2 MinGW64 not found at $MSYS2\mingw64\bin\" -ForegroundColor Red
    Write-Host "Please install MSYS2 and run: pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-freetype mingw-w64-x86_64-ftgl mingw-w64-x86_64-zlib mingw-w64-x86_64-make" -ForegroundColor Yellow
    exit 1
}

# 设置环境
$env:Path = "$MSYS2\mingw64\bin;$MSYS2\usr\bin;$env:Path"

Push-Location $PSScriptRoot\..

try {
    if ($Clean) {
        Write-Host "=== Cleaning ===" -ForegroundColor Cyan
        & mingw32-make -f build/Makefile clean
    }
    
    $target = if ($Quick) { "quick" } else { "all" }
    Write-Host "=== Building IUP Single DLL (mode: $target) ===" -ForegroundColor Cyan
    Write-Host "Compiler: $(gcc --version | Select-Object -First 1)" -ForegroundColor Gray
    
    if ($Quick) {
        & mingw32-make -f build/Makefile quick
    } else {
        & mingw32-make -f build/Makefile all -j4
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host "  BUILD SUCCESS!" -ForegroundColor Green
        Write-Host "  DLL:  build\iup.dll" -ForegroundColor Green
        Write-Host "  LIB:  build\iup.a" -ForegroundColor Green
        Write-Host "========================================================" -ForegroundColor Green
        $dll = Get-Item "build\iup.dll"
        Write-Host ("  Size: {0:N0} KB" -f ($dll.Length / 1024)) -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "BUILD FAILED with exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} finally {
    Pop-Location
}
