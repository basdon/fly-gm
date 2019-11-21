
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

varinit
{
	new time_h, time_s
	new lasttime
}

hook OnGameModeInit()
{
	lasttime = gettime()
	time_h = 7, time_s = 59
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
		if (++time_s >= 60) {
			time_s = 0
			if (++time_h >= 24) {
				time_h = 0
			}
			goto loop30s
		} else if (time_s == 30) {
loop30s:
##section loop30s
##include "playtime"

##endsection
		}
		lasttime = time
	}

// restore actual hook
#define @loop100
}

#printhookguards

