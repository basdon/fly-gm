
// vim: set filetype=c ts=8 noexpandtab:

#define VEL_TO_KPH(%0) (195.555*%0)
#define VEL_TO_KTS(%0) (96.77661*%0) // KPH / 293 * 145
#define VEL_TO_MPS(%0) (54.3297*%0) // (KPH / 3.6)
#define VEL_TO_KFPM(%0) (10.69482*%0) // K feet per minute (MPS * 3.28084 * 60 / 1000)
#define VEL_TO_KFPMA(%0) (6.11132*%0) // some adjustment (KFPM / 1.75)

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

hook VAR()
{
	new Text:pnltxt[PNLTXT_G_TOTAL]
	new PlayerText:playerpnltxt[MAX_PLAYERS][PNLTXT_P_TOTAL]
	new PlayerText:pnltxtvai[MAX_PLAYERS]
	new lastdatacache[MAX_PLAYERS]
	new headingcache[MAX_PLAYERS]
	new Iter:panelplayers[MAX_PLAYERS]

	stock const SPDMETERDATA[] = "160-~n~150-~n~140-~n~130-~n~120-~n~110-~n~100-~n~_90-~n~_80-~n~"\
	                             "_70-~n~_60-~n~_50-~n~_40-~n~_30-~n~_20-~n~_10-~n~___-~n~____~n~___"

	new PANEL_BGTEXT[] = "~n~~n~~n~"

	stock const _03DFORMAT[] = "%03d"
}

hook LOOP100()
{
	for (new _i : panelplayers) {
		new playerid = iter_access(panelplayers, _i)
		if (isAfk(playerid)) {
			continue
		}
		new vid = GetPlayerVehicleID(playerid)
		new Float:vx, Float:vy, Float:vz

		// ALT
		GetVehiclePos vid, vx, vy, vz
		new v = floatround(vz)
		if (((lastdatacache[playerid] & 0xFF0000) >> 16) == v) {
			goto skipalt
		}

		new txt[4]
		format txt, sizeof(txt), _03DFORMAT, v
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ALT], txt

		// ALT METER
		new t = v / 50
		if ((lastdatacache[playerid] & 0xFF000000) != (t << 24)) {
			lastdatacache[playerid] = (lastdatacache[playerid] & 0xFFFFFF) | (t << 24)
			new metertxt[] = "____-~n~____-~n~~n~~n~~n~~n~____-~n~____-~n~"
			for (new i = 0; i < 4; i++) {
				new value = t + 2 - i
				if (value < -18 || 19 < value) {
					continue
				}
				new pos = i * 8 + (i >> 1) * 12
				format metertxt[pos], 5, "%*d", (4 - ((value & 0x80000000) >>> 31)), (value * 50)
				metertxt[pos + 4] = '-'
			}
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ALT_METER], metertxt
		}

		// ALT METER2
		new altmetertxt[] = "_00~n~~n~_00"
		t = v + 10
		if (t < 0) t = -t, altmetertxt[0] = '-'
		altmetertxt[1] = '0' + (t / 10) % 10
		t = v - 10
		if (t < 0) t = -t, altmetertxt[9] = '-'
		altmetertxt[10] = '0' + (t / 10) % 10
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_ALT_METER2], altmetertxt

skipalt:
		GetVehicleVelocity vid, vx, vy, vz

		// SPD
		vx = VEL_TO_KTS(VectorSize(vx, vy, vz))
		v = floatround(vx, floatround_tozero)
		if ((lastdatacache[playerid] & 0xFF) == v) {
			goto skipspd
		}
		lastdatacache[playerid] = (lastdatacache[playerid] & 0xFFFFFF00) | v

		format txt, sizeof(txt), _03DFORMAT, v
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD], txt

		// SPD METER
		if (v < 0 || v > 149) {
			goto skipspd
		}

		new offset = (14 - v / 10) * 7
		if (((lastdatacache[playerid] & 0xFF00) >> 8) != offset) {
			assert offset < 256
			lastdatacache[playerid] = (lastdatacache[playerid] & 0xFFFF00FF) | (offset << 8)
			new metertxt[] = "xxx-~n~xxx-~n~~n~~n~~n~~n~xxx-~n~xxx-~n~"
			memcpy metertxt, SPDMETERDATA[offset], 0, 11 * 4, 11
			memcpy metertxt, SPDMETERDATA[offset + 14], 26 * 4, 37
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD_METER], metertxt
		}

		// SPD METER2
		new meter2txt[] = "0~n~~n~0"
		meter2txt[0] = '0' + ((v + 1) % 10)
		meter2txt[7] = '0' + ((v + 9) % 10)
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD_METER2], meter2txt

skipspd:
		// VAI
		vz = clamp(floatround(/*VEL_TO_KFPMA*14.5*/88.61422 * vz), -34, 34)
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
		new heading = floatround(vz)
		if (heading == 0) {
			heading = 360
		}
		if (heading == headingcache[playerid]) {
			continue
		}
		headingcache[playerid] = heading
		format txt, 4, "%03d", heading
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HDG], txt

		// HDG METER
		new hdgmeter[30] = { '_', ... }
		heading = heading % 360 + 1
		format hdgmeter[8], 4, _03DFORMAT, heading; heading = heading % 360 + 1
		format hdgmeter[4], 4, _03DFORMAT, heading; heading = heading % 360 + 1
		format hdgmeter[0], 4, _03DFORMAT, heading; heading = (heading + 355) % 360 + 1
		format hdgmeter[18], 4, _03DFORMAT, heading; heading = (heading + 358) % 360 + 1
		format hdgmeter[22], 4, _03DFORMAT, heading; heading = (heading + 358) % 360 + 1
		format hdgmeter[26], 4, _03DFORMAT, heading
		hdgmeter[3] = '_'
		hdgmeter[7] = '_'
		hdgmeter[11] = '_'
		hdgmeter[21] = '_'
		hdgmeter[25] = '_'
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_HDG_METER], hdgmeter

	}
}

hook ONPLAYERSTATECHANGE(playerid, newstate, oldstate)
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

hook ONGAMEMODEINIT()
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
	TDVAR = TextDrawCreate(203.0, 383.0, PANEL_BGTEXT);
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, METER2_BG);
	TextDrawTextSize(TDVAR, 100.0, 35.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_BG_ALT]
	TDVAR = TextDrawCreate(436.0, 383.0, PANEL_BGTEXT);
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

hook ONPLAYERDISCONNECT(playerid)
{
	iter_remove(panelplayers, playerid)
}

hook ONPLAYERCONNECT(playerid)
{
	lastdatacache[playerid] = 0xFFFFFFFF

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

