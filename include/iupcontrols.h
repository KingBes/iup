/** \file
 * \brief 高级控件: Matrix网格, Cells颜色选择, Dial旋钮, Gauge仪表盘 等
 *
 * 使用前需调用 IupControlsOpen() 初始化。
 * 需要链接 CD 库 (cd.h)。
 */

#ifndef __IUPCONTROLS_H 
#define __IUPCONTROLS_H

#ifdef __cplusplus
extern "C" {
#endif

/* 初始化高级控件库 */
int  IupControlsOpen(void);

/* 颜色选择格子 */
Ihandle* IupCells(void);
/* 网格/电子表格控件: IupMatrix(NULL) */
Ihandle* IupMatrix(const char *action);
/* 矩阵列表控件 */
Ihandle* IupMatrixList(void);
/* 扩展矩阵控件 */
Ihandle* IupMatrixEx(void);

/* 矩阵公式 (需 iupluamatrix) */
void IupMatrixSetFormula(Ihandle* ih, int col, const char* formula, const char* init);
void IupMatrixSetDynamic(Ihandle* ih, const char* init);

#ifdef __cplusplus
}
#endif

#endif
