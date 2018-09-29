
// vim: set filetype=c ts=8 noexpandtab:

#namespace "login"

#define LOGGED_NO 0
#define LOGGED_IN 1
#define LOGGED_GUEST 2

#define MAX_LOGIN_ATTEMPTS 4
#define PARSE5BYTENONNULL(%0,%1) ((%0[%1]&0x7F)|((%0[%1+1]&0x7F)<<7)|\
			((%0[%1+2]&0x7F)<<14)|((%0[%1+3]&0x7F)<<21)|((%0[%1+4]&0x0F)<<28))

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
	#define PREP_REGTEXT1 MOD_REGTEXT(125,"<<<<",162,"    ",4);MOD_REGTEXT(97,ECOL_INFO,130,ECOL_DIALOG_TEXT,8)
	#define PREP_REGTEXT2 MOD_REGTEXT(162,"<<<<",125,"    ",4);MOD_REGTEXT(130,ECOL_INFO,97,ECOL_DIALOG_TEXT,8)

	new LOGIN_CAPTION[] = "Login"
	new LOGIN_TEXT[] =
		""ECOL_WARN"Incorrect password!\n\n"ECOL_DIALOG_TEXT""\
		"Welcome! This account is registered.\n"\
		"Please sign in or change your name."
	#define LOGIN_TEXT_OFFSET 37

	new NAMECHANGE_CAPTION[] = "Change name"
	new NAMECHANGE_TEXT[] =
		""ECOL_WARN"Invalid name.\n\n"ECOL_DIALOG_TEXT""\
		"Enter your new name (3-20 length, 0-9a-zA-Z=()[]$@._).\n"\
		"Names starting with @ are reserved for guests."
	#define NAMECHANGE_TEXT_OFFSET 31
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
	#assert PLAYERNAMEVER == 1
	while (playernames[playerid][1] == '@') {
		SendClientMessage playerid, COL_SAMP_GREEN, "Names starting with '@' are reserved for guest players."
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
	checkUserExist playerid
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

hook OnDialogResponseCase(playerid, dialogid, response, listitem, inputtext[])
{
	case DIALOG_REGISTER1: {
		if (!response) {
			renameAndSpawnAsGuest playerid
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
			"Cancel"
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
		// max inputtext len seems to be 128
		new inputlen = strlen(inputtext)
		if (inputlen > 128) {
			inputtext[128] = 0
			inputlen = 128
		}
		new data[2 + (MAX_PLAYER_NAME * 3) + 3 + (128 * 3) + 3 + 15 + 1]
		data[0] = 'u'
		data[1] = '='
		new idx = 2 + Urlencode(NAMEOF(playerid), NAMELEN(playerid), data[2])
		memcpy data, "&p=", idx * 4, 3 * 4
		idx += 3
		idx += Urlencode(inputtext, inputlen, data[idx])
		data[idx++] = '&'
		data[idx++] = 'j'
		data[idx++] = '='
		GetPlayerIp playerid, data[idx], 16
		HTTP(playerid, HTTP_POST, #API_URL"/api-register.php", data, #PUB_LOGIN_REGISTER_CB)
		#return 1
	}
	case DIALOG_LOGIN1: {
		if (!response) {
			showNamechangeDialog playerid, .textoffset=NAMECHANGE_TEXT_OFFSET
			#return 1
		}
		GameTextForPlayer playerid, "~b~Logging in...", 0x800000, 3
		// max inputtext len seems to be 128
		new inputlen = strlen(inputtext)
		if (inputlen > 128) {
			inputtext[128] = 0
			inputlen = 128
		}
		new data[2 + 8 + 3 + (128 * 3) + 3 + 15 + 1]
		data[0] = 'i'
		data[1] = '='
		format data[2], 9, "%08x", userid[playerid]
		data[10] = '&'
		data[11] = 'p'
		data[12] = '='
		new idx = 13 + Urlencode(inputtext, inputlen, data[13])
		data[idx++] = '&'
		data[idx++] = 'j'
		data[idx++] = '='
		GetPlayerIp playerid, data[idx], 16
		if (failedlogins{playerid} == (MAX_LOGIN_ATTEMPTS - 1) * 2) {
			SendClientMessage playerid, COL_WARN, #WARN"You will be kicked if this login attempt is unsuccessful!"
		}
		HTTP(playerid, HTTP_POST, #API_URL"/api-login.php", data, #PUB_LOGIN_LOGIN_CB)
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
		new len = strlen(inputtext)
		if (len < 3 || 20 < len || inputtext[0] == '@' || !SetPlayerName(playerid, inputtext)) {
			showNamechangeDialog playerid, .textoffset=0
		} else {
			userid[playerid] = -1
			checkUserExist playerid
		}
		#return 1
	}
}

//@summary Check if a user with username of {@param playerid} exists
//@param playerid the player to check if their username is registered
checkUserExist(playerid)
{
	GameTextForPlayer playerid, "~b~Contacting login server...", 0x800000, 3
	new data[MAX_PLAYER_NAME * 3 + 4]
	data[0] = 'u'
	data[1] = '='
	Urlencode(NAMEOF(playerid), NAMELEN(playerid), data[2])
	HTTP(playerid, HTTP_POST, #API_URL"/api-user-exists.php", data, #PUB_LOGIN_USERCHECK_CB)
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
		"Play as guest"
}

//@summary Shows login dialog for player
//@param playerid player to show login dialog for
//@param textoffset textoffset in login string, should be {@code LOGIN_TEXT_OFFSET} or {@code 0}
showLoginDialog(playerid, textoffset=0)
{
	ShowPlayerDialog playerid,
		DIALOG_LOGIN1,
		DIALOG_STYLE_PASSWORD,
		LOGIN_CAPTION,
		LOGIN_TEXT[textoffset],
		"Login",
		"Change name"
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
		"Cancel"
}

//@summary Callback for usercheck done in {@link OnPlayerConnect}.
//@param playerid player that has been checked
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_USERCHECK_CB
export PUB_LOGIN_USERCHECK_CB(playerid, response_code, data[])
{
	hideGameTextForPlayer(playerid)
	if (response_code != 200) {
		LIMITSTRLEN(data, 500)
		printf "E-U01: %d, %s", response_code, data
		goto err
	}

	if (data[0] == 't') {
		if (strlen(data) < 6) {
			printf "E-U02: %d", strlen(data)
			goto err
		}
		userid[playerid] = PARSE5BYTENONNULL(data, 1)
		showLoginDialog playerid, .textoffset=LOGIN_TEXT_OFFSET
		return
	}

	if (data[0] == 'f') {
		showRegisterDialog playerid, .textoffset=REGISTER_TEXT_OFFSET
		return
	}

	LIMITSTRLEN(data, 500)
	printf "E-U03: %s", data
err:
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An occurred, you will be spawned as a guest", "Ok", ""
	SendClientMessage playerid, COL_WARN, WARN"An error occured while contacting the login server."
	SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
	renameAndSpawnAsGuest playerid
}

//@summary Callback for register call
//@param playerid player that wanted to register
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_REGISTER_CB
export PUB_LOGIN_REGISTER_CB(playerid, response_code, data[])
{
	hideGameTextForPlayer(playerid)
	if (response_code != 200) {
		LIMITSTRLEN(data, 500)
		printf "E-U04: %d, %s", response_code, data
		goto err
	}

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

	LIMITSTRLEN(data, 500)
	printf "E-U07: %s", data
err:
	ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An occurred, you will be spawned as a guest", "Ok", ""
	SendClientMessage playerid, COL_WARN, WARN"An error occured while registering."
	SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
	renameAndSpawnAsGuest playerid
}

//@summary Callback for login call
//@param playerid player that wanted to login
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
//@remarks PUB_LOGIN_LOGIN_CB
export PUB_LOGIN_LOGIN_CB(playerid, response_code, data[])
{
	hideGameTextForPlayer(playerid)
	if (response_code != 200) {
		LIMITSTRLEN(data, 500)
		printf "E-U08: %d, %s", response_code, data
		goto err
	}

	if (data[0] == 's') {
		if (strlen(data) < 11) {
			printf "E-U09: %d", strlen(data)
			goto err
		}
		SetPlayerScore playerid, PARSE5BYTENONNULL(data, 1)
		sessionid[playerid] = PARSE5BYTENONNULL(data, 6)
		loginPlayer playerid, LOGGED_IN
		new str[MAX_PLAYER_NAME + 6 + 30 + 1]
		format str, sizeof(str), "%s[%d] just logged in, welcome back!", NAMEOF(playerid), playerid
		SendClientMessageToAll COL_JOIN, str
		return
	}

	if (data[0] == 'f') {
		if ((failedlogins{playerid} += 2) > (MAX_LOGIN_ATTEMPTS - 1) * 2) {
			// no KickDelayed because no OnPlayerUpdate in class select
			// a warning message was sent before pwcheck saying player will be kicked so it's ok
			Kick playerid
			return
		}
		showLoginDialog playerid, .textoffset=0
		return
	}

	LIMITSTRLEN(data, 500)
	if (data[0] == 'e') {
		printf "E-U0A: %s", data[1]
	} else {
		printf "E-U0B: %s", data
	}

err:
	ShowPlayerDialog playerid, DIALOG_LOGIN_ERROR, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
		""#ECOL_WARN"An error occurred, please try again", "Ok", ""
}

//@summary Renames a player to give a guest name and spawns them as {@code LOGGED_GUEST}
//@param playerid the player to spawn as guest
//@remarks player will be kicked when the name {@code =playername} is already taken and it failed to give a random name 5 times
renameAndSpawnAsGuest(playerid)
{
	new newname[MAX_PLAYER_NAME]
	newname[0] = '@'
	memcpy(newname, NAMEOF(playerid), 4, NAMELEN(playerid) * 4 + 4)
	if (SetPlayerName(playerid, newname) == 1) {
		goto spawnasguest
	}
	new guard = 5;
	while (guard-- > 0) {
		for (new i = 1; i < 10; i++) {
			newname[i] = 'a' + random('z' - 'a' + 1)
		}
		if (SetPlayerName(playerid, newname) == 1) {
			goto spawnasguest
		}
	}
	print "F-U0C"
	SendClientMessage playerid, COL_WARN, WARN"Fatal error, please reconnect!"
	KickDelayed playerid
	goto @@return // just returning here gives 'unreachable code' warning for next line so yeah...
spawnasguest:
	loginPlayer playerid, LOGGED_GUEST
@@return:
}

//@summary Updates a player's last seen (usr and ses) and total time value in db
//@param playerid playerid to update
//@param isdisconnect is this call made from {@link OnPlayerDisconnect}?
//@remarks This function first checks if the player has a valid userid and sessionid
//@remarks If {@param isdisconnect} is {@code 0}, {@code 30} gets added to player's total time (inaccurate), \
otherwise player's totaltime is set to sum of session times (accurate)
updatePlayerLastseen(playerid, isdisconnect)
{
	static sessionquery1[] = "UPDATE usr SET l=UNIX_TIMESTAMP(),t=t+30 WHERE i=__________"
	static sessionquery2[] = "UPDATE ses SET e=UNIX_TIMESTAMP() WHERE i=__________"
	static sessionquery3[] = "UPDATE usr SET t=(SELECT SUM(e-s) FROM ses WHERE u=         ) WHERE i=_________"
	if (userid[playerid] != -1 && sessionid[playerid] != -1) {
		if (isdisconnect) {
			format sessionquery3[70], 10, "%d", userid[playerid]
			new len = strlen(sessionquery3[70])
			memcpy sessionquery3[51], sessionquery3[70], 0, len * 4
			mysql_tquery 1, sessionquery3
			sessionquery1[38] = '0'
		}
		format sessionquery1[49], 10, "%d", userid[playerid]
		format sessionquery2[42], 10, "%d", sessionid[playerid]
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

