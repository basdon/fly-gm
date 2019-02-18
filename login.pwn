
// vim: set filetype=c ts=8 noexpandtab:

#namespace "login"

#define LOGGED_NO 0
#define LOGGED_IN 1
#define LOGGED_GUEST 2

#define MAX_LOGIN_ATTEMPTS 4
#define PARSE5BYTENONNULL(%0,%1) ((%0[%1]&0x7F)|((%0[%1+1]&0x7F)<<7)|\
			((%0[%1+2]&0x7F)<<14)|((%0[%1+3]&0x7F)<<21)|((%0[%1+4]&0x0F)<<28))

// on join, [loginusercheck]

// -- [loginusercheck]
//    what: query check usr registered (get id & pw), check if ip should be blocked
//    transaction: TRANSACTION_LOGIN
//    msg: "~b~Contacting login server..."
//    note: done by calling checkUserExist with callback
//    cb: PUB_LOGIN_USERCHECK_CB

// -- [PUB_LOGIN_USERCHECK_CB]
//    what: cb from usr check query
//    transaction: TRANSACTION_LOGIN
//    - fail > spawn as guest
//    - blocked ip > spawn as guest
//    - not registered > [initialregisterbox] TRANSACTION_LOGIN
//    - registered > [loginbox] TRANSACTION_LOGIN

// -- [initialregisterbox]
//    what: dialog that asks for password
//    dialog: DIALOG_REGISTER1
//    transaction: TRANSACTION_LOGIN
//    buttons: "Next", "Play as guest"

// -- [DIALOG_REGISTER1]
//    what: response from dialog that asks for password
//    - cancel > give player guest name and spawn
//    - next > store given password hash, [confirmpwregisterbox]

// -- [confirmpwregisterbox]
//    what: dialog that asks for password confirmation
//    dialog: DIALOG_REGISTER2
//    transaction: TRANSACTION_LOGIN
//    buttons: "Confirm", "Cancel"

// -- [DIALOG_REGISTER2]
//    what: response from dialog that asks for password confirmation
//    - Confirm > match given password hash
//              - match > TODO: [registeraccount] TRANSACTION_LOGIN
//              - nomatch > [initialregisterbox] TRANSACTION_LOGIN
//    - Cancel > [initialregisterbox] TRANSACTION_LOGIN

// on guest session, guest does /register, [guestregister]

// -- [guestregister]
//    what: dialog to change guest name before registering
//    dialog: DIALOG_GUESTREGISTER1

// -- [DIALOG_GUESTREGISTER1]
//    what: dialog to change guest name before registering
//    - rejected name > halt
//    - approved name > [guestregisterusercheck] TRANSACTION_GUESTREGISTER

// -- [guestregisterusercheck]
//    what: query check usr registered (get id & pw), check if ip should be blocked
//    transaction: TRANSACTION_GUESTREGISTER
//    msg: "~b~Contacting login server..."
//    note: done by calling checkUserExist with callback
//    cb: PUB_LOGIN_GUESTREGISTERUSERCHECK_CB

// -- [PUB_LOGIN_GUESTREGISTERUSERCHECK_CB]
//    transaction: TRANSACTION_GUESTREGISTER
//    - fail > give guest name and halt
//    - blocked ip > give guest name and halt
//    - not registered > TODO: [guestregisterbox]
//    - registered > give guest name and halt

// -- [loginbox]

