
// vim: set filetype=c ts=8 noexpandtab:

#namespace "login"

hook OnPlayerConnect(playerid)
{
	#assert PLAYERNAMEVER == 1
	while (playernames[playerid][1] == '=') {
		// wiki states that SetPlayerName does not propagate for the user
		// if used in OnPlayerConnect, but tests have proven otherwise.
		if (NAMELEN(playerid) <= 3 || SetPlayerName(playerid, playernames[playerid][2]) != 1) {
			SendClientMessage playerid, COL_INFO_SAMP,
				"Failed to change your nickname. Please come back with a different name."
			KickDelayed playerid
			#allowreturn
			return 0
		}
		new s[34 + MAX_PLAYER_NAME + 1]
		format s, sizeof(s), "Your name has been changed to '%s'", NAMEOF(playerid)
		SendClientMessage playerid, COL_INFO_SAMP, "Names starting with '=' are reserved for guest players."
		SendClientMessage playerid, COL_INFO_SAMP, s
	}
	new data[MAX_PLAYER_NAME * 3 + 4]
	data[0] = 'u'
	data[1] = '='
	new len = urlencode(NAMEOF(playerid), NAMELEN(playerid), data[2])
	data[len + 2] = 0
	HTTP(playerid, HTTP_POST, #API_URL"/api-usercheck.php", data, #PUB_LOGIN_USERCHECK_CB)
}

//@summary Callback for usercheck done in {@link OnPlayerConnect}.
//@param playerid player that has been checked
//@param response_code http response code or one of the {@code HTTP_*} macros
//@param data response data
export PUB_LOGIN_USERCHECK_CB(playerid, response_code, data[])
{
	if (response_code != 200) {
		printf "usercheck api call returned code %d, data %s", response_code, data
		goto err;
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

	printf "usercheck api call returned '%s'", data
err:
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
spawnasguest:
	// TODO spawn as guest
}

#printhookguards

