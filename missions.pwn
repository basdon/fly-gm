
// vim: set filetype=c ts=8 noexpandtab:

#namespace "msp"

#define MISSION_LOAD_UNLOAD_TIME 2200
#define MISSION_CHECKPOINT_SIZE 11.0

varinit
{
	new PlayerText:passenger_satisfaction[MAX_PLAYERS]
}

hook OnGameModeInit()
{
	// msp id (i) should be selected DESC (since added first in linked list in plugin), but since rows are handled reversed here, sort ASC
	new Cache:msp = mysql_query(1, !"SELECT i,a,x,y,z,t FROM msp ORDER BY a ASC,i ASC")
	rowcount = cache_get_row_count()
	while (rowcount--) {
		new aptindex, id, Float:x, Float:y, Float:z, type
		cache_get_field_int(rowcount, 0, id)
		cache_get_field_int(rowcount, 1, aptindex)
		cache_get_field_flt(rowcount, 2, x)
		cache_get_field_flt(rowcount, 3, y)
		cache_get_field_flt(rowcount, 4, z)
		cache_get_field_int(rowcount, 5, type)
		Missions_AddPoint aptindex, id, x, y, z, type
	}
	cache_delete msp
	Missions_FinalizeAddPoints
	// close unfinished dangling flights
	mysql_query 1, !"UPDATE flg SET state=64 WHERE state=1", .use_cache=false
}

//hook OnGameModeExit()
//{
//	// airport.c frees the msp data
//}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1572: if (Command_Is(cmdtext, "/s", idx)) {
		if (Missions_GetState(playerid) == -1) {
			WARNMSG("You're not on an active mission.")
			#return 1
		}
		PlayerTextDrawHide playerid, passenger_satisfaction[playerid]
		DisablePlayerRaceCheckpoint playerid
		if (money_takeFrom(playerid, MISSION_CANCEL_FINE) != MISSION_CANCEL_FINE) {
			WARNMSG("You can't afford this!")
		} else if (Missions_EndUnfinished(playerid, MISSION_STATE_DECLINED, buf4096, buf32)) {
			mysql_tquery 1, buf4096
			// TODO: fix ssocket
			ssocket_send trackerSocket, buf32, 8
		}
		#return 1
	}
	case 1576: if (Command_Is(cmdtext, "/w", idx)) {
		startMission playerid
		#return 1
	}
	case 47060928: if (Command_Is(cmdtext, "/work", idx)) {
		startMission playerid
		#return 1
	}
	case 1438752217: if (Command_Is(cmdtext, "/autow", idx)) {
		if (REMOVEME_getprefs(playerid) & PREF_CONSTANT_WORK) {
			SendClientMessage playerid, COL_SAMP_GREY, "Constant work disabled"
		} else {
			SendClientMessage playerid, COL_SAMP_GREY, "Constant work enabled"
		}
		REMOVEME_setprefs(playerid, REMOVEME_getprefs(playerid)^PREF_CONSTANT_WORK)
		#return 1
	}
}

hook OnPlayerConnect(playerid)
{
	new PlayerText:msptmp = passenger_satisfaction[playerid] = CreatePlayerTextDraw(playerid, 88.0, 425.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, msptmp, 2);
	PlayerTextDrawBackgroundColor(playerid, msptmp, 255);
	PlayerTextDrawFont(playerid, msptmp, 1);
	PlayerTextDrawLetterSize(playerid, msptmp, 0.3, 1.0);
	PlayerTextDrawColor(playerid, msptmp, -1);
	PlayerTextDrawSetOutline(playerid, msptmp, 1);
	PlayerTextDrawSetProportional(playerid, msptmp, 1);
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	if (Missions_GetState(playerid) != -1) {
		DisablePlayerRaceCheckpoint playerid
		new vid, Float:f, missionstopreason = MISSION_STATE_DIED
		if ((vid = GetPlayerVehicleID(playerid))) {
			GetVehicleHealthSafe(playerid, vid, f)
			if (f <= 200.0) {
				missionstopreason = MISSION_STATE_CRASHED
			}
		}
		if (Missions_EndUnfinished(playerid, missionstopreason, buf4096, buf32)) {
			PlayerTextDrawHide playerid, passenger_satisfaction[playerid]
			mysql_tquery 1, buf4096
			// TODO: fix ssocket
			ssocket_send trackerSocket, buf32, 8
		}
	}
}

