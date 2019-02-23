SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "K:\Program Files\Git\usr\bin\sed.exe"
cp = "K:\Program Files\Git\usr\bin\cp.exe"
bash = K:/"Program Files"/Git/usr/bin/bash.exe

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
	$(bash) -c "sed -f $(ppfileoutline) basdon.pwn|sed -f $(ppfile)>p/basdon.p"

p/natives.p: natives.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) natives.pwn|sed -f $(ppfile)>p/natives.p"

p/sharedsymbols.p: sharedsymbols.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) sharedsymbols.pwn|sed -f $(ppfile)>p/sharedsymbols.p"

p/panel.p: panel.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) panel.pwn|sed -f $(ppfile)>p/panel.p"

p/pm.p: pm.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) pm.pwn|sed -f $(ppfile)>p/pm.p"

p/simpleiter.p: simpleiter.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) simpleiter.pwn|sed -f $(ppfile)>p/simpleiter.p"

p/game_sa.p: game_sa.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) game_sa.pwn|sed -f $(ppfile)>p/game_sa.p"

p/afk.p: afk.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) afk.pwn|sed -f $(ppfile)>p/afk.p"

p/playername.p: playername.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) playername.pwn|sed -f $(ppfile)>p/playername.p"

p/login.p: login.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) login.pwn|sed -f $(ppfile)>p/login.p"

p/util.p: util.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) util.pwn|sed -f $(ppfile)>p/util.p"

p/settings.p: settings.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) settings.pwn|sed -f $(ppfile)>p/settings.p"

p/colors.p: colors.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) colors.pwn|sed -f $(ppfile)>p/colors.p"

p/dialog.p: dialog.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) dialog.pwn|sed -f $(ppfile)>p/dialog.p"

p/spawn.p: spawn.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) spawn.pwn|sed -f $(ppfile)>p/spawn.p"

p/timecyc.p: timecyc.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) timecyc.pwn|sed -f $(ppfile)>p/timecyc.p"

p/tracker.p: tracker.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) tracker.pwn|sed -f $(ppfile)>p/tracker.p"

p/anticheat.p: anticheat.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) anticheat.pwn|sed -f $(ppfile)>p/anticheat.p"

p/dummies.p: dummies.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) dummies.pwn|sed -f $(ppfile)>p/dummies.p"

p/airport.p: airport.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) airport.pwn|sed -f $(ppfile)>p/airport.p"

p/zones.p: zones.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) zones.pwn|sed -f $(ppfile)>p/zones.p"

p/nav.p: nav.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) nav.pwn|sed -f $(ppfile)>p/nav.p"

p/objects.p: objects.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "sed -f $(ppfileoutline) objects.pwn|sed -f $(ppfile)>p/objects.p"

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
