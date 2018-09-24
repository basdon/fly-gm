
// vim: set filetype=c ts=8 noexpandtab:

#namespace "timecyc"

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

varinit
{
	new time_h, time_s
	new lasttime
#ifdef TIMECYC_OVERLAY_CLOCK
	new Text:clocktext
#endif
	new lockedweather = 0, upcomingweather = 0, currentweather = 0
	#define SetWeather USE_setWeather_INSTEAD
}

hook OnGameModeInit()
{
	lasttime = gettime()
	time_h = 0, time_s = 0

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
	new time = gettime() // TODO this can be used as time cache?
	if (time > lasttime) {
		if (++time_s >= 60) {
			time_s = 0
			currentweather = upcomingweather
			upcomingweather = lockedweather
			if (++time_h >= 24) {
				time_h = 0
			}
		}
#ifdef TIMECYC_OVERLAY_CLOCK
		new buf[6]
		format buf, 6, "%02d:%02d", time_h, time_s
		TextDrawSetString clocktext, buf
#endif
		lasttime = time
		// TODO: this is 1s loop
	}
}

hook OnPlayerRequestClass(playerid, classid)
{
#ifdef TIMECYC_OVERLAY_CLOCK
	TextDrawHideForPlayer playerid, clocktext
#endif
	TogglePlayerClock playerid, 0
	SetPlayerTime playerid, 12, 0
	SetPlayerWeather playerid, 0
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

//@summary Delegate for {@link SetPlayerWeather} to call using a timer
//@param playerid see {@link SetPlayerWeather}
//@param weather see {@link SetPlayerWeather}
//@remarks PUB_SETPLAYERWEATHER
export PUB_SETPLAYERWEATHER(playerid, weather)
{
	SetPlayerWeather playerid, weather
}

//@summary Delegate for {@link SetPlayerTime} to call using a timer
//@param playerid player to set time for
//@param hour hour to set
//@param minute minute to set
//@remarks If {@param hour} or {@param minute} is {@code -1}, the current time will be used
//@remarks PUB_SETPLAYERTIME
export PUB_SETPLAYERTIME(playerid, hour, minute)
{
	if (hour == -1 || minute == -1) {
		SetPlayerTime playerid, time_h, time_s
	} else {
		SetPlayerTime playerid, hour, minute
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

	// set time right
	SetPlayerTime playerid, time_h, time_s
	TogglePlayerClock playerid, 1

	if (currentweather == upcomingweather) {
		if (lockedweather != upcomingweather) {
			SetPlayerWeather playerid, lockedweather
			// no delay needed there ^
		}
		return
	}

	// need to change upcomingweather, so force a transition cycle
	new delay = 70
	new timeback = time_s - 2
	if (time_s <= 1) {
		delay += 2200
		timeback += 2
	}

	SetPlayerWeather playerid, upcomingweather
	// this sets lockedweather
	SetTimerEx #PUB_SETPLAYERTIME, delay, 0, "iii", playerid, time_h, timeback
	// sets upcomingweather to lockedweather
	SetTimerEx #PUB_SETPLAYERTIME, delay + 70, 0, "iii", playerid, -1, -1
	// reset time back as it should
	if (lockedweather != upcomingweather) {
		// finally set lockedweather if it's not the same as upcoming
		SetTimerEx #PUB_SETPLAYERWEATHER, delay + 40, 0, "ii", playerid, lockedweather
	}
}

#printhookguards

