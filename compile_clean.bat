:: Copyright (c) 2016-2017 Heim László
:: Delete all untracked files, and clean up working directory

@echo off

if exist bin rmdir /q /s bin
if exist obj rmdir /q /s obj
