
// vim: set filetype=c ts=8 noexpandtab:

#namespace "ac"

// see also dialog.pwn for dialog spoofing

// TODO: check animation (swimming, parachute), in conjunction with z-coord and z-velocity

#define FLOOD_DECLINE 3
#define FLOOD_DIALOG 10
#define FLOOD_LIMIT 100

varinit
{
	new kickprogress[MAX_PLAYERS]
	new floodcount[MAX_PLAYERS]
	new cc[MAX_PLAYERS]
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
}

hook loop100(playerid)
{
	foreach (new playerid : allplayers) {
		if (isAfk(playerid) && kickprogress[playerid]) {
			if ((kickprogress[playerid] -= 3) <= 0) {
				Kick playerid
			}
		}
		if (floodcount[playerid] > 0) {
			floodcount[playerid] = clamp(floodcount[playerid] - FLOOD_DECLINE, 0, cellmax)
		}
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
		new msg[38 + MAX_PLAYER_NAME + 2 + 4 + 1]
		format msg, sizeof(msg), "%s[%d] was kicked by system (excess flood)", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_WARN, msg
		KickDelayed playerid
	}
}

//@summary Kicks a player after they received next stream of packets
//@param playerid the player to kick
//@param delay the delay, in how many times a client should be synced before kicking (optional={@code 1})
//@remarks if KickDelayed was called previously, player will be kicked immediately
//@remarks is player is afk, {@param delay} will be clamped to {@code [4,cellmax]} for use in 100loop instead of OnPlayerUpdate
KickDelayed(playerid, delay=1)
{
	if (kickprogress[playerid]) {
		Kick playerid
		return
	}
	if (isAfk(playerid)) {
		delay = clamp(delay, 4, cellmax)
	}
	kickprogress[playerid] = delay
}

//@summary When passing playerid to callbacks (for example for a database query), when the callback is \
		called the player with {@param playerid} might be disconnected or even a different player. \
		This func checks if the player with given id is still the same player by counting the amount \
		of disconnects per playerid.
//@param playerid player id to check
//@param cid connection id that was assigned to the player, use {@code cc[playerid]} {@b when passing the callback's params}
//@returns {@code 0} if {@param playerid} is now assigned to a different player
isValidPlayer(playerid, cid)
{
	return cc[playerid] == cid
}

#printhookguards

