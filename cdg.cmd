@echo off
chcp 65001 & setlocal EnableDelayedExpansion
@REM type %0 | more +0 1>ret.txt
for /f "delims=: tokens=2" %%t in ('find /i /c /v "" %0') do (set /a "lastLine=%%t+1" & echo 文件总行数加一!lastLine!【直到最后一个非空行】)
set /a skipLine=0
set /a cdbFlag=0
for /f "delims=: tokens=1" %%t in ('more +%skipLine% %0 ^| findstr /r /n "^\[cdb]\>"') do (
	set /a str=%%t+%skipLine% & set /a cdbFlag+=1
	set /a "cf!cdbFlag!=!str!"
	echo 第!str!行包含标识字符串
)
@rem for /l %%y in (1, 1, %cdbFlag%) do call echo !cf%%y!
echo 总计%cdbFlag%个代码块
type %0 | more +!cf4! 1>Cdg_Normal_Java.java
set lineFlag=0
for /f "delims=" %%i in (%0) do (
	set /a lineFlag+=1
    if !lineFlag! gtr !cf3! (
        if !lineFlag! lss !cf4! (
            set lineContent=%%i
            echo !lineContent! 1>>Cdg_Medium_Java.java
        )
    )
    if !lineFlag! gtr !cf2! (
        if !lineFlag! lss !cf3! (
            set lineContent=%%i
            echo !lineContent! 1>>Cdg_Prime_Java.java
        )
    )
	if !lineFlag! gtr !cf1! (
		if !lineFlag! lss !cf2! (
			set lineContent=%%i
			echo !lineContent! 1>>jslog.js
		)
	)
)
echo 运行Java代码结果 1>ret.txt
java -version 2>>ret.txt
javac Cdg_Prime_Java.java
java Cdg_Prime_Java 1>>ret.txt
echo 运行JavaScript代码结果 1>>ret.txt
node -v 1>>ret.txt
node jslog.js 1>>ret.txt
@REM node serve.js 1>>ret.txt
type ret.txt
pause
del jslog.js Cdg_*_java.*
exit /b
[cdb] JavaScript
console.log('server is running');
console.log('server is destroyed');
[cdb] Java Prime
public class Cdg_Prime_Java {
    public static void main(String[] args) {
        System.out.println("Cdg_Prime_Java.main");
        Cdg_Medium_Java cdgMediumJava = new Cdg_Medium_Java();
        cdgMediumJava.exe();
    }
}
[cdb] Java medium
public class Cdg_Medium_Java {
    public void exe() {
        System.out.println("Cdg_Medium_Java.exe");
        Cdg_Normal_Java cdgNormalJava = new Cdg_Normal_Java();
        cdgNormalJava.exe();
    }
}
[cdb] Java Normal
public class Cdg_Normal_Java {
    public void exe() {
        System.out.println("Cdg_Normal_Java.exe");
    }
}