
// vim: set filetype=c ts=8 noexpandtab:

#namespace "heartbeat"

varinit
{
	new bootsession = -1
}

hook loop30s()
{
	if (bootsession != -1) {
		format buf144, sizeof(buf144), "UPDATE heartbeat SET tlast=UNIX_TIMESTAMP() WHERE id=%d", bootsession
		mysql_tquery 1, buf144
	}
}

hook OnGameModeExit()
{
	if (bootsession != -1) {
		format buf144, sizeof(buf144), "UPDATE heartbeat SET tlast=UNIX_TIMESTAMP(),cleanexit=1 WHERE id=%d", bootsession
		mysql_tquery 1, buf144
	}
}

hook OnGameModeInit()
{
	new Cache:bootlog = mysql_query(1, "INSERT INTO heartbeat(tstart,tlast) VALUES(UNIX_TIMESTAMP(),UNIX_TIMESTAMP())")
	bootsession = cache_insert_id()
	cache_delete bootlog
}

#printhookguards

