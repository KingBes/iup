# ===================================================================
#  IUP Single DLL - 一键构建
#  用法: powershell -File scripts/build.ps1 [-Demo] [-Test]
# ===================================================================
param([switch]$Demo, [switch]$Test)

$ErrorActionPreference = "Stop"
$MSYS2 = "C:\env\msys2"
$ROOT = Split-Path -Parent $PSScriptRoot

# 检查 MSYS2
if (-not (Test-Path "$MSYS2\mingw64\bin\gcc.exe")) {
    Write-Host "ERROR: MSYS2 MinGW64 not found." -ForegroundColor Red
    Write-Host "Install MSYS2 and run:" -ForegroundColor Yellow
    Write-Host "  pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-freetype mingw-w64-x86_64-ftgl mingw-w64-x86_64-zlib mingw-w64-x86_64-make" -ForegroundColor Gray
    exit 1
}

$env:Path = "$MSYS2\mingw64\bin;$MSYS2\usr\bin;$env:Path"

Push-Location $ROOT
try {
    # 检查外部库
    if (-not (Test-Path "cd/src")) {
        Write-Host "[1/3] Downloading external libraries..." -ForegroundColor Cyan
        bash scripts/download_deps.sh
    } else {
        Write-Host "[1/3] External libraries: OK" -ForegroundColor Green
    }

    # 编译 DLL
    Write-Host "[2/3] Building iup.dll..." -ForegroundColor Cyan
    mingw32-make -f build/Makefile_full.mak -j4
    if ($LASTEXITCODE -ne 0) { throw "DLL build failed" }

    # 编译 demo / test
    if ($Demo) {
        Write-Host "[3/3] Building demo.exe..." -ForegroundColor Cyan
        gcc -o build/demo.exe test/demo.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
    }
    if ($Test) {
        Write-Host "[3/3] Building test.exe..." -ForegroundColor Cyan
        gcc -o build/test.exe test/test.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
    }

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "  BUILD SUCCESS" -ForegroundColor Green
    Write-Host "  DLL: build/iup.dll ($([math]::Round((Get-Item build/iup.dll).Length/1MB,1)) MB)" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
} finally {
    Pop-Location
}
