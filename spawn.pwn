
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
	TogglePlayerClock playerid, 0
	SetPlayerColor playerid, 0x888888ff
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
	TogglePlayerClock playerid, 1
	// TODO sync player time/weather here
	// TODO: toggleplayerclock 0 on death and 1 on spawn?

	#allowreturn
	return 1
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
//@param classid Class id to show (optional={@code 0})
OnPlayerRequestClassImpl(playerid, classid = 0)
{
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

