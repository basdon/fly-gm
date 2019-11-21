
// vim: set filetype=c ts=8 noexpandtab:

#namespace "veh"

varinit
{

	#define __DestroyVehicle USE_DestroyVehicleSafe_INSTEAD
	#define DestroyVehicle __DestroyVehicle

	new lastvehicle[MAX_PLAYERS]
	new vv[MAX_VEHICLES] // vehicle reincarnation value

	// for odo and stuff
	new Float:playerodo[MAX_PLAYERS]
}

hook OnGameModeInit()
{
	new Cache:veh = mysql_query(1, !"SELECT v.i,m,ownerplayer,v.x,v.y,v.z,v.r,v.col1,v.col2,v.odo,u.name FROM veh v LEFT OUTER JOIN usr u ON v.ownerplayer = u.i LEFT OUTER JOIN apt a ON v.ap = a.i WHERE v.e=1 AND (ISNULL(v.ap) OR a.e = 1)")
	rowcount = cache_get_row_count()
	Veh_Init rowcount
	while (rowcount--) {
		new dbid, model, owneruserid, Float:x, Float:y, Float:z, Float:r, col1, col2, odo, ownername[MAX_PLAYER_NAME + 1]
		cache_get_field_int(rowcount, 0, dbid)
		cache_get_field_int(rowcount, 1, model)
		cache_get_field_int_nullable_default0_usebuf32(rowcount, 2, owneruserid)
		cache_get_field_flt(rowcount, 3, x)
		cache_get_field_flt(rowcount, 4, y)
		cache_get_field_flt(rowcount, 5, z)
		cache_get_field_flt(rowcount, 6, r)
		cache_get_field_int(rowcount, 7, col1)
		cache_get_field_int(rowcount, 8, col2)
		cache_get_field_int(rowcount, 9, odo)
		cache_get_field_str(rowcount, 10, ownername)
		Veh_Add(dbid, model, owneruserid, x, y, z, r, col1, col2, odo, ownername)
		// only spawn public vehicles statically
		if (owneruserid == 0) {
			new vehicleid = AddStaticVehicleEx(model, x, y, z, r, col1, col2, VEHICLE_RESPAWN_DELAY)
			if (vehicleid != INVALID_VEHICLE_ID) {
				Veh_UpdateSlot vehicleid, dbid
			}
		}
	}
	cache_delete veh
}

hook OnGameModeExit()
{
	Veh_Destroy
}

hook OnPlayerDisconnect(playerid, reason)
{
	Veh_OnPlayerDisconnect playerid

	new vehamount = Veh_CollectSpawnedVehicles(userid[playerid], buf144)
	new idx = 0
	while (vehamount--) {
		DestroyVehicleSafe buf144[idx]
		idx++
	}

	tmp1 = lastvehicle[playerid]
	if (tmp1 && IsValidVehicle(tmp1)) {
		new p = findPlayerInVehicleSeat(tmp1, .seatid=0)
		if (!p || p == playerid) {
			SetVehicleToRespawn tmp1
		}
	}
	lastvehicle[playerid] = 0
}

hook OnPlayerLogin(playerid)
{
	spawnPlayerVehicles userid[playerid]
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vid
	if (oldstate == PLAYER_STATE_DRIVER &&
		(vid = lastvehicle[playerid]) &&
		findPlayerInVehicleSeat(vid, .seatid=0) == INVALID_PLAYER_ID)
	{
		for (new p : players) {
			if (IsVehicleStreamedIn(vid, p)) {
				createVehicleOwnerLabel vid, p
			}
		}
	}

	if (newstate == PLAYER_STATE_DRIVER && (vid = GetPlayerVehicleID(playerid))) {
		for (new p : players) {
			destroyVehicleOwnerLabel vid, p
		}
	}
}

hook OnPlayerUpdate(playerid)
{
	new vid = GetPlayerVehicleID(playerid)
	if (vid && lastvehicle[playerid] != vid) {
		lastvehicle[playerid] = vid
	}
}

