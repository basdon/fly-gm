
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>
#include <a_http>
#include "simpleiter"
#include "util"
#include "settings"
#include "colors"

#pragma tabsize 0 // it does not go well with some macros and preprocess

#define VERSION "0.1"

#undef MAX_PLAYERS
#define MAX_PLAYERS (50)
#define SLOTS MAX_PLAYERS

#if !defined PROD
// NO http:// PREFIX!
#define API_URL "localhost:8080/sap"
#else
#error "no prod API_URL defined yet"
#endif

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

#define cos(%0) floatcos(%0, degrees)
#define sin(%0) floatsin(%0, degrees)
#define tan(%0) floattan(%0, degrees)
#define strcicmp(%0) strcmp(%0, .ignorecase=true)
#define strcscmp(%0) strcmp(%0, .ignorecase=false)
#define atoi strval

// public symbols
#define PUB_LOOP25 a
#define PUB_LOGIN_USERCHECK_CB b
#define PUB_KICKEX c

//@summary Public function to kick a player.
//@param playerid the player to kick
//@remarks Calls to {@link KickDelayed} gets replaced with a non-repeating timer to this function.
export PUB_KICKEX(playerid)
{
	Kick playerid
}
//@summary Delayed kick to be able to send some messages first
//@param playerid player to kick
//@remarks Is implemented as a preprocessor replacement.
//@seealso Kick
stock KickDelayed(playerid) {}
#define KickDelayed SetTimerEx #PUB_KICKEX,25,0,"i",

//@summary Iter that contains {@b logged in (or guest)} players
new Iter:players[MAX_PLAYERS]

//@summary Just an underscore used as empty text for dialogs, textdraws, ...
//@remarks normal variable
//@seealso TXT_EMPTY_CONST
new TXT_EMPTY[] = "_"

//@summary Just an underscore used as empty text for dialogs, textdraws, ...
//@remarks stock const
//@seealso TXT_EMPTY
stock const TXT_EMPTY_CONST[] = "_"

##section varinit
###include "dialog"
###include "playername"
###include "panel"
###include "game_sa"
###include "afk"
###include "login"
###include "spawn"
##endsection

main()
{
	print "  Loaded gamemode basdon-fly "#VERSION"\n"
##section init
##endsection
	SetTimer #PUB_LOOP25, 25, .repeating=1
}

//@summary Basic loop that handles (almost) all timed stuff.
//@remarks PUB_LOOP25
export PUB_LOOP25()
{
	static invoc = 0
##section loop25
##endsection
	++invoc
	if (invoc & 0x3 == 0) {
##section loop100
###include "panel"
##endsection
	}
	if (invoc >= 60) {
		invoc = 0
##section loop1M

##endsection
	}
}

public OnPlayerConnect(playerid)
{
	DisablePlayerCheckpoint(playerid)
	DisablePlayerRaceCheckpoint(playerid)

##section OnPlayerConnect
###include "playername"
###include "login"
###include "dialog"
###include "panel"
###include "spawn"
##endsection

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
##section OnPlayerDisconnect
###include "login"
###include "spawn"
###include "panel"
##endsection
	iter_remove(players, playerid)

	return 1
}

public OnPlayerRequestClass(playerid, classid)
{
##section OnPlayerRequestClass
###include "spawn"
##endsection
	return 1
}

public OnPlayerRequestSpawn(playerid)
{
##section OnPlayerRequestSpawn
###include "login"
// login needs to be first!
###include "spawn"
// spawn needs to be last!
##endsection
}

public OnPlayerSpawn(playerid)
{
	if (!isPlaying(playerid)) {
		return 0
	}

##section OnPlayerSpawn
###include "spawn"
###include "timecyc"
##endsection

	return 1
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if (!isPlaying(playerid)) {
		return 0
	}

##section OnPlayerDeath
###include "spawn"
###include "timecyc"
##endsection

	return 1
}

public OnPlayerCommandText(playerid, cmdtext[])
{

#if !defined PROD
	if (strcicmp("/jetpack", cmdtext) == 0) {
		SetPlayerSpecialAction playerid, SPECIAL_ACTION_USEJETPACK
		return 1
	}
	if (strcicmp("/kill", cmdtext) == 0) {
		SetPlayerHealth playerid, 0.0
		return 1
	}
	if (strcicmp("/clock", cmdtext, .length=6) == 0) {
		TogglePlayerClock playerid, atoi(cmdtext[7])
		return 1
	}
	if (strcicmp("/weather", cmdtext, .length=8) == 0) {
		SetWeather atoi(cmdtext[9])
		return 1
	}
	if (strcicmp("/time", cmdtext, .length=5) == 0) {
		SetPlayerTime playerid, atoi(cmdtext[6]), 0
		return 1
	}
#endif

##section OnPlayerCommandText
###include "login"
// login needs to be first!
##endsection
	return 0
}

public OnPlayerText(playerid, text[])
{
##section OnPlayerText
###include "login"
// login needs to be first!
##endsection
	return 1
}

public OnGameModeInit()
{
	SetGameModeText VERSION

	//UsePlayerPedAnims

	SetWorldTime 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1244.7747, 10.8281, 0.0, 0, 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1254.7747, 10.8281, 0.0, 0, 0

##section OnGameModeInit
###include "panel"
###include "spawn"
##endsection

	return 1;
}

public OnPlayerUpdate(playerid)
{
##section OnPlayerUpdate
###include "afk"
##endsection
	return 1
}

public OnGameModeExit()
{
	return 1
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
##section OnPlayerStateChange
###include "panel"
##endsection
    return 1
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
##section OnDialogResponse
###include "dialog"
##endsection
	return 0
}

#include "playername"
#include "login"
#include "panel"
#include "game_sa"
#include "afk"
#include "dialog"
#include "spawn"

