
// vim: set filetype=c ts=8 noexpandtab:

#namespace "veh"

varinit
{
	#define RESPAWN_DELAY 300 // in seconds
}

hook OnGameModeInit()
{
	new Cache:veh = mysql_query(1, !"SELECT veh.i,veh.m,veh.o,veh.x,veh.y,veh.z,veh.r,veh.c,veh.d,usr.n FROM veh LEFT OUTER JOIN usr ON veh.o = usr.i WHERE veh.e=1")
	rowcount = cache_get_row_count()
	Veh_Init rowcount
	while (rowcount--) {
		new id, model, owneruserid, Float:x, Float:y, Float:z, Float:r, col1, col2, ownername[MAX_PLAYER_NAME + 1]
		cache_get_field_int(rowcount, 0, id)
		cache_get_field_int(rowcount, 1, model)
		cache_get_field_int(rowcount, 2, owneruserid)
		cache_get_field_flt(rowcount, 3, x)
		cache_get_field_flt(rowcount, 4, y)
		cache_get_field_flt(rowcount, 5, z)
		cache_get_field_flt(rowcount, 6, r)
		cache_get_field_int(rowcount, 7, col1)
		cache_get_field_int(rowcount, 8, col2)
		cache_get_field_str(rowcount, 9, ownername)
		new dbid, vehicleid;
		dbid = Veh_Add(id, model, owneruserid, x, y, z, r, col1, col2, ownername)
		// only spawn public vehicles statically
		if (owneruserid == 0) {
			vehicleid = AddStaticVehicleEx(model, x, y, z, r, col1, col2, RESPAWN_DELAY)
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
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
	for (new p : players) {
		if (IsPlayerInVehicle(p, vehicleid) && GetPlayerVehicleSeat(p) == 0) {
			goto vehiclehasdriver
		}
	}
	if (Veh_ShouldCreateLabel(vehicleid, forplayerid, buf144)) {
		new PlayerText3D:labelid
		labelid = CreatePlayer3DTextLabel(forplayerid, buf144, 0xFFFF00FF, 0.0, 0.0, 0.0, 100.0, INVALID_PLAYER_ID, vehicleid, .testLOS=1)
		if (_:labelid != INVALID_3DTEXT_ID) {
			Veh_RegisterLabel vehicleid, forplayerid, labelid
		}
	}
vehiclehasdriver:
}

hook OnVehicleStreamOut(vehicleid, forplayerid)
{
	new PlayerText3D:labelid
	if (Veh_GetLabelToDelete(vehicleid, forplayerid, labelid)) {
		DeletePlayer3DTextLabel forplayerid, labelid
	}
}

#printhookguards

