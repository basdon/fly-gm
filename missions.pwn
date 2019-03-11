
// vim: set filetype=c ts=8 noexpandtab:

#namespace "mission"

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

#printhookguards

