
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>

#define VERSION "0.1"

#undef MAX_PLAYERS
#define MAX_PLAYERS (100)
#define SLOTS MAX_PLAYERS

#define EXPORT%0\32%1(%2) forward %1(%2);public %1(%2)

#define cos(%0) floatcos(%0, degrees)
#define sin(%0) floatsin(%0, degrees)
#define tan(%0) floattan(%0, degrees)
#define AddPlayerClassNoWeapon(%1) AddPlayerClass(%1,0,0,0,0,0,0)

// public symbols
#define PUB_LOOP25 a

#define INIT
##include "panel"

#undef INIT

main()
{
	print "  Loaded gamemode basdon-fly "#VERSION"\n"
	SetTimer #PUB_LOOP25, 25, .repeating=1
}

/// <summary>PUB_LOOP25</summary>
EXPORT PUB_LOOP25()
{
	static invoc = 0
#define LOOP25
#undef LOOP25
	++invoc
	if (invoc & 0x4) {
		invoc = 0
#define LOOP150
##include "panel"

#undef LOOP150
	}
}

public OnPlayerConnect(playerid)
{
	DisablePlayerCheckpoint(playerid)
	DisablePlayerRaceCheckpoint(playerid)

	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "_", "_", "_", "_")

	TogglePlayerClock(playerid, 1)
	SetPlayerTime(playerid, 12, 0)

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1
}

public OnGameModeInit()
{
	SetGameModeText VERSION

	UsePlayerPedAnims
	AddPlayerClassNoWeapon(0, 345.5279, 1950.8094, 17.6406, 90.0)
	SetWorldTime 0

	AddStaticVehicle 520, 345.5279, 1954.8094, 17.6406, 90.0, 0, 0

#define ONGAMEMODEINIT
##include "panel"

#undef ONGAMEMODEINIT

	return 1;
}

public OnGameModeExit()
{
	return 1
}

##include "panel"

