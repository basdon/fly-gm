
// vim: set filetype=c ts=8 noexpandtab:

#namespace "afk"

#if !defined isAfk
//@summary Check if a player is afk.
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@remarks A player is considered to be ask if they has not sent an update for over {@b 1000ms}.
//@returns {@code 0} if the player is not afk
stock isAfk(playerid) { }
#define isAfk(%0) (lastupdate[%0]<gettime()-1)
#endif

hook varinit()
{
	new lastupdate[MAX_PLAYERS]
}

hook OnPlayerUpdate(playerid)
{
	lastupdate[playerid] = gettime()
}

#printhookguards

