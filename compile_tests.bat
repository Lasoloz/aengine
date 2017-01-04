:: Copyright (c) 2016 Heim László
:: Compile and link tests with one command

:: Step #0: Turn echo off and create directories for objects and binaries
::          Copy dynamic link libraries to binary output

@echo off

echo Checking pre-requisities...

if not exist obj mkdir obj
if not exist obj\graphics mkdir obj\graphics
if not exist obj\tests mkdir obj\tests

if not exist bin mkdir bin

if not exist bin\mio.dll copy third-party\mio.dll bin\mio.dll
if not exist bin\util.dll copy third-party\util.dll bin\util.dll
if not exist bin\gfx.dll copy third-party\gfx.dll bin\gfx.dll
if not exist bin\test.ppm copy third-party\test.ppm bin\test.ppm


:: Step #1: Compile components
:: nasm MUST be added to path variable!
echo Compiling sources...

nasm -f win32 src/graphics/sprite.asm -o obj/graphics/sprite.obj
nasm -f win32 src/graphics/render.asm -o obj/graphics/render.obj

nasm -f win32 src/tests/test1.asm -o obj/tests/test1.obj
nasm -f win32 src/tests/test2.asm -o obj/tests/test2.obj


:: Step #2: Link tests
:: nlink MUST be added to path variable!
echo Linking tests...

nlink obj/graphics/sprite.obj^
      obj/tests/test1.obj^
      -lthird-party/mio -lthird-party/io -lthird-party/util^
      -o bin/test1.exe

nlink obj/graphics/sprite.obj^
      obj/graphics/render.obj^
      obj/tests/test2.obj^
      -lthird-party/mio -lthird-party/io -lthird-party/util -lthird-party/gfx^
      -o bin/test2.exe
