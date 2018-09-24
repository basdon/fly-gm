
// vim: set filetype=c ts=8 noexpandtab:

#namespace "login"

#define LOGGED_NO 0
#define LOGGED_IN 1
#define LOGGED_GUEST 2

varinit
{
	#define isPlaying(%0) (loggedstatus[%0])
	#define isRegistered(%0) (loggedstatus[%0] == LOGGED_IN)
	#define isGuest(%0) (loggedstatus[%0] == LOGGED_GUEST)

	new loggedstatus[MAX_PLAYERS];

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
}

hook OnPlayerDisconnect(playerid)
{
	loggedstatus[playerid] = LOGGED_NO
}

hook OnPlayerConnect(playerid)
{
	#assert PLAYERNAMEVER == 1
	while (playernames[playerid][1] == '=') {
		SendClientMessage playerid, COL_SAMP_GREEN, "Names starting with '=' are reserved for guest players."
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
	GameTextForPlayer playerid, "~b~Contacting login server...", 0x800000, 3
	new data[MAX_PLAYER_NAME * 3 + 4]
	data[0] = 'u'
	data[1] = '='
	Urlencode(NAMEOF(playerid), NAMELEN(playerid), data[2])
	HTTP(playerid, HTTP_POST, #API_URL"/api-user-exists.php", data, #PUB_LOGIN_USERCHECK_CB)
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
		// TODO password
		PREP_REGTEXT2
		ShowPlayerDialog playerid,
			DIALOG_REGISTER2,
			DIALOG_STYLE_INPUT,
			REGISTER_CAPTION,
			REGISTER_TEXT[REGISTER_TEXT_OFFSET],
			"Confirm",
			""
		#return 1
	}
	case DIALOG_REGISTER2: {
		if (!response) {
			showRegisterDialog playerid, .textoffset=0
			#return 1
		}
		// TODO actually register
		#return 1
	}
}

//@summary Shows register dialog for player
//@param playerid player to show register dialog for
//@param textoffset textoffset in register string, should be {@code REGISTER_TEXT_OFFSET} or {@code 0}
showRegisterDialog(playerid, textoffset)
{
	PREP_REGTEXT1
	ShowPlayerDialog playerid,
		DIALOG_REGISTER1,
		DIALOG_STYLE_INPUT,
		REGISTER_CAPTION,
		REGISTER_TEXT[textoffset],
		"Next",
		"Play as guest"
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
		// printf can crash server if formatstr or output len is > 1024
		data[499] = 0
		printf "[ERROR][LOGIN] usercheck api call returned code %d, data: '%s'", response_code, data
		goto err
	}

	if (data[0] == 't') {
		printf("does exist")
		// TODO ask pw
		return
	}

	if (data[0] == 'f') {
		showRegisterDialog playerid, .textoffset=REGISTER_TEXT_OFFSET
		return
	}

	// printf can crash server if formatstr or output len is > 1024
	data[499] = 0
	printf "[ERROR][LOGIN] usercheck api call returned unknown status: '%s'", data
err:
	SendClientMessage playerid, COL_WARN, WARN"An error occured while contacting the login server."
	SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
	renameAndSpawnAsGuest playerid
}

//@summary Renames a player to give a guest name and spawns them as {@code LOGGED_GUEST}
//@param playerid the player to spawn as guest
renameAndSpawnAsGuest(playerid)
{
	new newname[MAX_PLAYER_NAME]
	newname[0] = '='
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
	print "[ERROR][LOGIN] failed to give player a guest name, player will be kicked!!"
	SendClientMessage playerid, COL_WARN, WARN"Fatal error, you will be kicked (sorry!), please reconnect"
	KickDelayed playerid
	goto @@return // just returning here gives 'unreachable code' warning for next line so yeah...
spawnasguest:
	loginPlayer playerid, LOGGED_GUEST
@@return:
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

#undef isPlaying
//@summary Check if a player is playing (=past the login screen, can be guest)
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isSpawned
//@seealso isGuest
//@seealso isRegistered
//@returns {@code 0} if the player is not playing
stock isPlaying(playerid) {
	this_function _ should_not _ be_called
}

#undef isRegistered
//@summary Check if a player has an account (=is not a guest)
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isPlaying
//@seealso isGuest
//@returns {@code 0} if the player is not registered
stock isRegistered(playerid) {
	this_function _ should_not _ be_called
}

#undef isGuest
//@summary Check if a player is playing as a guest
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isPlaying
//@seealso isRegistered
//@returns {@code 0} if the player is not logged in
stock isGuest(playerid) {
	this_function _ should_not _ be_called
}

#printhookguards

