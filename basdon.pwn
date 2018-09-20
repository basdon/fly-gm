
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>
#include <a_http>
#include "simpleiter"
#include "util"
#include "settings"

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
#define AddPlayerClassNoWeapon(%1) AddPlayerClass(%1,0,0,0,0,0,0)

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

new Iter:players[MAX_PLAYERS]
new TXT_EMPTY[] = "_"

##section varinit
###include "dialog"
###include "playername"
###include "panel"
###include "game_sa"
###include "afk"
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

	TogglePlayerClock(playerid, 1)
	SetPlayerTime(playerid, 12, 0)

	iter_add(players, playerid)

##section OnPlayerConnect
###include "playername"
###include "login"
###include "dialog"
###include "panel"
##endsection

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
##section OnPlayerDisconnect
###include "panel"
##endsection
	iter_remove(players, playerid)

	return 1
}

new val = 1
public OnPlayerRequestSpawn(playerid)
{
	SendClientMessageToAll(-1, "request spawn");
	return val
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	val = 1
}

public OnGameModeInit()
{
	SetGameModeText VERSION

	//UsePlayerPedAnims
	AddPlayerClassNoWeapon(0, 1467.4471, 1244.7747, 10.8281, 90.0)
	SetWorldTime 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1244.7747, 10.8281, 0.0, 0, 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1254.7747, 10.8281, 0.0, 0, 0

##section OnGameModeInit
###include "panel"
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

