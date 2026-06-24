/** \file
 * \brief OpenGL Canvas 控件
 *
 * 提供 OpenGL 渲染上下文，用法类似 IupCanvas 但使用 GL 绘制。
 * 使用前需调用 IupGLCanvasOpen()。
 * 需要链接 OpenGL (libopengl32)。
 *
 * 用法:
 *   IupGLCanvasOpen();
 *   Ihandle* gl = IupGLCanvas(NULL);
 *   IupSetCallback(gl, "ACTION", gl_render);
 */

#ifndef __IUPGL_H 
#define __IUPGL_H

#ifdef __cplusplus
extern "C" {
#endif

/*---------------- OpenGL 缓冲区属性 (在控件映射前设置) ----------------*/
#define IUP_BUFFER    "BUFFER"      /* "SINGLE"(默认) 或 "DOUBLE"(双缓冲) */
#define IUP_STEREO    "STEREO"      /* "YES"/"NO" 立体视觉 */
#define IUP_BUFFER_SIZE  "BUFFER_SIZE"  /* 索引模式位深 */
#define IUP_RED_SIZE  "RED_SIZE"    /* 红色位数 */
#define IUP_GREEN_SIZE "GREEN_SIZE" /* 绿色位数 */
#define IUP_BLUE_SIZE "BLUE_SIZE"   /* 蓝色位数 */
#define IUP_ALPHA_SIZE "ALPHA_SIZE" /* 透明度位数 */
#define IUP_DEPTH_SIZE "DEPTH_SIZE" /* 深度缓冲位数 */
#define IUP_STENCIL_SIZE "STENCIL_SIZE" /* 模板缓冲位数 */

#define IUP_DOUBLE  "DOUBLE"
#define IUP_SINGLE  "SINGLE"
#define IUP_RGBA    "RGBA"

/* 初始化 OpenGL 绑定 */
void IupGLCanvasOpen(void);

/* 创建 OpenGL 画布控件 */
Ihandle *IupGLCanvas(const char *action);
/* GL 背景框 */
Ihandle* IupGLBackgroundBox(Ihandle* child);

/* 设置当前 GL 上下文 */
void IupGLMakeCurrent(Ihandle* ih);
/* 检查是否为当前上下文 */
int IupGLIsCurrent(Ihandle* ih);
/* 交换缓冲区 (双缓冲模式) */
void IupGLSwapBuffers(Ihandle* ih);
/* 设置调色板 */
void IupGLPalette(Ihandle* ih, int index, float r, float g, float b);
/* 使用位图字体 */
void IupGLUseFont(Ihandle* ih, int first, int count, int list_base);
/* 等待 GL 操作完成 */
void IupGLWait(int gl);

#ifdef __cplusplus
}
#endif

#endif
