
// vim: set filetype=c ts=8 noexpandtab:

#include <a_samp>
#include <a_http>
#include <a_mysql_min>
#include <bcrypt>
#include <simplesocket>
#include "natives"

#pragma tabsize 0 // it does not go well with some macros and preprocess

#undef MAX_PLAYERS
#include "sharedsymbols"
#ifndef MAX_PLAYERS
#error "no MAX_PLAYERS"
#endif

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

#namespace "basdon"

new buf4096[4096], buf144[144], buf64[64], buf32[32], buf32_1[32]
new emptystring[] = "", underscorestring[] = "_"

//@summary Dummy function to fill the native table.
export dummies()
{
	new i, Float:f
	AddPlayerClass 0, f, f, f, f, 0, 0, 0, 0, 0, 0
	AddStaticVehicleEx 0, f, f, f, f, 0, 0, 0, 0
	ChangeVehicleColor 0, 0, 0
	ClearAnimations 0, 0
	CreateObject 0, f, f, f, f, f, f, f
	CreatePlayer3DTextLabel 0, buf144, 0, f, f, f, f
	CreatePlayerObject 0, 0, f, f, f, f, f, f, f
	CreatePlayerTextDraw 0, f, f, buf144
	CreateVehicle 0, f, f, f, f, 0, 0, 0, 0
	DeletePlayer3DTextLabel 0, PlayerText3D:0
	DestroyObject 0
	DestroyPlayerObject 0, 0
	DestroyVehicle 0
	DisablePlayerCheckpoint 0
	DisablePlayerRaceCheckpoint 0
	EnableStuntBonusForAll 0
	ForceClassSelection 0
	GameTextForPlayer 0, buf144, 0, 0
	GetConsoleVarAsInt buf144
	GetPlayerFacingAngle 0, f
	GetPlayerIp 0, buf144, 0
	GetPlayerKeys 0, i, i, i
	GetPlayerName 0, buf144, 0
	GetPlayerPing 0
	GetPlayerPos 0, f, f, f
	GetPlayerScore 0
	GetPlayerState 0
	GetPlayerVehicleID 0
	GetPlayerVehicleSeat 0
	GetServerTickRate
	GetVehicleDamageStatus 0, i, i, i, i
	GetVehicleHealth 0, f
	GetVehicleModel 0
	GetVehicleParamsEx 0, i, i, i, i, i, i, i
	GetVehiclePos 0, f, f, f
	GetVehicleRotationQuat 0, f, f, f, f
	GetVehicleVelocity 0, f, f, f
	GetVehicleZAngle 0, f
	GivePlayerMoney 0, 0
	GivePlayerWeapon 0, 0, 0
	IsValidVehicle 0
	IsVehicleStreamedIn 0, 0
	Kick 0
	MoveObject 0, f, f, f, f, f, f, f
	PlayerPlaySound 0, 0, f, f, f
	PlayerTextDrawAlignment 0, PlayerText:0, 0
	PlayerTextDrawBackgroundColor 0, PlayerText:0, 0
	PlayerTextDrawColor 0, PlayerText:0, 0
	PlayerTextDrawDestroy 0, PlayerText:0
	PlayerTextDrawFont 0, PlayerText:0, 0
	PlayerTextDrawHide 0, PlayerText:0
	PlayerTextDrawLetterSize 0, PlayerText:0, f, f
	PlayerTextDrawSetOutline 0, PlayerText:0, 1
	PlayerTextDrawSetProportional 0, PlayerText:0, 1
	PlayerTextDrawSetShadow 0, PlayerText:0, 0
	PlayerTextDrawSetString 0, PlayerText:0, buf144
	PlayerTextDrawShow 0, PlayerText:0
	PutPlayerInVehicle 0, 0, 0
	RemoveBuildingForPlayer 0, 0, f, f, f, f
	RemovePlayerMapIcon 0, 0
	RepairVehicle 0
	ResetPlayerMoney 0
	SHA256_PassHash buf144, buf144, buf144, 0
	SendClientMessage 0, 0, buf144
	SendClientMessageToAll 0, buf144
	SendRconCommand buf144
	SetGameModeText buf144
	SetCameraBehindPlayer 0
	SetPlayerCameraPos 0, f, f, f
	SetPlayerCameraLookAt 0, f, f, f
	SetPlayerColor 0, 0
	SetPlayerFacingAngle 0, f
	SetPlayerHealth 0, f
	SetPlayerMapIcon 0, 0, f, f, f, 0, 0, 0
	SetPlayerName 0, buf144
	SetPlayerPos 0, f, f, f
	SetPlayerRaceCheckpoint 0, 0, f, f, f, f, f, f, f
	SetPlayerScore 0, 0
	SetPlayerSpecialAction 0, 0
	SetPlayerTime 0, 0, 0
	SetPlayerWeather 0, 0
	SetSpawnInfo 0, 0, 0, f, f, f, f, 0, 0, 0, 0, 0, 0
	SetVehicleHealth 0, f
	SetVehicleParamsEx 0, 0, 0, 0, 0, 0, 0, 0
	SetVehicleToRespawn 0
	ShowPlayerDialog 0, 0, 0, buf144, buf144, buf144, buf144
	SpawnPlayer 0
	TextDrawAlignment Text:0, 0
	TextDrawBoxColor Text:0, 0
	TextDrawColor Text:0, 0
	TextDrawCreate f, f, buf144
	TextDrawFont Text:0, 0
	TextDrawHideForPlayer 0, Text:0
	TextDrawLetterSize Text:0, f, f
	TextDrawSetOutline Text:0, 0
	TextDrawSetProportional Text:0, 1
	TextDrawSetShadow Text:0, 0
	TextDrawShowForPlayer 0, Text:0
	TextDrawTextSize Text:0, f, f
	TextDrawUseBox Text:0, 1
	TogglePlayerClock 0, 0
	TogglePlayerControllable 0, 0
	TogglePlayerSpectating 0, 0
	UpdateVehicleDamageStatus 0, i, i, i, i
	UsePlayerPedAnims
	bcrypt_check buf144, buf144, buf144, buf144
	bcrypt_get_hash buf144
	bcrypt_hash buf144, 0, buf144, buf144
	bcrypt_is_equal
	cache_delete Cache:0
	cache_get_row 0, 0, buf4096
	cache_get_row_count 0
	cache_get_row_int 0, 0
	cache_get_row_float 0, 0
	cache_insert_id
	gettime
	mysql_connect buf144, buf144, buf144, buf144, 0, bool:0, 0
	mysql_close
	mysql_errno
	mysql_escape_string buf144, buf144, 1, 1000
	mysql_log LOG_ERROR | LOG_WARNING, LOG_TYPE_TEXT
	mysql_query 0, buf4096, bool:1
	mysql_tquery 0, buf4096, buf4096, buf4096
	mysql_unprocessed_queries
	random 0
	ssocket_connect ssocket:0, buf144, 0
	ssocket_create
	ssocket_destroy ssocket:0
	ssocket_listen ssocket:0, 0
	ssocket_send ssocket:0, buf144, 0
	tickcount
}

