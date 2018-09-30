
// vim: set filetype=c ts=8 noexpandtab:

#namespace "afk"

varinit
{
	#define isAfk(%0) iter_has(afkplayers,%0)

	new lastupdate[MAX_PLAYERS]
	new Iter:afkplayers[MAX_PLAYERS]
	new uncommittedplaytime[MAX_PLAYERS]
}

hook OnPlayerUpdate(playerid)
{
	if (iter_has(afkplayers, playerid)) {
		iter_remove(afkplayers, playerid)
		onPlayerWasAfk playerid
	}
	lastupdate[playerid] = gettime()
}

hook loop100()
{
	foreach (new playerid : players) {
		if (!iter_has(afkplayers, playerid) && lastupdate[playerid] < gettime() - 1) {
			iter_add(afkplayers, playerid)
			onPlayerNowAfk playerid
		}
	}
}

hook onPlayerNowAfk(playerid)
{
	uncommittedplaytime[playerid] = gettime() - uncommittedplaytime[playerid]
}

hook onPlayerWasAfk(playerid)
{
	uncommittedplaytime[playerid] = gettime() - uncommittedplaytime[playerid]
}

hook OnPlayerConnect(playerid)
{
	iter_add(afkplayers, playerid)
	uncommittedplaytime[playerid] = 0
}

hook OnPlayerDisconnect(playerid)
{
	iter_remove(afkplayers, playerid)
}

//@summary Gets the amounf of seconds a player has played since the last call to this function
//@param playerid the playerid to get the uncommitted playtime of
//@returns the amount of seconds this player has played (not afk) since the last call
getAndClearUncommittedPlaytime(playerid)
{
	new time
	if (isAfk(playerid)) {
		time = uncommittedplaytime[playerid]
		uncommittedplaytime[playerid] = 0
	} else {
		new now = gettime()
		time = now - uncommittedplaytime[playerid]
		uncommittedplaytime[playerid] = now
	}
	return time
}

#printhookguards

