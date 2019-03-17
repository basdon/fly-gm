
// vim: set filetype=c ts=8 noexpandtab:

#namespace "msp"

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
	mysql_query 1, !"UPDATE flg SET state=2 WHERE state=1", .use_cache=false
}

//hook OnGameModeExit()
//{
//	// airport.c frees the msp data
//}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1572: if (Command_Is(cmdtext, "/s", idx)) {
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
}

//@summary attempts to start a mission from closest mission point to a random point
//@param playerid player to start mission for
startMission(playerid)
{
	new Float:x, Float:y, Float:z
	new vehicleid

	if (!(vehicleid = GetPlayerVehicleID(playerid))) {
		WARNMSG("Get in a vehicle before starting work!");
		return
	}

	GetPlayerPos playerid, x, y, z
	if (!Missions_Create(playerid, x, y, z, vehicleid, buf144, buf4096)) {
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
		new Float:x, Float:y, Float:z;
		if (Missions_Start(playerid, cache_insert_id(), x, y, z, buf144)) {
			SetPlayerRaceCheckpoint playerid, 2, x, y, z, 0.0, 0.0, 0.0, 11.0
			SendClientMessage playerid, COL_MISSION, buf144
		}
	}
}

#printhookguards

