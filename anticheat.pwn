
// vim: set filetype=c ts=8 noexpandtab:

#namespace "ac"

// see also dialog.pwn for dialog spoofing

// TODO: check animation (swimming, parachute), in conjunction with z-coord and z-velocity

#define FLOOD_DECLINE 3 // per 100ms
#define FLOOD_DIALOG 10
#define FLOOD_CHAT 30
#define FLOOD_LIMIT 100

varinit
{
	#define CRASH(%0) GameTextForPlayer(%0,crashstr,5,5)

	stock const crashstr[] = "Wasted~~k~SWITCH_DEBUG_CAM_ON~~k~~TOGGLE_DPAD~~k~~NETWORK_TALK~~k~~SHOW_MOUSE_POINTER_TOGGLE~"

	new kickprogress[MAX_PLAYERS]
	new cc[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	kickprogress[playerid] = 0
	ResetPlayerMoney playerid
}

hook OnPlayerDisconnect(playerid, reason)
{
	cc[playerid]++
}

hook OnPlayerUpdate(playerid)
{
	if (kickprogress[playerid]) {
		if (kickprogress[playerid]-- == 1) {
			Kick playerid
		}
	}
}

hook loop100()
{
	foreach (new playerid : allplayers) {
		// TODO
		//if (isAfk(playerid) && kickprogress[playerid]) {
		//	if ((kickprogress[playerid] -= 3) <= 0) {
		//		Kick playerid
		//	}
		//}
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
	// TODO
	//if (isAfk(playerid)) {
	//	delay = clamp(delay, 4, cellmax)
	//}
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

