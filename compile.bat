:: Compile the project with one command
:: Netwide Assembler executable must be added to the path variable
if not exist obj mkdir obj
nasm src/main.asm -f win32 -o obj/main.obj

:: Linker must be added to the path variable
if not exist bin mkdir bin
nlink obj/main.obj -lthird-party/io -lthird-party/gfx -o bin/main.exe

:: Post-Compile operations: copy .dll near binary
if not exist bin\gfx.dll copy third-party\gfx.dll bin\gfx.dll
