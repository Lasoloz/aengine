:: Copyright (c) 2016 Heim László
:: Compile the project with one command

:: Compilation of object files:
:: Netwide Assembler executable must be added to the path variable
if not exist obj mkdir obj
if not exist obj\math mkdir obj\math
if not exist obj\tests mkdir obj\tests
nasm src/math/vecint.asm -f win32 -o obj/math/vecint.obj
nasm src/tests/test0.asm -f win32 -o obj/tests/test0.obj

:: Linking of object files:
:: Linker must be added to the path variable
if not exist bin mkdir bin
if not exist bin\tests mkdir bin\tests
nlink obj/tests/test0.obj obj/math/vecint.obj -lthird-party/mio -lthird-party/io -lthird-party/util -o bin/tests/test0.exe

:: Post-Compile operations:
:: Copy dynamic link libraries near binary
if not exist bin\tests\util.dll copy third-party\util.dll bin\tests\util.dll
