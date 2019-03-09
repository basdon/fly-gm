
// vim: set filetype=c ts=8 noexpandtab:

#namespace "nav"

#define SOUND_NAV_SET 1083
#define SOUND_NAV_DEL 1084

hook OnVehicleSpawn(vehicleid)
{
	Nav_Reset vehicleid
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1496596: if (Command_Is(cmdtext, "/adf", idx)) {
		new vid = GetPlayerVehicleID(playerid)
		if (vid == 0 || !Game_IsAirVehicle(GetVehicleModel(vid))) {
			WARNMSG("You're not in an ADF capable vehicle")
			#return 1
		}
		if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
			WARNMSG("Only the pilot can change navigation settings")
			#return 1
		}
		switch (Nav_EnableADF(vid, cmdtext[idx], buf64)) {
		case RESULT_ADF_OFF: {
			PlayerPlaySound playerid, SOUND_NAV_DEL, 0.0, 0.0, 0.0
			panel_resetNavForPassengers vid
		}
		case RESULT_ADF_ON: {
			PlayerPlaySound playerid, SOUND_NAV_SET, 0.0, 0.0, 0.0
			panel_hideVorBarForPassengers vid
		}
		case RESULT_ADF_ERR: SendClientMessage playerid, COL_WARN, buf64
		}
		#return 1
	}
	case 1517130: if (Command_Is(cmdtext, "/vor", idx)) {
		new vid = GetPlayerVehicleID(playerid)
		if (vid == 0 || !Game_IsPlane(GetVehicleModel(vid))) {
			WARNMSG("You're not in a VOR capable vehicle")
			#return 1
		}
		if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
			WARNMSG("Only the pilot can change navigation settings")
			#return 1
		}
		switch (Nav_EnableVOR(vid, cmdtext[idx], buf64)) {
		case RESULT_VOR_OFF: {
			PlayerPlaySound playerid, SOUND_NAV_DEL, 0.0, 0.0, 0.0
			panel_resetNavForPassengers vid
		}
		case RESULT_VOR_ON: {
			PlayerPlaySound playerid, SOUND_NAV_SET, 0.0, 0.0, 0.0
			panel_showVorBarForPassengers vid
		}
		case RESULT_VOR_ERR: SendClientMessage playerid, COL_WARN, buf64
		}
		#return 1
	}
	case 1504545: if (Command_Is(cmdtext, "/ils", idx)) {
		new vid = GetPlayerVehicleID(playerid)
		if (vid == 0 || !Game_IsPlane(GetVehicleModel(vid))) {
			WARNMSG("You're not in an ILS capable vehicle")
			#return 1
		}
		if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
			WARNMSG("Only the pilot can change navigation settings")
			#return 1
		}
		switch (Nav_ToggleILS(vid)) {
		case RESULT_ILS_ON: PlayerPlaySound playerid, SOUND_NAV_DEL, 0.0, 0.0, 0.0
		case RESULT_ILS_OFF: PlayerPlaySound playerid, SOUND_NAV_SET, 0.0, 0.0, 0.0
		case RESULT_ILS_NOVOR: WARNMSG("ILS can only be activated when VOR is already active")
		case RESULT_ILS_NOILS: WARNMSG("The selected runway does not have ILS capabilities")
		}
		#return 1
	}
}

#printhookguards

