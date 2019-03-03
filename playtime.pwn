
// vim: set filetype=c ts=8 noexpandtab:

#namespace "playtime"

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

hook loop30s()
{
	foreach (new playerid : players) {
		updatePlayerLastseen playerid, .isdisconnect=0
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
	updatePlayerLastseen playerid, .isdisconnect=1
}

//@summary Updates a player's last seen (usr and ses) and total/actual time value in db
//@param playerid playerid to update
//@param isdisconnect is this call made from {@link OnPlayerDisconnect}?
//@remarks This function first checks if the player has a valid userid and sessionid
//@remarks If {@param isdisconnect} is {@code 0}, {@code 30} gets added to player's total time (inaccurate), \
otherwise player's totaltime is set to sum of session times (accurate)
updatePlayerLastseen(playerid, isdisconnect)
{
	new playtimetoadd
	if (isAfk(playerid)) {
		playtimetoadd = uncommittedplaytime[playerid]
		uncommittedplaytime[playerid] = 0
	} else {
		new now = gettime()
		playtimetoadd = now - uncommittedplaytime[playerid]
		uncommittedplaytime[playerid] = now
	}

	if (Playtime_FormatUpdateTimes(userid[playerid], sessionid[playerid], playtimetoadd, isdisconnect, buf4096)) {
		mysql_tquery 1, buf4096[2]
		new pos
		if ((pos = buf4096[0])) {
			mysql_tquery 1, buf4096[pos]
		}
		if ((pos = buf4096[1])) {
			mysql_tquery 1, buf4096[pos]
		}

	}
}

#printhookguards

