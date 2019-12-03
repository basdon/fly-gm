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

REM always do prod builds now, since gm is pretty much empty

REM SET "_EXTRAFLAGS=%~1"
REM SET "_FLAGS=-d3 -O0"
REM
REM IF [%~1] EQU [prod] (
REM	set "_EXTRAFLAGS=PROD=1 %~2"
REM	set "_FLAGS=-d0 -O1"
REM )

set "_EXTRAFLAGS=%~1"
set "_FLAGS=-d0 -O1"

IF [%~1] EQU [nomake] (
	SET "_EXTRAFLAGS="
	GOTO SKIPMAKE
)
make build
IF %ERRORLEVEL% NEQ 0 EXIT /B
ECHO.
:SKIPMAKE
"%_PAWNCC%" -(- -;- -i"%CD%/vendor/" -Dp/ %_EXTRAFLAGS% basdon.p -r../out/basdon.xml -o../out/basdon.amx %_FLAGS%
IF %ERRORLEVEL% NEQ 0 EXIT /B
ECHO.
IF EXIST "out\basdon.xml" (
	MOVE /Y "out\basdon.xml" "doc.xml"
	sed -i 's/xml-stylesheet href="[^"]*"/xml-stylesheet href="pawndoc.xsl"/' doc.xml
)

