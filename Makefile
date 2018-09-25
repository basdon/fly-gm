SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
cp = "K:\Program Files\Git\usr\bin\cp.exe"
ppfile = preprocess.sed
pp = $(sed) -f $(ppfile)

#FILE basdon
#FILE natives
#FILE panel
#FILE simpleiter
#FILE game_sa
#FILE afk
#FILE playername
#FILE login
#FILE util
#FILE settings
#FILE colors
#FILE dialog
#FILE spawn
#FILE timecyc
#FILE anticheat

#START
#S2

build: p/sharedsymbols.p p/anticheat.p p/timecyc.p p/spawn.p p/dialog.p p/colors.p p/settings.p p/util.p p/login.p p/playername.p p/afk.p p/game_sa.p p/simpleiter.p p/panel.p p/natives.p p/basdon.p
	@echo.

p/basdon.p: basdon.pwn $(ppfile)
	$(pp) basdon.pwn>p/basdon.p

p/natives.p: natives.pwn $(ppfile)
	$(pp) natives.pwn>p/natives.p

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

p/login.p: login.pwn $(ppfile)
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

p/timecyc.p: timecyc.pwn $(ppfile)
	$(pp) timecyc.pwn>p/timecyc.p

p/anticheat.p: anticheat.pwn $(ppfile)
	$(pp) anticheat.pwn>p/anticheat.p

#S3
#STOP

file: Makefile mkmakefile.sed
	$(sed) -f mkmakefile.sed -i makefile

natives.pwn: ../../plugin/basdonfly.pwn
	COPY /Y ..\..\plugin\basdonfly.pwn natives.pwn

p/sharedsymbols.p: ../../plugin/sharedsymbols.h
	COPY /Y ..\..\plugin\sharedsymbols.h p\sharedsymbols.p

clean:
	DEL p
