
// vim: set filetype=c ts=8 noexpandtab:

#namespace "pname"

varinit
{
#define PLAYERNAMEVER 1 // increase this when any of this logic changes
#define SetPlayerName SetPlayerNameHook
#define NAMEOF(%0) playernames[%0][1]
#define NAMELEN(%0) playernames[%0][0]
	new playernames[MAX_PLAYERS][MAX_PLAYER_NAME + 2]
}

hook OnPlayerConnect(playerid)
{
	playernames[playerid][0] = GetPlayerName(playerid, playernames[playerid][1], 20)
}

//@summary Hooks {@link SetPlayerName} to cache playernames
//@param playerid see {@link SetPlayerName}
//@param name see {@link SetPlayerName}
//@returns see {@link SetPlayerName}
//@remarks see {@link SetPlayerName}
//@remarks has {@code onPlayerNameChange} section
//@seealso SetPlayerName
SetPlayerNameHook(playerid, const name[])
{
#undef SetPlayerName
	new res = SetPlayerName(playerid, name)
#define SetPlayerName SetPlayerNameHook
	if (res == 1) {
		new len = strlen(name)
		playernames[playerid][0] = len
		#allowmemcpywitharrayindexer
		memcpy(playernames[playerid], name, 4, ++len * 4)
##section onPlayerNameChange
###include "login"
##endsection
		new s[34 + MAX_PLAYER_NAME + 1]
		format s, sizeof(s), "Your name has been changed to '%s'", NAMEOF(playerid)
		SendClientMessage playerid, COL_SAMP_GREEN, s
		// TODO: if we ever do name changes, broadcast to other players that someone's name changed
	}
	return res
}

#printhookguards

