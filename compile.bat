@ECHO OFF

SET "_PAWNCC=..\..\..\pawno\pawncc-original.exe"

DEL /Q out\*
BREAK>out\.gitkeep

IF [%~1] EQU [clean] (
	::make clean
	DEL /Q p\*.p
	BREAK>p\.gitkeep
	EXIT /B
)

IF [%~1] EQU [make] (
	"%_MAKE%" %~2
	EXIT /B
)

SET "_EXTRAFLAGS=%~1"
SET "_FLAGS=-d3 -O1"

IF [%~1] EQU [prod] (
        set "_EXTRAFLAGS=PROD=1"
        set "_FLAGS=-d0 -O0"
)

make build
IF %ERRORLEVEL% NEQ 0 EXIT /B
ECHO.
"%_PAWNCC%" -(- -;- -i"%CD%/vendor/" -Dp/ %_EXTRAFLAGS% basdon.p -r../out/basdon.xml -o../out/basdon.amx %_FLAGS%
IF %ERRORLEVEL% NEQ 0 EXIT /B
ECHO.
IF EXIST "out\basdon.xml" (
	MOVE /Y "out\basdon.xml" "doc.xml"
	sed -i 's/xml-stylesheet href="[^"]*"/xml-stylesheet href="pawndoc.xsl"/' doc.xml
)

