
// vim: set filetype=c ts=8 noexpandtab:

#namespace "prefs"

varinit
{
	new prefs[MAX_PLAYERS]
}

hook OnDialogResponseCase(playerid, dialogid, response, listitem, inputtext[])
{
	case DIALOG_PREFERENCES: {
		if (response && Prefs_DoActionForRow(listitem, prefs[playerid])) {
			prefs_show_dialog playerid
		}
		#return 1
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1569, -533185687: if (Command_Is(cmdtext, "/p", idx) || Command_Is(cmdtext, "/preferences", idx)) {
		prefs_show_dialog playerid
		#return 1
	}
}

hook OnPlayerConnect(playerid)
{
	prefs[playerid] = DEFAULTPREFS
}

//@summary Shows preferences dialog for player
//@param playerid player to show dialog for
prefs_show_dialog(playerid)
{
	Prefs_FormatDialog prefs[playerid], buf4096
	ShowPlayerDialog\
		playerid,
		DIALOG_PREFERENCES,
		DIALOG_STYLE_TABLIST,
		"Preferences",
		buf4096,
		"Change", "Close"
}

#printhookguards

