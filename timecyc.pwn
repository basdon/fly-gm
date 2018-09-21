
// vim: set filetype=c ts=8 noexpandtab:

#namespace "timecyc"

// toggling the clock off once will advance weather change a bit
// toggling the clock off a second time will instantly change the weather to the next one
// setting the time ahead will keep interpolating the weather but make up for the jump
// setting the time back will instantly change the weather to the next one

hook OnPlayerSpawn(playerid)
{
	TogglePlayerClock playerid, 1
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	TogglePlayerClock playerid, 0
}

#printhookguards

