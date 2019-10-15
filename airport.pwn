
// vim: set filetype=c ts=8 noexpandtab:

#namespace "apt"

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

