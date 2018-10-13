
// vim: set filetype=c ts=8 noexpandtab:

#namespace "nav"

#define SOUND_NAV_SET 1057

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
		if (!Params_GetString(cmdtext, idx, buf144)) {
			SendClientMessage playerid, COL_WARN, WARN"Syntax: /adf [beacon] - see /beacons or /nearest"
			#return 1
		}
		new vid = GetPlayerVehicleID(playerid)
		if (vid == 0 || !IsAirVehicle(GetVehicleModel(vid))) {
			SendClientMessage playerid, COL_WARN, WARN"You're not in an ADF capable vehicle"
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

	}
	case 1504545: if (IsCommand(cmdtext, "/ils", idx)) {

	}
}

#printhookguards

