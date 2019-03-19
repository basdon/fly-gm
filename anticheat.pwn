
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
	#define GetVehicleHealth@@ please_use_GetVehicleHealthSafe
	#define GetVehicleHealth GetVehicleHealth@@
	#define PutPlayerInVehicle@@ use_PutPlayerInVehicleSafe
	#define PutPlayerInVehicle PutPlayerInVehicle@@
	#define GetPlayerMoney@@ please_use_money_var
	#define GetPlayerMoney GetPlayerMoney@@
	#define GivePlayerMoney@@ please_use_money_funcs
	#define GivePlayerMoney GivePlayerMoney@@

	new kickprogress[MAX_PLAYERS]
	new floodcount[MAX_PLAYERS]
	new disallowedvehicleinfractions[MAX_PLAYERS char]
	new cc[MAX_PLAYERS]
	new vehicle_health_check_player_idx
	new money[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	kickprogress[playerid] = 0
	floodcount[playerid] = 0
	disallowedvehicleinfractions{playerid} = 0
}

hook OnPlayerDisconnect(playerid, reason)
{
	cc[playerid]++
}

hook OnPlayerText(playerid, text[])
{
	flood playerid, FLOOD_CHAT
	if (floodcount[playerid] > FLOOD_LIMIT - FLOOD_CHAT - FLOOD_CHAT / 2) {
		WARNMSG("Don't spam!")
	}
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
	if (vehicle_health_check_player_idx >= iter_count(allplayers)) {
		vehicle_health_check_player_idx = 0
	} else {
		new vehicleid, playerid = iter_access(allplayers, vehicle_health_check_player_idx++)
		if ((vehicleid = GetPlayerVehicleID(playerid))) {
			new Float:hp
			GetVehicleHealthSafe playerid, vehicleid, hp
		}
	}

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

hook loop5000()
{
	foreach (new playerid : players) {
		if (disallowedvehicleinfractions{playerid}) {
			disallowedvehicleinfractions{playerid}--
		}
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	flood playerid, FLOOD_DIALOG
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (!ispassenger) {
		new Float:hp
#undef GetVehicleHealth
		GetVehicleHealth vehicleid, hp
#define GetVehicleHealth GetVehicleHelp@@
		if (isNaN(hp) || hp < 0.0 || 1000.0 < hp) {
			SetVehicleHealth vehicleid, 1000.0
		}
	}
}

//@summary Add {@param amount} of flood value to player. Players with a flood value of more than {@code FLOOD_LIMIT} will be kicked.
//@param playerid player to add flood value to
//@param amount amount of flood value to add
flood(playerid, amount)
{
	if ((floodcount[playerid] += amount) >= FLOOD_LIMIT) {
		ac_log playerid, "excess flood"
		format buf144, sizeof(buf144), "%s[%d] was kicked by system (excess flood)", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_WARN, buf144
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

//@summary Gets the vehicle health, but checks first for NaN or unacceptable high/low values, and handling offenders
//@param playerid the player in the vehicle, {@code INVALID_PLAYER_ID} is accepted
//@param vehicleid vehicle id of which to get the hp
//@param hp reference to store vehicel hp in
//@returns {@code 1} if the player is being kicked because of invalid hp
//@seealso GetVehicleHealth
//@remarks macro makes sure {@link GetVehicleHealth} can't be used, don't worry
GetVehicleHealthSafe(playerid, vehicleid, &Float:hp)
{
#undef GetVehicleHealth
	GetVehicleHealth vehicleid, hp
#define GetVehicleHealth GetVehicleHelp@@
	// tested: passengers have no saying in what the vehicle hp is
	if (isNaN(hp)) {
		if (playerid != INVALID_PLAYER_ID && GetPlayerVehicleSeat(playerid) != 0) {
			hp = 1000.0
			return 0
		}
		ac_log playerid, "NaN vehicle hp"
	} else if (hp > 1000.0) {
		if (playerid != INVALID_PLAYER_ID && GetPlayerVehicleSeat(playerid) != 0) {
			hp = 1000.0
			return 0
		}
		format buf144, sizeof(buf144), "vehicle hp %.4f", hp
		ac_log playerid, buf144
	} else if (hp < 0.0) {
		hp = 0.0
		return 0
	} else {
		return 0
	}
	format buf144, sizeof(buf144), "%s[%d] was kicked by system (invalid vehicle hp)", NAMEOF(playerid), playerid
	SendClientMessageToAll COL_WARN, buf144
	KickDelayed playerid
	SetVehicleHealth vehicleid, 1000.0
	return 1
}

//@summary See {@link PutPlayerInVehicle}, but resets the vehicle's health to {@code 1000.0} first if it has an invalid value
//@param playerid The ID of the player to put in a vehicle
//@param vehicleid The ID of the vehicle to put the player in
//@param seatid The ID of the seat to put the player in
//@returns {@code 1 on success}
PutPlayerInVehicleSafe(playerid, vehicleid, seatid)
{
	if (seatid == 0) {
		new Float:hp
#undef GetVehicleHealth
		GetVehicleHealth vehicleid, hp
#define GetVehicleHealth GetVehicleHelp@@
		if (isNaN(hp) || hp < 0.0 || 1000.0 < hp) {
			SetVehicleHealth vehicleid, 1000.0
		}
	}
#undef PutPlayerInVehicle
	PutPlayerInVehicle playerid, vehicleid, seatid
#define PutPlayerInVehicle PutPlayerInVehicle@@
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

//@summary Should be called at most every second when a player is in a vehicle they aren't allowed to be in,\
		player will be kicked if this happens too often
//@param playerid the offending player
ac_disallowedVehicle1s(playerid)
{
	// value gets decreased in loop5000
	if ((disallowedvehicleinfractions{playerid} += 3) > 15) {
		ac_log playerid, "unauthorized vehicle access"
		format buf144, sizeof(buf144), "%s[%d] was kicked by system (unauthorized vehicle access)", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_WARN, buf144
		KickDelayed playerid
	}
}

//@summary Log something to db (acl table)
//@param playerid player
//@param message message (don't sqli yourself)
ac_log(playerid, const message[])
{
	Ac_FormatLog playerid, loggedstatus[playerid], message, buf4096
	mysql_tquery 1, buf4096
}

//@summary Takes money from a player
//@param playerid player to take money from
//@returns actual amount of money that was taken from {@param playerid}
//@remarks will not take any money when it would cause an underflow
money_takeFrom(playerid, amount)
{
	if (money[playerid] - amount > money[playerid]) {
		return 0
	}
	money[playerid] -= amount
	return amount
}

//@summary Gives money to a player
//@param playerid player to give money to
//@returns actual amount of money that was given to {@param playerid}
//@remarks will not give any money when it would cause an overflow
money_giveTo(playerid, amount)
{
	if (money[playerid] + amount < money[playerid]) {
		return 0
	}
	money[playerid] += amount
	return amount
}

#printhookguards

