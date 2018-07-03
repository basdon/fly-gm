
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>
#include "simpleiter"

#pragma tabsize 0 // it does not go well with some macros and preprocess

#define VERSION "0.1"

#undef MAX_PLAYERS
#define MAX_PLAYERS (50)
#define SLOTS MAX_PLAYERS

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

#define cos(%0) floatcos(%0, degrees)
#define sin(%0) floatsin(%0, degrees)
#define tan(%0) floattan(%0, degrees)
#define AddPlayerClassNoWeapon(%1) AddPlayerClass(%1,0,0,0,0,0,0)

// public symbols
#define PUB_LOOP25 a

new Iter:players[MAX_PLAYERS]
new TXT_EMPTY[] = "_"

##section varinit
##include "playername"

##include "panel"

##include "game_sa"

##include "afk"

##endsection

main()
{
	print "  Loaded gamemode basdon-fly "#VERSION"\n"
##section init
##endsection
	SetTimer #PUB_LOOP25, 25, .repeating=1
}

/// <summary>PUB_LOOP25</summary>
export PUB_LOOP25()
{
	static invoc = 0
##section loop25
##endsection
	++invoc
	if (invoc & 0x3 == 0) {
##section loop100
##include "panel"

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

	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY, TXT_EMPTY)

	TogglePlayerClock(playerid, 1)
	SetPlayerTime(playerid, 12, 0)

	iter_add(players, playerid)

##section OnPlayerConnect
##include "playername"

##include "panel"

##endsection

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
##section OnPlayerDisconnect
##include "panel"

##endsection
	iter_remove(players, playerid)

	return 1
}

new val = 0
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
##include "panel"

##endsection

	return 1;
}

public OnPlayerUpdate(playerid)
{
##section OnPlayerUpdate
##include "afk"

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
##include "panel"

##endsection
    return 1
}

#include "playername"
#include "panel"
#include "game_sa"
#include "afk"

