
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
#define PNLTXT_ADF_DIS 8
#define PNLTXT_ADF_ALT 9
#define PNLTXT_ADF_CRS 10
#define PNLTXT_HPFL 11
#define PNLTXT_P_TOTAL 12

varinit
{
	new Text:pnltxt[PNLTXT_G_TOTAL]
	new Text:vorbar
	new PlayerText:playerpnltxt[MAX_PLAYERS][PNLTXT_P_TOTAL]
	new PlayerText:pnltxtvai[MAX_PLAYERS]
	new PlayerText:pnltxtvor[MAX_PLAYERS]
	new Iter:panelplayers[MAX_PLAYERS]
#define isPanelActive(%0) (_:pnltxtvai[playerid] != -1)
}

hook loop100()
{
#define buf4 buf32
#define buf13 buf32_1
#define buf44 buf64
	for (new _i : panelplayers) {
		new playerid = iter_access(panelplayers, _i)

		new vid = GetPlayerVehicleID(playerid)
		new Float:vx, Float:vy, Float:vz, Float:heading

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

		// HDG
		GetVehicleZAngle(vid, heading)
		if (Panel_FormatHeading(playerid, floatround(heading), buf4, buf44)) {
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HDG], buf4
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HDG_METER], buf44
		}

		if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
			Nav_Update vid, vx, vy, vz, heading
		}

		if (Nav_Format(playerid, vid, buf32, buf32_1, buf64, buf144, vx)) {
			if (buf32[0]) {
				PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ADF_DIS], buf32
			}
			if (buf32_1[0]) {
				PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ADF_ALT], buf32_1
			}
			if (buf64[0]) {
				PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ADF_CRS], buf64
			}
			if (buf144[0]) {
				GameTextForPlayer playerid, buf144, 200, 6
			}
#define TDVAR pnltxtvor[playerid]
			if (_:TDVAR != -1) {
				PlayerTextDrawDestroy(playerid, TDVAR)
			}
			if (vx < 640.0) {
				new PlayerText:tmp_ = TDVAR = CreatePlayerTextDraw(playerid, vx, 407.0, "i")
				PlayerTextDrawAlignment(playerid, tmp_, 2)
				PlayerTextDrawFont(playerid, tmp_, 2)
				PlayerTextDrawLetterSize(playerid, tmp_, 0.4, 1.6)
				PlayerTextDrawColor(playerid, tmp_, 0xff00ffff)
				PlayerTextDrawSetOutline(playerid, tmp_, 0)
				PlayerTextDrawSetProportional(playerid, tmp_, 1)
				PlayerTextDrawSetShadow(playerid, tmp_, 0)
				PlayerTextDrawShow(playerid, tmp_)
			} else {
				TDVAR = PlayerText:-1;
			}
#undef TDVAR
		}

		// HP/FL
		new Float:hp
		GetVehicleHealthSafe playerid, vid, hp
		if (Veh_FormatPanelText(playerid, vid, hp, buf144)) {
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HPFL], buf144
		}

		// SPD
		GetVehicleVelocity vid, vx, vy, vz
		vx = VEL_TO_KTS(VectorSize(vx, vy, vz))
		// TODO move those ops to plugin? ^
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
	}
#undef buf4
#undef buf13
#undef buf44
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if ((newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && isInAirVehicle(playerid)) {
		pnltxtvai[playerid] = CreatePlayerTextDraw(playerid, -10.0, -10.0, "_")
		for (new i = 0; i < sizeof(pnltxt); i++) TextDrawShowForPlayer playerid, pnltxt[i]
		for (new i = 0; i < sizeof(playerpnltxt[]); i++) PlayerTextDrawShow playerid, playerpnltxt[playerid][i]
		iter_add(panelplayers, playerid)
		panel_resetNav playerid
		if (Nav_GetActiveNavType(GetPlayerVehicleID(playerid)) & (NAV_VOR | NAV_ILS)) {
			TextDrawShowForPlayer playerid, vorbar
		}
	} else if (isPanelActive(playerid)) {
		for (new i = 0; i < sizeof(pnltxt); i++) TextDrawHideForPlayer playerid, pnltxt[i]
		for (new i = 0; i < sizeof(playerpnltxt[]); i++) PlayerTextDrawHide playerid, playerpnltxt[playerid][i]
		TextDrawHideForPlayer playerid, vorbar
		iter_remove(panelplayers, playerid)
		PlayerTextDrawDestroy(playerid, pnltxtvai[playerid])
		pnltxtvai[playerid] = PlayerText:-1
		if (_:pnltxtvor[playerid] != -1) {
			PlayerTextDrawDestroy(playerid, pnltxtvor[playerid])
			pnltxtvor[playerid] = PlayerText:-1
		}
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
	pnltxtvai[playerid] = PlayerText:-1
	pnltxtvor[playerid] = PlayerText:-1

#define METER_COLOR 0x989898FF
#define METER2_COLOR 0x585858FF

	new PlayerText:tmp

	tmp = playerpnltxt[playerid][PNLTXT_SPD_METER] = CreatePlayerTextDraw(playerid, 220.0, 360.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 3);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.25, 1.0);
	PlayerTextDrawColor(playerid, tmp, METER_COLOR);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_SPD_METER2] = CreatePlayerTextDraw(playerid, 217.0, 380.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.3, 1.2);
	PlayerTextDrawColor(playerid, tmp, METER2_COLOR);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_SPD] = CreatePlayerTextDraw(playerid, 222.0, 389.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 3);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.4, 1.6);
	PlayerTextDrawColor(playerid, tmp, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_ALT_METER] = CreatePlayerTextDraw(playerid, 453.0, 360.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 3);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.25, 1.0);
	PlayerTextDrawColor(playerid, tmp, METER_COLOR);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_ALT_METER2] = CreatePlayerTextDraw(playerid, 442.0, 380.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.3, 1.2);
	PlayerTextDrawColor(playerid, tmp, METER2_COLOR);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_ALT] = CreatePlayerTextDraw(playerid, 455.0, 389.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 3);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.4, 1.6);
	PlayerTextDrawColor(playerid, tmp, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_HDG_METER] = CreatePlayerTextDraw(playerid, 320.0, 423.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.22, 1.0);
	PlayerTextDrawColor(playerid, tmp, METER_COLOR);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_HDG] = CreatePlayerTextDraw(playerid, 320.0, 420.0, TXT_EMPTY);
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.4, 1.6);
	PlayerTextDrawColor(playerid, tmp, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_ADF_DIS] = CreatePlayerTextDraw(playerid, 265.0, 360.0, "-");
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.25, 1.0);
	PlayerTextDrawColor(playerid, tmp, 0xff00ffff);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_ADF_ALT] = CreatePlayerTextDraw(playerid, 330.0, 360.0, "-");
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.25, 1.0);
	PlayerTextDrawColor(playerid, tmp, 0xff00ffff);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_ADF_CRS] = CreatePlayerTextDraw(playerid, 395.0, 360.0, "-");
	PlayerTextDrawAlignment(playerid, tmp, 2);
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.25, 1.0);
	PlayerTextDrawColor(playerid, tmp, 0xff00ffff);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);

	tmp = playerpnltxt[playerid][PNLTXT_HPFL] = CreatePlayerTextDraw(playerid, 227.0, 381.0, "HP ~g~1000/1000  ~w~FL ~g~10000/10000");
	PlayerTextDrawFont(playerid, tmp, 2);
	PlayerTextDrawLetterSize(playerid, tmp, 0.25, 1.0);
	PlayerTextDrawColor(playerid, tmp, 0xffffffff);
	PlayerTextDrawSetOutline(playerid, tmp, 0);
	PlayerTextDrawSetShadow(playerid, tmp, 0);
	PlayerTextDrawSetProportional(playerid, tmp, 0);

