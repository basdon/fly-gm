
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

	//@summary Logged in status, either {@code LOGGED_NO}, {@code LOGGED_IN} or {@code LOGGED_GUEST}
	new loggedstatus[MAX_PLAYERS];
}

hook OnPlayerDisconnect(playerid)
{
	loggedstatus[playerid] = LOGGED_NO
}

hook OnPlayerConnect(playerid)
{
	#assert PLAYERNAMEVER == 1
	while (playernames[playerid][1] == '=') {
		// wiki states that SetPlayerName does not propagate for the user
		// if used in OnPlayerConnect, but tests have proven otherwise.
		if (NAMELEN(playerid) <= 3 || SetPlayerName(playerid, playernames[playerid][2]) != 1) {
			SendClientMessage playerid, COL_WARN,
				WARN"Failed to change your nickname. Please come back with a different name."
			KickDelayed playerid
			#allowreturn
			return 0
		}
		SendClientMessage playerid, COL_SAMP_GREEN, "Names starting with '=' are reserved for guest players."
	}
	new data[MAX_PLAYER_NAME * 3 + 4]
	data[0] = 'u'
	data[1] = '='
	new len = urlencode(NAMEOF(playerid), NAMELEN(playerid), data[2])
	data[len + 2] = 0
	HTTP(playerid, HTTP_POST, #API_URL"/api-usercheck.php", data, #PUB_LOGIN_USERCHECK_CB)
}

hook OnPlayerRequestSpawn(playerid)
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#allowreturn
		return 0
	}
}

hook OnPlayerCommandText(playerid, cmdtext[])
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#allowreturn
		return 1
	}
}

hook OnPlayerText(playerid, text[])
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#allowreturn
		return 0
	}
}

//@summary Callback for usercheck done in {@link OnPlayerConnect}.
//@param playerid player that has been checked
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
export PUB_LOGIN_USERCHECK_CB(playerid, response_code, data[])
{
	if (response_code != 200) {
		// printf can crash server if formatstr or output len is > 1024
		if (strlen(data) > 500) {
			data[499] = 0
		}
		printf "[ERROR][LOGIN] usercheck api call returned code %d, data: '%s'", response_code, data
		goto err
	}

	if (data[0] == 't') {
		printf("does exist")
		// TODO ask pw
		return
	}

	if (data[0] == 'f') {
		printf("does not exist")
		// TODO ask register
		return
	}

	// printf can crash server if formatstr or output len is > 1024
	if (strlen(data) > 500) {
		data[499] = 0
	}
	printf "[ERROR][LOGIN] usercheck api call returned unknown status: '%s'", data
err:
	SendClientMessage playerid, COL_WARN, WARN"An error occured while contacting the login server."
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
	print "[ERROR][LOGIN] failed to give player a guest name after err, player will be kicked!!"
	SendClientMessage playerid, COL_WARN, WARN"Fatal error, you will be kicked (sorry!), please reconnect"
	KickDelayed playerid
	goto @@return // just returning here gives 'unreachable code' warning for next line so yeah...
spawnasguest:
	SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
	loggedstatus[playerid] = LOGGED_GUEST
	// TODO spawn as guest
@@return:
}

#define _isPlaying isPlaying
#undef isPlaying
#define _isRegistered isRegistered
#undef isRegistered
#define _isGuest isGuest
#undef isGuest

//@summary Check if a player is playing (=past the login screen, can be guest)
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isGuest
//@seealso isRegistered
//@returns {@code 0} if the player is not playing
stock isPlaying(playerid) { }

//@summary Check if a player has an account (=is not a guest)
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isPlaying
//@seealso isGuest
//@returns {@code 0} if the player is not registered
stock isRegistered(playerid) { }

//@summary Check if a player is playing as a guest
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isPlaying
//@seealso isRegistered
//@returns {@code 0} if the player is not logged in
stock isGuest(playerid) { }

#define isPlaying _isPlaying
#undef _isPlaying
#define isRegistered _isRegistered
#undef _isRegistered
#define isGuest _isGuest
#undef _isGuest

#printhookguards

