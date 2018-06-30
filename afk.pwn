
// vim: set filetype=c ts=8 noexpandtab:

#define isAfk(%0) (lastupdate[%0]<gettime()-1)

hook VAR()
{
	new lastupdate[MAX_PLAYERS]
}

hook ONPLAYERUPDATE(playerid)
{
	lastupdate[playerid] = gettime()
}

