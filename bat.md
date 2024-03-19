# bat学习

## 基础命令

```sh
@echo off，关闭之后所有命令的回显，不然bat文件中每条指令会在cmd命令窗口显示
rem，注释，还有::也表示注释，两者区别，大家请小度
echo，输出
echo=，输出空白行
```

## 乱码

- chcp 65001 UTF-8
- chcp 936 GBK

## 默认全局变量

```sh
set var2="var2"
if not defined var2 ( 
    echo var2 is not defined, the value is: %var2%
) else ( 
    echo var2 is defined, the value is: %var2%
)

if "%var2%"=="" (
    echo var2 is not defined, the value is: %var2%
) else (
    echo var2 is defined, the value is: %var2%
)
```

## 变量赋值

```sh
@echo off
set var1=2+2
set /a var2=2+2
set /p var3=Please input a number:
rem set /p md5=<file_info.md5
echo var1: %var1%
echo var2: %var2%
echo var3: %var3%
rem echo md5: %md5%

变量赋值时等号前后不能有空格，类似set a = 1会报错
/a 是表达式运算，仅适合32位整型运算，可以是负数
/p 是提示输入，将输入值赋值给变量
set /p md5=<file_info.md5, 读取md5文件内容并赋值给md5变量
可通过set a=清空变量
```

## 变量读取

> 可通过%var%, 读取变量值
> set var，列出var开头的所有变量
> set，列出所有变量，如系统环境变量TEMP、PATH等也会列举出来
> !var!，两个感叹号，延迟读取变量值，本文后面 “变量延迟” 部分会详细讲解
> 需要了解的一些系统内置变量
>
> > %date%，系统日期，类似：2020/02/29 周六
> > %time%，获取系统时间，类似：17:13:15.18
> > %cd%，获取当前目录
> > %RANDOM% 系统 返回 0 到 32767 之间的任意十进制数字
> > %NUMBER_OF_PROCESSORS% 系统 指定安装在计算机上的处理器的数目。
> > %PROCESSOR_ARCHITECTURE% 系统 返回处理器的芯片体系结构。值：x86 或 IA64 基于Itanium
> > %PROCESSOR_IDENTFIER% 系统 返回处理器说明。
> > %PROCESSOR_LEVEL% 系统 返回计算机上安装的处理器的型号。
> > %PROCESSOR_REVISION% 系统 返回处理器的版本号。
> > %COMPUTERNAME% 系统 返回计算机的名称。
> > %USERNAME% 本地 返回当前登录的用户的名称。
> > %USERPROFILE% 本地 返回当前用户的配置文件的位置。
> > %~dp0，bat脚本文件所在目录

## 变量作用域

- 默认为全局变量（Global），可使用setlocal命令将变量作用域设置为local，直到endlocal或exit命令，或bat文件执行结束，变量local作用域也结束并恢复到global作用域

```sh
@echo off
setlocal
set v=Local Variable
echo v=%v%
```

## 变量延迟

```sh
@echo off
set a=1
set /a a+=1 > nul & echo %a%
1
当我们准备执行一条命令的时候，命令解释器会先将命令读取，如果命令中有环境变量，那么就会将变量的值先读取来出，然后在运行这条命令，如：echo %a%，当我们执行这条命令的时候，命令解释器会先读出%a%的值，即1，然后执行echo，所以输出1。
```

```sh
@echo off
setlocal EnableDelayedExpansion
set a=1
set /a a+=1 > nul & echo !a!
2
输出a+=1运算后的a值，即2。bat脚本提供了变量延迟，即变量在使用时再读取
setlocal EnableDelayedExpansion 开启变量延迟，无需关注变量延迟如何关闭，有时为了代码简洁也写成：@echo off & setlocal EnableDelayedExpansion
!a!，两个叹号，变量才会延迟读取
```

## 特殊变量

```sh
@echo off & setlocal
echo arg0=%0
echo arg1=%1
echo arg1 去除引号=%~1
echo batfile fullpath=%~f0
echo batfile=%~n0
echo batfolder=%~dp0

运行输入  .\test.bat var_arg "marcus"
```

> %*，表示参数列表，比如：var_arg.bat arg1 arg2 arg3，则 %* = arg1 arg2 arg3
> %0，表示脚本文件名，调用时var_arg则%0=var_arg，若调用时var_arg.bat则%0=var_arg.bat
> %1，表示第一个参数
> %~1，第一个参数去引号，如：var_arg.bat “arg1”，%~1得到arg1
> %~f0，脚本文件完整路径名
> %~dp0，脚本文件所在目录

