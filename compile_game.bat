:: Copyright (c) 2016-2017 Heim László
:: Compile and link Solitaire demo application

:: Step #0: Turn echo off and create directories for objects and binaries
::          Copy dynamic link libraries to binary output

@echo off

echo Checking pre-requisities...

if not exist obj mkdir obj
if not exist obj\graphics mkdir obj\graphics
if not exist obj\tests mkdir obj\tests
if not exist obj\demo mkdir obj\demo

if not exist game mkdir game

if not exist game\io.dll copy third-party\io.dll game\io.dll
if not exist game\mio.dll copy third-party\mio.dll game\mio.dll
if not exist game\util.dll copy third-party\util.dll game\util.dll
if not exist game\gfx.dll copy third-party\gfx.dll game\gfx.dll


:: Step #1: Compile components
:: nasm MUST be added to path variable!
echo Compiling sources...

nasm -f win32 src/graphics/sprite.asm -o obj/graphics/sprite.obj
nasm -f win32 src/graphics/render.asm -o obj/graphics/render.obj
nasm -f win32 src/graphics/fonts.asm -o obj/graphics/fonts.obj
nasm -f win32 src/userutil.asm -o obj/userutil.obj
nasm -f win32 src/demo/snake_map.asm -o obj/demo/snake_map.obj

nasm -f win32 src/demo/snake.asm -o obj/snake.obj

::nasm -f win32 src/demo/cards.asm -o obj/demo/cards.obj

::nasm -f win32 src/demo/solitaire.asm -o obj/solitaire.obj


:: Step #2: Link tests
:: nlink MUST be added to path variable!
echo Linking game...

::nlink obj/solitaire.obj^
::      obj/graphics/fonts.obj^
::      obj/userutil.obj^
::      obj/graphics/sprite.obj^
::      obj/graphics/render.obj^
::      obj/demo/cards.obj^
::      -lthird-party/mio -lthird-party/io -lthird-party/util -lthird-party/gfx^
::      -o game/solitaire.exe

nlink obj/snake.obj^
      obj/graphics/fonts.obj^
      obj/userutil.obj^
      obj/graphics/sprite.obj^
      obj/graphics/render.obj^
      obj/demo/snake_map.obj^
      -lthird-party/mio -lthird-party/io -lthird-party/util -lthird-party/gfx^
      -o game/snake.exe
