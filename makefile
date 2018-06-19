SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
ppfile = preprocess.sed
pp = $(sed) -f $(ppfile)

build: p/basdon.p p/panel.p
	@echo.

p/basdon.p: basdon.pwn $(ppfile)
	$(pp) basdon.pwn>p/basdon.p

p/panel.p: panel.pwn $(ppfile)
	$(pp) panel.pwn>p/panel.p

clean:
	del p
