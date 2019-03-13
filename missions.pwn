
// vim: set filetype=c ts=8 noexpandtab:

#namespace "msp"

hook OnGameModeInit()
{
	new Cache:msp = mysql_query(1, !"SELECT i,a,x,y,z,t FROM msp")
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
}

//hook OnGameModeExit()
//{
//	// airport.c frees the msp data
//}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1576: if (Command_Is(cmdtext, "/w", idx)) {
		startMission playerid
		#return 1
	}
	case 47060928: if (Command_Is(cmdtext, "/work", idx)) {
		startMission playerid
		#return 1
	}
}

//@summary attempts to start a mission from closest mission point to a random point
//@param playerid player to start mission for
startMission(playerid)
{
	new Float:x, Float:y, Float:z
	new vehicleid, vehiclemodel

	if (!(vehicleid = GetPlayerVehicleID(playerid))) {
		WARNMSG("Get in a vehicle before starting work!");
		return
	}

	vehiclemodel = GetVehicleModel(vehicleid)
	GetPlayerPos playerid, x, y, z
	if (!Missions_Start(x, y, z, vehiclemodel, buf144)) {
		SendClientMessage playerid, COL_WARN, buf144
	} else {
		SendClientMessage playerid, COL_MISSION, buf144
		SetPlayerRaceCheckpoint playerid, 2, x, y, z, 0.0, 0.0, 0.0, 11.0
	}
}

#printhookguards