varinit
{
	#define isPlaying(%0) (loggedstatus[%0])
	#define isRegistered(%0) (loggedstatus[%0] == LOGGED_IN)
	#define isGuest(%0) (loggedstatus[%0] == LOGGED_GUEST)

	new loggedstatus[MAX_PLAYERS]
	new failedlogins[MAX_PLAYERS char]
	new userid[MAX_PLAYERS]
	new sessionid[MAX_PLAYERS]

	new REGISTER_CAPTION[] = "Register"
	new REGISTER_TEXT[] =
		""ECOL_WARN"Passwords do not match!\n\n"\
		""ECOL_DIALOG_TEXT"Welcome! Register your account or continue as a guest.\n\n"\
		""ECOL_DIALOG_TEXT"* choose a password <<<<\n"\
		""ECOL_DIALOG_TEXT"* confirm your password <<<<"
	#define REGISTER_TEXT_OFFSET 33
	#define MOD_REGTEXT(%0,%1,%2,%3,%4) memcpy(REGISTER_TEXT,%1,4*%0,4*%4);memcpy(REGISTER_TEXT,%3,4*%2,4*%4)
	#define PREP_REGTEXT1 MOD_REGTEXT(125,fourleft,162,ninespaces,4);MOD_REGTEXT(97,ecol_info,130,ecol_dialog_text,8)
	#define PREP_REGTEXT2 MOD_REGTEXT(162,fourleft,125,ninespaces,4);MOD_REGTEXT(130,ecol_info,97,ecol_dialog_text,8)

	new LOGIN_CAPTION[] = "Login"
	new LOGIN_TEXT[] =
		""ECOL_WARN"Incorrect password!\n\n"ECOL_DIALOG_TEXT""\
		"Welcome! This account is registered.\n"\
		"Please sign in or change your name."
	#define LOGIN_TEXT_OFFSET 37

	new NAMECHANGE_CAPTION[] = "Change name"
	new NAMECHANGE_TEXT[] =
		""ECOL_WARN"Invalid name or name is taken (press tab).\n\n"ECOL_DIALOG_TEXT""\
		"Enter your new name (3-20 length, 0-9a-zA-Z=()[]$@._).\n"\
		"Names starting with @ are reserved for guests."
	#define NAMECHANGE_TEXT_OFFSET 60

	new GUESTREGISTER_TEXT[] =
		""ECOL_DIALOG_TEXT"* choose a name (3-20 length, 0-9a-zA-Z=()[]$@._). <<<<\n"\
		""ECOL_DIALOG_TEXT"* choose a password <<<<\n"\
		""ECOL_DIALOG_TEXT"* confirm your password <<<<"
	#define PREP_GUESTREGTEXT(%0,%1,%2,%3,%4,%5) \
		memcpy(GUESTREGISTER_TEXT,fourleft,4*%0,16);\
		memcpy(GUESTREGISTER_TEXT,ninespaces,4*%1,16);\
		memcpy(GUESTREGISTER_TEXT,ninespaces,4*%2,16);\
		memcpy(GUESTREGISTER_TEXT,ecol_info,4*%3,32);\
		memcpy(GUESTREGISTER_TEXT,ecol_dialog_text,4*%4,32);\
		memcpy(GUESTREGISTER_TEXT,ecol_dialog_text,4*%5,32)
	#define PREP_GUESTREGTEXT1 PREP_GUESTREGTEXT(59,92,129,0,64,97)
	#define PREP_GUESTREGTEXT2 PREP_GUESTREGTEXT(92,59,129,64,0,97)
	#define PREP_GUESTREGTEXT3 PREP_GUESTREGTEXT(129,92,59,97,64,0)

	new CHANGEPASS_CAPTION[] = "Change password"
	new CHANGEPASS_TEXT[] =
		""ECOL_DIALOG_TEXT"* enter your current password <<<<\n"\
		""ECOL_DIALOG_TEXT"* choose a new password <<<<\n"\
		""ECOL_DIALOG_TEXT"* confirm your password <<<<"
	#define PREP_CPTEXT(%0,%1,%2,%3,%4,%5) \
		memcpy(CHANGEPASS_TEXT,fourleft,4*%0,16);\
		memcpy(CHANGEPASS_TEXT,ninespaces,4*%1,16);\
		memcpy(CHANGEPASS_TEXT,ninespaces,4*%2,16);\
		memcpy(CHANGEPASS_TEXT,ecol_info,4*%3,32);\
		memcpy(CHANGEPASS_TEXT,ecol_dialog_text,4*%4,32);\
		memcpy(CHANGEPASS_TEXT,ecol_dialog_text,4*%5,32)
	#define PREP_CHANGEPASSTEXT1 PREP_CPTEXT(38,75,112,0,43,80)
	#define PREP_CHANGEPASSTEXT2 PREP_CPTEXT(75,38,112,43,0,80)
	#define PREP_CHANGEPASSTEXT3 PREP_CPTEXT(112,75,38,80,43,0)

	new ninespaces[] = "         "
	new fourleft[] = "<<<<"
}

hook loop30s()
{
	foreach (new playerid : players) {
		updatePlayerLastseen playerid, .isdisconnect=0
	}
}

hook OnPlayerDisconnect(playerid, reason)
{
	if (isPlaying(playerid)) {
		new reasons[] = "\3\11\16timeout\0quit\0kicked"
		new str[MAX_PLAYER_NAME + 6 + 21 + 8 + 1]
		format str, sizeof(str), "%s[%d] left the server (%s)", NAMEOF(playerid), playerid, reasons[reasons[reason]]
		SendClientMessageToAll COL_QUIT, str
	}
	updatePlayerLastseen playerid, .isdisconnect=1
	loggedstatus[playerid] = LOGGED_NO
	ResetPasswordConfirmData playerid
}

