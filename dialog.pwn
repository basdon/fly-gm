
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
#define DIALOG_FAILEDLOGINNOTICE 535

#define TRANSACTION_NONE 0
#define TRANSACTION_OVERRIDE 1
#define TRANSACTION_MISSION_OVERVIEW 128
#define TRANSACTION_LOGIN DIALOG_REGISTER_FIRSTPASS
#define TRANSACTION_GUESTREGISTER DIALOG_GUESTREGISTER_CHOOSENAME
#define TRANSACTION_CHANGEPASS DIALOG_CHANGEPASS_PREVPASS

varinit
{
native Dialog_ShowPlayerDialog(playerid, dialogid, style, caption[], info[], button1[], button2[], transactionid=-1)
native Dialog_EnsureTransaction(playerid, transactionid)
native Dialog_EndTransaction(playerid, transactionid)
#define ShowPlayerDialog Dialog_ShowPlayerDialog
}

//@summary Sets the current dialog transaction for a player to {@param transactionid}
//@param playerid the playerid that needs the dialogtransaction
//@param transactionid the transactionid to set
//@remarks Will log a warning (W-D01) if a previous, different dialog transaction was active
//@seealso endDialogTransaction
ensureDialogTransaction(playerid, transactionid)
{
	Dialog_EnsureTransaction(playerid, transactionid)
}

//@summary Ends a dialog transaction for a player
//@param playerid the playerid to end the transaction for
//@param transactionid the transaction to end
//@remarks if {@param transactionid} does not match current player's transaction, nothing will happen
//@remarks Will log a warning (W-D04) if current transaction does not match {@param transactionid}
//@seealso ensureDialogTransaction
endDialogTransaction(playerid, transactionid)
{
	Dialog_EndTransaction(playerid, transactionid)
}

#printhookguards

