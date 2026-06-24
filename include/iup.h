/** \file
 * \brief IUP 主 API - 跨平台 GUI 工具包 (纯C)
 *
 * 最小程序:
 *   IupOpen(&argc, &argv);                         // 初始化
 *   Ihandle* dlg = IupDialog(IupLabel("Hello"));   // 创建界面
 *   IupShow(dlg);   IupMainLoop();  IupClose();    // 显示+循环+关闭
 */

#ifndef __IUP_H 
#define __IUP_H

#include "iupkey.h"
#include "iupdef.h"
#include "iup_export.h"

#ifdef __cplusplus
extern "C" {
#endif

#define IUP_NAME "IUP - Portable User Interface"
#define IUP_DESCRIPTION "Multi-platform Toolkit for Building Graphical User Interfaces"
#define IUP_COPYRIGHT "Copyright (C) 1994-2025 Tecgraf/PUC-Rio"
#define IUP_VERSION "3.32"
#define IUP_VERSION_NUMBER 332000
#define IUP_VERSION_DATE "2025/01/06"

typedef struct Ihandle_ Ihandle;        /* 控件句柄 */
typedef int (*Icallback)(Ihandle*);      /* 回调函数类型 */

/*========================================================================
 * 一、生命周期: 初始化/关闭/消息循环
 *========================================================================*/
IUP_API int       IupOpen          (int *argc, char ***argv);   /* 初始化 */
IUP_API void      IupClose         (void);                      /* 关闭 */
IUP_API int       IupIsOpened      (void);                      /* 是否已初始化 */
IUPIMGLIB_API void IupImageLibOpen(void);                       /* 打开内置图标库 */
IUP_API int       IupMainLoop      (void);                      /* 主消息循环 */
IUP_API int       IupLoopStep      (void);                      /* 单步循环 */
IUP_API int       IupLoopStepWait  (void);                      /* 单步等待 */
IUP_API int       IupMainLoopLevel (void);                      /* 循环层级 */
IUP_API void      IupFlush         (void);                      /* 刷新事件 */
IUP_API void      IupExitLoop      (void);                      /* 退出循环 */
IUP_API void      IupPostMessage   (Ihandle* ih, const char* s, int i, double d, void* p); /* 投递消息 */
IUP_API int       IupRecordInput(const char* filename, int mode);     /* 录制输入 */
IUP_API int       IupPlayInput(const char* filename);                /* 回放输入 */
IUP_API void      IupUpdate        (Ihandle* ih);                /* 刷新控件 */
IUP_API void      IupUpdateChildren(Ihandle* ih);                /* 刷新子控件 */
IUP_API void      IupRedraw        (Ihandle* ih, int children);  /* 重绘 */
IUP_API void      IupRefresh       (Ihandle* ih);                /* 刷新布局 */
IUP_API void      IupRefreshChildren(Ihandle* ih);               /* 刷新子控件布局 */
IUP_API int       IupExecute(const char *filename, const char* parameters);    /* 执行外部程序 */
IUP_API int       IupExecuteWait(const char *filename, const char* parameters); /* 执行并等待 */
IUP_API int       IupHelp(const char* url);                      /* 打开浏览器帮助 */
IUP_API void      IupLog(const char* type, const char* format, ...); /* 日志 */
IUP_API char*     IupLoad          (const char *filename);       /* 加载LED文件 */
IUP_API char*     IupLoadBuffer    (const char *buffer);         /* 加载LED缓冲 */
IUP_API char*     IupVersion       (void);                       /* 版本号 */
IUP_API char*     IupVersionDate   (void);                       /* 版本日期 */
IUP_API int       IupVersionNumber (void);                       /* 版本数字 */
IUP_API void      IupVersionShow   (void);                       /* 显示版本 */
IUP_API void      IupSetLanguage   (const char *lng);            /* 设置语言 */
IUP_API char*     IupGetLanguage   (void);                       /* 获取语言 */
IUP_API void      IupSetLanguageString(const char* name, const char* str);
IUP_API void      IupStoreLanguageString(const char* name, const char* str);
IUP_API char*     IupGetLanguageString(const char* name);
IUP_API void      IupSetLanguagePack(Ihandle* ih);

/*========================================================================
 * 二、控件树: 创建/销毁/父子关系
 *========================================================================*/
IUP_API void      IupDestroy      (Ihandle* ih);                 /* 销毁控件 */
IUP_API void      IupDetach       (Ihandle* child);              /* 分离子控件 */
IUP_API Ihandle*  IupAppend       (Ihandle* ih, Ihandle* child); /* 追加子控件 */
IUP_API Ihandle*  IupInsert       (Ihandle* ih, Ihandle* ref_child, Ihandle* child); /* 插入 */
IUP_API Ihandle*  IupGetChild     (Ihandle* ih, int pos);        /* 获取子控件 */
IUP_API int       IupGetChildPos  (Ihandle* ih, Ihandle* child); /* 获取位置 */
IUP_API int       IupGetChildCount(Ihandle* ih);                 /* 子控件数 */
IUP_API Ihandle*  IupGetNextChild (Ihandle* ih, Ihandle* child); /* 下一个 */
IUP_API Ihandle*  IupGetBrother   (Ihandle* ih);                 /* 兄弟控件 */
IUP_API Ihandle*  IupGetParent    (Ihandle* ih);                 /* 父控件 */
IUP_API Ihandle*  IupGetDialog    (Ihandle* ih);                 /* 所属对话框 */
IUP_API Ihandle*  IupGetDialogChild(Ihandle* ih, const char* name); /* 按名查找 */
IUP_API int       IupReparent     (Ihandle* ih, Ihandle* new_parent, Ihandle* ref_child); /* 移动父容器 */

/*========================================================================
 * 三、显示: 显示/隐藏/弹出
 *========================================================================*/
IUP_API int       IupPopup         (Ihandle* ih, int x, int y);   /* 弹出(菜单) */
IUP_API int       IupShow          (Ihandle* ih);                 /* 显示 */
IUP_API int       IupShowXY        (Ihandle* ih, int x, int y);   /* 显示在指定位置 */
IUP_API int       IupHide          (Ihandle* ih);                 /* 隐藏 */
IUP_API int       IupMap           (Ihandle* ih);                 /* 映射到屏幕 */
IUP_API void      IupUnmap         (Ihandle* ih);                 /* 取消映射 */

/*========================================================================
 * 四、属性系统 (核心 - 所有控件通过字符串属性控制外观和行为)
 *========================================================================*/
IUP_API void      IupResetAttribute(Ihandle* ih, const char* name);  /* 重置属性 */
IUP_API int       IupGetAllAttributes(Ihandle* ih, char** names, int n);
IUP_API void      IupCopyAttributes(Ihandle* src_ih, Ihandle* dst_ih);
IUP_API Ihandle*  IupSetAtt(const char* handle_name, Ihandle* ih, const char* name, ...);
IUP_API Ihandle*  IupSetAttributes (Ihandle* ih, const char *str);   /* 批量设置 */
IUP_API char*     IupGetAttributes (Ihandle* ih);                    /* 获取所有属性 */
IUP_API void      IupSetAttribute   (Ihandle* ih, const char* name, const char* value);
IUP_API void      IupSetStrAttribute(Ihandle* ih, const char* name, const char* value);
IUP_API void      IupSetStrf        (Ihandle* ih, const char* name, const char* format, ...);
IUP_API void      IupSetInt         (Ihandle* ih, const char* name, int value);
IUP_API void      IupSetFloat       (Ihandle* ih, const char* name, float value);
IUP_API void      IupSetDouble      (Ihandle* ih, const char* name, double value);
IUP_API void      IupSetRGB         (Ihandle* ih, const char* name, unsigned char r, unsigned char g, unsigned char b);
IUP_API void      IupSetRGBA        (Ihandle* ih, const char* name, unsigned char r, unsigned char g, unsigned char b, unsigned char a);
IUP_API char*     IupGetAttribute(Ihandle* ih, const char* name);
IUP_API int       IupGetInt      (Ihandle* ih, const char* name);
IUP_API int       IupGetInt2     (Ihandle* ih, const char* name);
IUP_API int       IupGetIntInt   (Ihandle* ih, const char* name, int *i1, int *i2);
IUP_API float     IupGetFloat    (Ihandle* ih, const char* name);
IUP_API double    IupGetDouble(Ihandle* ih, const char* name);
IUP_API void      IupGetRGB      (Ihandle* ih, const char* name, unsigned char *r, unsigned char *g, unsigned char *b);
IUP_API void      IupGetRGBA     (Ihandle* ih, const char* name, unsigned char *r, unsigned char *g, unsigned char *b, unsigned char *a);
/* 带ID属性 (列表/tree/矩阵) */
IUP_API void  IupSetAttributeId(Ihandle* ih, const char* name, int id, const char *value);
IUP_API void  IupSetStrAttributeId(Ihandle* ih, const char* name, int id, const char *value);
IUP_API void  IupSetStrfId(Ihandle* ih, const char* name, int id, const char* format, ...);
IUP_API void  IupSetIntId(Ihandle* ih, const char* name, int id, int value);
IUP_API void  IupSetFloatId(Ihandle* ih, const char* name, int id, float value);
IUP_API void  IupSetDoubleId(Ihandle* ih, const char* name, int id, double value);
IUP_API void  IupSetRGBId(Ihandle* ih, const char* name, int id, unsigned char r, unsigned char g, unsigned char b);
IUP_API char*  IupGetAttributeId(Ihandle* ih, const char* name, int id);
IUP_API int    IupGetIntId(Ihandle* ih, const char* name, int id);
IUP_API float  IupGetFloatId(Ihandle* ih, const char* name, int id);
IUP_API double IupGetDoubleId(Ihandle* ih, const char* name, int id);
IUP_API void   IupGetRGBId(Ihandle* ih, const char* name, int id, unsigned char *r, unsigned char *g, unsigned char *b);
/* 二维ID (行,列) */
IUP_API void  IupSetAttributeId2(Ihandle* ih, const char* name, int lin, int col, const char* value);
IUP_API void  IupSetStrAttributeId2(Ihandle* ih, const char* name, int lin, int col, const char* value);
IUP_API void  IupSetStrfId2(Ihandle* ih, const char* name, int lin, int col, const char* format, ...);
IUP_API void  IupSetIntId2(Ihandle* ih, const char* name, int lin, int col, int value);
IUP_API void  IupSetFloatId2(Ihandle* ih, const char* name, int lin, int col, float value);
IUP_API void  IupSetDoubleId2(Ihandle* ih, const char* name, int lin, int col, double value);
IUP_API void  IupSetRGBId2(Ihandle* ih, const char* name, int lin, int col, unsigned char r, unsigned char g, unsigned char b);
IUP_API char*  IupGetAttributeId2(Ihandle* ih, const char* name, int lin, int col);
IUP_API int    IupGetIntId2(Ihandle* ih, const char* name, int lin, int col);
IUP_API float  IupGetFloatId2(Ihandle* ih, const char* name, int lin, int col);
IUP_API double IupGetDoubleId2(Ihandle* ih, const char* name, int lin, int col);
IUP_API void   IupGetRGBId2(Ihandle* ih, const char* name, int lin, int col, unsigned char *r, unsigned char *g, unsigned char *b);
/* 全局属性 */
IUP_API void      IupSetGlobal  (const char* name, const char* value);
IUP_API void      IupSetStrGlobal(const char* name, const char* value);
IUP_API char*     IupGetGlobal  (const char* name);
/* 焦点 */
IUP_API Ihandle*  IupSetFocus     (Ihandle* ih);
IUP_API Ihandle*  IupGetFocus     (void);
IUP_API Ihandle*  IupPreviousField(Ihandle* ih);
IUP_API Ihandle*  IupNextField    (Ihandle* ih);
/* 回调 */
IUP_API Icallback IupGetCallback (Ihandle* ih, const char *name);
IUP_API Icallback IupSetCallback (Ihandle* ih, const char *name, Icallback func);
IUP_API Ihandle*  IupSetCallbacks(Ihandle* ih, const char *name, Icallback func, ...);
IUP_API Icallback IupGetFunction(const char *name);
IUP_API Icallback IupSetFunction(const char *name, Icallback func);
/* 命名句柄 */
IUP_API Ihandle*  IupGetHandle    (const char *name);
IUP_API Ihandle*  IupSetHandle    (const char *name, Ihandle* ih);
IUP_API int       IupGetAllNames  (char** names, int n);
IUP_API int       IupGetAllDialogs(char** names, int n);
IUP_API char*     IupGetName      (Ihandle* ih);
/* 属性句柄 */
IUP_API void      IupSetAttributeHandle(Ihandle* ih, const char* name, Ihandle* ih_named);
IUP_API Ihandle*  IupGetAttributeHandle(Ihandle* ih, const char* name);
IUP_API void      IupSetAttributeHandleId(Ihandle* ih, const char* name, int id, Ihandle* ih_named);
IUP_API Ihandle*  IupGetAttributeHandleId(Ihandle* ih, const char* name, int id);
IUP_API void      IupSetAttributeHandleId2(Ihandle* ih, const char* name, int lin, int col, Ihandle* ih_named);
IUP_API Ihandle*  IupGetAttributeHandleId2(Ihandle* ih, const char* name, int lin, int col);
/* 类系统 */
IUP_API char*     IupGetClassName(Ihandle* ih);
IUP_API char*     IupGetClassType(Ihandle* ih);
IUP_API int       IupGetAllClasses(char** names, int n);
IUP_API int       IupGetClassAttributes(const char* classname, char** names, int n);
IUP_API int       IupGetClassCallbacks(const char* classname, char** names, int n);
IUP_API void      IupSaveClassAttributes(Ihandle* ih);
IUP_API void      IupCopyClassAttributes(Ihandle* src_ih, Ihandle* dst_ih);
IUP_API void      IupSetClassDefaultAttribute(const char* classname, const char *name, const char* value);
IUP_API int       IupClassMatch(Ihandle* ih, const char* classname);
/* 动态创建控件 */
IUP_API Ihandle*  IupCreate (const char *classname);
IUP_API Ihandle*  IupCreatev(const char *classname, void* *params);
IUP_API Ihandle*  IupCreatep(const char *classname, void* first, ...);

/*========================================================================
 * 五、控件创建 - 容器
 *========================================================================*/
IUP_API Ihandle*  IupFill (void);          /* 空白填充 */
IUP_API Ihandle*  IupSpace(void);          /* 间距 */
IUP_API Ihandle*  IupRadio      (Ihandle* child);                   /* 单选组 */
IUP_API Ihandle*  IupVbox       (Ihandle* child, ...);              /* 垂直布局 */
IUP_API Ihandle*  IupVboxv      (Ihandle* *children);
IUP_API Ihandle*  IupZbox       (Ihandle* child, ...);              /* 层叠布局 */
IUP_API Ihandle*  IupZboxv      (Ihandle* *children);
IUP_API Ihandle*  IupHbox       (Ihandle* child, ...);              /* 水平布局 */
IUP_API Ihandle*  IupHboxv      (Ihandle* *children);
IUP_API Ihandle*  IupNormalizer (Ihandle* ih_first, ...);           /* 归一化容器 */
IUP_API Ihandle*  IupNormalizerv(Ihandle* *ih_list);
IUP_API Ihandle*  IupCbox       (Ihandle* child, ...);              /* 居中布局 */
IUP_API Ihandle*  IupCboxv      (Ihandle* *children);
IUP_API Ihandle*  IupSbox       (Ihandle* child);                   /* 尺寸约束 */
IUP_API Ihandle*  IupSplit      (Ihandle* child1, Ihandle* child2); /* 分割面板 */
IUP_API Ihandle*  IupScrollBox  (Ihandle* child);                   /* 滚动容器 */
IUP_API Ihandle*  IupFlatScrollBox(Ihandle* child);
IUP_API Ihandle*  IupGridBox    (Ihandle* child, ...);              /* 网格布局 */
IUP_API Ihandle*  IupGridBoxv   (Ihandle* *children);
IUP_API Ihandle*  IupMultiBox   (Ihandle* child, ...);              /* 多视图 */
IUP_API Ihandle*  IupMultiBoxv  (Ihandle **children);
IUP_API Ihandle*  IupExpander(Ihandle* child);                      /* 折叠面板 */
IUP_API Ihandle*  IupDetachBox  (Ihandle* child);                   /* 可分离 */
IUP_API Ihandle*  IupBackgroundBox(Ihandle* child);
IUP_API Ihandle*  IupFrame      (Ihandle* child);                   /* 分组框 */
IUP_API Ihandle*  IupFlatFrame  (Ihandle* child);

/*========================================================================
 * 六、控件创建 - 图像/菜单/按钮/输入
 *========================================================================*/
IUP_API Ihandle*  IupImage      (int width, int height, const unsigned char* pixels);
IUP_API Ihandle*  IupImageRGB   (int width, int height, const unsigned char* pixels);
IUP_API Ihandle*  IupImageRGBA  (int width, int height, const unsigned char* pixels);
IUP_API Ihandle*  IupItem       (const char* title, const char* action);  /* 菜单项 */
IUP_API Ihandle*  IupSubmenu    (const char* title, Ihandle* child);       /* 子菜单 */
IUP_API Ihandle*  IupSeparator  (void);                                   /* 分隔线 */
IUP_API Ihandle*  IupMenu       (Ihandle* child, ...);            /* 菜单栏 */
IUP_API Ihandle*  IupMenuv      (Ihandle* *children);
IUP_API Ihandle*  IupButton     (const char* title, const char* action);  /* 按钮 */
IUP_API Ihandle*  IupFlatButton (const char* title);
IUP_API Ihandle*  IupFlatToggle (const char* title);
IUP_API Ihandle*  IupDropButton (Ihandle* dropchild);
IUP_API Ihandle*  IupFlatLabel  (const char* title);
IUP_API Ihandle*  IupFlatSeparator(void);
IUP_API Ihandle*  IupCanvas     (const char* action);                     /* 画布 */
IUP_API Ihandle*  IupDialog     (Ihandle* child);                         /* 对话框 */
IUP_API Ihandle*  IupUser       (void);                                   /* 用户控件 */
IUP_API Ihandle*  IupThread     (void);                                   /* 线程 */
IUP_API Ihandle*  IupLabel      (const char* title);                      /* 标签 */
IUP_API Ihandle*  IupList       (const char* action);                     /* 列表 */
IUP_API Ihandle*  IupFlatList   (void);
IUP_API Ihandle*  IupText       (const char* action);                     /* 文本输入 */
IUP_API Ihandle*  IupMultiLine  (const char* action);                     /* 多行文本 */
IUP_API Ihandle*  IupToggle     (const char* title, const char* action);  /* 开关 */
IUP_API Ihandle*  IupTimer      (void);                                   /* 定时器 */
IUP_API Ihandle*  IupClipboard  (void);                                   /* 剪贴板 */
IUP_API Ihandle*  IupProgressBar(void);                                   /* 进度条 */
IUP_API Ihandle*  IupVal        (const char *type);                       /* 滑动条 */
IUP_API Ihandle*  IupFlatVal    (const char *type);
IUP_API Ihandle*  IupFlatTree   (void);                                   /* 树形控件 */
IUP_API Ihandle*  IupTabs       (Ihandle* child, ...);            /* 标签页 */
IUP_API Ihandle*  IupTabsv      (Ihandle* *children);
IUP_API Ihandle*  IupFlatTabs   (Ihandle* first, ...);
IUP_API Ihandle*  IupFlatTabsv  (Ihandle* *children);
IUP_API Ihandle*  IupTree       (void);
IUP_API Ihandle*  IupLink       (const char* url, const char* title);     /* 超链接 */
IUP_API Ihandle*  IupAnimatedLabel(Ihandle* animation);
IUP_API Ihandle*  IupDatePick   (void);                                   /* 日期选择 */
IUP_API Ihandle*  IupCalendar   (void);                                   /* 日历 */
IUP_API Ihandle*  IupColorbar   (void);       /* 颜色条 */
IUP_API Ihandle*  IupGauge      (void);       /* 仪表盘 */
IUP_API Ihandle*  IupDial       (const char* type); /* 旋钮 */
IUP_API Ihandle*  IupColorBrowser(void);       /* 颜色浏览器 */
IUP_API Ihandle*  IupSpin       (void);        /* 数值调节 (旧) */
IUP_API Ihandle*  IupSpinbox    (Ihandle* child);

/*========================================================================
 * 七、工具函数
 *========================================================================*/
IUP_API int IupStringCompare(const char* str1, const char* str2, int casesensitive, int lexicographic);
IUP_API int IupSaveImageAsText(Ihandle* ih, const char* filename, const char* format, const char* name);
IUP_API Ihandle* IupImageGetHandle(const char* name);
IUP_API void  IupTextConvertLinColToPos(Ihandle* ih, int lin, int col, int *pos);
IUP_API void  IupTextConvertPosToLinCol(Ihandle* ih, int pos, int *lin, int *col);
IUP_API int   IupConvertXYToPos(Ihandle* ih, int x, int y);
/* 旧版兼容 */
IUP_API void IupStoreGlobal(const char* name, const char* value);
IUP_API void IupStoreAttribute(Ihandle* ih, const char* name, const char* value);
IUP_API void IupSetfAttribute(Ihandle* ih, const char* name, const char* format, ...);
IUP_API void IupStoreAttributeId(Ihandle* ih, const char* name, int id, const char *value);
IUP_API void IupSetfAttributeId(Ihandle* ih, const char* name, int id, const char* f, ...);
IUP_API void IupStoreAttributeId2(Ihandle* ih, const char* name, int lin, int col, const char* value);
IUP_API void IupSetfAttributeId2(Ihandle* ih, const char* name, int lin, int col, const char* format, ...);
/* Tree工具 */
IUP_API int   IupTreeSetUserId(Ihandle* ih, int id, void* userid);
IUP_API void* IupTreeGetUserId(Ihandle* ih, int id);
IUP_API int   IupTreeGetId(Ihandle* ih, void *userid);
IUP_API void  IupTreeSetAttributeHandle(Ihandle* ih, const char* name, int id, Ihandle* ih_named);

/*========================================================================
 * 八、标准对话框
 *========================================================================*/
IUP_API Ihandle* IupFileDlg(void);
IUP_API Ihandle* IupMessageDlg(void);
IUP_API Ihandle* IupColorDlg(void);
IUP_API Ihandle* IupFontDlg(void);
IUP_API Ihandle* IupProgressDlg(void);
IUP_API int  IupGetFile(char *arq);                                     /* 文件选择 */
IUP_API void IupMessage(const char *title, const char *msg);            /* 消息框 */
IUP_API void IupMessagef(const char *title, const char *format, ...);   /* 格式化消息框 */
IUP_API void IupMessageError(Ihandle* parent, const char* message);
IUP_API int IupMessageAlarm(Ihandle* parent, const char* title, const char *message, const char *buttons);
IUP_API int  IupAlarm(const char *title, const char *msg, const char *b1, const char *b2, const char *b3); /* 告警框 */
IUP_API int  IupScanf(const char *format, ...);                         /* 输入框 */
IUP_API int  IupListDialog(int type, const char *title, int size, const char** list, int op, int max_col, int max_lin, int* marks);
IUP_API int  IupGetText(const char* title, char* text, int maxsize);    /* 文本输入 */
IUP_API int  IupGetColor(int x, int y, unsigned char* r, unsigned char* g, unsigned char* b);
typedef int (*Iparamcb)(Ihandle* dialog, int param_index, void* user_data);
IUP_API int IupGetParam(const char* title, Iparamcb action, void* user_data, const char* format,...); /* 参数输入 */
IUP_API int IupGetParamv(const char* title, Iparamcb action, void* user_data, const char* format, int param_count, int param_extra, void** param_data);
IUP_API Ihandle* IupParam(const char* format);
IUP_API Ihandle*  IupParamBox(Ihandle* param, ...);
IUP_API Ihandle*  IupParamBoxv(Ihandle* *param_array);
IUP_API Ihandle* IupLayoutDialog(Ihandle* dialog);                     /* 布局查看 */
IUP_API Ihandle* IupElementPropertiesDialog(Ihandle* parent, Ihandle* elem); /* 属性编辑 */
IUP_API Ihandle* IupGlobalsDialog(void);
IUP_API Ihandle* IupClassInfoDialog(Ihandle* parent);

#ifdef __cplusplus
}
#endif

