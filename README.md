# IUP - 纯 C 跨平台 GUI 工具包

> 基于 [IUP 3.32](http://www.tecgraf.puc-rio.br/iup)，精简为纯 C，仅保留 Win/Linux/macOS 三平台。

## 平台支持

| 平台   | 驱动         | 编译器       |
|--------|-------------|-------------|
| Windows | Win32 API   | MinGW64 GCC |
| Linux   | GTK+ / Motif | GCC         |
| macOS   | Cocoa       | Clang / GCC |

## 模块

| 模块     | 说明                | 状态 |
|---------|---------------------|------|
| iup     | 核心 GUI (50+ 控件)  | ✅ 无依赖 |
| iupimglib | 内置图标库          | ✅ 无依赖 |
| srcledc   | LED 布局编译器       | ✅ 无依赖 |
| iupgl    | OpenGL 画布         | ✅ 仅需系统 OpenGL |
| iupglcontrols | OpenGL 控件库 | ❌ 需 FTGL 库 |
| iupcontrols | 高级控件 (Matrix等) | ❌ 需 CD 库 |
| iupim    | 图像加载 (PNG/JPG等) | ❌ 需 IM 库 |

## Windows 编译 (MinGW64)

```bash
# MSYS2 MinGW64 shell 中
mingw32-make TEC_UNAME=mingw6_64 MINGW6_64=/mingw64 iup iupgl iupimglib ledc

# DLL 版本
mingw32-make TEC_UNAME=dllw6_64 MINGW6_64=/mingw64 iup
```

## Linux / macOS 编译

```bash
# 自动检测平台
make iup iupimglib ledc
```

## 最小程序

```c
#include <iup.h>

int main(int argc, char **argv) {
    IupOpen(&argc, &argv);
    Ihandle *dlg = IupDialog(IupLabel("Hello, World!"));
    IupSetAttribute(dlg, "TITLE", "Hello");
    IupShow(dlg);
    IupMainLoop();
    IupClose();
    return 0;
}
```

编译运行：
```bash
gcc -o hello hello.c -Iinclude -Llib/dllw6_64 -liup -lgdi32 -lcomctl32 -lcomdlg32 -lole32
```

## 许可证

MIT - Copyright (C) 1994-2025 Tecgraf/PUC-Rio
