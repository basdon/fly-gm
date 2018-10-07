
// vim: set filetype=c ts=8 noexpandtab:

#namespace "airport"

hook OnGameModeInit()
{
	new Cache:apc = mysql_query(1, "SELECT c,e,n,b,x,y,z FROM apt ORDER BY i ASC")
	new rowcount = cache_get_row_count()
	APT_Init rowcount
	while (rowcount--) {
		new code[4 + 1], enabled, name[MAX_AIRPORT_NAME + 1], beacon[4 + 1], Float:x, Float:y, Float:z
		cache_get_field_str(rowcount, 0, code)
		cache_get_field_int(rowcount, 1, enabled)
		cache_get_field_str(rowcount, 2, name)
		cache_get_field_str(rowcount, 3, beacon)
		cache_get_field_flt(rowcount, 4, x)
		cache_get_field_flt(rowcount, 5, y)
		cache_get_field_flt(rowcount, 6, z)
		APT_Add rowcount, code, enabled, name, beacon, x, y, z
	}
	cache_delete apc
	apc = mysql_query(1, "SELECT a,s,h,x,y,z FROM rnw")
	rowcount = cache_get_row_count()
	while (rowcount--) {
		new aptindex, specifier[2], Float:heading, Float:x, Float:y, Float:z
		cache_get_field_int(rowcount, 0, aptindex)
		cache_get_field_str(rowcount, 1, specifier)
		cache_get_field_int(rowcount, 2, heading)
		cache_get_field_int(rowcount, 3, x)
		cache_get_field_int(rowcount, 4, y)
		cache_get_field_int(rowcount, 5, z)
		APT_AddRunway aptindex, specifier[0], heading, x, y, z
	}
	cache_delete apc
}

hook OnGameModeExit()
{
	APT_Destroy
}

#printhookguards

