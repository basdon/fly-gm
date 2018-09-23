
// vim: set filetype=c ts=8 noexpandtab:

#namespace "timecyc"

// toggling the clock off once will advance weather change a bit
// toggling the clock off a second time will instantly change the weather to the next one
// setting the time ahead will keep interpolating the weather but make up for the jump
// setting the time back will instantly change the weather to the next one

varinit
{
	new time_h, time_s
	new lasttime
	new Text:clocktext
}

hook OnGameModeInit()
{
	lasttime = gettime()
	time_h = 0, time_s = 0

	clocktext = TextDrawCreate(608.0, 22.0, "12:73")
	TextDrawColor clocktext, 0xE1E1E1FF
	TextDrawLetterSize clocktext, 0.55, 2.2
	TextDrawSetProportional clocktext, 0
	TextDrawFont clocktext, 3
	TextDrawAlignment clocktext, 3
	TextDrawSetShadow clocktext, 0
	TextDrawSetOutline clocktext, 2
	TextDrawBackgroundColor clocktext, 0x000000FF
}

hook loop100()
{
	new time = gettime() // TODO this can be used as time cache?
	if (time > lasttime) {
		if (++time_s >= 60) {
			time_s = 0
			if (++time_h >= 24) {
				time_h = 0
			}
		}
		new buf[6]
		format buf, 6, "%02d:%02d", time_h, time_s
		TextDrawSetString clocktext, buf
		lasttime = time
		// TODO: this is 1s loop
	}
}

hook OnPlayerRequestSpawn(playerid)
{
	TextDrawShowForPlayer playerid, clocktext
	updateTimecycForPlayer playerid
}

hook OnPlayerSpawn(playerid)
{
	TogglePlayerClock playerid, 1
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	TogglePlayerClock playerid, 0
}

//@summary Make sure player's time is in sync
//@param playerid player to sync
updateTimecycForPlayer(playerid)
{
	// TODO timecyc sync
}

#printhookguards