## 返回码和errorlevel

- 通常来说一条命令的执行结果返回的值只有两个，0 表示"成功"，1 表示"失败"，实际上，errorlevel 返回值可以是一个任何整型值，一般只定义在0~255之间。

```sh
@echo off
rem return code demo
exit /b %1

```

```sh
D:\cmdtest>returncode 0
D:\cmdtest>echo %errorlevel%
0
D:\cmdtest>returncode 1
D:\cmdtest>echo %errorlevel%
1
D:\cmdtest>returncode -1
D:\cmdtest>echo %errorlevel%
-1

bat脚本文件中exit指定的code即返回码，就是下一行获取到的errorlevel值，从demo可以看出errorlevel甚至可以是负值。
如果bat脚本文件中没有exit code命令，bat文件执行结束后，会不会有返回码？没有，有点类似void函数，因此errorlevel仍然是上次的-1。
```

- 可以根据errorlevel是否等于0来判断脚本是否成功执行（0表示成功，>0值表示失败），若明确脚本返回码的情况下，也可以根据具体返回码值做具体处理，DEMO如下：假设执行脚本后，errorlevel=0，则

```sh
D:\cmdtest>if errorlevel 1 (echo fail) else (echo success)
success
D:\cmdtest>if %errorlevel% EQU 0 (echo success) else (echo fail)
success

errorlevel 1，errorlevel >= 1
%errorlevel% EQU 0，errorlevel == 0
```



## stdin0, stdout1, stderr2

### 重定向

```sh
标准输出重定向
dir > dir.txt		//dir文件、目录列表输出到dir.txt, dir.txt文件重新生成
dir >> dir.txt		//dir文件、目录列表添加到dir.txt, dir.txt存在则添加，否则新建
echo line1 > line.txt	//覆盖line.txt,内容为line1
type con > line.txt	//响应键盘输入，直到按ctrl+z结束，输出到line.txt文件
```

```sh
错误输出重定向
d:\cmdtest\stdout>dir aaa 2>error.txt
d:\cmdtest\stdout>type error.txt
找不到文件
```

```sh
标准、错误输出合并
d:\cmdtest\stdout>DIR SomeFile.txt > output.txt 2>&1
d:\cmdtest\stdout>type output.txt
 驱动器 D 中的卷是 软件
 卷的序列号是 65F3-3762

 d:\cmdtest\stdout 的目录

找不到文件

说明：遍历SomeFile.txt，先将遍历结果输出到output.txt，如果出错则将错误信息添加到
output.txt（此处的“找不到文件”）。
```

```sh
标准输入
D:\cmdtest\stdout>sort < countries.txt
America
Australia
China
England

D:\cmdtest\stdout>type countries.txt
China
America
England
Australia
D:\cmdtest\stdout>
```

## 输出挂起、丢弃

```sh
字符串查找
@echo off & setlocal
set str1=The most severe place of New SARS is Wuhan.
set str2=%~1
echo %str1% | findstr /i "%str2%" > nul && (echo "found") || (echo "not found")

带参数运行
```

```sh
程序暂停若干秒
@echo off
echo "program sleep 5 seconds, start..."
ping /n 5 127.1>nul
echo "program sleep 5 seconds, end..."
exit /b 0

```

## 管道符 | 使用

- 管道符 | 通常用于一个命令的输出作为另一个命令的输入
- DIR /B，/B 使用空格式(没有标题信息或摘要)。
- DIR /B | SORT，将dir /b结果进行字符串排序

## if判断

```sh
@echo off
IF EXIST "temp.txt" (
    ECHO found
) ELSE (
    ECHO not found
)

```

```sh
IF "%var%"=="" (TODO)
IF NOT DEFINED var (TODO)

```

```sh
@echo off & setlocal
set /p arg1="please input a string:"
set /p arg2="please input another string:"
if %arg1%==%arg2% (echo %arg1% equals %arg2%) else (echo %arg1% not equals %arg2%)
if not %arg1%==%arg2% (echo %arg1% not equals %arg2%) else (echo %arg1% equals %arg2%)
if %arg1% equ %arg2% (echo %arg1% equals %arg2%) else (echo %arg1% not equals %arg2%)
if %arg1% neq %arg2% (echo %arg1% not equals %arg2%) else (echo %arg1% equals %arg2%)

set /p name="please input your name: "
if /i "%name%"=="marcus" ( echo You are Marcus! ) else ( echo You are not Marcus! )

两个字符串变量是否相等，可以使用==，equ；不等则可以使用 not ==，neq
字符串变量与常量比较，请带双引号，如："%name%"==“marcus”
带 /i,表示忽略大小写，类似java的equalsIgnoreCase
```

