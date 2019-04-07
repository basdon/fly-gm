
// vim: set filetype=c ts=8 noexpandtab:

#namespace "dialog"

#define DIALOG_DUMMY 127
#define DIALOG_REGISTER_FIRSTPASS 520
#define DIALOG_REGISTER_CONFIRMPASS 521
#define DIALOG_LOGIN_LOGIN_OR_NAMECHANGE 522
#define DIALOG_LOGIN_LOADACCOUNTERROR 523
#define DIALOG_LOGIN_NAMECHANGE 524
#define DIALOG_GUESTREGISTER_CHOOSENAME 525
#define DIALOG_GUESTREGISTER_FIRSTPASS 526
#define DIALOG_GUESTREGISTER_CONFIRMPASS 527
#define DIALOG_CHANGEPASS_PREVPASS 529
#define DIALOG_CHANGEPASS_FIRSTPASS 530
#define DIALOG_CHANGEPASS_CONFIRMPASS 531
#define DIALOG_NEAREST 533
#define DIALOG_PREFERENCES 534

#define TRANSACTION_NONE 0
#define TRANSACTION_OVERRIDE 1
#define TRANSACTION_MISSION_OVERVIEW 128
#define TRANSACTION_LOGIN DIALOG_REGISTER_FIRSTPASS
#define TRANSACTION_GUESTREGISTER DIALOG_GUESTREGISTER_CHOOSENAME
#define TRANSACTION_CHANGEPASS DIALOG_CHANGEPASS_PREVPASS

varinit
{
#define ShowPlayerDialog ShowPlayerDialogSafe
	new showndialog[MAX_PLAYERS]
	new dialogtransaction[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	dialogtransaction[playerid] = TRANSACTION_NONE
	ShowPlayerDialog playerid, -1, DIALOG_STYLE_MSGBOX, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY, TRANSACTION_NONE
}

hook OnPlayerDisconnect(playerid)
{
	Dialog_DropQueue playerid
}

hook loop5000()
{
	foreach (new playerid : allplayers) {
		if (!dialogtransaction[playerid] && Dialog_HasInQueue(playerid)) {
			new dialogid, style, transactionid
			Dialog_PopQueue playerid, dialogid, style, buf64, buf4096, buf32, buf32_1, transactionid
			ShowPlayerDialogSafe playerid, dialogid, style, buf64, buf4096, buf32, buf32_1, transactionid
		}
	}
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
//@seealso endDialogTransaction
ensureDialogTransaction(playerid, transactionid)
{
	if (dialogtransaction[playerid] && dialogtransaction[playerid] != transactionid) {
		printf "W-D01: %d, %d", transactionid, dialogtransaction[playerid]
		return
	}
	dialogtransaction[playerid] = transactionid
}

//@summary Ends a dialog transaction for a player
//@param playerid the playerid to end the transaction for
//@param transactionid the transaction to end
//@remarks if {@param transactionid} does not match current player's transaction, nothing will happen
//@remarks Will log a warning (W-D04) if current transaction does not match {@param transactionid}
//@seealso ensureDialogTransaction
endDialogTransaction(playerid, transactionid)
{
	if (dialogtransaction[playerid] != transactionid) {
		printf "W-D04: %d, %d", transactionid, dialogtransaction[playerid]
		return
	}
	dialogtransaction[playerid] = TRANSACTION_NONE
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
			printf "I-D03: %d, %d", dialogid, dialogtransaction[playerid]
			Dialog_Queue playerid, dialogid, style, caption, info, button1, button2, transactionid
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

