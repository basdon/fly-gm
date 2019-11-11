
// vim: set filetype=c ts=8 noexpandtab:

#namespace "msp"

#define MISSION_LOAD_UNLOAD_TIME 2200
#define MISSION_CHECKPOINT_SIZE 11.0

hook OnPlayerEnterRaceCP(playerid)
{
	new Float:x, Float:y, Float:z
	new vehicleid = GetPlayerVehicleID(playerid)
	GetVehicleVelocity vehicleid, x, y, z
	new res = Missions_EnterCheckpoint(playerid, vehicleid, vv[vehicleid], x, y, z, buf144)

	if (res != 0 && GetPlayerVehicleSeat(playerid) != 0) {
		WARNMSG("Get in the driver seat and re-enter the checkpoint.")
		#return 1
	}

	if (res == MISSION_ENTERCHECKPOINTRES_LOAD) {
		DisablePlayerRaceCheckpoint playerid
		GameTextForPlayer playerid, "~p~Loading...", 0x800000, 3
		SetTimerEx #PUB_MISSION_LOADTIMER, MISSION_LOAD_UNLOAD_TIME, 0, "ii", playerid, cc[playerid]
		TogglePlayerControllable playerid, 0
		resetMissionNav playerid, vehicleid

		#outline
		//@summary Callback after mission load timer
		//@param playerid player that is loading cargo
		//@param cid cc of playerid (see {@link isValidPlayer})
		export __SHORTNAMED PUB_MISSION_LOADTIMER(playerid, cid)
		{
			if (!isValidPlayer(playerid, cid)) return

			hideGameTextForPlayer(playerid)
			TogglePlayerControllable playerid, 1
			new Float:x, Float:y, Float:z
			if (Missions_PostLoad(playerid, x, y, z, buf144)) {
				SetPlayerRaceCheckpoint playerid, 2, x, y, z, 0.0, 0.0, 0.0, MISSION_CHECKPOINT_SIZE
				mysql_tquery 1, buf144
			}
		}

		#return 1
	} else if (res == MISSION_ENTERCHECKPOINTRES_UNLOAD) {
		new Float:vehiclehp

		DisablePlayerRaceCheckpoint(playerid)
		GameTextForPlayer playerid, "~p~Unloading...", 0x800000, 3
		GetVehicleHealthSafe playerid, vehicleid, vehiclehp
		if (vehiclehp < 251.0) {
			SetVehicleHealth vehicleid, 300.0
		}
		SetTimerEx #PUB_MISSION_UNLOADTIMER, MISSION_LOAD_UNLOAD_TIME, 0, "iif", playerid, cc[playerid], vehiclehp
		TogglePlayerControllable playerid, 0
		resetMissionNav playerid, vehicleid

		#outline
		//@summary Callback after mission unload timer
		//@param playerid player that is unloading cargo
		//@param cid cc of playerid (see {@link isValidPlayer})
		//@param vehiclehp hp of the vehicle at unloading time
		export __SHORTNAMED PUB_MISSION_UNLOADTIMER(playerid, cid, Float:vehiclehp)
		{
			if (!isValidPlayer(playerid, cid)) return

			hideGameTextForPlayer(playerid)
			TogglePlayerControllable playerid, 1
			new pay
			if (Missions_PostUnload(playerid, vehiclehp, pay, buf4096)) {
				money_giveTo playerid, pay
				for (new p : allplayers) {
					if (REMOVEME_getprefs(p) & PREF_SHOW_MISSION_MSGS) {
						SendClientMessage p, COL_MISSION, buf4096
					}
				}
				mysql_tquery 1, buf4096[200]
				if (REMOVEME_getprefs(playerid) & PREF_CONSTANT_WORK) {
					/*TODO startMission playerid*/
				}
				if (buf4096[2000]) {
					Ac_FormatLog playerid, loggedstatus[playerid], buf4096[2000], buf4096
					mysql_tquery 1, buf4096
				}
				if (buf4096[2100]) {
					Ac_FormatLog playerid, loggedstatus[playerid], buf4096[2100], buf4096
					mysql_tquery 1, buf4096
				}
				ShowPlayerDialog\
					playerid,
					DIALOG_DUMMY,
					DIALOG_STYLE_MSGBOX,
					"Flight Overview",
					buf4096[1000],
					"Close", "",
					TRANSACTION_MISSION_OVERVIEW
			}
		}

		#return 1
	} else if (res == MISSION_ENTERCHECKPOINTRES_ERR) {
		SendClientMessage playerid, COL_WARN, buf144
		#return 1
	}
}

//@summary Resets nav for vehicle when player's preferences allow it
//@param playerid playerid that is in a mission
//@param vehicleid vehicle to reset nav for, when needed
resetMissionNav(playerid, vehicleid)
{
	if (REMOVEME_getprefs(playerid) & PREF_WORK_AUTONAV) {
		Nav_Reset vehicleid
	}
}

#printhookguards

