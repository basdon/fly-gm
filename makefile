SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
pp = $(sed) -f preprocess.sed

basdon: p/basdon.p p/panel.p
	@echo.

p/basdon.p: basdon.pwn
	$(pp) basdon.pwn>p/basdon.p

p/panel.p: panel.pwn
	$(pp) panel.pwn>p/panel.p

clean:
	del p
