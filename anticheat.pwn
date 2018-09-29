
// vim: set filetype=c ts=8 noexpandtab:

#namespace "ac"

// see also dialog.pwn for dialog spoofing

#define FLOOD_DECLINE 3
#define FLOOD_DIALOG 10
#define FLOOD_LIMIT 100

varinit
{
	new kickprogress[MAX_PLAYERS]
	new floodcount[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	kickprogress[playerid] = 0
	floodcount[playerid] = 0
}

hook OnPlayerUpdate(playerid)
{
	if (kickprogress[playerid]) {
		if (kickprogress[playerid]-- == 1) {
			Kick playerid
		}
	}
	if (floodcount[playerid] > 0) {
		floodcount[playerid] -= FLOOD_DECLINE
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	flood playerid, FLOOD_DIALOG
}

//@summary Add {@param amount} of flood value to player. Players with a flood value of more than {@code FLOOD_LIMIT} will be kicked.
//@param playerid player to add flood value to
//@param amount amount of flood value to add
flood(playerid, amount)
{
	if ((floodcount[playerid] += amount) >= FLOOD_LIMIT) {
		if (isPlaying(playerid)) {
			new msg[38 + MAX_PLAYER_NAME + 2 + 4 + 1]
			format msg, sizeof(msg), "%s[%d] was kicked by system (excess flood)", NAMEOF(playerid), playerid
			SendClientMessageToAll COL_WARN, msg
		}
		KickDelayed playerid
	}
}

//@summary Kicks a player after they received next stream of packets
//@param playerid the player to kick
//@param delay the delay, in how many times a client should be synced before kicking (optional={@code 1})
//@remarks if KickDelayed was called previously or player is in login phase, player will be kicked immediately
KickDelayed(playerid, delay=1) {
	if (kickprogress[playerid] || !isPlaying(playerid)) {
		Kick playerid
		return
	}
	kickprogress[playerid] = delay
}

#printhookguards

