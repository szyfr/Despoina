@echo off

cls

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "date=%dt:~0,4%_%dt:~4,2%_%dt:~6,2%"

ROBOCOPY "data"    "target\debug\%date%\data"           /mir /nfl /ndl /njh /njs /np /ns /nc > nul
ROBOCOPY "src"     "target\debug\%date%\source\src"     /mir /nfl /ndl /njh /njs /np /ns /nc > nul
ROBOCOPY "include" "target\debug\%date%\source\include" /mir /nfl /ndl /njh /njs /np /ns /nc > nul

nasm -fwin64 src\main.asm -o target\debug\%date%\hecate.obj
GoLink /console /ENTRY:main target\debug\%date%\hecate.obj kernel32.dll user32.dll gdi32.dll ucrtbase.dll sdl2.dll