main()
{
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return B_OnDialogResponse(
		playerid, dialogid, response, listitem, inputtext)
}

public OnGameModeInit()
{
	B_Validate(
		MAX_PLAYERS, buf4096, buf144, buf64, buf32, buf32_1,
		emptystring, underscorestring)
	return B_OnGameModeInit()
}

public OnGameModeExit()
{
	return B_OnGameModeExit()
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return B_OnPlayerCommandText(playerid, cmdtext)
}

public OnPlayerConnect(playerid)
{
#ifndef PROD
	// Keep this. There are currently no code effects of PROD,
	// but it does influence compiler flags.
	SendClientMessage playerid, 0xe84c3dff, "GM: DEVELOPMENT BUILD"
#endif
	return B_OnPlayerConnect(playerid)
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return B_OnPlayerDeath(playerid, killerid, reason)
}

public OnPlayerDisconnect(playerid, reason)
{
	return B_OnPlayerDisconnect(playerid, reason)
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return B_OnPlayerEnterRaceCP(playerid)
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	B_OnPlayerEnterVehicle playerid, vehicleid, ispassenger
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	B_OnPlayerKeyStateChange playerid, oldkeys, newkeys
}

public OnPlayerRequestClass(playerid, classid)
{
	return B_OnPlayerRequestClass(playerid, classid)
}

public OnPlayerRequestSpawn(playerid)
{
	return B_OnPlayerRequestSpawn(playerid)
}

public OnPlayerSpawn(playerid)
{
	return B_OnPlayerSpawn(playerid)
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return B_OnPlayerStateChange(playerid, newstate, oldstate)
}

public OnPlayerText(playerid, text[])
{
	return B_OnPlayerText(playerid, text)
}

public OnPlayerUpdate(playerid)
{
	return B_OnPlayerUpdate(playerid)
}

public OnVehicleSpawn(vehicleid)
{
	B_OnVehicleSpawn vehicleid
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	B_OnVehicleStreamIn vehicleid, forplayerid
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	B_OnVehicleStreamOut vehicleid, forplayerid
}

public SSocket_OnRecv(ssocket:handle, data[], len)
{
	B_OnRecv handle, data, len
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	printf "query err %d - %s - %s - %s", errorid, error, callback, query
}

export MM(function, data)
{
	B_OnCallbackHit function, data
}

