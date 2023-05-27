@echo off

cls

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "date=%dt:~0,4%_%dt:~4,2%_%dt:~6,2%"

set "name=Despoina"

ROBOCOPY "data"    "target\debug\%date%\data"           /mir /nfl /ndl /njh /njs /np /ns /nc > nul
ROBOCOPY "src"     "target\debug\%date%\source\src"     /mir /nfl /ndl /njh /njs /np /ns /nc > nul
ROBOCOPY "include" "target\debug\%date%\source\include" /mir /nfl /ndl /njh /njs /np /ns /nc > nul

odin build G:\%name%\src -out=G:\%name%\target\debug\%date%\%name%.exe