```sh
@echo off & setlocal
set num1=1
set num2=2
if %num1% EQU %num2% (echo %num1% == %num2%) else (echo echo %num1% != %num2%)

EQU，等于
NEQ，不等于
LSS，小于
LEQ，小于等于
GTR，大于
GEQ，大于或等于

```

```sh
if errorlevel 1 (TODO)
if %errorlevel% equ 0 (TODO)

```

## &、&&、||

> &，顺序执行多条命令，而不管命令是否执行成功
> 如：本文demo中经常出现的 @echo off & setlocal
> &&，顺序执行多条命令，当碰到执行出错的命令后将不执行后面的命令
> ||，顺序执行多条命令，当碰到执行正确的命令后将不执行后面的命令（即：只有前面命令执行错误时才执行后面命令），findstr命令时经常会使用&&和||符号，分别表示：找到执行…,没找到执行…

```sh
set str="Apple,Huawei,Xiaomi,Oppo,Vivo"
echo  %str% | findstr /i "asus" > nul && (echo found) || (echo notfound)

```

## 循环

```sh
@echo off
set var=0
echo ************loop start.
:continue
set /a var+=1
echo loop time: %var%
if %var% lss 10 goto continue
echo ************loop end.
echo loop execution finished.

```

```sh
@echo off
set var=0
echo ************loop start.
for /L %%i in (1,1,10) do (echo loop time: %%i)
echo ************loop end.
echo loop execution finished.


for /L in (start, step, end) do ():
for循环，bat文件中变量使用%%i，在cmd命令框则使用%i
可以在cmd命令框中使用 for /? 查看for命令使用说明
```