hook OnPlayerConnect(playerid)
{
	userid[playerid] = -1
	sessionid[playerid] = -1
	failedlogins{playerid} = 0

	// check name validity (even though server might do this already)
	#assert PLAYERNAMEVER == 1
	{
		for (new i = playernames[playerid][0]; i > 0; i--) {
			new _c = playernames[playerid][i]
			if (35 < _c && _c < 68 && (0xF23FF431 >>> (_c - 36)) & 1) {
				continue
			}
			if (66 < _c && _c < 99 && (0xD5FFFFFF >>> (_c - 67)) & 1) {
				continue
			}
			if (98 < _c && _c < 123) {
				continue
			}
			goto invalidname
		}
	}

	#assert PLAYERNAMEVER == 1
	while (playernames[playerid][1] == '@') {
		SendClientMessage playerid, COL_SAMP_GREEN, "Names starting with '@' are reserved for guest players."
invalidname:
		// wiki states that SetPlayerName does not propagate for the user
		// if used in OnPlayerConnect, but tests have proven otherwise.
		if (NAMELEN(playerid) <= 3 || SetPlayerName(playerid, playernames[playerid][2]) != 1) {
			SendClientMessage playerid, COL_WARN,
				WARN"Failed to change your nickname. Please come back with a different name."
			KickDelayed playerid
			#allowreturn
			return 0
		}
	}

	ensureDialogTransaction playerid, TRANSACTION_LOGIN
	checkUserExist playerid, ""#PUB_LOGIN_USERCHECK_CB""
}

hook OnPlayerRequestSpawn(playerid)
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#return 0
	}
}

hook OnPlayerCommandText(playerid, cmdtext[])
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#return 1
	}
}

hook OnPlayerText(playerid, text[])
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#return 0
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 258772946: if (IsCommand(cmdtext, "/register", idx)) if (isGuest(playerid)) {
		if (sessionid[playerid] == -1 || userid[playerid] == -1) {
			ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, REGISTER_CAPTION,
				""#ECOL_WARN"You are not on an active guest session. Please reconnect if you want to register.", "Ok", ""
			#return 1
		}
		PREP_GUESTREGTEXT1
		ShowPlayerDialog playerid, DIALOG_GUESTREGISTER1, DIALOG_STYLE_INPUT, REGISTER_CAPTION, GUESTREGISTER_TEXT, "Next", "Cancel", TRANSACTION_GUESTREGISTER
		#return 1
	} else {
		SendClientMessage playerid, COL_WARN, #WARN"You're already registered!"
		#return 1
	}
	case -1292722118: if (!isGuest(playerid) && IsCommand(cmdtext, "/changepassword", idx)) {
		PREP_CHANGEPASSTEXT1
		ShowPlayerDialog playerid, DIALOG_CHANGEPASS1, DIALOG_STYLE_PASSWORD, CHANGEPASS_CAPTION, CHANGEPASS_TEXT, "Next", "Cancel", TRANSACTION_CHANGEPASS
		#return 1
	}
}

