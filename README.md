# IUP Single DLL Build

将 [IUP](https://www.tecgraf.puc-rio.br/iup/) 3.32 全部模块编译为 **单个零依赖 DLL**，支持 Windows x64。

## 特性

- 单 DLL 文件，无需安装任何运行时
- 包含所有模块：GUI 核心、OpenGL、Scintilla 代码编辑器、MathGL 3D/2D 绘图、TUIO 触控、OLE/COM 控件、CD 矢量绘图、IM 图像处理
- 仅依赖 Windows 系统 DLL（kernel32 / user32 / gdi32 等）

## 构建

### 环境要求

- **MSYS2 MinGW64**（GCC 16+）
- 安装依赖包：
  ```bash
  pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-freetype \
            mingw-w64-x86_64-ftgl mingw-w64-x86_64-zlib mingw-w64-x86_64-make
  ```

### 下载外部库

CD 和 IM 库源码需要从 SourceForge 下载：

```bash
bash scripts/download_deps.sh
```

### 编译 DLL

```bash
# 完整构建（约 5-10 分钟）
mingw32-make -f build/Makefile_full.mak -j4
```

产物：
| 文件 | 说明 |
|------|------|
| `build/iup.dll` | ~18 MB，单 DLL |
| `build/iup.a` | 导入库 |

### 编译测试程序

```bash
gcc -o build/demo.exe test/demo.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
gcc -o build/test.exe test/test.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
```

## 模块清单

| 模块 | 说明 | 来源 |
|------|------|------|
| IUP Core | 窗口、按钮、布局、对话框等基础控件 | `src/` |
| CD 5.14 | Canvas Draw 矢量绘图 | `cd/`（需下载） |
| IM 3.15 | 图像处理（TIFF/JPEG/PNG） | `im/`（需下载） |
| Controls | Matrix、MatrixEx 高级控件 | `srccontrols/` |
| GL Canvas | OpenGL 画布 | `srcgl/` |
| GL Controls | OpenGL 控件（按钮/文本/进度条） | `srcglcontrols/` |
| Plot | 2D 绘图控件 | `srcplot/` |
| MglPlot | 3D/2D 科学绘图（MathGL 内嵌） | `srcmglplot/` |
| Scintilla 3.11.2 | 代码编辑器（130+ 语言语法高亮） | `srcscintilla/` |
| TUIO | 多点触控协议 | `srctuio/` |
| OLE | Windows COM/OLE 控件嵌入 | `srcole/` |
| ImageLib | 内置图标库 | `srcimglib/` |
| IM Bridge | IM 图像库桥接 | `srcim/` |
| CD Bridge | CD 绘图库桥接 | `srccd/` |

## 使用示例

```c
#include <iup.h>
#include <iupcontrols.h>

int main() {
    IupOpen(NULL, NULL);
    IupControlsOpen();

    Ihandle *dlg = IupDialog(
        IupVbox(
            IupLabel("Hello from IUP DLL!"),
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
gcc -o myapp.exe myapp.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
```

## GCC 16 兼容性

本项目已修复 GCC 16 对原始源码的兼容性问题：

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

## 许可

IUP 使用 MIT 许可证。CD 和 IM 同样使用 MIT 许可证。