> 对一组文件中的每一个文件执行某个特定命令。
> FOR %variable IN (set) DO command [command-parameters]
> %variable 指定一个单一字母可替换的参数。
> (set) 指定一个或一组文件。可以使用通配符。
> command 指定对每个文件执行的命令。
> command-parameters
> 为特定命令指定参数或命令行开关。
> 在批处理程序中使用 FOR 命令时，指定变量请使用 %%variable
> 而不要用 %variable。变量名称是区分大小写的，所以 %i 不同于 %I.
> 如果启用命令扩展，则会支持下列 FOR 命令的其他格式:
> FOR /D %variable IN (set) DO command [command-parameters]
> 如果集中包含通配符，则指定与目录名匹配，而不与文件名匹配。
> FOR /R [[drive:]path] %variable IN (set) DO command [command-parameters]
> 检查以 [drive:]path 为根的目录树，指向每个目录中的 FOR 语句。
> 如果在 /R 后没有指定目录规范，则使用当前目录。如果集仅为一个单点(.)字符，
> 则枚举该目录树。
> FOR /L %variable IN (start,step,end) DO command [command-parameters]
> 该集表示以增量形式从开始到结束的一个数字序列。因此，(1,1,5)将产生序列
> 1 2 3 4 5，(5,-1,1)将产生序列(5 4 3 2 1)
> FOR /F [“options”] %variable IN (file-set) DO command [command-parameters]
> FOR /F [“options”] %variable IN (“string”) DO command [command-parameters]
> FOR /F [“options”] %variable IN (‘command’) DO command [command-parameters]
> 或者，如果有 usebackq 选项:
> FOR /F [“options”] %variable IN (file-set) DO command [command-parameters]
> FOR /F [“options”] %variable IN (“string”) DO command [command-parameters]
> FOR /F [“options”] %variable IN (‘command’) DO command [command-parameters]
> …
> 另外，FOR 变量参照的替换已被增强。您现在可以使用下列
> 选项语法:
> %~I - 删除任何引号(")，扩展 %I
> %~fI - 将 %I 扩展到一个完全合格的路径名
> %~dI - 仅将 %I 扩展到一个驱动器号
> %~pI - 仅将 %I 扩展到一个路径
> %~nI - 仅将 %I 扩展到一个文件名
> %~xI - 仅将 %I 扩展到一个文件扩展名
> %~sI - 扩展的路径只含有短名
> %~aI - 将 %I 扩展到文件的文件属性
> %~tI - 将 %I 扩展到文件的日期/时间
> %~zI - 将 %I 扩展到文件的大小
> %~P A T H : I − 查 找 列 在 路 径 环 境 变 量 的 目 录 ， 并 将 到 找 到 的 第 一 个 完 全 合 格 的 名 称 。 如 果 环 境 变 量 名 未 被 定 义 ， 或 者 没 有 找 到 文 件 ， 此 组 合 键 会 扩 展 到 空 字 符 串 可 以 组 合 修 饰 符 来 得 到 多 重 结 果 : PATH:I - 查找列在路径环境变量的目录，并将 %I 扩展 到找到的第一个完全合格的名称。如果环境变量名 未被定义，或者没有找到文件，此组合键会扩展到 空字符串 可以组合修饰符来得到多重结果: %~dpI - 仅将 %I 扩展到一个驱动器号和路径 %~nxI - 仅将 %I 扩展到一个文件名和扩展名 %~fsI - 仅将 %I 扩展到一个带有短名的完整路径名 %~dpPATH:I−查找列在路径环境变量的目录，并将到找到的第一个完全合格的名称。如果环境变量名未被定义，或者没有找到文件，此组合键会扩展到空字符串可以组合修饰符来得到多重结果:PATH:I - 搜索列在路径环境变量的目录，并将 %I 扩展
> 到找到的第一个驱动器号和路径。
> %~ftzaI - 将 %I 扩展到类似输出线路的 DIR
> 在以上例子中，%I 和 PATH 可用其他有效数值代替。%~ 语法
> 用一个有效的 FOR 变量名终止。选取类似 %I 的大写变量名
> 比较易读，而且避免与不分大小写的组合键混淆。

```sh
@echo off
echo 遍历字符串
for %%i in (Hangzhou Ningbo Wenzhou Shaoxin) do  echo %%i >> dir.txt

echo 遍历USERPROFILE下的文件
FOR %%i IN (%USERPROFILE%\*) DO  echo %%i >> error.txt

```

```sh
遍历目录
语法：FOR /D %variable IN (set) DO command [command-parameters]
rem 遍历文件目录
FOR /D %I IN (%USERPROFILE%\*) DO @ECHO %I

递归遍历
语法：FOR /R [[drive:]path] %variable IN (set) DO command [command-parameters]
rem 递归遍历文件
FOR /R "%TEMP%" %I IN (*) DO @ECHO %I
rem 递归遍历文件目录
FOR /R "%TEMP%" /D %I IN (*) DO @ECHO %I

```

```sh
FOR /L %variable IN (start,step,end) DO command [command-parameters]
该集表示以增量形式从开始到结束的一个数字序列。
rem (1,1,5)将产生序列 1 2 3 4 5
FOR /L %i in (1,1,5) do @echo %i

rem (5,-1,1)将产生序列(5 4 3 2 1)
FOR /L %i in (5,-1,1) do @echo %i

```

```sh
FOR /F ["options"] %variable IN (file-set) DO command [command-parameters]
FOR /F ["options"] %variable IN ("string") DO command [command-parameters]
FOR /F ["options"] %variable IN ('command') DO command [command-parameters]

    fileset 为一个或多个文件名。继续到 fileset 中的下一个文件之前，
    每份文件都被打开、读取并经过处理。处理包括读取文件，将其分成一行行的文字，
    然后将每行解析成零或更多的符号。然后用已找到的符号字符串变量值调用 For 循环。
    以默认方式，/F 通过每个文件的每一行中分开的第一个空白符号。跳过空白行。
    您可通过指定可选 "options" 参数替代默认解析操作。这个带引号的字符串包括一个
    或多个指定不同解析选项的关键字。这些关键字为:

        eol=c           - 指一个行注释字符的结尾(就一个)
        skip=n          - 指在文件开始时忽略的行数。
        delims=xxx      - 指分隔符集。这个替换了空格和跳格键的
                          默认分隔符集。
        tokens=x,y,m-n  - 指每行的哪一个符号被传递到每个迭代
                          的 for 本身。这会导致额外变量名称的分配。m-n
                          格式为一个范围。通过 nth 符号指定 mth。如果
                          符号字符串中的最后一个字符星号，
                          那么额外的变量将在最后一个符号解析之后
                          分配并接受行的保留文本。

```

git archive -o ../updated.zip HEAD $(git diff --name-only HEAD^)