
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
#define WARNMSGPB144(%0) strunpack(buf144, !WARN%0);SendClientMessage(playerid, COL_WARN, buf144)

// public symbols
#define PUB_LOOP25 ba // basdon
#define PUB_LOGIN_USERCHECK_CB la // login
#define PUB_LOGIN_REGISTER_CB lb // login
#define PUB_LOGIN_PWVERIFY_CB lc // login
#define PUB_LOGIN_CREATE_GUEST_SES ld // login
#define PUB_LOGIN_GUESTREGISTERUSERCHECK_CB le // login
#define PUB_LOGIN_GUESTREGISTER_CB lf // login
#define PUB_LOGIN_CHANGEPASS_CHECK_CB lg // login
#define PUB_LOGIN_CHANGEPASS_CHANGE_CB lh // login
#define PUB_LOGIN_LOADACCOUNT_CB li // login
#define PUB_LOGIN_CREATEGAMESESSION_CB lj // login
#define PUB_LOGIN_GUESTREGISTER_HASHPW_CB lk // login
#define PUB_LOGIN_CHANGEPASS_HASHPW_CB ll // login
#define PUB_LOGIN_CREATE_GUEST_USR lm // login
#define PUB_LOGIN_REGISTER_HASHPW_CB ln // login
#define PUB_LOGIN_CREATE_NEWUSER_SES lo // login
#define PUB_TIMECYC_NEXTWEATHER ta // timcyc
#define PUB_MISSION_CREATE ma // missions
#define PUB_MISSION_LOADTIMER mb // missions
#define PUB_MISSION_UNLOADTIMER mc // missions

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
new emptystring[] = ""

#define SetPlayerPos SetPlayerPosHook

##section varinit
###include "anticheat"
###include "dev"
###include "dialog"
###include "game_sa"
###include "heartbeat"
###include "login"
###include "missions"
###include "objects"
###include "panel"
###include "playername"
###include "playtime"
###include "pm"
###include "prefs"
###include "protips"
###include "spawn"
###include "timecyc"
###include "tracker"
###include "vehicles"
###include "zones"
##endsection

main()
{
	// beware: sometimes main() gets called after OnGameModeInit
	print "  Loaded gamemode basdon-fly "#VERSION"\n"
##section init
##endsection
	SetTimer #PUB_LOOP25, 25, .repeating=1
}

//@summary Function that should never be called, does dummy calls to natives to make {@code SYSREQ.C} happy
export dummies()
{
	new Float:f
	ChangeVehicleColor 0, 0, 0
	CreateVehicle 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0
	CreatePlayerObject 0, 0, f, f, f, f, f, f, f
	DestroyPlayerObject 0, 0
	DisablePlayerRaceCheckpoint 0
	GetPlayerPos 0, f, f, f
	GetPlayerVehicleID 0
	GetVehiclePos 0, f, f, f
	GetVehicleZAngle 0, f
	RemoveBuildingForPlayer 0, 0, f, f, f, f
	SendClientMessage 0, 0, buf144
	SendClientMessageToAll 0, buf144
	SetPlayerRaceCheckpoint 0, 0, f, f, f, f, f, f, f
	SetVehicleToRespawn 0
	Veh_UpdateSlot 0, 0
	cache_delete Cache:0
	cache_get_row 0, 0, buf4096
	cache_get_row_count 0
	cache_get_row_int 0, 0
	cache_get_row_float 0, 0
	mysql_query 0, buf4096, bool:1
	mysql_tquery 0, buf4096, buf4096, buf4096
	//mysql_tquery 0, buf4096
	random(0)
}

//@summary Basic loop that handles (almost) all timed stuff.
export __SHORTNAMED PUB_LOOP25()
{
	static lastinvoctime = 0
	static invoc = 0
	B_Timer25
##section loop25
##endsection
	invoc = (++invoc & 0x3)
	if (!invoc) {
##section loop100
###include "anticheat"
###include "panel"
###include "playtime"
###include "timecyc"
##endsection
		invoc = 0
	}
	new _tc = tickcount()
	if (_tc - lastinvoctime > 4984) {
		// this should be 4985-5010(+5)
		// 1s,30s,1m loop is inside timecyc
##section loop5000
###include "anticheat"
###include "dialog"
###include "objects"
###include "vehicles"
##endsection
		lastinvoctime = _tc
	}
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
###include "airport"
###include "login"
###include "prefs"
	}
##endsection
	return 0
}

public OnGameModeInit()
{
	if (!B_Validate(MAX_PLAYERS, buf4096, buf144, buf64, buf32, buf32_1, emptystring)) {
		SendRconCommand "exit"
		return 1
	}

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

	B_OnGameModeInit

##section OnGameModeInit
###include "airport"
###include "heartbeat"
###include "missions" // 'airport' must be run somewhere before this
###include "objects"
###include "panel"
###include "spawn"
###include "timecyc"
###include "tracker"
###include "vehicles"
##endsection

	return 1;
}

