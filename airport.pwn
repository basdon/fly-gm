
// vim: set filetype=c ts=8 noexpandtab:

#namespace "apt"

hook OnGameModeInit()
{
	new Cache:apc = mysql_query(1, !"SELECT c,e,n,b,x,y,z FROM apt ORDER BY i ASC")
	rowcount = cache_get_row_count()
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
	apc = mysql_query(1, !"SELECT a,s,h,x,y,z,n FROM rnw WHERE type=1")
	rowcount = cache_get_row_count()
	while (rowcount--) {
		new aptindex, specifier[2], Float:heading, Float:x, Float:y, Float:z, nav
		cache_get_field_int(rowcount, 0, aptindex)
		cache_get_field_str(rowcount, 1, specifier)
		cache_get_field_int(rowcount, 2, heading)
		cache_get_field_int(rowcount, 3, x)
		cache_get_field_int(rowcount, 4, y)
		cache_get_field_int(rowcount, 5, z)
		cache_get_field_int(rowcount, 6, nav)
		APT_AddRunway aptindex, specifier[0], heading, x, y, z, nav
	}
	cache_delete apc
}

hook OnGameModeExit()
{
	APT_Destroy
}

hook OnPlayerDisconnect(playerid)
{
	APT_MapIndexFromListDialog playerid // frees memory
}

hook OnDialogResponseCase(playerid, dialogid, response, listitem, inputtext[])
{
	case DIALOG_NEAREST: {
		new aptidx = APT_MapIndexFromListDialog(playerid, listitem)
		// don't move that ^ (frees memory)
		if (!response) {
			#return 1;
		}
		APT_FormatInfo aptidx, buf4096
		APT_FormatCodeAndName aptidx, buf64
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, buf64, buf4096, "Close", ""
		#return 1;
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 2133486927: if (Command_Is(cmdtext, "/nearest", idx)) {
		new Float: x, Float: y, Float:z;
		GetPlayerPos playerid, x, y, z
		APT_FormatNearestList playerid, x, y, buf4096
		ShowPlayerDialog playerid, DIALOG_NEAREST, DIALOG_STYLE_TABLIST, "Nearest airports", buf4096, "Info", "Close"
		#return 1
	}
	case 72939936: if (Command_Is(cmdtext, "/beacons", idx)) {
		APT_FormatBeaconList buf4096
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, "Beacons", buf4096, "Close", ""
		#return 1
	}
}

#printhookguards