/*========================================================================
 * 常量: 返回值/回调值/位置/鼠标
 *========================================================================*/
#define IUP_ERROR     1
#define IUP_NOERROR   0
#define IUP_OPENED   -1
#define IUP_INVALID  -1
#define IUP_INVALID_ID -10
#define IUP_IGNORE    -1
#define IUP_DEFAULT   -2
#define IUP_CLOSE     -3
#define IUP_CONTINUE  -4
#define IUP_CENTER        0xFFFF
#define IUP_LEFT          0xFFFE
#define IUP_RIGHT         0xFFFD
#define IUP_MOUSEPOS      0xFFFC
#define IUP_CURRENT       0xFFFB
#define IUP_CENTERPARENT  0xFFFA
#define IUP_LEFTPARENT    0xFFF9
#define IUP_RIGHTPARENT   0xFFF8
#define IUP_TOP           IUP_LEFT
#define IUP_BOTTOM        IUP_RIGHT
#define IUP_TOPPARENT     IUP_LEFTPARENT
#define IUP_BOTTOMPARENT  IUP_RIGHTPARENT

enum{IUP_SHOW, IUP_RESTORE, IUP_MINIMIZE, IUP_MAXIMIZE, IUP_HIDE};
enum{IUP_SBUP, IUP_SBDN, IUP_SBPGUP, IUP_SBPGDN, IUP_SBPOSV, IUP_SBDRAGV, IUP_SBLEFT, IUP_SBRIGHT, IUP_SBPGLEFT, IUP_SBPGRIGHT, IUP_SBPOSH, IUP_SBDRAGH};

