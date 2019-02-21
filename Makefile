SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
cp = "K:\Program Files\Git\usr\bin\cp.exe"
ppfile = preprocess.sed
ppfileoutline = preprocess-outline.sed

#FILE basdon
#FILE natives
#FILE sharedsymbols
#FILE panel
#FILE pm
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
#FILE tracker
#FILE anticheat
#FILE dummies
#FILE airport
#FILE zones
#FILE nav
#FILE objects

#START
#S2

build: p/sharedsymbols.p p/objects.p p/nav.p p/zones.p p/airport.p p/dummies.p p/anticheat.p p/tracker.p p/timecyc.p p/spawn.p p/dialog.p p/colors.p p/settings.p p/util.p p/login.p p/playername.p p/afk.p p/game_sa.p p/simpleiter.p p/pm.p p/panel.p p/sharedsymbols.p p/natives.p p/basdon.p
	@echo.

p/basdon.p: basdon.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) basdon.pwn>p/basdon.p
	$(sed) -f $(ppfile) -i p/basdon.p

p/natives.p: natives.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) natives.pwn>p/natives.p
	$(sed) -f $(ppfile) -i p/natives.p

p/sharedsymbols.p: sharedsymbols.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) sharedsymbols.pwn>p/sharedsymbols.p
	$(sed) -f $(ppfile) -i p/sharedsymbols.p

p/panel.p: panel.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) panel.pwn>p/panel.p
	$(sed) -f $(ppfile) -i p/panel.p

p/pm.p: pm.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) pm.pwn>p/pm.p
	$(sed) -f $(ppfile) -i p/pm.p

p/simpleiter.p: simpleiter.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) simpleiter.pwn>p/simpleiter.p
	$(sed) -f $(ppfile) -i p/simpleiter.p

p/game_sa.p: game_sa.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) game_sa.pwn>p/game_sa.p
	$(sed) -f $(ppfile) -i p/game_sa.p

p/afk.p: afk.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) afk.pwn>p/afk.p
	$(sed) -f $(ppfile) -i p/afk.p

p/playername.p: playername.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) playername.pwn>p/playername.p
	$(sed) -f $(ppfile) -i p/playername.p

p/login.p: login.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) login.pwn>p/login.p
	$(sed) -f $(ppfile) -i p/login.p

p/util.p: util.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) util.pwn>p/util.p
	$(sed) -f $(ppfile) -i p/util.p

p/settings.p: settings.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) settings.pwn>p/settings.p
	$(sed) -f $(ppfile) -i p/settings.p

p/colors.p: colors.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) colors.pwn>p/colors.p
	$(sed) -f $(ppfile) -i p/colors.p

p/dialog.p: dialog.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) dialog.pwn>p/dialog.p
	$(sed) -f $(ppfile) -i p/dialog.p

p/spawn.p: spawn.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) spawn.pwn>p/spawn.p
	$(sed) -f $(ppfile) -i p/spawn.p

p/timecyc.p: timecyc.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) timecyc.pwn>p/timecyc.p
	$(sed) -f $(ppfile) -i p/timecyc.p

p/tracker.p: tracker.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) tracker.pwn>p/tracker.p
	$(sed) -f $(ppfile) -i p/tracker.p

p/anticheat.p: anticheat.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) anticheat.pwn>p/anticheat.p
	$(sed) -f $(ppfile) -i p/anticheat.p

p/dummies.p: dummies.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) dummies.pwn>p/dummies.p
	$(sed) -f $(ppfile) -i p/dummies.p

p/airport.p: airport.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) airport.pwn>p/airport.p
	$(sed) -f $(ppfile) -i p/airport.p

p/zones.p: zones.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) zones.pwn>p/zones.p
	$(sed) -f $(ppfile) -i p/zones.p

p/nav.p: nav.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) nav.pwn>p/nav.p
	$(sed) -f $(ppfile) -i p/nav.p

p/objects.p: objects.pwn $(ppfile) $(ppfileoutline)
	$(sed) -f $(ppfileoutline) objects.pwn>p/objects.p
	$(sed) -f $(ppfile) -i p/objects.p

#S3
#STOP

file: Makefile mkmakefile.sed
	$(sed) -f mkmakefile.sed -i makefile

natives.pwn: ../../plugin/basdonfly.pwn
	COPY /Y ..\..\plugin\basdonfly.pwn natives.pwn

sharedsymbols.pwn: ../../plugin/sharedsymbols.h
	COPY /Y ..\..\plugin\sharedsymbols.h sharedsymbols.pwn

clean:
	DEL p
