@echo off
REM This builds all the tools for 1 uname

call make_uname_lib.bat srcledc %1 %2 %3 %4 %5 %6 %7 %8 %9

call make_uname_lib.bat srcview %1 %2 %3 %4 %5 %6 %7 %8 %9

call make_uname_lib.bat srcvled %1 %2 %3 %4 %5 %6 %7 %8 %9

call make_uname_lib.bat html\examples\tests %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\..

call make_uname_lib.bat html\examples\tutorial\simple_paint2 %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..\..\..
