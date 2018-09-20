SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
ppfile = preprocess.sed
pp = $(sed) -f $(ppfile)

build: p/basdon.p p/panel.p p/game_sa.p p/afk.p p/playername.p p/login.p \
       p/util.p p/settings.p p/dialog.p p/simpleiter.p p/colors.p p/spawn.p
	@echo.

p/basdon.p: basdon.pwn $(ppfile)
	$(pp) basdon.pwn>p/basdon.p

p/panel.p: panel.pwn $(ppfile)
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

p/settings.p: settings.pwn $(ppfile)
	$(pp) settings.pwn>p/settings.p

p/colors.p: colors.pwn $(ppfile)
	$(pp) colors.pwn>p/colors.p

p/dialog.p: dialog.pwn $(ppfile)
	$(pp) dialog.pwn>p/dialog.p

p/spawn.p: spawn.pwn $(ppfile)
	$(pp) spawn.pwn>p/spawn.p

clean:
	del p
