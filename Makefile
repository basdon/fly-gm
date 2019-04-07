SHELL = cmd.exe
.SHELLFLAGS = /c
sed = "C:\Program Files\Git\usr\bin\sed.exe"
cp = "C:\Program Files\Git\usr\bin\cp.exe"
bash = C:/"Program Files"/Git/usr/bin/bash.exe
sedx = C:/Program\ Files/Git/usr/bin/sed.exe

ppfile = preprocess.sed
ppfileoutline = preprocess-outline.sed

#FILE basdon
#FILE dev
#FILE natives
#FILE sharedsymbols
#FILE panel
#FILE pm
#FILE simpleiter
#FILE game_sa
#FILE playtime
#FILE playername
#FILE prefs
#FILE login
#FILE missions
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
#FILE vehicles
#FILE objects

#START
#S2

build: p/sharedsymbols.p p/objects.p p/vehicles.p p/nav.p p/zones.p p/airport.p p/dummies.p p/anticheat.p p/tracker.p p/timecyc.p p/spawn.p p/dialog.p p/colors.p p/settings.p p/util.p p/missions.p p/login.p p/prefs.p p/playername.p p/playtime.p p/game_sa.p p/simpleiter.p p/pm.p p/panel.p p/sharedsymbols.p p/natives.p p/dev.p p/basdon.p
	@echo.

p/basdon.p: basdon.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) basdon.pwn|$(sedx) -f $(ppfile)>p/basdon.p"

p/dev.p: dev.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) dev.pwn|$(sedx) -f $(ppfile)>p/dev.p"

p/natives.p: natives.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) natives.pwn|$(sedx) -f $(ppfile)>p/natives.p"

p/sharedsymbols.p: sharedsymbols.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) sharedsymbols.pwn|$(sedx) -f $(ppfile)>p/sharedsymbols.p"

p/panel.p: panel.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) panel.pwn|$(sedx) -f $(ppfile)>p/panel.p"

p/pm.p: pm.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) pm.pwn|$(sedx) -f $(ppfile)>p/pm.p"

p/simpleiter.p: simpleiter.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) simpleiter.pwn|$(sedx) -f $(ppfile)>p/simpleiter.p"

p/game_sa.p: game_sa.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) game_sa.pwn|$(sedx) -f $(ppfile)>p/game_sa.p"

p/playtime.p: playtime.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) playtime.pwn|$(sedx) -f $(ppfile)>p/playtime.p"

p/playername.p: playername.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) playername.pwn|$(sedx) -f $(ppfile)>p/playername.p"

p/prefs.p: prefs.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) prefs.pwn|$(sedx) -f $(ppfile)>p/prefs.p"

p/login.p: login.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) login.pwn|$(sedx) -f $(ppfile)>p/login.p"

p/missions.p: missions.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) missions.pwn|$(sedx) -f $(ppfile)>p/missions.p"

p/util.p: util.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) util.pwn|$(sedx) -f $(ppfile)>p/util.p"

p/settings.p: settings.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) settings.pwn|$(sedx) -f $(ppfile)>p/settings.p"

p/colors.p: colors.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) colors.pwn|$(sedx) -f $(ppfile)>p/colors.p"

p/dialog.p: dialog.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) dialog.pwn|$(sedx) -f $(ppfile)>p/dialog.p"

p/spawn.p: spawn.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) spawn.pwn|$(sedx) -f $(ppfile)>p/spawn.p"

p/timecyc.p: timecyc.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) timecyc.pwn|$(sedx) -f $(ppfile)>p/timecyc.p"

p/tracker.p: tracker.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) tracker.pwn|$(sedx) -f $(ppfile)>p/tracker.p"

p/anticheat.p: anticheat.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) anticheat.pwn|$(sedx) -f $(ppfile)>p/anticheat.p"

p/dummies.p: dummies.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) dummies.pwn|$(sedx) -f $(ppfile)>p/dummies.p"

p/airport.p: airport.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) airport.pwn|$(sedx) -f $(ppfile)>p/airport.p"

p/zones.p: zones.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) zones.pwn|$(sedx) -f $(ppfile)>p/zones.p"

p/nav.p: nav.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) nav.pwn|$(sedx) -f $(ppfile)>p/nav.p"

p/vehicles.p: vehicles.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) vehicles.pwn|$(sedx) -f $(ppfile)>p/vehicles.p"

p/objects.p: objects.pwn $(ppfile) $(ppfileoutline)
	$(bash) -c "$(sedx) -f $(ppfileoutline) objects.pwn|$(sedx) -f $(ppfile)>p/objects.p"

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
