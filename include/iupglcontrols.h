/** \file
 * \brief OpenGL 控件库 (按钮、标签、文本框等 OpenGL 版本)
 *
 * 提供基于 OpenGL 渲染的常用控件。
 * 使用前需调用 IupGLControlsOpen()。
 * 需要链接 OpenGL + FTGL (字体库)。
 */

#ifndef __IUPGLCONTROLS_H 
#define __IUPGLCONTROLS_H

#ifdef __cplusplus
extern "C" {
#endif

/* 初始化 GL 控件库 */
int  IupGLControlsOpen(void);

/* 布局容器: IupGLCanvasBox(child1, child2, NULL) */
Ihandle* IupGLCanvasBox(Ihandle* child, ...);

/* 子画布 (在主 GL Canvas 中划分区域) */
Ihandle* IupGLSubCanvas(void);

/* GL 控件 */
Ihandle* IupGLLabel(const char* title);     /* 标签 */
Ihandle* IupGLSeparator(void);              /* 分隔线 */
Ihandle* IupGLButton(const char* title);    /* 按钮 */
Ihandle* IupGLToggle(const char* title);    /* 开关 */
Ihandle* IupGLLink(const char *url, const char * title); /* 超链接 */
Ihandle* IupGLProgressBar(void);            /* 进度条 */
Ihandle* IupGLVal(void);                    /* 滑动条 */
Ihandle* IupGLFrame(Ihandle* child);        /* 分组框 */
Ihandle* IupGLExpander(Ihandle* child);     /* 折叠面板 */
Ihandle* IupGLScrollBox(Ihandle* child);    /* 滚动区域 */
Ihandle* IupGLSizeBox(Ihandle* child);      /* 尺寸约束 */
Ihandle* IupGLText(void);                   /* 文本输入 */

/* GL 绘制工具函数 */
void IupGLDrawImage(Ihandle* ih, const char* name, int x, int y, int active);
void IupGLDrawText(Ihandle* ih, const char* str, int len, int x, int y);
void IupGLDrawGetTextSize(Ihandle* ih, const char* str, int *w, int *h);
void IupGLDrawGetImageInfo(const char* name, int *w, int *h, int *bpp);

#ifdef __cplusplus
}
#endif

#endif
