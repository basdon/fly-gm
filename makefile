SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
ppfile = preprocess.sed
pp = $(sed) -f $(ppfile)

build: p/basdon.p p/panel.p p/game_sa.p p/afk.p p/playername.p p/login.p p/util.p
	@echo.

p/basdon.p: basdon.pwn p/simpleiter.p $(ppfile)
	$(pp) basdon.pwn>p/basdon.p

p/panel.p: panel.pwn p/simpleiter.p $(ppfile)
	$(pp) panel.pwn>p/panel.p

p/simpleiter.p: simpleiter.pwn $(ppfile)
	$(pp) simpleiter.pwn>p/simpleiter.p

p/game_sa.p: game_sa.pwn $(ppfile)
	$(pp) game_sa.pwn>p/game_sa.p

p/afk.p: afk.pwn $(ppfile)
	$(pp) afk.pwn>p/afk.p

p/playername.p: playername.pwn $(ppfile)
	$(pp) playername.pwn>p/playername.p

p/login.p: login.pwn p/basdon.p $(ppfile)
	$(pp) login.pwn>p/login.p

p/util.p: util.pwn $(ppfile)
	$(pp) util.pwn>p/util.p

clean:
	del p
