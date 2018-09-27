
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
		if (kickprogress[playerid]-- == 1) {
			Kick playerid
		}
	}
}

//@summary Kicks a player after they received next stream of packets
//@param playerid the player to kick
//@param delay the delay, in how many times a client should be synced before kicking (optional={@code 1})
KickDelayed(playerid, delay=1) {
	if (!kickprogress[playerid]) {
		kickprogress[playerid] = delay
	}
}

#printhookguards

