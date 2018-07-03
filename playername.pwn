
// vim: set filetype=c ts=8 noexpandtab:

#namespace "pname"

hook varinit()
{
	new playernames[MAX_PLAYERS][MAX_PLAYER_NAME + 2]

	SetPlayerNameHook(playerid, const newname[])
	{
		new res = SetPlayerName(playerid, newname)
		if (res == 1) {
			new len = strlen(newname)
			playernames[playerid][0] = len
			memcpy(playernames[playerid], newname, 4, ++len * 4)
		}
		#allowreturn
		return res
	}

	#define SetPlayerName( SetPlayerNameHook(
	#define NAMEOF(%0) playernames[%0][1]
	#define NAMELEN(%0) playernames[%0][0]
}

hook OnPlayerConnect(playerid)
{

	playernames[playerid][0] = GetPlayerName(playerid, playernames[playerid][1], 20)
}

#printhookguards

