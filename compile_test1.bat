:: Copyright (c) 2016 Heim László
:: Compile the test with one command

:: Compilation of object files:
:: Netwide Assembler executable must be added to the path variable
@echo off
if not exist obj mkdir obj
if not exist obj\graphics mkdir obj\graphics
if not exist obj\tests mkdir obj\tests
echo Compiling files...
nasm src/graphics/sprite.asm -f win32 -o obj/graphics/sprite.obj
nasm src/tests/test1.asm -f win32 -o obj/tests/test1.obj

:: Linking of object files:
:: Linker must be added to the path variable
if not exist bin mkdir bin
if not exist bin\tests mkdir bin\tests
echo Linking files...
nlink obj/tests/test1.obj obj/graphics/sprite.obj -lthird-party/mio -lthird-party/io -lthird-party/util -o bin/tests/test1.exe

:: Post-Compile operations:
:: Copy dynamic link libraries near binary
if not exist bin\tests\util.dll copy third-party\util.dll bin\tests\util.dll
