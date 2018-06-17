@ECHO OFF

SET "_MAKE=K:\cygwin64\bin\make.exe"
SET "_SED=K:\Program Files\Git\usr\bin\sed.exe"
SET "_PAWNCC=..\..\..\pawno\pawncc-original.exe"

IF [%~1] EQU [clean] (
	::"%_MAKE%" clean
	IF EXIST p RD p /S /Q
	IF EXIST basdon.amx DEL basdon.amx /Q
	IF EXIST basdon.lst DEL basdon.lst /Q
	IF EXIST basdon.asm DEL basdon.asm /Q
	IF EXIST basdon.xml DEL basdon.xml /Q
	EXIT
)

IF NOT EXIST p MKDIR p

"%_MAKE%" basdon
IF %ERRORLEVEL% NEQ 0 EXIT
ECHO.
"%_PAWNCC%" -(- -;- -ivendor/ -Dp/ %~1 basdon.p -r
IF %ERRORLEVEL% NEQ 0 EXIT
ECHO.
IF EXIST "p\basdon.xml" (
	MOVE "p\basdon.xml" basdon.xml>NUL
	"%_SED%" -i 's/xml-stylesheet href="[^"]*"/xml-stylesheet href="pawndoc.xsl"/' basdon.xml
)
IF EXIST "p\basdon.lst" MOVE "p\basdon.lst" basdon.lst>NUL
IF EXIST "p\basdon.asm" MOVE "p\basdon.asm" basdon.asm>NUL
IF EXIST "p\basdon.amx" MOVE "p\basdon.amx" basdon.amx>NUL
