
// vim: set filetype=c ts=8 noexpandtab:

#include "dummies"
#include <a_samp>
#include <a_http>
#include <a_mysql_min>
#include <bcrypt>
#include <socket>
#include "simpleiter"
#include "util"
#include "settings"
#include "natives"

#pragma tabsize 0 // it does not go well with some macros and preprocess

#define VERSION "0.1"

#undef MAX_PLAYERS
#include "sharedsymbols"
#include "colors"
#ifndef MAX_PLAYERS
#error "no MAX_PLAYERS"
#endif
#define SLOTS MAX_PLAYERS

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

#define cos(%0) floatcos(%0, degrees)
#define sin(%0) floatsin(%0, degrees)
#define tan(%0) floattan(%0, degrees)
#define strcicmp(%0) strcmp(%0, .ignorecase=true)
#define strcscmp(%0) strcmp(%0, .ignorecase=false)
#define atoi strval
#define FLOAT_PINF (Float:0x7F800000)
#define FLOAT_NINF (Float:0xFF800000)
#define WARNMSG(%0) SendClientMessage(playerid, COL_WARN, WARN%0)

// public symbols
#define PUB_LOOP25 a // main
#define PUB_LOGIN_USERCHECK_CB b // login
#define PUB_LOGIN_REGISTER_CB c // login
#define PUB_LOGIN_PWVERIFY_CB d // login
#define PUB_LOGIN_CREATE_GUEST_SES e // login
#define PUB_LOGIN_GUESTREGISTERUSERCHECK_CB f // login
#define PUB_LOGIN_GUESTREGISTER_CB g // login
#define PUB_LOGIN_CHANGEPASS_CHECK_CB h // login
#define PUB_LOGIN_CHANGEPASS_CHANGE_CB o // login
#define PUB_TIMECYC_NEXTWEATHER ab // timcyc
#define PUB_LOGIN_LOADACCOUNT_CB q // login
#define PUB_LOGIN_CREATEGAMESESSION_CB aa // login
#define PUB_LOGIN_GUESTREGISTER_HASHPW_CB s // login
#define PUB_LOGIN_CHANGEPASS_HASHPW_CB t // login
#define PUB_LOGIN_CREATE_GUEST_USR u // login
#define PUB_LOGIN_REGISTER_HASHPW_CB v // login
#define PUB_LOGIN_CREATE_NEWUSER_SES w // login

#namespace "basdon"

//@summary Checks if a float is any NaN
//@param n number to check for NaN-ness
//@returns {@code 1} if {@param n} is any NaN
stock isNaN(Float:n)
{
	return (_:n | 0x807FFFFF) == -1 && (_:n & 0x007FFFFF)
}

//@summary Iter that contains {@b logged in (or guest)} players
new Iter:players[MAX_PLAYERS]

//@summary Iter that contains {@b all} players
new Iter:allplayers[MAX_PLAYERS]

//@summary Just an underscore used as empty text for dialogs, textdraws, ...
//@remarks normal variable
//@seealso TXT_EMPTY_CONST
new TXT_EMPTY[] = "_"

//@summary Just an underscore used as empty text for dialogs, textdraws, ...
//@remarks stock const
//@seealso TXT_EMPTY
stock const TXT_EMPTY_CONST[] = "_"

new tmp1
new buf4096[4096], buf144[144], buf64[64], buf32[32], buf32_1[32]

#define SetPlayerPos SetPlayerPosHook

##section varinit
###include "dialog"
###include "playername"
###include "panel"
###include "game_sa"
###include "playtime"
###include "login"
###include "objects"
###include "pm"
###include "spawn"
###include "timecyc"
###include "tracker"
###include "anticheat"
###include "vehicles"
###include "zones"
##endsection

main()
{
	if (!ValidateMaxPlayers(MAX_PLAYERS)) {
		SendRconCommand "exit"
		return
	}

	print "  Loaded gamemode basdon-fly "#VERSION"\n"
##section init
##endsection
	SetTimer #PUB_LOOP25, 25, .repeating=1
}

//@summary Function that should never be called, does dummy calls to natives to make {@code SYSREQ.C} happy
export dummies()
{
	CreateVehicle 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0
	Veh_UpdateSlot 0, 0
}

