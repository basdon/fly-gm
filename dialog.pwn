
// vim: set filetype=c ts=8 noexpandtab:

#namespace "dialog"

hook varinit()
{
	new showndialog[MAX_PLAYERS]

	ShowPlayerDialogSafe(playerid, dialogid, style, caption[], info[], button1[], button2[])
	{
		showndialog[playerid] = dialogid
		ShowPlayerDialog playerid, dialogid, style, caption, info, button1, button2
	}
	#define ShowPlayerDialog ShowPlayerDialogSafe
}

hook OnPlayerConnect(playerid)
{
	ShowPlayerDialog playerid, -1, DIALOG_STYLE_MSGBOX, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid != showndialog[playerid]) {
		printf "unexpected dialog response from player %d: %d (expected %d)", playerid, dialogid, showndialog[playerid]
		// TODO log
		showndialog[playerid] = -1
		#allowreturn
		return 1
	}
	showndialog[playerid] = -1
}

#printhookguards

