PROJNAME = iup
APPNAME := iupvled
OPT = YES

SRC = iup_vled.c iup_vled_imgs.c vled_image_editor.c

IUP := ..

LINKER = $(CPPC)

USE_IUPCONTROLS = Yes
USE_IUP3 = Yes

ifeq "$(TEC_SYSNAME)" "Haiku"
  USE_HAIKU = Yes
else
  USE_STATIC = Yes
ifdef GTK_DEFAULT
  ifdef USE_MOTIF
    # Build Motif version in Linux and BSD
    APPNAME := $(APPNAME)mot
  endif
else  
  ifdef USE_GTK
    # Build GTK version in IRIX,SunOS,AIX,Win32
    APPNAME := $(APPNAME)gtk
  endif
endif
endif

USE_IM = Yes
ifdef USE_IM
  DEFINES += USE_IM  
  ifneq ($(findstring Win, $(TEC_SYSNAME)), )
    LIBS += iupim im_process cdim
  else
    ifdef USE_STATIC
      ifdef DBG_DIR
        IUP_LIB = $(IUP)/lib/$(TEC_UNAME)d
      else
        IUP_LIB = $(IUP)/lib/$(TEC_UNAME)
      endif  
      SLIB += $(IUP_LIB)/libiupim.a $(IM_LIB)/libim_process.a $(CD_LIB)/libcdim.a
    else
      LIBS += iupim im_process cdim
    endif             
  endif             
endif 

ifneq ($(findstring Win, $(TEC_SYSNAME)), )
  LIBS += iupimglib imm32 msimg32
else
  LIBS += atk-1.0
  ifdef USE_STATIC
    ifdef DBG_DIR
      IUP_LIB = $(IUP)/lib/$(TEC_UNAME)d
    else
      IUP_LIB = $(IUP)/lib/$(TEC_UNAME)
    endif  
    SLIB += $(IUP_LIB)/libiupimglib.a
  else
    LIBS += iupimglib
  endif             
endif

#USE_NO_OPENGL=Yes
ifndef USE_NO_OPENGL
  USE_OPENGL = Yes
  USE_FTGL = Yes
  ifneq ($(findstring Win, $(TEC_SYSNAME)), )
    LIBS += iupglcontrols
  else
    ifdef USE_STATIC
      ifdef DBG_DIR
        IUP_LIB = $(IUP)/lib/$(TEC_UNAME)d
      else
        IUP_LIB = $(IUP)/lib/$(TEC_UNAME)
      endif  
      SLIB += $(IUP_LIB)/libiupglcontrols.a 
    else
      LIBS += iupglcontrols
    endif             
  endif
else
  DEFINES += USE_NO_OPENGL
endif

USE_NO_SCINTILLA=Yes
DEFINES += USE_NO_SCINTILLA

USE_NO_WEB=Yes
DEFINES += USE_NO_WEB

USE_NO_PLOT=Yes
DEFINES += USE_NO_PLOT

ifneq ($(findstring Win, $(TEC_SYSNAME)), )
  SRC += ../etc/iup.rc
endif

ifneq ($(findstring cygw, $(TEC_UNAME)), )
  LIBS += fontconfig
endif

ifneq ($(findstring MacOS, $(TEC_UNAME)), )
  LIBS += fontconfig
endif

INCLUDES = ../src
