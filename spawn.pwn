
// vim: set filetype=c ts=8 noexpandtab:

#namespace "spawn"

// 0.2 vinewood rulez
#define VINEWOOD_CAMERA_PS 1498.3066, -887.3567, 62.9459
#define VINEWOOD_CAMERA_AT 1395.9752, -787.6342, 82.1637

#define SPAWN_ORDER_VER 1

hook OnGameModeInit()
{
	#define AddPlayerClassNoWeapon(%1) AddPlayerClass(%1,0,0,0,0,0,0)

	#assert SPAWN_ORDER_VER == 1
	AddPlayerClassNoWeapon(61, 1488.5236, -873.1125, 59.3885, 232.0) // pilot
	AddPlayerClassNoWeapon(133, 1488.5236, -873.1125, 59.3885, 232.0) // trucker
	AddPlayerClassNoWeapon(275, 1488.5236, -873.1125, 59.3885, 232.0) // rescue worker
	AddPlayerClassNoWeapon(287, 1488.5236, -873.1125, 59.3885, 232.0) // army
	AddPlayerClassNoWeapon(287, 1488.5236, -873.1125, 59.3885, 232.0) // aid worker
}

hook OnPlayerConnect(playerid)
{
	SetPlayerPos playerid, 1415.386, -807.9211, 85.0615
	// OnPlayerRequestClass seems to not be called when player
	// is connected and alt-tabbed during gmx, should we really need this?...
	SetPlayerCameraPos playerid, VINEWOOD_CAMERA_PS
	SetPlayerCameraLookAt playerid, VINEWOOD_CAMERA_AT
}

hook OnPlayerRequestClass(playerid, classid)
{
	// is also called upon connecting, but then player is not
	// logged in yet, so don't show if that's the case
	if (isPlaying(playerid)) {
		OnPlayerRequestClassImpl playerid, classid
	}
}

hook OnPlayerRequestSpawn(playerid)
{
	// to hide the class name text
	GameTextForPlayer playerid, TXT_EMPTY_CONST, 5, 3

	#allowreturn
	return 1
}

//@summary Class names, used for class selection
#assert SPAWN_ORDER_VER == 1
stock const CLASSNAMES[] = "~p~Pilot\0~y~Trucker\0~b~~h~~h~Rescue worker\0~g~Army\0~r~~h~~h~Aid worker"

//@summary Class selection, sets camera, dance moves, shows class name
//@param playerid Player to show class selection for
//@param classid Class id to show (optional=0)
OnPlayerRequestClassImpl(playerid, classid = 0)
{
	SetPlayerCameraPos playerid, VINEWOOD_CAMERA_PS
	SetPlayerCameraLookAt playerid, VINEWOOD_CAMERA_AT
	SetPlayerPos playerid, 1478.8986, -867.5325, 57.5157
	SetPlayerFacingAngle playerid, 226.0
	SetPlayerSpecialAction playerid, SPECIAL_ACTION_DANCE1
	#assert SPAWN_ORDER_VER == 1
	new positions[] = { 0, 9, 20, 43, 51 };
	GameTextForPlayer playerid, CLASSNAMES[positions[classid]], 120000, 3
}

#printhookguards