#define IUP_BUTTON1   '1'
#define IUP_BUTTON2   '2'
#define IUP_BUTTON3   '3'
#define IUP_BUTTON4   '4'
#define IUP_BUTTON5   '5'
#define iup_isshift(_s)    (_s[0]=='S')
#define iup_iscontrol(_s)  (_s[1]=='C')
#define iup_isbutton1(_s)  (_s[2]=='1')
#define iup_isbutton2(_s)  (_s[3]=='2')
#define iup_isbutton3(_s)  (_s[4]=='3')
#define iup_isdouble(_s)   (_s[5]=='D')
#define iup_isalt(_s)      (_s[6]=='A')
#define iup_issys(_s)      (_s[7]=='Y')
#define iup_isbutton4(_s)  (_s[8]=='4')
#define iup_isbutton5(_s)  (_s[9]=='5')

#define isshift     iup_isshift
#define iscontrol   iup_iscontrol
#define isbutton1   iup_isbutton1
#define isbutton2   iup_isbutton2
#define isbutton3   iup_isbutton3
#define isdouble    iup_isdouble
#define isalt       iup_isalt
#define issys       iup_issys

#define IUP_MASK_FLOAT       "[+/-]?(/d+/.?/d*|/./d+)"
#define IUP_MASK_UFLOAT            "(/d+/.?/d*|/./d+)"
#define IUP_MASK_EFLOAT      "[+/-]?(/d+/.?/d*|/./d+)([eE][+/-]?/d+)?"
#define IUP_MASK_UEFLOAT           "(/d+/.?/d*|/./d+)([eE][+/-]?/d+)?"
#define IUP_MASK_FLOATCOMMA  "[+/-]?(/d+/,?/d*|/,/d+)"
#define IUP_MASK_UFLOATCOMMA       "(/d+/,?/d*|/,/d+)"
#define IUP_MASK_INT          "[+/-]?/d+"
#define IUP_MASK_UINT               "/d+"

enum {IUP_RECBINARY, IUP_RECTEXT};

#define IUP_GETPARAM_OK     -1
#define IUP_GETPARAM_CANCEL -3
#define IUP_GETPARAM_INIT   -2

#endif