//@summary Basic loop that handles (almost) all timed stuff.
export __SHORTNAMED PUB_LOOP25()
{
	static lastinvoctime = 0
	static invoc = 0
##section loop25
##endsection
	invoc = (++invoc & 0x3)
	if (!invoc) {
##section loop100
###include "panel"
###include "playtime"
###include "timecyc"
###include "anticheat"
##endsection
		invoc = 0
	}
	new _tc = tickcount()
	if (_tc - lastinvoctime > 4984) {
		// this should be 4985-5010(+5)
		// 1s,30s,1m loop is inside timecyc
##section loop5000
###include "dialog"
###include "objects"
##endsection
		lastinvoctime = _tc
	}
}

public OnPlayerConnect(playerid)
{
	DisablePlayerCheckpoint(playerid)
	DisablePlayerRaceCheckpoint(playerid)

	iter_add(allplayers, playerid)

##section OnPlayerConnect
###include "dialog" // keep this first
###include "playername" // keep this second
###include "login"
###include "panel"
###include "spawn"
###include "timecyc"
###include "anticheat"
###include "playtime"
###include "objects"
###include "pm"
###include "zones"
##endsection

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
##section OnPlayerDisconnect
###include "login"
###include "spawn"
###include "panel"
###include "playtime"
###include "dialog"
###include "airport"
###include "vehicles"
###include "playername" // keep this last-ish (clears data)
###include "pm"
##endsection
	iter_remove(players, playerid)
	iter_remove(allplayers, playerid)

	return 1
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
##section OnPlayerEnterVehicle
###include "vehicles"
##endsection
}

//@summary Function that gets called when a player logs in
//@param playerid the player that just logged in
OnPlayerLogin(playerid)
{
##section OnPlayerLogin
###include "vehicles"
##endsection
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
###include "zones"
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
###include "zones"
##endsection

	return 1
}

