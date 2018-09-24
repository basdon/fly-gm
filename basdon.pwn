
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>
#include <a_http>
#include "simpleiter"
#include "util"
#include "settings"
#include "colors"
#include "natives"

#pragma tabsize 0 // it does not go well with some macros and preprocess

#define VERSION "0.1"

#undef MAX_PLAYERS
#include "sharedsymbols"
#ifndef MAX_PLAYERS
#error "no MAX_PLAYERS"
#endif
#define SLOTS MAX_PLAYERS

#ifndef PROD
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
#define PUB_LOOP25 a // main
#define PUB_LOGIN_USERCHECK_CB b // login
#define PUB_KICKEX c // main

//@summary Public function to kick a player.
//@param playerid the player to kick
//@remarks Calls to {@link KickDelayed} gets replaced with a non-repeating timer to this function.
//@remarks PUB_KICKEX
export PUB_KICKEX(playerid)
{
	Kick playerid
}

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
###include "timecyc"
##endsection

main()
{
	if (!ValidateMaxPlayers(MAX_PLAYERS)) {
		SendRconCommand "exit"
	}

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
###include "afk"
###include "timecyc"
##endsection
		// 1s loop is inside timecyc
		if (invoc >= 120) {
			// 3000ms
			invoc = 0
		}
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
###include "timecyc"
##endsection

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
##section OnPlayerDisconnect
###include "login"
###include "spawn"
###include "panel"
###include "afk"
##endsection
	iter_remove(players, playerid)

	return 1
}

public OnPlayerRequestClass(playerid, classid)
{
##section OnPlayerRequestClass
###include "timecyc"
###include "spawn"
##endsection
	return 1
}

public OnPlayerRequestSpawn(playerid)
{
##section OnPlayerRequestSpawn
###include "login" // login needs to be first! (to block if not logged)
###include "timecyc"
###include "spawn" // spawn needs to be last! (to set things when actually spawning)
##endsection
}

public OnPlayerSpawn(playerid)
{
	if (!isPlaying(playerid)) {
		return 0
	}

##section OnPlayerSpawn
###include "spawn"
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

#ifndef PROD
	if (strcicmp("/jetpack", cmdtext) == 0) {
		SetPlayerSpecialAction playerid, SPECIAL_ACTION_USEJETPACK
		return 1
	}
	if (strcicmp("/kill", cmdtext) == 0) {
		SetPlayerHealth playerid, 0.0
		return 1
	}
	if (strcicmp("/tweather", cmdtext, .length=9) == 0) {
		setWeather atoi(cmdtext[10])
		SendClientMessageToAll -1, "changing weather"
		return 1
	}
	if (strcicmp("/timex", cmdtext, .length=6) == 0) {
		SetPlayerTime playerid, atoi(cmdtext[7]), atoi(cmdtext[9])
		return 1
	}
#endif

##section OnPlayerCommandText
###include "login" // login needs to be first! (to block if not logged)
##endsection
	return 0
}

public OnPlayerText(playerid, text[])
{
##section OnPlayerText
###include "login" // login needs to be first! (to block if not logged)
##endsection
	return 1
}

//@summary Called when a player goes afk
//@summary playerid the playerid that went afk
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@seealso onPlayerWasAfk
//@seealso isAfk
onPlayerNowAfk(playerid)
{
##section onPlayerNowAfk
###include "panel"
##endsection
}

//@summary Gets called when a player comes back from being afk
//@summary playerid the playerid that is now back
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@seealso onPlayerNowAfk
//@seealso isAfk
onPlayerWasAfk(playerid)
{
##section onPlayerWasAfk
###include "panel"
###include "timecyc"
##endsection
}

public OnGameModeInit()
{
	SetGameModeText VERSION

	UsePlayerPedAnims
	EnableStuntBonusForAll 0

	AddStaticVehicle MODEL_HYDRA + 1, 1477.4471, 1220.7747, 10.8281, 0.0, 0, 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1240.7747, 10.8281, 0.0, 0, 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1254.7747, 10.8281, 0.0, 0, 0

##section OnGameModeInit
###include "panel"
###include "spawn"
###include "timecyc"
##endsection

	return 1;
}

public OnPlayerUpdate(playerid)
{
##section OnPlayerUpdate
###include "afk"
###include "timecyc"
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

##section OnDialogResponseCase
	switch (dialogid) {
###include "login"
	}
##endsection
	return 0
}

#include "playername"
#include "panel"
#include "timecyc"
#include "dialog"
// try to keep these last
#include "login"
#include "game_sa"
#include "afk"
#include "spawn"

