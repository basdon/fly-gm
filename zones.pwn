
// vim: set filetype=c ts=8 noexpandtab:

#namespace "zones"

varinit
{
	new PlayerText:zonetext[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	Zones_InvalidateForPlayer playerid

#define TDVAR zonetext[playerid]
	TDVAR = CreatePlayerTextDraw(playerid, 88.0, 320.0, TXT_EMPTY)
	PlayerTextDrawAlignment playerid, TDVAR, 2
	PlayerTextDrawFont playerid, TDVAR, 1
	PlayerTextDrawLetterSize playerid, TDVAR, 0.3, 1.0
	PlayerTextDrawColor playerid, TDVAR, -1
	PlayerTextDrawSetOutline playerid, TDVAR, 1
	PlayerTextDrawSetShadow playerid, TDVAR, 0
	PlayerTextDrawSetProportional playerid, TDVAR, 1
#undef TDVAR
}

hook OnPlayerSpawn(playerid)
{
	updatePlayerZone playerid
	PlayerTextDrawShow playerid, zonetext[playerid]
}

hook OnPlayerDeath(playerid)
{
	PlayerTextDrawHide playerid, zonetext[playerid]
}

hook onSetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	updatePlayerZoneEx playerid, x, y, z
}

hook loop1s()
{
	foreach (new playerid : players) {
		if (!isAfk(playerid)) {
			updatePlayerZone playerid
		}
	}
}

//@summary Checks if a player's zone changed an updates stuff accordingly
//@param playerid the playerid for which to update their zone
//@remarks Use {@link updatePlayerZoneEx} if the player's position is already known
//@seealso updatePlayerZoneEx
updatePlayerZone(playerid)
{
	new Float:x, Float:y, Float:z
	GetPlayerPos playerid, x, y, z
	updatePlayerZoneEx playerid, x, y, z
}

//@summary Checks if a player's zone changed an updates stuff accordingly
//@param playerid the playerid for which to update their zone
//@param x x position of player
//@param y y position of player
//@param z z position of player
//@seealso updatePlayerZoneEx
updatePlayerZoneEx(playerid, Float:x, Float:y, Float:z)
{
	if (Zones_UpdateForPlayer(playerid, x, y, z)) {
		Zones_FormatForPlayer playerid, buf4096
		PlayerTextDrawSetString playerid, zonetext[playerid], buf4096
	}
}

#printhookguards