hook OnDialogResponseCase(playerid, dialogid, response, listitem, inputtext[])
{
	case DIALOG_REGISTER1: {
		if (!response) {
			ResetPasswordConfirmData playerid
			if (giveGuestName(playerid)) {
				spawnAsGuest playerid
			}
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		SetPasswordConfirmData playerid, pwhash
		PREP_REGTEXT2
		ShowPlayerDialog playerid,
			DIALOG_REGISTER2,
			DIALOG_STYLE_PASSWORD,
			REGISTER_CAPTION,
			REGISTER_TEXT[REGISTER_TEXT_OFFSET],
			"Confirm",
			"Cancel",
			TRANSACTION_LOGIN
		#return 1
	}
	case DIALOG_REGISTER2: {
		if (!response) {
			ResetPasswordConfirmData playerid
			showRegisterDialog playerid, .textoffset=REGISTER_TEXT_OFFSET
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		if (!ValidatePasswordConfirmData(playerid, pwhash)) {
			showRegisterDialog playerid
			#return 1
		}
		GameTextForPlayer playerid, "~b~Making your account...", 0x800000, 3
		FormatLoginApiRegister playerid, inputtext, buf4096
		HTTP(playerid, HTTP_POST, #API_URL"/api-register.php", buf4096, #PUB_LOGIN_REGISTER_CB)
		ensureDialogTransaction playerid, TRANSACTION_LOGIN
		#return 1
	}
	case DIALOG_LOGIN_LOGIN_OR_GUEST: {
		if (!response) {
			showNamechangeDialog playerid, .textoffset=NAMECHANGE_TEXT_OFFSET
			#return 1
		}
		GameTextForPlayer playerid, "~b~Logging in...", 0x800000, 3
		new pw[65]
		Login_GetPassword playerid, pw
		bcrypt_check inputtext, pw, #PUB_LOGIN_LOGIN_CB, "i", playerid
		ensureDialogTransaction playerid, TRANSACTION_LOGIN
		#return 1
	}
	case DIALOG_LOGIN_ERROR: {
		showLoginDialog playerid, .textoffset=LOGIN_TEXT_OFFSET
		#return 1
	}
	case DIALOG_NAMECHANGE: {
		if (!response) {
			showLoginDialog playerid, .textoffset=LOGIN_TEXT_OFFSET
			#return 1
		}
		if (!changePlayerNameFromInput(playerid, inputtext)) {
			showNamechangeDialog playerid, .textoffset=0
			#return 1
		}
		userid[playerid] = -1
		checkUserExist playerid, ""#PUB_LOGIN_USERCHECK_CB""
		ensureDialogTransaction playerid, TRANSACTION_LOGIN
		#return 1
	}
	case DIALOG_GUESTREGISTER1: {
		if (!response) {
			#return 1
		}
		if (!changePlayerNameFromInput(playerid, inputtext)) {
			ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, REGISTER_CAPTION,
				""#ECOL_WARN"Name rejected, it is either not valid or already taken (press tab). Try again.", "Ok", "", TRANSACTION_GUESTREGISTER
			#return 1
		}
		checkUserExist playerid, ""#PUB_LOGIN_GUESTREGISTERUSERCHECK_CB""
		ensureDialogTransaction playerid, TRANSACTION_GUESTREGISTER
		#return 1
	}
	case DIALOG_GUESTREGISTER2: {
		if (!response) {
			ResetPasswordConfirmData playerid
			if (giveGuestName(playerid)) {
				savePlayerName playerid
			}
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		SetPasswordConfirmData playerid, pwhash
		PREP_GUESTREGTEXT3
		ShowPlayerDialog playerid, DIALOG_GUESTREGISTER3, DIALOG_STYLE_PASSWORD, REGISTER_CAPTION, GUESTREGISTER_TEXT, "Next", "Cancel", TRANSACTION_GUESTREGISTER
		#return 1
	}
	case DIALOG_GUESTREGISTER3: {
		if (!response) {
			ResetPasswordConfirmData playerid
			if (giveGuestName(playerid)) {
				savePlayerName playerid
			}
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		if (!ValidatePasswordConfirmData(playerid, pwhash)) {
			ShowPlayerDialog playerid, DIALOG_GUESTREGISTER4, DIALOG_STYLE_MSGBOX, REGISTER_CAPTION,
				""#ECOL_WARN"Passwords do not match, please try again", "Ok", "", TRANSACTION_GUESTREGISTER
			#return 1
		}
		GameTextForPlayer playerid, "~b~Making your account...", 0x800000, 3
		FormatLoginApiGuestRegister playerid, userid[playerid], inputtext, buf4096
		HTTP(playerid, HTTP_POST, #API_URL"/api-change.php", buf4096, #PUB_LOGIN_GUESTREGISTER_CB)
		ensureDialogTransaction playerid, TRANSACTION_GUESTREGISTER
		#return 1
	}
	case DIALOG_GUESTREGISTER4: {
		PREP_GUESTREGTEXT2
		ShowPlayerDialog playerid, DIALOG_GUESTREGISTER2, DIALOG_STYLE_PASSWORD, REGISTER_CAPTION, GUESTREGISTER_TEXT, "Next", "Cancel", TRANSACTION_GUESTREGISTER
		#return 1
	}
	case DIALOG_CHANGEPASS1: {
		if (!response) {
			#return 1
		}
		GameTextForPlayer playerid, "~b~Verifying...", 0x800000, 3
		FormatLoginApiCheckChangePass userid[playerid], inputtext, buf4096
		HTTP(playerid, HTTP_POST, #API_URL"/api-checkpass.php", buf4096, #PUB_LOGIN_CHANGEPASS_CHECK_CB)
		ensureDialogTransaction playerid, TRANSACTION_CHANGEPASS
		#return 1
	}
	case DIALOG_CHANGEPASS2: {
		if (!response) {
			ResetPasswordConfirmData playerid
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		SetPasswordConfirmData playerid, pwhash
		PREP_CHANGEPASSTEXT3
		ShowPlayerDialog playerid, DIALOG_CHANGEPASS3, DIALOG_STYLE_PASSWORD, CHANGEPASS_CAPTION, CHANGEPASS_TEXT, "Next", "Cancel", TRANSACTION_CHANGEPASS
		#return 1
	}
	case DIALOG_CHANGEPASS3: {
		if (!response) {
			ResetPasswordConfirmData playerid
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		if (!ValidatePasswordConfirmData(playerid, pwhash)) {
			ShowPlayerDialog playerid, DIALOG_CHANGEPASS4, DIALOG_STYLE_MSGBOX, REGISTER_CAPTION,
				""#ECOL_WARN"Passwords do not match, please try again", "Ok", "", TRANSACTION_CHANGEPASS
			#return 1
		}
		GameTextForPlayer playerid, "~b~Updating...", 0x800000, 3
		FormatLoginApiCheckChangePass userid[playerid], inputtext, buf4096
		HTTP(playerid, HTTP_POST, #API_URL"/api-change.php", buf4096, #PUB_LOGIN_CHANGEPASS_CHANGE_CB)
		ensureDialogTransaction playerid, TRANSACTION_CHANGEPASS
		#return 1
	}
	case DIALOG_CHANGEPASS4: {
		PREP_CHANGEPASSTEXT2
		ShowPlayerDialog playerid, DIALOG_CHANGEPASS2, DIALOG_STYLE_PASSWORD, CHANGEPASS_CAPTION, CHANGEPASS_TEXT, "Next", "Cancel", TRANSACTION_CHANGEPASS
		#return 1
	}
}

//@summary Changes a player's name to the specified string, checking for validity (length, guest symbol) first
//@param playerid the playerid that needs the new name
//@param inputtext the name to change to
//@returns {@code 0} if the input was not valid or name is already taken by a player
changePlayerNameFromInput(playerid, inputtext[])
{
	new len = strlen(inputtext)
	return 2 < len && len < 21 && inputtext[0] != '@' && SetPlayerName(playerid, inputtext);
}

//@summary Check if a user with username of {@param playerid} exists
//@param playerid the player to check if their username is registered
//@param callback the callback that will be notified when api call reponds
checkUserExist(playerid, callback[])
{
	GameTextForPlayer playerid, "~b~Contacting login server...", 0x800000, 3
	Login_FormatCheckUserExist playerid, buf4096
	mysql_tquery 1, buf4096, callback, "i", playerid
}

//@summary Shows register dialog for player
//@param playerid player to show register dialog for
//@param textoffset textoffset in register string, should be {@code REGISTER_TEXT_OFFSET} or {@code 0}
showRegisterDialog(playerid, textoffset=0)
{
	PREP_REGTEXT1
	ShowPlayerDialog playerid,
		DIALOG_REGISTER1,
		DIALOG_STYLE_PASSWORD,
		REGISTER_CAPTION,
		REGISTER_TEXT[textoffset],
		"Next",
		"Play as guest",
		TRANSACTION_LOGIN
}

//@summary Shows login dialog for player
//@param playerid player to show login dialog for
//@param textoffset textoffset in login string, should be {@code LOGIN_TEXT_OFFSET} or {@code 0}
showLoginDialog(playerid, textoffset=0)
{
	ShowPlayerDialog playerid,
		DIALOG_LOGIN_LOGIN_OR_GUEST,
		DIALOG_STYLE_PASSWORD,
		LOGIN_CAPTION,
		LOGIN_TEXT[textoffset],
		"Login",
		"Change name",
		TRANSACTION_LOGIN
}

//@summary Shows namechange dialog for player (during login phase)
//@param playerid player to show namechange dialog for
//@param textoffset textoffset in login string, should be {@code NAMECHANGE_TEXT_OFFSET} or {@code 0}
showNamechangeDialog(playerid, textoffset=0)
{
	ShowPlayerDialog playerid,
		DIALOG_NAMECHANGE,
		DIALOG_STYLE_INPUT,
		NAMECHANGE_CAPTION,
		NAMECHANGE_TEXT[textoffset],
		"Change",
		"Cancel",
		TRANSACTION_LOGIN
}

//@summary Report api err response to console
//@param response_code response code from HTTP callback
//@param data data from HTTP callback
//@param errcode the errorcode associated with this error
report_api_err(response_code, data[], errcode[])
{
	LIMITSTRLEN(data, 500)
	printf "%s: %d, %s", errcode, response_code, data
}

//@summary Report api unknown response to console
//@param data data from HTTP callback
//@param errcode the errorcode associated with this error
report_api_unknown_response(data[], errcode[])
{
	LIMITSTRLEN(data, 500)
	printf "%s: %s", errcode, data
}

#define COMMON_CHECKRESPONSECODE_NOHIDETEXT(%0) if(response_code!=200){report_api_err(response_code,data,%0);goto err;}
#define COMMON_CHECKRESPONSECODE(%0) hideGameTextForPlayer(playerid);COMMON_CHECKRESPONSECODE_NOHIDETEXT(%0)
#define COMMON_UNKNOWNRESPONSE(%0) report_api_unknown_response(data,%0)

//@summary Callback for usercheck done in {@link OnPlayerConnect} and after changing name during login.
//@param playerid player that has been checked
//@remarks PUB_LOGIN_USERCHECK_CB
export PUB_LOGIN_USERCHECK_CB(playerid)
{
	endDialogTransaction playerid, TRANSACTION_LOGIN
	hideGameTextForPlayer(playerid)

	if (!cache_get_row_count()) {
		printf "E-U02"
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"An error occurred, you will be spawned as a guest", "Ok", ""
		SendClientMessage playerid, COL_WARN, WARN"An error occured while contacting the login server."
		goto asguest
	}

	new failedattempts, id, pw[65]

	cache_get_field_int(0, 0, failedattempts)
	if (failedattempts > 10) {
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"You will be spawned as guest due to too many failed logins from your location", "Ok", ""
asguest:
		SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
		if (giveGuestName(playerid)) {
			spawnAsGuest playerid
		}
		return
	}

	cache_get_field_str(0, 1, pw)
	if (ismysqlnull(pw)) {
		// user doesn't exist
		showRegisterDialog playerid, .textoffset=REGISTER_TEXT_OFFSET
		return
	}

	// user does exist
	Login_UsePassword playerid, pw
	cache_get_field_int(0, 2, id)
	userid[playerid] = id
	showLoginDialog playerid, .textoffset=LOGIN_TEXT_OFFSET
}

//@summary Callback for register call
//@param playerid player that wanted to register
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_REGISTER_CB
export PUB_LOGIN_REGISTER_CB(playerid, response_code, data[])
{
	endDialogTransaction playerid, TRANSACTION_LOGIN
	COMMON_CHECKRESPONSECODE("E-U04")
	if (data[0] == 's') {
		if (strlen(data) < 11) {
			printf "E-U05: %d", strlen(data)
			goto err
		}
		userid[playerid] = PARSE5BYTENONNULL(data, 1)
		sessionid[playerid] = PARSE5BYTENONNULL(data, 6)
		loginPlayer playerid, LOGGED_IN
		new str[MAX_PLAYER_NAME + 6 + 37 + 1]
		format str, sizeof(str), "%s[%d] just registered an account, welcome!", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_JOIN, str
		return
	}
	if (data[0] == 'e') {
		LIMITSTRLEN(data, 500)
		printf "E-U06: %s", data[1]
		goto err
	}
	COMMON_UNKNOWNRESPONSE("E-U07")
err:
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An error occurred, you will be spawned as a guest", "Ok", ""
	SendClientMessage playerid, COL_WARN, WARN"An error occured while registering."
	SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
	if (giveGuestName(playerid)) {
		spawnAsGuest playerid
	}
}

//@summary Callback for login call
//@param playerid player that wanted to login
//@remarks PUB_LOGIN_LOGIN_CB
export PUB_LOGIN_LOGIN_CB(playerid)
{
	endDialogTransaction playerid, TRANSACTION_LOGIN
	hideGameTextForPlayer(playerid)

	if (bcrypt_is_equal()) {
		// great, correct password, do stuff
		GameTextForPlayer playerid, "~b~Loading account...", 0x800000, 3
		PlayerData_SetUserId playerid, userid[playerid]
		Login_FormatLoadAccountData userid[playerid], buf4096
		mysql_tquery 1, buf4096, #PUB_LOGIN_LOADACCOUNT_CB, "i", playerid
	} else {
		// failed login
		if ((failedlogins{playerid} += 2) > (MAX_LOGIN_ATTEMPTS - 1) * 2) {
			SendClientMessage playerid, COL_WARN, #WARN"Too many failed login attempts!"
			KickDelayed playerid
			return
		}
		showLoginDialog playerid, .textoffset=0
	}
}

//@summary Callback for loading account data
//@param playerid player
//@remarks PUB_LOGIN_LOADACCOUNT_CB
export PUB_LOGIN_LOADACCOUNT_CB(playerid)
{
	hideGameTextForPlayer(playerid)

	if (!cache_get_row_count()) {
		printf "E-U1A"
err:
		SendClientMessage playerid, COL_WARN, #WARN"Something went wrong, please reconnect"
		return
	}

	GameTextForPlayer playerid, "~b~Creating game session...", 0x800000, 3
	new score
	cache_get_field_int(0, 0, score)
	SetPlayerScore playerid, score

	if (!Login_FormatCreateUserSession(playerid, buf4096)) {
		printf "E-U1B"
		goto err
	}
	mysql_tquery 1, buf4096[1]
	mysql_tquery 1, buf4096[buf4096[0]], #PUB_LOGIN_CREATEGAMESESSION_CB, "i", playerid
}

//@summary Callback when creating game session
//@param playerid player
//@remarks spawns the player at the end
//@remarks PUB_LOGIN_CREATEGAMESESSION_CB
export PUB_LOGIN_CREATEGAMESESSION_CB(playerid)
{
	sessionid[playerid] = cache_insert_id()
	loginPlayer playerid, LOGGED_IN
	new str[MAX_PLAYER_NAME + 6 + 30 + 1]
	format str, sizeof(str), "%s[%d] just logged in, welcome back!", NAMEOF(playerid), playerid
	SendClientMessageToAll COL_JOIN, str
}

//@summary Callback for guest call
//@param playerid player that needed a guest account
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_GUEST_CB
export PUB_LOGIN_GUEST_CB(playerid, response_code, data[])
{
	hideGameTextForPlayer(playerid)
	loginPlayer playerid, LOGGED_GUEST
	COMMON_CHECKRESPONSECODE_NOHIDETEXT("E-U0E")
	if (data[0] == 's') {
		if (strlen(data) < 11) {
			printf "E-U0F: %d", strlen(data)
			goto err
		}
		userid[playerid] = PARSE5BYTENONNULL(data, 1)
		sessionid[playerid] = PARSE5BYTENONNULL(data, 6)
		new str[MAX_PLAYER_NAME + 6 + 28 + 1]
		format str, sizeof(str), "%s[%d] joined as a guest, welcome!", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_JOIN, str
		SendClientMessage playerid, COL_INFO,
			""#INFO"You are now playing as a guest. You can use /register at any time to save your stats."
		return
	}
	LIMITSTRLEN(data, 500)
	if (data[0] == 'e') {
		printf "E-U10: %s", data[1]
	} else {
		printf "E-U11: %s", data
	}
err:
	SendClientMessage playerid, COL_WARN, #WARN"An error occurred while creating a guest session."
	SendClientMessage playerid, COL_WARN, #WARN"You can play, but you won't be able to save your stats later."
}

//@summary Callback for usercheck done after renaming while guest is registering from existing guest session.
//@param playerid player that has been checked
//@remarks PUB_LOGIN_GUESTREGISTERUSERCHECK_CB
export PUB_LOGIN_GUESTREGISTERUSERCHECK_CB(playerid, response_code, data[])
{
	endDialogTransaction playerid, TRANSACTION_GUESTREGISTER
	hideGameTextForPlayer(playerid)

	if (!cache_get_row_count()) {
		printf "E-U12"
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"An error occurred, you will be spawned as a guest", "Ok", ""
		SendClientMessage playerid, COL_WARN, WARN"An error occured while contacting the login server."
		goto giveguestname
	}

	new failedattempts, pw[65]

	cache_get_field_int(0, 0, failedattempts)
	if (failedattempts > 10) {
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"You cannot register right now because there are too many failed logins from your location", "Ok", ""
		goto giveguestname
	}

	cache_get_field_str(0, 1, pw)
	if (ismysqlnull(pw)) {
		// user doesn't exist
		PREP_GUESTREGTEXT2
		ShowPlayerDialog playerid, DIALOG_GUESTREGISTER2, DIALOG_STYLE_PASSWORD, REGISTER_CAPTION, GUESTREGISTER_TEXT, "Next", "Cancel", TRANSACTION_GUESTREGISTER
		return
	}

	// user does exist
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"This name is registered, please retry with a different name.",
		"Ok", "", TRANSACTION_GUESTREGISTER
giveguestname:
	if (giveGuestName(playerid)) {
		savePlayerName playerid
	}
}

//@summary Callback after guest registers from a guest session
//@param playerid player that wanted to register
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_GUESTREGISTER_CB
export PUB_LOGIN_GUESTREGISTER_CB(playerid, response_code, data[])
{
	endDialogTransaction playerid, TRANSACTION_GUESTREGISTER
	COMMON_CHECKRESPONSECODE("E-U14")
	if (data[0] == 's') {
		loggedstatus[playerid] = LOGGED_IN
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			"Your account has been registered and your stats are saved, welcome!",
			"Ok", "", TRANSACTION_GUESTREGISTER
		new str[MAX_PLAYER_NAME + 6 + 46 + 1]
		format str, sizeof(str), "Guest %s[%d] just registered their account, welcome!", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_JOIN, str
		return
	}
	COMMON_UNKNOWNRESPONSE("E-U15")
err:
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An occurred, please try again later.", "Ok", "", TRANSACTION_GUESTREGISTER
	if (giveGuestName(playerid)) {
		savePlayerName playerid
	}
}

//@summary Callback after checking a player's password during change password process
//@param playerid player that wanted to change password
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_CHANGEPASS_CHECK_CB
export PUB_LOGIN_CHANGEPASS_CHECK_CB(playerid, response_code, data[])
{
	endDialogTransaction playerid, TRANSACTION_CHANGEPASS
	COMMON_CHECKRESPONSECODE("E-U16")
	if (data[0] == 't') {
		PREP_CHANGEPASSTEXT2
		ShowPlayerDialog playerid, DIALOG_CHANGEPASS2, DIALOG_STYLE_PASSWORD, CHANGEPASS_CAPTION, CHANGEPASS_TEXT, "Next", "Cancel", TRANSACTION_CHANGEPASS
		return
	}
	if (data[0] == 'f') {
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"Incorrect password", "Ok", "", TRANSACTION_CHANGEPASS
		return
	}
	COMMON_UNKNOWNRESPONSE("E-U17")
err:
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An error occurred, please try again later.", "Ok", "", TRANSACTION_CHANGEPASS
}

//@summary Callback after call to change a player's password
//@param playerid player that wanted to change password
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_CHANGEPASS_CHANGE_CB
export PUB_LOGIN_CHANGEPASS_CHANGE_CB(playerid, response_code, data[])
{
	endDialogTransaction playerid, TRANSACTION_CHANGEPASS
	COMMON_CHECKRESPONSECODE("E-U18")
	if (data[0] == 's') {
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, CHANGEPASS_CAPTION,
			"Password changed!", "Ok", "", TRANSACTION_CHANGEPASS
		return
	}
	COMMON_UNKNOWNRESPONSE("E-U19")
err:
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An error occurred, please try again later.", "Ok", "", TRANSACTION_CHANGEPASS
}

//@summary Saves a player's name in db
//@param playerid player to save the name of
savePlayerName(playerid)
{
	#assert MAX_PLAYER_NAME == 24
	static query[] = "UPDATE usr SET n='_________________________ WHERE i=__________"
	memcpy query, ninespaces, 53 * 4, 9 * 4
	format query[52], 10, _pd, userid[playerid]
	memcpy query, "                       ", 20 * 4, 23 * 4
	memcpy query, NAMEOF(playerid), 18 * 4, NAMELEN(playerid) * 4
	query[18 + NAMELEN(playerid)] = '\'';
	mysql_tquery 1, query
}

//@summary Renames a player to a guest name
//@param playerid the player to give a guest name to
//@returns {@code 0} if it was unsuccessful, which means the player is getting kicked
//@remarks player will be kicked when the name {@code @playername} is already taken and it failed to give a random name 5 times
giveGuestName(playerid)
{
	new newname[MAX_PLAYER_NAME]
	newname[0] = '@'
	memcpy(newname, NAMEOF(playerid), 4, NAMELEN(playerid) * 4 + 4)
	if (SetPlayerName(playerid, newname) == 1) {
		return 1
	}
	new guard = 5;
	while (guard-- > 0) {
		for (new i = 1; i < 10; i++) {
			newname[i] = 'a' + random('z' - 'a' + 1)
		}
		if (SetPlayerName(playerid, newname) == 1) {
			return 1
		}
	}
	print "F-U0C"
	SendClientMessage playerid, COL_WARN, WARN"Fatal error, please reconnect!"
	KickDelayed playerid
	return 0
}

//@summary Creates a guest session for player and spawns them as guest.
//@param playerid the player to spawn as guest
spawnAsGuest(playerid)
{
	GameTextForPlayer playerid, "~b~Creating guest session...", 0x800000, 3
	FormatLoginApiUserExistsGuest playerid, buf4096
	HTTP(playerid, HTTP_POST, #API_URL"/api-guest.php", buf4096, #PUB_LOGIN_GUEST_CB)
}

//@summary Updates a player's last seen (usr and ses) and total/actual time value in db
//@param playerid playerid to update
//@param isdisconnect is this call made from {@link OnPlayerDisconnect}?
//@remarks This function first checks if the player has a valid userid and sessionid
//@remarks If {@param isdisconnect} is {@code 0}, {@code 30} gets added to player's total time (inaccurate), \
otherwise player's totaltime is set to sum of session times (accurate)
updatePlayerLastseen(playerid, isdisconnect)
{
	static sessionquery1[] = "UPDATE usr SET l=UNIX_TIMESTAMP(),t=t+30,a=a+__________ WHERE i=__________"
	static sessionquery2[] = "UPDATE ses SET e=UNIX_TIMESTAMP() WHERE i=__________"
	static sessionquery3[] = "UPDATE usr SET t=(SELECT SUM(e-s) FROM ses WHERE u=usr.i) WHERE i=__________"
	if (userid[playerid] != -1 && sessionid[playerid] != -1) {
		if (isdisconnect) {
			memcpy sessionquery3, ninespaces, 67 * 4, 9 * 4
			format sessionquery3[66], 10, _pd, userid[playerid]
			mysql_tquery 1, sessionquery3
			sessionquery1[38] = '0'
		}
		memcpy sessionquery1, ninespaces, 46 * 4, 9 * 4
		format sessionquery1[45], 10, _pd, getAndClearUncommittedPlaytime(playerid)
		sessionquery1[45 + strlen(sessionquery1[45])] = ' '
		memcpy sessionquery1, ninespaces, 65 * 4, 9 * 4
		format sessionquery1[64], 10, _pd, userid[playerid]
		format sessionquery2[42], 10, _pd, sessionid[playerid]
		mysql_tquery 1, sessionquery1
		mysql_tquery 1, sessionquery2
		sessionquery1[38] = '3'
	}
}

//@summary Sets a player's logged status and triggers class selection for them
//@param playerid The player to login
//@param status the logged status to give, should be either {@code LOGGED_IN} or {@code LOGGED_GUEST}
loginPlayer(playerid, status)
{
	loggedstatus[playerid] = status
	iter_add(players, playerid)
	OnPlayerRequestClassImpl playerid
}

#printhookguards