hook OnVehicleSpawn(vehicleid)
{
	vv[vehicleid]++
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
	if (findPlayerInVehicleSeat(vehicleid, .seatid=0) == INVALID_PLAYER_ID) {
		createVehicleOwnerLabel vehicleid, forplayerid
	}
}

hook OnVehicleStreamOut(vehicleid, forplayerid)
{
	destroyVehicleOwnerLabel vehicleid, forplayerid
}

DestroyVehicleSafe(vehicleid)
{
	#undef DestroyVehicle
	DestroyVehicle vehicleid
	Veh_UpdateSlot vehicleid, -1
	#define DestroyVehicle __DestroyVehicle
	// DestroyVehicle will also trigger OnVehicleStreamOut, so no need to destroy owner labels here
}

//@summary Created an owner label on a vehicle for a player if needed
//@param vehicleid vehicle of whom to create the owner label for
//@param playerid player for who to create the owner label for
createVehicleOwnerLabel(vehicleid, playerid)
{
	if (Veh_ShouldCreateLabel(vehicleid, playerid, buf144)) {
		new PlayerText3D:labelid
		labelid = CreatePlayer3DTextLabel(playerid, buf144, 0xFFFF00FF, 0.0, 0.0, 0.0, 75.0, INVALID_PLAYER_ID, vehicleid, .testLOS=1)
		if (_:labelid != INVALID_3DTEXT_ID) {
			Veh_RegisterLabel vehicleid, playerid, labelid
		}
	}
}

//@summary Destroys an owner label on a vehicle for a player if needed
//@param vehicleid vehicle of whom to destroy the owner label for
//@param playerid player for who to destroy the owner label for
destroyVehicleOwnerLabel(vehicleid, playerid)
{
	new PlayerText3D:labelid
	if (Veh_GetLabelToDelete(vehicleid, playerid, labelid)) {
		DeletePlayer3DTextLabel playerid, labelid
	}
}

//@summary Finds the player that is in the given seat in the vehicle
//@param vehicleid vehicle where the player should be
//@param seatid seat where the player should be
//@returns {@code INVALID_PLAYER_ID} if there's no player in that seat, playerid otherwise
findPlayerInVehicleSeat(vehicleid, seatid)
{
	for (new p : players) {
		if (IsPlayerInVehicle(p, vehicleid) && GetPlayerVehicleSeat(p) == seatid) {
			return p;
		}
	}
	return INVALID_PLAYER_ID
}

//@summary Spawns vehicles owned by a player
//@param usrid user id of the player for who their vehicles should be spawned
spawnPlayerVehicles(usrid)
{
	new vehamount = Veh_CollectPlayerVehicles(usrid, buf4096)
	new vid
	#emit CONST.pri buf4096
	#emit STOR.pri tmp1
	while (vehamount--) {
		#emit PUSH.C 0 // addsiren
		#assert VEHICLE_RESPAWN_DELAY == 300
		#emit PUSH.C 300 // respawn delay
		#emit LOAD.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // col2
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // col1
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // r
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // z
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // y
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // x
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // model
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit PUSH.C 36
		#emit SYSREQ.C CreateVehicle
		#emit STACK 40
		#emit STOR.S.pri vid

		if (vid != INVALID_VEHICLE_ID) {
			#emit LREF.alt tmp1
			#emit PUSH.alt
			#emit PUSH.S vid
			#emit PUSH.C 8
			#emit SYSREQ.C Veh_UpdateSlot
			#emit STACK 12
		}

		numargs // NOP, inline asm direcly after conditionals get included in the conditional
		#emit LOAD.pri tmp1
		#emit ADD.C 4
		#emit STOR.pri tmp1
	}

	/*
	new idx = 0
	while (vehamount--) {
		vid = CreateVehicle(\
			buf4096[idx+6],
			Float:buf4096[idx+5],
			Float:buf4096[idx+4],
			Float:buf4096[idx+3],
			Float:buf4096[idx+2],
			buf4096[idx+1],
			buf4096[idx],
			VEHICLE_RESPAWN_DELAY)
		if (vid != INVALID_VEHICLE_ID) {
			Veh_UpdateSlot vid, buf4096[idx+7]
		}
		idx += 8
	}
	*/
}

#printhookguards

