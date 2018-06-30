
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>
#include "simpleiter"

#pragma tabsize 0 // it does not go well with some macros and preprocess

#define VERSION "0.1"

#undef MAX_PLAYERS
#define MAX_PLAYERS (50)
#define SLOTS MAX_PLAYERS

#define EXPORT%0\32%1(%2) forward %1(%2);public %1(%2)

#define cos(%0) floatcos(%0, degrees)
#define sin(%0) floatsin(%0, degrees)
#define tan(%0) floattan(%0, degrees)
#define AddPlayerClassNoWeapon(%1) AddPlayerClass(%1,0,0,0,0,0,0)

// public symbols
#define PUB_LOOP25 a

new Iter:players[MAX_PLAYERS]
new TXT_EMPTY[] = "_"

#define VAR
##include "panel"

##include "game_sa"

#undef VAR

main()
{
	print "  Loaded gamemode basdon-fly "#VERSION"\n"
#define INIT
#undef INIT
	SetTimer #PUB_LOOP25, 25, .repeating=1
}

/// <summary>PUB_LOOP25</summary>
EXPORT PUB_LOOP25()
{
	static invoc = 0
#define LOOP25
#undef LOOP25
	++invoc
	if (invoc & 0x3 == 0) {
#define LOOP100
##include "panel"

#undef LOOP100
	}
	if (invoc >= 60) {
		invoc = 0
#define LOOP1M

#undef LOOP1M
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

#define ONPLAYERCONNECT
##include "panel"

#undef ONPLAYERCONNECT

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
	iter_remove(players, playerid)

	return 1
}

public OnGameModeInit()
{
	SetGameModeText VERSION

	//UsePlayerPedAnims
	AddPlayerClassNoWeapon(0, 1467.4471, 1244.7747, 10.8281, 90.0)
	SetWorldTime 0
	AddStaticVehicle MODEL_HYDRA, 1477.4471, 1244.7747, 10.8281, 0.0, 0, 0

#define ONGAMEMODEINIT
##include "panel"

#undef ONGAMEMODEINIT

	return 1;
}

public OnGameModeExit()
{
	return 1
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
#define ONPLAYERSTATECHANGE
##include "panel"

#undef ONPLAYERSTATECHANGE
    return 1
}

#include "panel"
#include "game_sa"

