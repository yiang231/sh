@echo off
setlocal
::EnableDelayedExpansion
chcp 65001
@REM rem chcp 936
set fromLocation=C:\Users\Administrator\Desktop\zhangyangdev\pensionaccount
set toLocation=C:\Users\Administrator\Desktop\zhangyangLS5\pensionaccount
set dov=100b23ee11f3de8158c78e95e8564876e2db1b9e
set dnv=c6a1b4b29be5adff80021180b26791bdd79672e4
set iov=%1
set inv=%2
set "ov="
set "del="
if "%iov%" neq "d" (
if "%iov%" neq "" (
set "ov=%iov%"
) else (
set "ov=%dov%"
)
) else (
set "del=d"
set "ov=%dov%"
)
set "nv="
if "%inv%" neq "" (
set "nv=%inv%"
) else (
set "nv=%dnv%"
)
cd %fromLocation%
echo new version [%ov%] >%toLocation%\diff.txt
echo old version [%nv%] >>%toLocation%\diff.txt
git diff --name-only %ov% %nv% >>%toLocation%\diff.txt
for /f "delims=" %%i in ('git diff --name-only %ov% %nv%') do call set "DIFF=%%DIFF%% %%i"
git archive --format=zip -o%toLocation%\updated.zip %nv% %DIFF%
cd %toLocation%
rem 7z l updated.zip >>diff.txt
type diff.txt
if /i "%del%" equ "d" (del diff.txt)
7z x -mmt%NUMBER_OF_PROCESSORS% -bt -aoa updated.zip -o%toLocation%\ >>%toLocation%\diff.txt
pause