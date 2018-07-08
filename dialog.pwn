
// vim: set filetype=c ts=8 noexpandtab:

#namespace "dialog"

varinit
{
#define ShowPlayerDialog ShowPlayerDialogSafe
	new showndialog[MAX_PLAYERS]
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

//@summary Hooks {@link ShowPlayerDialog} to save the shown id to validate in {@link OnDialogResponse}.
//@param playerid see {@link ShowPlayerDialog}
//@param dialogid see {@link ShowPlayerDialog}
//@param style see {@link ShowPlayerDialog}
//@param caption see {@link ShowPlayerDialog}
//@param info see {@link ShowPlayerDialog}
//@param button1 see {@link ShowPlayerDialog}
//@param button2 see {@link ShowPlayerDialog}
//@returns info see {@link ShowPlayerDialog}
//@remarks info see {@link ShowPlayerDialog}
ShowPlayerDialogSafe(playerid, dialogid, style, caption[], info[], button1[], button2[])
{
	showndialog[playerid] = dialogid
#undef ShowPlayerDialog
	ShowPlayerDialog playerid, dialogid, style, caption, info, button1, button2
#define ShowPlayerDialog ShowPlayerDialogSafe
}

#printhookguards

