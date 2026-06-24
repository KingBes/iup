/** \file
 * \brief 配置文件工具 API (类似 .ini 文件读写)
 *
 * 用于保存/读取应用程序配置，支持分组、键值对。
 * 底层自动使用系统标准配置路径存储。
 *
 * 用法:
 *   Ihandle* cfg = IupConfig();                  // 创建
 *   IupSetAttribute(cfg, "APP_NAME", "MyApp");   // 设应用名
 *   IupConfigLoad(cfg);                           // 加载配置文件
 *   IupConfigSetVariableStr(cfg, "窗口", "位置", "100,200");  // 写入
 *   IupConfigSave(cfg);                           // 保存
 *   const char* pos = IupConfigGetVariableStr(cfg, "窗口", "位置"); // 读取
 */

#ifndef IUP_CONFIG_H
#define IUP_CONFIG_H

#if	defined(__cplusplus)
extern "C" {
#endif

/* 创建配置对象 */
IUP_API Ihandle* IupConfig(void);
/* 从磁盘加载配置 */
IUP_API int IupConfigLoad(Ihandle* ih);
/* 保存配置到磁盘 */
IUP_API int IupConfigSave(Ihandle* ih);

/*---------------- 变量读写 ----------------*/

/* 写入字符串: 参数: group分组, key键, value值 */
IUP_API void IupConfigSetVariableStr(Ihandle* ih, const char* group, const char* key, const char* value);
/* 写入字符串 (带ID下标) */
IUP_API void IupConfigSetVariableStrId(Ihandle* ih, const char* group, const char* key, int id, const char* value);
/* 写入整数 */
IUP_API void IupConfigSetVariableInt(Ihandle* ih, const char* group, const char* key, int value);
IUP_API void IupConfigSetVariableIntId(Ihandle* ih, const char* group, const char* key, int id, int value);
/* 写入浮点 */
IUP_API void IupConfigSetVariableDouble(Ihandle* ih, const char* group, const char* key, double value);
IUP_API void IupConfigSetVariableDoubleId(Ihandle* ih, const char* group, const char* key, int id, double value);

/* 读取字符串 */
IUP_API const char* IupConfigGetVariableStr(Ihandle* ih, const char* group, const char* key);
IUP_API const char* IupConfigGetVariableStrId(Ihandle* ih, const char* group, const char* key, int id);
/* 读取字符串 (可指定默认值) */
IUP_API const char* IupConfigGetVariableStrDef(Ihandle* ih, const char* group, const char* key, const char* def);
/* 读取整数 */
IUP_API int    IupConfigGetVariableInt(Ihandle* ih, const char* group, const char* key);
/* 读取整数 (可指定默认值) */
IUP_API int    IupConfigGetVariableIntDef(Ihandle* ih, const char* group, const char* key, int def);
/* 读取浮点 */
IUP_API double IupConfigGetVariableDouble(Ihandle* ih, const char* group, const char* key);
/* 读取浮点 (可指定默认值) */
IUP_API double IupConfigGetVariableDoubleDef(Ihandle* ih, const char* group, const char* key, double def);

/* 复制配置 */
IUP_API void IupConfigCopy(Ihandle* ih1, Ihandle* ih2, const char* exclude_prefix);

/*---------------- 列表变量、最近文件 ----------------*/

/* 列表变量 (可变长度的键值列表, add=1追加) */
IUP_API void IupConfigSetListVariable(Ihandle* ih, const char *group, const char* key, const char* value, int add);

/* 初始化最近文件菜单 */
IUP_API void IupConfigRecentInit(Ihandle* ih, Ihandle* menu, Icallback recent_cb, int max_recent);
/* 更新最近文件列表 */
IUP_API void IupConfigRecentUpdate(Ihandle* ih, const char* filename);

/* 对话框位置/大小记忆 */
IUP_API void IupConfigDialogShow(Ihandle* ih, Ihandle* dialog, const char* name);
IUP_API void IupConfigDialogClosed(Ihandle* ih, Ihandle* dialog, const char* name);

#if defined(__cplusplus)
}
#endif

#endif
