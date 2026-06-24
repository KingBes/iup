/** \file
 * \brief 图像加载/保存 (基于 IM 库)
 *
 * 从文件加载图像到 IUP 使用，支持 PNG/JPG/BMP/TIFF/GIF 等。
 * 使用前需调用 IupImOpen()，需要链接 IM 库。
 *
 * 用法:
 *   IupImOpen();
 *   Ihandle* img = IupLoadImage("photo.png");
 *   IupSetAttribute(btn, "IMAGE", "photo.png");
 */

#ifndef __IUPIM_H
#define __IUPIM_H

#if	defined(__cplusplus)
extern "C" {
#endif

void IupImOpen(void);  /* 初始化 */

Ihandle* IupLoadImage(const char* filename);           /* 从文件加载图像 */
int IupSaveImage(Ihandle* ih, const char* filename, const char* format); /* 保存图像 */

Ihandle* IupLoadAnimation(const char* filename);       /* 加载动画 (GIF等) */
Ihandle* IupLoadAnimationFrames(const char** filename_list, int file_count); /* 从多帧加载动画 */

#if defined(__cplusplus)
}
#endif

#endif
