
// vim: set filetype=c ts=8 noexpandtab:

#namespace "dialog"

#define DIALOG_DUMMY 127
#define DIALOG_REGISTER1 520
#define DIALOG_REGISTER2 521
#define DIALOG_LOGIN1 522
#define DIALOG_LOGIN_ERROR 523
#define DIALOG_NAMECHANGE 524
#define DIALOG_GUESTREGISTER1 525
#define DIALOG_GUESTREGISTER2 526
#define DIALOG_GUESTREGISTER3 527
#define DIALOG_GUESTREGISTER4 528
#define DIALOG_CHANGEPASS1 529
#define DIALOG_CHANGEPASS2 530
#define DIALOG_CHANGEPASS3 531
#define DIALOG_CHANGEPASS4 532

#define TRANSACTION_NONE 0
#define TRANSACTION_OVERRIDE 1
#define TRANSACTION_LOGIN DIALOG_REGISTER1
#define TRANSACTION_GUESTREGISTER DIALOG_GUESTREGISTER1
#define TRANSACTION_CHANGEPASS DIALOG_CHANGEPASS1

varinit
{
#define ShowPlayerDialog ShowPlayerDialogSafe
	new showndialog[MAX_PLAYERS]
	new dialogtransaction[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	dialogtransaction[playerid] = TRANSACTION_NONE
	ShowPlayerDialog playerid, -1, DIALOG_STYLE_MSGBOX, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	dialogtransaction[playerid] = TRANSACTION_NONE
	if (dialogid != showndialog[playerid]) {
		printf "unexpected dialog response from player %d: %d (expected %d)", playerid, dialogid, showndialog[playerid]
		// TODO log
		showndialog[playerid] = -1
		#allowreturn
		return 1
	}
	showndialog[playerid] = -1
}

//@summary Sets the current dialog transaction for a player to {@param transactionid}
//@param playerid the playerid that needs the dialogtransaction
//@param transactionid the transactionid to set
//@remarks Will log a warning (W-D01) if a previous, different dialog transaction was active
ensureDialogTransaction(playerid, transactionid)
{
	if (dialogtransaction[playerid] && dialogtransaction[playerid] != transactionid) {
		printf "W-D01: %d, %d", transactionid, dialogtransaction[playerid]
		return
	}
	dialogtransaction[playerid] = transactionid
}

//@summary Hooks {@link ShowPlayerDialog} to save the shown id to validate in {@link OnDialogResponse}. Also adds transactions.
//@param playerid see {@link ShowPlayerDialog}
//@param dialogid see {@link ShowPlayerDialog}
//@param style see {@link ShowPlayerDialog}
//@param caption see {@link ShowPlayerDialog}
//@param info see {@link ShowPlayerDialog}
//@param button1 see {@link ShowPlayerDialog}
//@param button2 see {@link ShowPlayerDialog}
//@param transactionid transaction id of this dialog (optional={@param dialogid}) (use {@code TRANSACTION_OVERRIDE} to override any running dialog transaction)
//@returns info see {@link ShowPlayerDialog}
//@remarks info see {@link ShowPlayerDialog}
//@remarks A warning (W-D02) will be logged if {@code TRANSACTION_OVERRIDE} is used and it actually overrides current transaction for player
ShowPlayerDialogSafe(playerid, dialogid, style, caption[], info[], button1[], button2[], transactionid=-1)
{
	if (transactionid == -1) {
		transactionid = dialogid
	}
	if (dialogtransaction[playerid] && dialogtransaction[playerid] != transactionid) {
		if (transactionid != TRANSACTION_OVERRIDE) {
			QueueDialog playerid, dialogid, style, caption, info, button1, button2
			return
		}
		printf "W-D02: %d", dialogtransaction[playerid]
	}
	dialogtransaction[playerid] = transactionid
	showndialog[playerid] = dialogid
#undef ShowPlayerDialog
	ShowPlayerDialog playerid, dialogid, style, caption, info, button1, button2
#define ShowPlayerDialog ShowPlayerDialogSafe
}

#printhookguards