/*
	// ILS
	tmp = CreatePlayerTextDraw(playerid, 320.0, 100.0, "-")
	//"~w~X~n~~w~X~n~~w~X~n~~w~X~n~~w~X ~w~X ~w~X ~w~X ~w~X ~w~X ~w~X ~w~X ~w~X~n~~w~X~n~~w~X~n~~w~X~n~~w~X")
	PlayerTextDrawAlignment(playerid, tmp, 2)
	PlayerTextDrawBackgroundColor(playerid, tmp, 0x000000FF)
	PlayerTextDrawFont(playerid, playerid, tmp, 2)
	PlayerTextDrawLetterSize(playerid, tmp, 0.45, 2.5)
	PlayerTextDrawColor(playerid, tmp, -1)
	PlayerTextDrawSetOutline(playerid, tmp, 1)
	PlayerTextDrawSetProportional(playerid, tmp, 1)
*/
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
	TDVAR = TextDrawCreate(227.0, 360.0, "DIS_______________ALT_______________CRS");
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.25, 1.0);
	TextDrawColor(TDVAR, 0xFFFFFFFF);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);
	TextDrawSetProportional(TDVAR, 1);
#undef TDVAR

#define TDVAR vorbar
	TDVAR = TextDrawCreate(320.0, 410.0, "O_____O_____O_____-_____O_____O_____O")
	TextDrawFont(TDVAR, 1)
	TextDrawAlignment(TDVAR, 2)
	TextDrawLetterSize(TDVAR, 0.25, 1.0)
	TextDrawColor(TDVAR, 0xFFFFFFFF)
	TextDrawSetOutline(TDVAR, 0)
	TextDrawSetShadow(TDVAR, 0)
	TextDrawSetProportional(TDVAR, 1)
	TextDrawUseBox(TDVAR, 1)
	TextDrawBoxColor(TDVAR, 0x66)
	TextDrawTextSize(TDVAR, 0.0, 170.0)
#undef TDVAR
}

//@summary Resets nav indicators for a player
//@param playerid player to reset indicators for
panel_resetNav(playerid)
{
	if (isPanelActive(playerid)) {
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ADF_DIS], "-"
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ADF_ALT], "-"
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ADF_CRS], "-"
		if (_:pnltxtvor[playerid] != -1) {
			PlayerTextDrawDestroy playerid, pnltxtvor[playerid]
			pnltxtvor[playerid] = PlayerText:-1
		}
		TextDrawHideForPlayer playerid, vorbar
		Nav_ResetCache playerid
	}
}

//@summary Shows the VOR bar for passengers of given vehicle
//@param vehicleid vehicle of which all passengers' VOR bar should be shown
panel_showVorBarForPassengers(vehicleid)
{
	foreach (new playerid : players) {
		if (GetPlayerVehicleID(playerid) == vehicleid) {
			TextDrawShowForPlayer playerid, vorbar
		}
	}
}

//@summary Hides the VOR bar for passengers of given vehicle
//@param vehicleid vehicle of which all passengers' VOR bar should be hidden
panel_hideVorBarForPassengers(vehicleid)
{
	foreach (new playerid : players) {
		if (GetPlayerVehicleID(playerid) == vehicleid) {
			TextDrawHideForPlayer playerid, vorbar
		}
	}
}

//@summary Resets nav indicators for all players in given vehicle
//@param vehicleid vehicle of which all passengers' nav should reset
panel_resetNavForPassengers(vehicleid)
{
	foreach (new playerid : players) {
		if (GetPlayerVehicleID(playerid) == vehicleid) {
			panel_resetNav(playerid)
		}
	}
}

#printhookguards

