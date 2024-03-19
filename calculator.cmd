echo off
chcp 65001 & setlocal
:next
set /p input=
if /i "%input%" EQU "exit" goto end
set /a cal=%input%
echo = %cal% & goto next
endlocal
:end
set timeout=2
rem ping -n 3 127.0.0.1 >nul
rem timeout /t %timeout%
choice /t %timeout% /d y >nul
rem pause
exit /b