@ECHO OFF

IF NOT EXIST out MKDIR out
DEL /Q out

IF [%~1] EQU [clean] GOTO:EOF

SET "_PAWNCC=pawncc.exe"
"%_PAWNCC%">NUL 2>NUL
IF ERRORLEVEL 9009 (
	SET "_PAWNCC=%CD%\..\..\..\pawno\pawncc-original.exe"
)
"%_PAWNCC%" -(- -;- -i"%CD%/vendor/" -p -d0 -O1 -v2 %* -oout/basdon.amx basdon.pwn
IF EXIST basdon.xml DEL basdon.xml

