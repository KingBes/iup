/** \file
 * \brief Canvas 自绘 API (无需 CD 库)
 *
 * 所有函数只能在 IupCanvas 的 ACTION 回调中使用，
 * 且必须包裹在 IupDrawBegin / IupDrawEnd 之间。
 *
 * 用法示例:
 *   static int draw(Ihandle* ih) {
 *     IupDrawBegin(ih);
 *     IupSetAttribute(ih, "DRAWCOLOR", "255 0 0");   // 红色
 *     IupDrawLine(ih, 0, 0, 100, 100);               // 画线
 *     IupDrawEnd(ih);
 *     return IUP_DEFAULT;
 *   }
 *   Ihandle* cv = IupCanvas(NULL);
 *   IupSetCallback(cv, "ACTION", draw);
 */

#ifndef __IUPDRAW_H 
#define __IUPDRAW_H

#ifdef __cplusplus
extern "C" {
#endif

/*---------------- 绘制开关 ----------------*/

/* 开始绘制 (必须在 ACTION 回调中调用) */
IUP_API void IupDrawBegin(Ihandle* ih);
/* 结束绘制 */
IUP_API void IupDrawEnd(Ihandle* ih);

/*---------------- 裁剪区域 ----------------*/

/* 设置裁剪矩形 */
IUP_API void IupDrawSetClipRect(Ihandle* ih, int x1, int y1, int x2, int y2);
/* 获取当前裁剪矩形 */
IUP_API void IupDrawGetClipRect(Ihandle* ih, int *x1, int *y1, int *x2, int *y2);
/* 重置裁剪区域 (恢复完整可绘制区域) */
IUP_API void IupDrawResetClip(Ihandle* ih);

/*---------------- 基础图形 (颜色由 DRAWCOLOR 属性控制，样式由 DRAWSTYLE 控制) ----------------*/

/* 画线: (x1,y1)->(x2,y2) */
IUP_API void IupDrawLine(Ihandle* ih, int x1, int y1, int x2, int y2);
/* 画矩形: 左上角(x1,y1) 右下角(x2,y2) */
IUP_API void IupDrawRectangle(Ihandle* ih, int x1, int y1, int x2, int y2);
/* 画弧/椭圆: a1起始角度 a2终止角度 (单位:度) */
IUP_API void IupDrawArc(Ihandle* ih, int x1, int y1, int x2, int y2, double a1, double a2);
/* 画多边形: points = [x1,y1, x2,y2, ...], count=顶点数 */
IUP_API void IupDrawPolygon(Ihandle* ih, int* points, int count);
/* 绘制文本: text内容 len长度, 位置(x,y), 区域(w,h)传0不限 */
IUP_API void IupDrawText(Ihandle* ih, const char* text, int len, int x, int y, int w, int h);
/* 绘制图像: name=图像名 (需先 IupImage 创建) */
IUP_API void IupDrawImage(Ihandle* ih, const char* name, int x, int y, int w, int h);
/* 绘制选择框 (虚线矩形) */
IUP_API void IupDrawSelectRect(Ihandle* ih, int x1, int y1, int x2, int y2);
/* 绘制焦点框 */
IUP_API void IupDrawFocusRect(Ihandle* ih, int x1, int y1, int x2, int y2);
/* 用父控件背景填充 */
IUP_API void IupDrawParentBackground(Ihandle* ih);

/*---------------- 尺寸查询 ----------------*/

/* 获取 Canvas 当前大小 */
IUP_API void IupDrawGetSize(Ihandle* ih, int *w, int *h);
/* 获取文本渲染尺寸 (不实际绘制) */
IUP_API void IupDrawGetTextSize(Ihandle* ih, const char* text, int len, int *w, int *h);
/* 获取图像信息 */
IUP_API void IupDrawGetImageInfo(const char* name, int *w, int *h, int *bpp);

/*---------------- 相关属性说明 ----------------*/
/*
 * DRAWCOLOR     颜色 "R G B" 如 "255 0 0" (红)
 * DRAWSTYLE     "FILL"(填充) 或 "STROKE"(描边)
 * DRAWLINEWIDTH 线宽 (像素)
 * DRAWFONT      字体 (需 CD 库，否则无效)
 * DASHDOT       虚线样式
 */

#ifdef __cplusplus
}
#endif

#endif
