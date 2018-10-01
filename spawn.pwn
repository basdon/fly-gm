
// vim: set filetype=c ts=8 noexpandtab:

#namespace "spawn"

// 0.2 vinewood rulez
#define VINEWOOD_CAMERA_PS 1496.7052, -883.7934, 59.9061
#define VINEWOOD_CAMERA_AT 1395.9752, -787.6342, 82.1637

#define SPAWN_ORDER_VER 1
#define CLASS_PILOT 0
#define CLASS_TRUCKER 1
#define CLASS_RESCUE 2
#define CLASS_ARMY 3
#define CLASS_AID 4

varinit
{
	#define isSpawned(%0) spawned[%0]
	new spawned[MAX_PLAYERS]
	#define getPlayerClass(%0) playerclass[%0]
	new playerclass[MAX_PLAYERS]
}

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

hook OnPlayerDisconnect(playerid)
{
	spawned[playerid] = 0
}

hook OnPlayerConnect(playerid)
{
	SetPlayerColor playerid, 0x888888ff
	SetPlayerPos playerid, 1415.386, -807.9211, 85.0615
	// since this does not work on first invocation, 'preload' the animation here before request class
	SetPlayerSpecialAction playerid, SPECIAL_ACTION_DANCE1
	// OnPlayerRequestClass seems to not be called when player
	// is connected and alt-tabbed during gmx, should we really need this?...
	SetPlayerCameraPos playerid, VINEWOOD_CAMERA_PS
	SetPlayerCameraLookAt playerid, VINEWOOD_CAMERA_AT
}

hook OnPlayerRequestClass(playerid, classid)
{
	// cannot block changing class, so save it
	playerclass[playerid] = classid

	// is also called upon connecting, but then player is not
	// logged in yet, so don't show if that's the case
	if (isPlaying(playerid)) {
		OnPlayerRequestClassImpl playerid, classid
	}
}

hook OnPlayerRequestSpawn(playerid)
{
	if (playerclass[playerid] == CLASS_TRUCKER) {
		SendClientMessage playerid, COL_WARN, WARN"Trucker class is not available yet."
		#return 0
	}
	hideGameTextForPlayer(playerid)
	#allowreturn
	return 1
}

hook OnPlayerSpawn(playerid)
{
	spawned[playerid] = 1
	SetPlayerPos playerid, 1477.4471, 1244.7747, 10.8281
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	spawned[playerid] = 0
}

//@summary Class names, used for class selection
#assert SPAWN_ORDER_VER == 1
stock const SPAWN_CLASSNAMES[] = "~p~Pilot\0~y~Trucker\0~b~~h~~h~Rescue worker\0~g~~h~Army\0~r~~h~~h~Aid worker"
//@summary Class name offset for each class
//@seealso SPAWN_CLASSNAMES
stock const SPAWN_POSITIONS[] = { 0, 9, 20, 43, 54 };
//@summary Array with colors for each class
stock const CLASS_COLORS[] = {
	0xa86efcff,
	0xe2c063ff,
	0x7087ffff,
	0x519c42ff,
	0xff3740ff,
};

//@summary Class selection, sets camera, dance moves, shows class name
//@param playerid Player to show class selection for
//@param classid Class id to show (optional={@code -1})
//@remarks if {@param classid} is {@code -1}, the last know classid will be used
OnPlayerRequestClassImpl(playerid, classid = -1)
{
	if (classid == -1) {
		classid = playerclass[playerid]
	}

	SetPlayerCameraPos playerid, VINEWOOD_CAMERA_PS
	SetPlayerCameraLookAt playerid, VINEWOOD_CAMERA_AT
	SetPlayerPos playerid, 1486.2727, -874.0833, 58.8885
	SetPlayerFacingAngle playerid, 236.0
	SetPlayerSpecialAction playerid, SPECIAL_ACTION_DANCE1
	#assert SPAWN_ORDER_VER == 1
	GameTextForPlayer playerid, SPAWN_CLASSNAMES[SPAWN_POSITIONS[classid]], 0x800000, 3
	SetPlayerColor playerid, CLASS_COLORS[classid]
}

#printhookguards

