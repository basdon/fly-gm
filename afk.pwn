
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
		if (!iter_has(afkplayers, playerid) && lastupdate[playerid] < gettime() - 1) {
			iter_add(afkplayers, playerid)
			onPlayerNowAfk playerid
		}
	}
}

hook OnPlayerDisconnect(playerid)
{
	iter_remove(afkplayers, playerid)
}

#printhookguards

