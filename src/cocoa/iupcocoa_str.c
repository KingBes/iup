/*
 * IUP Cocoa String + File Utilities
 *
 * Provides platform-specific string conversion and file system
 * operations for macOS/Cocoa.
 */

#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#import <Cocoa/Cocoa.h>

#include "iup.h"
#include "iup_str.h"
#include "iup_drv.h"

/* ---- UTF-8 string conversion ---- */

static char* iupCocoaCheckUtf8Buffer(char* utf8_buffer, int *utf8_buffer_max, int len)
{
  if (!utf8_buffer)
  {
    utf8_buffer = malloc(len + 1);
    *utf8_buffer_max = len;
  }
  else if (*utf8_buffer_max < len)
  {
    utf8_buffer = realloc(utf8_buffer, len + 1);
    *utf8_buffer_max = len;
  }
  return utf8_buffer;
}

static char* iupStrCopyToUtf8Buffer(const char* str, int len, char* utf8_buffer, int *utf8_buffer_max)
{
  utf8_buffer = iupCocoaCheckUtf8Buffer(utf8_buffer, utf8_buffer_max, len);
  memcpy(utf8_buffer, str, len);
  utf8_buffer[len] = 0;
  return utf8_buffer;
}

/* Used in glfont */
IUP_SDK_API char* iupStrConvertToUTF8(const char* str, int len, char* utf8_buffer, int *utf8_buffer_max, int utf8mode)
{
  (void)utf8mode;
  return iupStrCopyToUtf8Buffer(str, len, utf8_buffer, utf8_buffer_max);
}

/* ---- File system operations (originally in iupmac_info.m) ---- */

char* iupdrvGetCurrentDirectory(void)
{
  NSString* curDir = [[NSFileManager defaultManager] currentDirectoryPath];
  const char* dir = [curDir UTF8String];
  size_t size = strlen(dir) + 1;
  char* buffer = (char*)iupStrGetMemory(size);
  strcpy(buffer, dir);
  return buffer;
}

int iupdrvSetCurrentDirectory(const char* dir)
{
  NSString* path = [NSString stringWithUTF8String:dir];
  return [[NSFileManager defaultManager] changeCurrentDirectoryPath:path] ? 1 : 0;
}

int iupdrvMakeDirectory(const char* name)
{
  NSString* path = [NSString stringWithUTF8String:name];
  NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithUnsignedInt:0775], NSFilePosixPermissions, nil];
  return [[NSFileManager defaultManager] createDirectoryAtPath:path
      withIntermediateDirectories:YES attributes:dic error:NULL] ? 1 : 0;
}

int iupdrvIsFile(const char* name)
{
  NSString* path = [NSString stringWithUTF8String:name];
  BOOL isDir;
  BOOL r = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
  return (r && !isDir) ? 1 : 0;
}

int iupdrvIsDirectory(const char* name)
{
  NSString* path = [NSString stringWithUTF8String:name];
  BOOL isDir;
  BOOL r = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
  return (r && isDir) ? 1 : 0;
}
