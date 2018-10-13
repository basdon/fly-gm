
// vim: set filetype=c ts=8 noexpandtab:

#namespace "panel"

// see sharedsymbols.h / sharedsymbols.pwn
#define VEL_TO_KTS(%0) (VEL_TO_KTS_VAL*%0)
#define VEL_TO_KFPMA(%0) (VEL_TO_KFPMA_VAL*%0)

#define PNLTXT_BG 0
#define PNLTXT_VAI_METER 1
#define PNLTXT_BG_SPD 2
#define PNLTXT_BG_ALT 3
#define PNLTXT_ADF 4
#define PNLTXT_G_TOTAL 5

// METER = overview meters (SPD, ALT, HDG)
// METER2 = extra small (SPD & ALT) meters
#define PNLTXT_SPD_METER 0
#define PNLTXT_SPD_METER2 1
#define PNLTXT_SPD 2
#define PNLTXT_ALT_METER 3
#define PNLTXT_ALT_METER2 4
#define PNLTXT_ALT 5
#define PNLTXT_HDG_METER 6
#define PNLTXT_HDG 7
#define PNLTXT_P_TOTAL 8

varinit
{
	new Text:pnltxt[PNLTXT_G_TOTAL]
	new PlayerText:playerpnltxt[MAX_PLAYERS][PNLTXT_P_TOTAL]
	new PlayerText:pnltxtvai[MAX_PLAYERS]
	new Iter:panelplayers[MAX_PLAYERS]
}

hook loop100()
{
	static buf4[5] // value (spd, alt)
	static buf13[14] // small meter (spd, alt)
	static buf44[45] // large meter (spd, alt)

	for (new _i : panelplayers) {
		new playerid = iter_access(panelplayers, _i)

		new vid = GetPlayerVehicleID(playerid)
		new Float:vx, Float:vy, Float:vz

		// ALT
		GetVehiclePos vid, vx, vy, vz
		if (Panel_FormatAltitude(playerid, floatround(vz), buf4, buf13, buf44)) {
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ALT], buf4
			if (buf13[0]) {
				PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ALT_METER2], buf13
			}
			if (buf44[0]) {
				PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ALT_METER], buf44
			}
		}

		// SPD
		GetVehicleVelocity vid, vx, vy, vz
		vx = VEL_TO_KTS(VectorSize(vx, vy, vz))
		if (Panel_FormatSpeed(playerid, floatround(vx, floatround_tozero), buf4, buf13, buf44)) {
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD], buf4
			if (buf13[0]) {
				PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD_METER2], buf13
				if (buf44[0]) {
					PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD_METER], buf44
				}
			}
		}

		// VAI
		#assert VEL_VER == 2
		vz = clamp(floatround(/*VEL_TO_KFPMA*14.5*/81.64485 * vz), -34, 34)
		#define TDVAR tmp
		new PlayerText:TDVAR = pnltxtvai[playerid]
		PlayerTextDrawDestroy(playerid, TDVAR)
		TDVAR = CreatePlayerTextDraw(playerid, 458.0, 391.0 - vz, "~<~")
		PlayerTextDrawAlignment(playerid, TDVAR, 2)
		PlayerTextDrawFont(playerid, TDVAR, 2)
		PlayerTextDrawLetterSize(playerid, TDVAR, 0.25, 1.1)
		PlayerTextDrawColor(playerid, TDVAR, 0xFF0000FF)
		PlayerTextDrawSetOutline(playerid, TDVAR, 0)
		PlayerTextDrawSetShadow(playerid, TDVAR, 0)
		PlayerTextDrawShow(playerid, TDVAR)
		#undef TDVAR

		// HDG
		GetVehicleZAngle(vid, vz)
		if (Panel_FormatHeading(playerid, floatround(vz), buf4, buf44)) {
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HDG], buf4
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HDG_METER], buf44
		}
	}
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER && isInAirVehicle(playerid)) {
		pnltxtvai[playerid] = CreatePlayerTextDraw(playerid, -10.0, -10.0, "_")
		for (new i = 0; i < sizeof(pnltxt); i++) TextDrawShowForPlayer playerid, pnltxt[i]
		for (new i = 0; i < sizeof(playerpnltxt[]); i++) PlayerTextDrawShow playerid, playerpnltxt[playerid][i]
		iter_add(panelplayers, playerid)
	} else if (oldstate == PLAYER_STATE_DRIVER) {
		for (new i = 0; i < sizeof(pnltxt); i++) TextDrawHideForPlayer playerid, pnltxt[i]
		for (new i = 0; i < sizeof(playerpnltxt[]); i++) PlayerTextDrawHide playerid, playerpnltxt[playerid][i]
		iter_remove(panelplayers, playerid)
		PlayerTextDrawDestroy(playerid, pnltxtvai[playerid])
	}
}