hook OnPlayerDisconnect(playerid, reason)
{
	if (Missions_EndUnfinished(playerid, MISSION_STATE_ABANDONED, buf4096, buf32)) {
		mysql_tquery 1, buf4096
		// TODO: fix ssocket
		ssocket_send trackerSocket, buf32, 8
	}
}

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
				if (Missions_ShouldShowSatisfaction(playerid)) {
					PlayerTextDrawSetString playerid, passenger_satisfaction[playerid], "Passenger~n~Satisfaction: 100%"
					PlayerTextDrawShow playerid, passenger_satisfaction[playerid]
				}
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
		PlayerTextDrawHide playerid, passenger_satisfaction[playerid]

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
				// TODO: fix ssocket
				ssocket_send trackerSocket, buf4096[2201], buf4096[2200]
				money_giveTo playerid, pay
				for (new p : allplayers) {
					if (REMOVEME_getprefs(p) & PREF_SHOW_MISSION_MSGS) {
						SendClientMessage p, COL_MISSION, buf4096
					}
				}
				ShowPlayerDialog\
					playerid,
					DIALOG_DUMMY,
					DIALOG_STYLE_MSGBOX,
					"Flight Overview",
					buf4096[1000],
					"Close", "",
					TRANSACTION_MISSION_OVERVIEW
				mysql_tquery 1, buf4096[200]
				if (REMOVEME_getprefs(playerid) & PREF_CONSTANT_WORK) {
					startMission playerid
				}
				if (buf4096[2000]) {
					Ac_FormatLog playerid, loggedstatus[playerid], buf4096[2000], buf4096
					mysql_tquery 1, buf4096
				}
				if (buf4096[2100]) {
					Ac_FormatLog playerid, loggedstatus[playerid], buf4096[2100], buf4096
					mysql_tquery 1, buf4096
				}
			}
		}

		#return 1
	} else if (res == MISSION_ENTERCHECKPOINTRES_ERR) {
		SendClientMessage playerid, COL_WARN, buf144
		#return 1
	}
}

//@summary attempts to start a mission from closest mission point to a random point
//@param playerid player to start mission for
startMission(playerid)
{
	new Float:x, Float:y, Float:z, Float:vehiclehp
	new vehicleid

	if (GetPlayerVehicleSeat(playerid) != 0) {
		WARNMSG("You must be the driver of a vehicle before starting work!")
		return
	}
	vehicleid = GetPlayerVehicleID(playerid)

	if (GetVehicleHealthSafe(playerid, vehicleid, vehiclehp)) return
	GetPlayerPos playerid, x, y, z
	if (!Missions_Create(playerid, x, y, z, vehicleid, vv[vehicleid], vehiclehp, buf144, buf4096)) {
		SendClientMessage playerid, COL_WARN, buf144
		return
	}

	GameTextForPlayer playerid, "~b~Retrieving flight data...", 0x800000, 3
	mysql_tquery 1, buf4096 // start msp outbound flights
	mysql_tquery 1, buf4096[200] // end msp inbound flights
	mysql_tquery 1, buf4096[400], #PUB_MISSION_CREATE, "ii", playerid, cc[playerid]

	#outline
	//@summary Callback from query that inserts a new mission into the flg table
	//@param playerid player that created the mission
	//@param cid cc of playerid (see {@link isValidPlayer})
	export __SHORTNAMED PUB_MISSION_CREATE(playerid, cid)
	{
		if (!isValidPlayer(playerid, cid)) return
		hideGameTextForPlayer(playerid)
		new Float:x, Float:y, Float:z
		if (Missions_Start(playerid, cache_insert_id(), x, y, z, buf4096, buf32)) {
			// TODO: fix ssocket
			ssocket_send trackerSocket, buf32, 40
			SetPlayerRaceCheckpoint playerid, 2, x, y, z, 0.0, 0.0, 0.0, MISSION_CHECKPOINT_SIZE
			SendClientMessage playerid, COL_MISSION, buf4096
			Missions_OnWeatherChanged lockedweather
			if (REMOVEME_getprefs(playerid) & PREF_CONSTANT_WORK) {
				SendClientMessage playerid, COL_SAMP_GREY, "Constant work is ON, a new mission will be started when you complete this one (/autow to disable)."
			}
		}
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