public OnGameModeExit()
{
##section OnGameModeExit
###include "airport"
###include "heartbeat"
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

public OnObjectMoved(objectid)
{
##section OnObjectMoved
##endsection
}

public OnPlayerCommandText(playerid, cmdtext[])
{
##section OnPlayerCommandText
###include "login" // login needs to be first! (to block if not logged)
###include "spawn" // block if not spawned
###include "dev"
##endsection

	new uid = userid[playerid]
	if (uid == -1) {
		mysql_format 1, buf4096, sizeof(buf4096), "INSERT INTO cmdlog(loggedstatus,cmd) VALUES(%d,'%e')", loggedstatus[playerid], cmdtext
	} else {
		mysql_format 1, buf4096, sizeof(buf4096), "INSERT INTO cmdlog(player,loggedstatus,cmd) VALUES(%d,%d,'%e')", uid, loggedstatus[playerid], cmdtext
	}
	mysql_tquery 1, buf4096

	return B_OnPlayerCommandText(playerid, cmdtext)
}

//@summary Called from plugin after {@link OnPlayerCommandText} and processing plugin commands
//@param hash hash of the command
export OnPlayerCommandTextHash(playerid, hash, cmdtext[])
{
	new idx
	switch (hash) {
	case 159897060: if (Command_Is(cmdtext, "/helpkeys", idx)) {
		GameTextForPlayer playerid, "~w~start/stop engine: ~b~~k~~CONVERSATION_NO~~n~~w~landing gear: ~b~~k~~TOGGLE_SUBMISSIONS~", 5000, 3
		return 1
	}
	case -1408243412: if (Command_Is(cmdtext, "/tickrate", idx)) {
		format(buf144, sizeof(buf144), "%d", GetServerTickRate())
		SendClientMessage playerid, -1, buf144
		return 1
	}
##section OnPlayerCommandTextCase
###include "airport"
###include "login"
###include "missions"
###include "nav"
###include "pm"
###include "prefs"
###include "protips"
###include "timecyc"
###include "zones"
###include "vehicles"
###include "dev" // keep this last (it has the default case)
##endsection
	}

	return 0
}

public OnPlayerConnect(playerid)
{
	DisablePlayerCheckpoint(playerid)
	DisablePlayerRaceCheckpoint(playerid)

	iter_add(allplayers, playerid)

#ifndef PROD
	SendClientMessage playerid, COL_WARN, "GM: DEVELOPMENT BUILD"
#endif

	B_OnPlayerConnect playerid

##section OnPlayerConnect
###include "dialog" // keep this first
###include "playername" // keep this second (sets data: name, ip, ..)
###include "anticheat"
###include "login"
###include "missions"
###include "objects"
###include "panel"
###include "playtime"
###include "pm"
###include "prefs"
###include "spawn"
###include "timecyc"
###include "vehicles"
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
###include "missions"
###include "spawn"
###include "timecyc"
###include "zones"
##endsection

	return 1
}

public OnPlayerDisconnect(playerid, reason)
{
	B_OnPlayerDisconnect playerid, reason

##section OnPlayerDisconnect
###include "airport"
###include "anticheat"
###include "dialog"
###include "missions"
###include "panel"
###include "playtime"
###include "spawn"
###include "vehicles"
###include "login" // keep this last-ish (clears logged in status)
###include "playername" // keep this last-ish (clears data)
###include "pm"
##endsection
	iter_remove(players, playerid)
	iter_remove(allplayers, playerid)

	return 1
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
##section OnPlayerEnterRaceCP
###include "missions"
##endsection
	return 1
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
##section OnPlayerEnterVehicle
###include "anticheat"
###include "vehicles"
##endsection
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
##section OnPlayerKeyStateChange
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

//@summary Called when a player goes afk
//@param playerid the playerid that went afk
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@seealso onPlayerWasAfk
//@seealso isAfk
onPlayerNowAfk(playerid)
{
##section onPlayerNowAfk
###include "panel"
###include "playtime"
##endsection
}

public OnPlayerRequestClass(playerid, classid)
{
##section OnPlayerRequestClass
###include "spawn"
###include "timecyc"
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

public OnPlayerStateChange(playerid, newstate, oldstate)
{
##section OnPlayerStateChange
###include "panel"
###include "vehicles"
##endsection
    return 1
}

public OnPlayerText(playerid, text[])
{
##section OnPlayerText
###include "login" // login needs to be first! (to block if not logged)
###include "anticheat"
##endsection
	return 1
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

//@summary Gets called when a player comes back from being afk
//@param playerid the playerid that is now back
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@seealso onPlayerNowAfk
//@seealso isAfk
onPlayerWasAfk(playerid)
{
##section onPlayerWasAfk
###include "panel"
###include "playtime"
###include "timecyc"
##endsection
}

public OnVehicleSpawn(vehicleid)
{
	B_OnVehicleSpawn vehicleid
##section OnVehicleSpawn
###include "vehicles"
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

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	printf "query err %d - %s - %s - %s", errorid, error, callback, query
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
###include "vehicles"
###include "zones"
##endsection
#undef SetPlayerPos
	SetPlayerPos playerid, x, y, z
#define SetPlayerPos SetPlayerPosHook
}

#include "anticheat"
#include "playername" // try to keep this top-ish (for onPlayerNameChange section)
#include "timecyc" // also try to keep this top-ish (because 1s 30s 1m loop hooks)
#include "airport"
#include "dev"
#include "dialog"
#include "game_sa"
#include "heartbeat"
#include "login"
#include "missions"
#include "playtime"
#include "protips"
#include "nav"
#include "objects"
#include "panel"
#include "pm"
#include "prefs"
#include "spawn"
#include "tracker"
#include "vehicles"
#include "zones"