hook onPlayerNowAfk(playerid)
{
	iter_remove(panelplayers, playerid)
}

hook onPlayerWasAfk(playerid)
{
	if (isInAirVehicle(playerid)) {
		iter_add(panelplayers, playerid)
	}
}

hook OnPlayerDisconnect(playerid)
{
	iter_remove(panelplayers, playerid)
}

hook OnPlayerConnect(playerid)
{
	Panel_ResetCaches playerid

#define METER_COLOR 0x989898FF
#define METER2_COLOR 0x585858FF

#define TDVAR playerpnltxt[playerid][PNLTXT_SPD_METER]
	TDVAR = CreatePlayerTextDraw(playerid, 220.0, 360.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.25, 1.0);
	PlayerTextDrawColor(playerid, TDVAR, METER_COLOR);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_SPD_METER2]
	TDVAR = CreatePlayerTextDraw(playerid, 217.0, 380.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.3, 1.2);
	PlayerTextDrawColor(playerid, TDVAR, METER2_COLOR);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_SPD]
	TDVAR = CreatePlayerTextDraw(playerid, 222.0, 389.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.4, 1.6);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_ALT_METER]
	TDVAR = CreatePlayerTextDraw(playerid, 453.0, 360.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.25, 1.0);
	PlayerTextDrawColor(playerid, TDVAR, METER_COLOR);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_ALT_METER2]
	TDVAR = CreatePlayerTextDraw(playerid, 442.0, 380.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.3, 1.2);
	PlayerTextDrawColor(playerid, TDVAR, METER2_COLOR);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_ALT]
	TDVAR = CreatePlayerTextDraw(playerid, 455.0, 389.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.4, 1.6);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_HDG_METER]
	TDVAR = CreatePlayerTextDraw(playerid, 320.0, 423.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.22, 1.0);
	PlayerTextDrawColor(playerid, TDVAR, METER_COLOR);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_HDG]
	TDVAR = CreatePlayerTextDraw(playerid, 320.0, 420.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.4, 1.6);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR
}

hook OnGameModeInit()
{
#define PANEL_BG 0x00000077
#define METER2_BG 0x00000077

#define TDVAR pnltxt[PNLTXT_BG]
	TDVAR = TextDrawCreate(320.0, 360.0, "~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.5, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, PANEL_BG);
	TextDrawTextSize(TDVAR, 100.0, 271.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_VAI_METER]
	TDVAR = TextDrawCreate(461.0, 364.0, "-2~n~-_~n~-1~n~-_~n~-0~n~-_~n~-1~n~-_~n~-2");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.2, 0.8);
	TextDrawColor(TDVAR, 0xFFFFFFFF);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);
	TextDrawSetProportional(TDVAR, 1);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, PANEL_BG);
	TextDrawTextSize(TDVAR, 476.0, 7.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_BG_SPD]
	TDVAR = TextDrawCreate(203.0, 383.0, "~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, METER2_BG);
	TextDrawTextSize(TDVAR, 100.0, 35.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_BG_ALT]
	TDVAR = TextDrawCreate(436.0, 383.0, "~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, METER2_BG);
	TextDrawTextSize(TDVAR, 100.0, 35.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_ADF]
	TDVAR = TextDrawCreate(320.0, 360.0, "DIS_________________ETA_________________CRS________");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.25, 1.0);
	TextDrawColor(TDVAR, 0xFFFFFFFF);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);
	TextDrawSetProportional(TDVAR, 1);
#undef TDVAR

}

#printhookguards

