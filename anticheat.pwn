
// vim: set filetype=c ts=8 noexpandtab:

#namespace "ac"

varinit
{
	new kickprogress[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	kickprogress[playerid] = 0
}

hook OnPlayerUpdate(playerid)
{
	if (kickprogress[playerid]) {
		Kick playerid
	}
}

//@summary Kicks a player after they received next stream of packets
//@param playerid the player to kick
KickDelayed(playerid) {
	if (!kickprogress[playerid]) {
		kickprogress[playerid] = 1
	}
}

#printhookguards

