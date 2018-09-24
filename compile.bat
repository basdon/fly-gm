@ECHO OFF

SET "_MAKE=K:\cygwin64\bin\make.exe"
SET "_SED=K:\Program Files\Git\usr\bin\sed.exe"
SET "_PAWNCC=..\..\..\pawno\pawncc-original.exe"

IF EXIST out RD out /S /Q

IF [%~1] EQU [clean] (
	::"%_MAKE%" clean
	IF EXIST p RD p /S /Q
	EXIT
)

MKDIR out
IF NOT EXIST p MKDIR p

IF [%~1] EQU [make] (
	"%_MAKE%" %~2
	EXIT
)

SET "_EXTRAFLAGS=%~1"
SET "_FLAGS=-d3 -O1"

IF [%~1] EQU [prod] (
        set "_EXTRAFLAGS=PROD=1"
        set "_FLAGS=-d0 -O0"
)

"%_MAKE%" build
IF %ERRORLEVEL% NEQ 0 EXIT
ECHO.
"%_PAWNCC%" -(- -;- -i"%CD%/vendor/" -Dp/ %_EXTRAFLAGS% basdon.p -r../out/basdon.xml -o../out/basdon.amx %_FLAGS%
IF %ERRORLEVEL% NEQ 0 EXIT
ECHO.
IF EXIST "out\basdon.xml" (
	MOVE /Y "out\basdon.xml" "doc.xml"
	"%_SED%" -i 's/xml-stylesheet href="[^"]*"/xml-stylesheet href="pawndoc.xsl"/' doc.xml
)