//@summary Hooks {@link SetPlayerPos} to do stuff
//@param playerid see {@link SetPlayerPos}
//@param x see {@link SetPlayerPos}
//@param y see {@link SetPlayerPos}
//@param z see {@link SetPlayerPos}
//@returns see {@link SetPlayerPos}
//@remarks see {@link SetPlayerPos}
//@remarks has {@code onSetPlayerPos} section
//@seealso SetPlayerPos
SetPlayerPosHook(playerid, Float:x, Float:y, Float:z)
{
##section onSetPlayerPos
###include "zones"
##endsection
#undef SetPlayerPos
	SetPlayerPos playerid, x, y, z
#define SetPlayerPos SetPlayerPosHook
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
	if (strcicmp("/fweather", cmdtext, .length=9) == 0) {
		lockedweather = upcomingweather = currentweather = atoi(cmdtext[10]) // timecyc hack
		forceTimecycForPlayer playerid
		SendClientMessageToAll -1, "changing weather"
		return 1
	}
	if (strcicmp("/sound", cmdtext, .length=6) == 0) {
		PlayerPlaySound playerid, atoi(cmdtext[7]), 0.0, 0.0, 0.0
		return 1
	}
	if (strcicmp("/timex", cmdtext, .length=6) == 0) {
		SetPlayerTime playerid, atoi(cmdtext[7]), atoi(cmdtext[9])
		return 1
	}
	if (strcicmp("/kickme", cmdtext, .length=7) == 0) {
		SendClientMessage playerid, -1, "you're kicked, bye"
		KickDelayed playerid
		return 1
	}
	if (strcicmp("/crashme", cmdtext, .length=8) == 0) {
		GameTextForPlayer playerid, "Wasted~~k~SWITCH_DEBUG_CAM_ON~~k~~TOGGLE_DPAD~~k~~NETWORK_TALK~~k~~SHOW_MOUSE_POINTER_TOGGLE~", 5, 5
		return 1
	}
#endif

##section OnPlayerCommandText
###include "login" // login needs to be first! (to block if not logged)
###include "spawn" // block if not spawned
##endsection

	new idx
	switch (CommandHash(cmdtext)) {
##section OnPlayerCommandTextCase
###include "login"
###include "airport"
###include "nav"
###include "pm"
###include "timecyc"
###include "zones"
##endsection

#ifndef PROD
	case 48476: if (IsCommand(cmdtext, "/gt", idx)) {
		if (Params_GetString(cmdtext, idx, buf32) && Params_GetString(cmdtext, idx, buf144)) {
			GameTextForPlayer(playerid, buf144, 4000, strval(buf32))
		}
		return 1
	}
	case 608035061: if (IsCommand(cmdtext, "/nweather", idx)) {
		PUB_TIMECYC_NEXTWEATHER
		return 1
	}
	default: printf "command '%s' hash: %d", cmdtext, CommandHash(cmdtext)
#endif
	}

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
//@param playerid the playerid that went afk
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@seealso onPlayerWasAfk
//@seealso isAfk
onPlayerNowAfk(playerid)
{
##section onPlayerNowAfk
###include "playtime"
###include "panel"
##endsection
}

//@summary Gets called when a player comes back from being afk
//@param playerid the playerid that is now back
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@seealso onPlayerNowAfk
//@seealso isAfk
onPlayerWasAfk(playerid)
{
##section onPlayerWasAfk
###include "playtime"
###include "panel"
###include "timecyc"
##endsection
}

public OnGameModeInit()
{
	new File:mysqlfile = fopen("mysql.dat", io_read)
	if (!mysqlfile) {
		printf "file mysql.dat not found"
		SendRconCommand "exit"
		return 1
	}
	new creds[100]
	fblockread mysqlfile, creds
	fclose mysqlfile

	mysql_log LOG_ERROR | LOG_WARNING
	if (!mysql_connect("127.0.0.1", creds[creds[0]], creds[creds[1]], creds[creds[2]]) || mysql_errno() != 0) {
		printf "no db connection"
		SendRconCommand "exit"
		return 1
	}
	//mysql_set_charset "Windows-1252"

	SetGameModeText VERSION

	UsePlayerPedAnims
	EnableStuntBonusForAll 0

	new rowcount // used in airprot, vehicles

##section OnGameModeInit
###include "objects"
###include "panel"
###include "spawn"
###include "timecyc"
###include "tracker"
###include "vehicles"
###include "airport"
##endsection

	return 1;
}

public OnPlayerUpdate(playerid)
{
##section OnPlayerUpdate
###include "playtime"
###include "timecyc"
###include "vehicles"
###include "anticheat" // keep this last (lastvehicle updated in vehicles)
##endsection
	return 1
}

public OnGameModeExit()
{
##section OnGameModeExit
###include "airport"
###include "tracker"
###include "vehicles"
##endsection

	if (mysql_unprocessed_queries() > 0) {
		new starttime = gettime()
		do {
			if (gettime() - starttime > 10) {
				print "queries are taking > 10s, exiting anyways"
				goto fuckit
			}
			print "waiting on queries before exiting"
			for (new i = 0; i < 80_000_000; i++) {}
		} while (mysql_unprocessed_queries() > 0)
		print "done"
	}
fuckit:
	mysql_close()
	return 1
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
##section OnPlayerStateChange
###include "panel"
###include "vehicles"
##endsection
    return 1
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
##section OnDialogResponse
###include "anticheat"
###include "dialog"
##endsection

##section OnDialogResponseCase
	switch (dialogid) {
	case DIALOG_DUMMY: return 1
###include "login"
###include "airport"
	}
##endsection
	return 0
}

public OnVehicleSpawn(vehicleid)
{
##section OnVehicleSpawn
###include "nav"
##endsection
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
##section OnVehicleStreamIn
###include "vehicles"
##endsection
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
##section OnVehicleStreamOut
###include "vehicles"
##endsection
}

public OnObjectMoved(objectid)
{
##section OnObjectMoved
##endsection
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	printf "query err %d - %s - %s - %s", errorid, error, callback, query
}

#include "anticheat"
#include "playername" // try to keep this top-ish (for onPlayerNameChange section)
#include "timecyc" // also try to keep this top-ish (because 1s 30s loop hooks)
#include "panel"
#include "nav"
#include "dialog"
#include "login"
#include "game_sa"
#include "playtime"
#include "objects"
#include "pm"
#include "spawn"
#include "tracker"
#include "airport"
#include "vehicles"
#include "zones"

