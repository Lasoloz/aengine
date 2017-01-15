:: Copyright (c) 2016-2017 Heim László
:: Compile and link tests with one command

:: Step #0: Turn echo off and create directories for objects and binaries
::          Copy dynamic link libraries to binary output

@echo off

echo Checking pre-requisities...

if not exist obj mkdir obj
if not exist obj\graphics mkdir obj\graphics
if not exist obj\tests mkdir obj\tests

if not exist bin mkdir bin

if not exist bin\io.dll copy third-party\io.dll bin\io.dll
if not exist bin\mio.dll copy third-party\mio.dll bin\mio.dll
if not exist bin\util.dll copy third-party\util.dll bin\util.dll
if not exist bin\gfx.dll copy third-party\gfx.dll bin\gfx.dll
if not exist bin\test.ppm copy third-party\test.ppm bin\test.ppm
if not exist bin\test1.ppm copy third-party\test1.ppm bin\test1.ppm
if not exist bin\test2.ppm copy third-party\test2.ppm bin\test2.ppm
if not exist bin\test3.ppm copy third-party\test3.ppm bin\test3.ppm
if not exist bin\test4.ppm copy third-party\test4.ppm bin\test4.ppm
if not exist bin\test5.ppm copy third-party\test5.ppm bin\test5.ppm


:: Step #1: Compile components
:: nasm MUST be added to path variable!
echo Compiling sources...

nasm -f win32 src/graphics/sprite.asm -o obj/graphics/sprite.obj
nasm -f win32 src/graphics/render.asm -o obj/graphics/render.obj
nasm -f win32 src/graphics/fonts.asm -o obj/graphics/fonts.obj
nasm -f win32 src/userutil.asm -o obj/userutil.obj

nasm -f win32 src/tests/test1.asm -o obj/tests/test1.obj
nasm -f win32 src/tests/test2.asm -o obj/tests/test2.obj
nasm -f win32 src/tests/test3.asm -o obj/tests/test3.obj


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

nlink obj/tests/test3.obj^
      obj/graphics/fonts.obj^
      obj/userutil.obj^
      obj/graphics/sprite.obj^
      obj/graphics/render.obj^
      -lthird-party/mio -lthird-party/io -lthird-party/util -lthird-party/gfx^
      -o bin/test3.exe
