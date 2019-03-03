
// vim: set filetype=c ts=8 noexpandtab:

#namespace "veh"

varinit
{
}

hook OnGameModeInit()
{
	new Cache:veh = mysql_query(1, "SELECT veh.i,veh.m,veh.o,veh.x,veh.y,veh.z,veh.r,veh.c,veh.d,usr.n FROM veh JOIN usr ON veh.o = usr.i")
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
		Veh_Add id, model, owneruserid, x, y, z, r, col1, col2, ownername
	}
	cache_delete veh
}

hook OnGameModeExit()
{
	Veh_Destroy
}

#printhookguards

