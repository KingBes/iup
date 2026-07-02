# IUP Single-Library Build

将 [IUP](https://www.tecgraf.puc-rio.br/iup/) 3.32 全部模块编译为 **单个零外部依赖的动态库**，支持 Windows / Linux / macOS。

[![Build All Platforms](https://github.com/ewmailing/iup/actions/workflows/build.yml/badge.svg)](https://github.com/ewmailing/iup/actions/workflows/build.yml)

## 特性

- 单文件库，无需安装任何第三方运行时
- 包含所有模块：GUI 核心、OpenGL、CD 矢量绘图、IM 图像处理、MathGL 3D/2D 绘图、Scintilla 代码编辑器、TUIO 触控等
- **跨平台**：Windows x64、Linux x64/ARM64、macOS ARM64
- 零外部依赖（仅依赖操作系统系统库）

## 平台支持

| 平台 | 产物 | 后端 |
|------|------|------|
| Windows x86_64 | `iup.dll` (MSVC) / `iup.dll` (MinGW) | Win32 API |
| Linux x86_64 | `libiup.so` | GTK3 |
| Linux aarch64 | `libiup.so` | GTK3 |
| macOS aarch64 | `libiup.dylib` | Cocoa |

### macOS 功能说明

macOS Cocoa 后端部分模块以桩（stub）形式提供，保证库可编译和链接，但对应功能不可用：

| 模块 | 状态 | 说明 |
|------|------|------|
| Scintilla | ⚠️ 桩 | Scintilla 3.11.2 无 Cocoa 后端（仅 gtk/win32） |
| CD | ⚠️ 桩 | CD 无 macOS 原生后端，矢量绘图 API 不可用 |
| Plot / MglPlot | ⚠️ 桩 | 依赖 CD，绘图功能不可用 |
| GL 字体 | ⚠️ 桩 | 依赖 FTGL，GL 文字渲染不可用 |
| OLE | N/A | Windows 专有功能 |

## 构建

### 前置条件

```bash
# 下载 CD 和 IM 库源码
bash scripts/download_deps.sh
```

### Windows (MinGW64)

环境：**MSYS2 MinGW64**（GCC 16+）

```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-freetype \
          mingw-w64-x86_64-ftgl mingw-w64-x86_64-zlib mingw-w64-x86_64-make

mingw32-make -f build/Makefile_full.mak -j4
```

| 产物 | 说明 |
|------|------|
| `build/iup.dll` | ~18 MB，单 DLL |
| `build/iup.a` | 导入库 |

### Windows (MSVC 2022)

```powershell
# 需要安装 vcpkg
vcpkg install freetype zlib --triplet x64-windows-static

.\build\build_msvc_full.ps1
```

| 产物 | 说明 |
|------|------|
| `build/iup.dll` | 单 DLL |
| `build/iup.lib` | 导入库 |

### Linux

```bash
sudo apt-get install -y gcc g++ make pkg-config \
    libgtk-3-dev libglu1-mesa-dev libcairo2-dev libgl1-mesa-dev

bash scripts/build_linux.sh
```

产物输出到 `build/linux/`。

### macOS

```bash
# 仅需 Xcode Command Line Tools + wget
brew install wget

bash scripts/build_macos.sh
```

产物输出到 `build/macos/`。

## 模块清单

| 模块 | 语言 | 说明 |
|------|------|------|
| IUP Core | C | 窗口、按钮、布局、对话框等基础控件 |
| Controls | C | Matrix、MatrixEx 高级表格控件 |
| GL Canvas | C | OpenGL 画布 |
| GL Controls | C | OpenGL 渲染的 GUI 控件 |
| Plot | C++ | 2D 图表绘制 |
| MglPlot | C++ | 3D/2D 科学数据可视化 |
| Scintilla 3.11.2 | C++ | 代码编辑器（130+ 语言语法高亮） |
| TUIO | C++ | 多点触控协议 |
| OLE | C++ | Windows COM/OLE 控件嵌入 |
| CD 5.14 | C | Canvas Draw 矢量绘图 |
| IM 3.15 | C/C++ | 图像处理（TIFF/JPEG/PNG） |
| ImageLib | C | 内置图标库 |

## 使用示例

```c
#include <iup.h>
#include <iupcontrols.h>

int main() {
    IupOpen(NULL, NULL);
    IupControlsOpen();

    Ihandle *dlg = IupDialog(
        IupVbox(
            IupLabel("Hello from IUP!"),
            IupButton("Click Me", NULL),
            NULL));
    IupSetAttribute(dlg, "TITLE", "IUP Demo");
    IupSetAttribute(dlg, "SIZE", "300x200");

    IupShow(dlg);
    IupMainLoop();
    IupClose();
    return 0;
}
```

编译：

```bash
# Windows (MinGW)
gcc -o myapp.exe myapp.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL

# Windows (MSVC)
cl myapp.c /Iinclude /link build/iup.lib

# Linux
gcc -o myapp myapp.c -Iinclude -Lbuild/linux -liup -Wl,-rpath,'$ORIGIN'

# macOS
clang -o myapp myapp.c -Iinclude -Lbuild/macos -liup -Wl,-rpath,@loader_path
```

## 编译器兼容性修复

原始 IUP/CD/IM 源码针对旧版编译器编写，本项目已在以下文件中适配新编译器（GCC 16 / Clang 16+）：

| 文件 | 修复内容 |
|------|----------|
| `src/win/iupwin_info.c` | `ReportEvent` 参数类型转换 |
| `src/win/iupwin_image.c` | `CreateDIBSection` 指针类型 |
| `srctuio/iup_tuio.cpp` | 64 位指针 → int 转换 |
| `srccd/iup_cd.c` | 函数指针类型匹配 |
| `srccd/iup_draw_cd.c` | 同上 |
| `cd/src/win32/cdwclp.c` | `CreateDIBSection` |
| `cd/src/win32/cdwdib.c` | 同上 |
| `cd/src/drv/pptx.c` | `minizip` const 类型 |
| `cd/src/intcgm/cd_intcgm.c` | CGM 函数指针类型 |
| `im/src/im_dib.cpp` | `CreateFile` → `CreateFileA` |
| `im/src/im_sysfile_win32.cpp` | 同上 |
| `srcscintilla/.../Catalogue.cxx` | 移除 LPeg 词法器引用 |
| `srcglcontrols/iup_glfont.c` | 添加 `#include <string.h>`（C99 隐式声明） |
| `src/cocoa/iupcocoa_common.m` | 添加 `iupdrvBaseSetFgColorAttrib` 桩 |
| `src/iup_config.c` | macOS Cocoa 桩移至 `IupAppDelegate.m` |

添加的 macOS 平台桩文件：

| 文件 | 说明 |
|------|------|
| `src/scintilla/iup_scintilla_cocoa.c` | Scintilla Cocoa 平台桩 |
| `src/gl/iup_glcanvas_cocoa.c` | GL Canvas Cocoa 平台桩 |
| `src/cocoa/iupcocoa_str.c` | UTF-8 字符串转换 |
| `build/cd_stub_cocoa.c` | CD 平台符号桩 |
| `build/ftgl_stub.cpp` | FTGL 桩实现 |

## CI/CD

通过 GitHub Actions 自动构建四个平台：

- `windows-x86_64` — MSVC 2022
- `linux-x86_64` — Ubuntu + GTK3
- `linux-aarch64` — Ubuntu ARM64 + GTK3
- `macos-aarch64` — macOS + Cocoa

详见 `.github/workflows/build.yml`。

## 许可

IUP 使用 MIT 许可证。CD 和 IM 同样使用 MIT 许可证。

Copyright (C) 1994-2025 Tecgraf/PUC-Rio.
