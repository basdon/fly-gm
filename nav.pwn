
// vim: set filetype=c ts=8 noexpandtab:

#namespace "nav"

#define SOUND_NAV_SET 1083
#define SOUND_NAV_DEL 1084

varinit
{
}

hook OnVehicleSpawn(vehicleid)
{
	Nav_Reset vehicleid
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1496596: if (IsCommand(cmdtext, "/adf", idx)) {
		new vid = GetPlayerVehicleID(playerid)
		if (vid == 0 || !IsAirVehicle(GetVehicleModel(vid))) {
			SendClientMessage playerid, COL_WARN, WARN"You're not in an ADF capable vehicle"
			#return 1
		}
		if (!Params_GetString(cmdtext, idx, buf144)) {
			if (Nav_Reset(vid)) {
				PlayerPlaySound playerid, SOUND_NAV_DEL, 0.0, 0.0, 0.0
				panel_resetNavForPassengers vid
			} else {
				SendClientMessage playerid, COL_WARN, WARN"Syntax: /adf [beacon] - see /beacons or /nearest"
			}
			#return 1
		}
		if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
			SendClientMessage playerid, COL_WARN, WARN"Only the pilot can change navigation settings"
			#return 1
		}
		if (!Nav_EnableADF(vid, buf144)) {
			SendClientMessage playerid, COL_WARN, WARN"Unknown beacon - see /beacons or /nearest"
			#return 1
		}
		PlayerPlaySound playerid, SOUND_NAV_SET, 0.0, 0.0, 0.0
		#return 1
	}
	case 1517130: if (IsCommand(cmdtext, "/vor", idx)) {
		new vid = GetPlayerVehicleID(playerid)
		if (vid == 0 || !IsPlane(GetVehicleModel(vid))) {
			SendClientMessage playerid, COL_WARN, WARN"You're not in a VOR capable vehicle"
			#return 1
		}
		if (!Nav_EnableVOR(vid, cmdtext[idx], buf64)) {
			switch (buf64[0]) {
			case 0: SendClientMessage playerid, COL_WARN, WARN"Syntax: /vor [beacon][runway] - see /nearest or /beacons"
			case 1: {
				PlayerPlaySound playerid, SOUND_NAV_DEL, 0.0, 0.0, 0.0
				panel_resetNavForPassengers vid
			}
			default: SendClientMessage playerid, COL_WARN, buf64
			}
			#return 1
		}
		PlayerPlaySound playerid, SOUND_NAV_SET, 0.0, 0.0, 0.0
		#return 1
	}
	case 1504545: if (IsCommand(cmdtext, "/ils", idx)) {

	}
}

#printhookguards

