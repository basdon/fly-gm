
// vim: set filetype=c ts=8 noexpandtab:

#namespace "pname"

#if defined @varinit
#define PLAYERNAMEVER 1 // increase this when any of this logic changes
new playernames[MAX_PLAYERS][MAX_PLAYER_NAME + 2]

SetPlayerNameHook(playerid, const name[])
// (doc is here because it somehow gets attached to 'playernames' variable when it's put above)
//@summary Hooks {@link SetPlayerName} to cache playernames
//@param playerid see {@link SetPlayerName}
//@param name see {@link SetPlayerName}
//@returns see {@link SetPlayerName}
//@remarks see {@link SetPlayerName}
//@seealso SetPlayerName
{
	new res = SetPlayerName(playerid, name)
	if (res == 1) {
		new len = strlen(name)
		playernames[playerid][0] = len
		memcpy(playernames[playerid], name, 4, ++len * 4)
	}
	return res
}

#define SetPlayerName( SetPlayerNameHook(
#define NAMEOF(%0) playernames[%0][1]
#define NAMELEN(%0) playernames[%0][0]
#endinput
#endif

hook OnPlayerConnect(playerid)
{
	playernames[playerid][0] = GetPlayerName(playerid, playernames[playerid][1], 20)
}

#printhookguards

