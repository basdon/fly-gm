
// vim: set filetype=c ts=8 noexpandtab:

#namespace "afk"

varinit
{
	#define isAfk(%0) iter_has(afkplayers,%0)

	new lastupdate[MAX_PLAYERS]
	new Iter:afkplayers[MAX_PLAYERS]
}

hook OnPlayerUpdate(playerid)
{
	if (iter_has(afkplayers, playerid)) {
		iter_remove(afkplayers, playerid)
		onPlayerWasAfk playerid
	}
	lastupdate[playerid] = gettime()
}

hook loop100(playerid)
{
	for (new _i : players) {
		new playerid = iter_access(players, _i)
		if (!iter_has(afkplayers, playerid) && lastupdate[playerid] < gettime() - 1 && !isSpawned(playerid)) {
			iter_add(afkplayers, playerid)
			onPlayerNowAfk playerid
		}
	}
}

hook OnPlayerDisconnect(playerid)
{
	iter_remove(afkplayers, playerid)
}

#define _isAfk isAfk
#undef isAfk
//@summary Check if a player is afk.
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@remarks A player is considered to be ask if they has not sent an update for over {@b 1000ms}.
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@returns {@code 0} if the player is not afk
//@seealso isSpawned
stock isAfk(playerid) {
	this_function _ should_not _ be_called
}
#define isAfk _isAfk
#undef _isAfk

#printhookguards

