
// vim: set filetype=c ts=8 noexpandtab:

#namespace "tcyc"

// phase one: lockedweather changes
// (nothing happens)
// phase two: upcomingweather changes to lockedweather
// (transitioning)
// phase three: currentweather changes to upcomingweather

// next phase is triggered when next minutes is lower than previous minutes number (hrs completely ignored)
// minutes going up only has the effect that the transition is corrected for that time

// this works to change weather instantly:
// TogglePlayerClock 0
// SetPlayerWeather 16
// TogglePlayerClock 1
// SetPlayerWeather 0 // this sets lockedweather as it should

// changing player time multiple times does NOT work

// if player dies, cycle goes

//#define TIMECYC_OVERLAY_CLOCK
#define TIMECYC_TEMP_MINUTES 30

varinit
{
	new time_h, time_s
	new lasttime
#ifdef TIMECYC_OVERLAY_CLOCK
	new Text:clocktext
#endif
	new lockedweather = 0, upcomingweather = 0, currentweather = 0
	new playertimecycstate[MAX_PLAYERS]
	#define SetWeather USE_setWeather_INSTEAD
	#define TIMESIG(%0) ((lockedweather << 24) | (upcomingweather << 16) | (currentweather << 8) | (%0))
}

hook OnGameModeInit()
{
	lasttime = gettime()
	time_h = 7, time_s = 59

	PUB_TIMECYC_NEXTWEATHER
	SetTimer #PUB_TIMECYC_NEXTWEATHER, 15 * 60000, .repeating=1

#ifdef TIMECYC_OVERLAY_CLOCK
	clocktext = TextDrawCreate(608.0, 22.0, "12:73")
	TextDrawColor clocktext, 0xE1E1E1FF
	TextDrawLetterSize clocktext, 0.55, 2.2
	TextDrawSetProportional clocktext, 0
	TextDrawFont clocktext, 3
	TextDrawAlignment clocktext, 3
	TextDrawSetShadow clocktext, 0
	TextDrawSetOutline clocktext, 2
	TextDrawBackgroundColor clocktext, 0x000000FF
#endif
}

hook loop100()
{
// very ew, but if @loop100 is defined, other loophooks in here might get confused, so temp undefine it
#ifndef @loop100
#error "in loop100 but no @loop100 defined"
#endif
#undef @loop100

	new time = gettime() // TODO this can be used as time cache?
	if (time > lasttime) {
##section loop1s
##endsection
##section loop1splayers
	foreach (new playerid : players) {
##include "vehicles"

##include "zones"

	}
##endsection
		if (++time_s >= 60) {
			time_s = 0
			currentweather = upcomingweather
			upcomingweather = lockedweather
			if (++time_h >= 24) {
				time_h = 0
			}
			goto loop30s
#assert TIMECYC_TEMP_MINUTES == 30
		} else if (time_s == TIMECYC_TEMP_MINUTES) {
			if (currentweather == upcomingweather && time_s == TIMECYC_TEMP_MINUTES) {
				// sync everyone every minutes if no transition is going on, just in case
				for (new _i : players) {
					new playerid = iter_access(players, _i)
					if (isSpawned(playerid) && !isAfk(playerid)) {
						forceTimecycForPlayer playerid
					}
				}
			}
loop30s:
##section loop30s
##include "playtime"

##endsection
		}
#ifdef TIMECYC_OVERLAY_CLOCK
		new buf[6]
		format buf, 6, "%02d:%02d", time_h, time_s
		TextDrawSetString clocktext, buf
#endif
		lasttime = time
	}

// restore actual hook
#define @loop100
}

hook OnPlayerConnect(playerid)
{
	playertimecycstate[playerid] = 0
}

hook OnPlayerRequestClass(playerid, classid)
{
#ifdef TIMECYC_OVERLAY_CLOCK
	TextDrawHideForPlayer playerid, clocktext
#endif
	TogglePlayerClock playerid, 0
	SetPlayerTime playerid, 12, 0
	SetPlayerWeather playerid, 1
}

hook OnPlayerRequestSpawn(playerid)
{
#ifdef TIMECYC_OVERLAY_CLOCK
	TextDrawShowForPlayer playerid, clocktext
#endif
}

//hook OnPlayerSpawn(playerid)
//{
//	// onPlayerWasAfk handles this...
//}

hook OnPlayerDeath(playerid, killerid, reason)
{
	TogglePlayerClock playerid, 0
}

hook onPlayerWasAfk(playerid)
{
	forceTimecycForPlayer playerid
}

hook OnPlayerUpdate(playerid)
{
	if (playertimecycstate[playerid]) {
		switch ((playertimecycstate[playerid] & 0xFF)) {
		case 1: {
			SetPlayerTime playerid, time_h, 0
			playertimecycstate[playerid]++
		}
		case 2: {
			SetPlayerTime playerid, time_h, time_s
			if (playertimecycstate[playerid] != TIMESIG(2)) {
				// weather changed while we were syncing, force it again...
				// this should be rare, if it even happens at all
				printf "[timecyc] it happened"
				forceTimecycForPlayer playerid
			} else {
				if (lockedweather != upcomingweather) {
					SetPlayerWeather playerid, lockedweather
				}
				playertimecycstate[playerid] = 0
			}
		}
		}
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1531147493, 1449357374: if (Command_Is(cmdtext, "/weather", idx) || Command_Is(cmdtext, "/metar", idx)) {
		Timecyc_GetCurrentWeatherMsg buf144
		SendClientMessage playerid, COLOR_METAR, buf144
		#return 1
	}
}

//@summary Change the weather (slowly)
//@param weather the weather id to change to
setWeather(weather)
{
	if (lockedweather == weather) {
		return
	}
	lockedweather = weather
	for (new _i : players) {
		new playerid = iter_access(players, _i)
		if (isSpawned(playerid) && !isAfk(playerid)) {
			SetPlayerWeather playerid, lockedweather
		}
	}
}

//@summary Sync weather (and thus time) for a player
//@param playerid the player that needs to be synced
forceTimecycForPlayer(playerid)
{
	// set current weather to all (currentweather, upcomingweather, lockedweather)
	TogglePlayerClock playerid, 0
	SetPlayerWeather playerid, currentweather
	// no delay needed there ^

	if (currentweather == upcomingweather) {
		// set time right
		SetPlayerTime playerid, time_h, time_s
		TogglePlayerClock playerid, 1
		if (lockedweather != upcomingweather) {
			SetPlayerWeather playerid, lockedweather
			// no delay needed there ^
		}
		playertimecycstate[playerid] = 0
		return
	}

	// need to change upcomingweather, so force a transition cycle
	SetPlayerTime playerid, time_h, TIMECYC_TEMP_MINUTES
	TogglePlayerClock playerid, 1
	SetPlayerWeather playerid, upcomingweather
	// this sets lockedweather

	// rest is done in OnPlayerUpdate
	playertimecycstate[playerid] = TIMESIG(1)
}

//@summary Advances the weather
export __SHORTNAMED PUB_TIMECYC_NEXTWEATHER()
{
	new weather = random(NEXT_WEATHER_POSSIBILITIES)
	setWeather Timecyc_GetNextWeatherMsgQuery(weather, buf144, buf4096)
	SendClientMessageToAll COLOR_METAR, buf144
	if (buf4096[0]) {
		mysql_tquery 1, buf4096
	}
}

#printhookguards

