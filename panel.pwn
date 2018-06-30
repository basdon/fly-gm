
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
	new Iter:panelplayers[MAX_PLAYERS]

	stock const SPDMETERDATA[] = "160-~n~150-~n~140-~n~130-~n~120-~n~110-~n~100-~n~_90-~n~_80-~n~"\
	                             "_70-~n~_60-~n~_50-~n~_40-~n~_30-~n~_20-~n~_10-~n~___-~n~____~n~___"
}

hook LOOP100()
{
	for (new i : panelplayers) {
		new playerid = iter_access(panelplayers, i)
		new vid = GetPlayerVehicleID(playerid)
		new Float:vx, Float:vy, Float:vz
		GetVehiclePos vid, vx, vy, vz
		GetVehicleVelocity vid, vx, vy, vz

		// SPD
		vx = VEL_TO_KTS(VectorSize(vx, vy, vz))
		new txt[4]
		format txt, sizeof(txt), "%03.0f", vx
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD], txt

		// SPD METER
		new v = floatround(vx, floatround_tozero)
		if (v >= 0 && v < 150) {
			new metertxt[] = "xxx-~n~xxx-~n~~n~~n~~n~~n~xxx-~n~xxx-~n~"
			new offset = (14 - v / 10) * 7
			memcpy metertxt, SPDMETERDATA[offset], 0, 11 * 4, 11
			memcpy metertxt, SPDMETERDATA[offset + 14], 26 * 4, 37
			PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD_METER], metertxt
		}

		// SPD METER2
		new meter2txt[] = "0~n~~n~0"
		meter2txt[0] = '0' + ((v + 1) % 10)
		meter2txt[7] = '0' + ((v + 9) % 10)
		PlayerTextDrawSetString playerid, playerpnltxt[playerid][PNLTXT_SPD_METER2], meter2txt

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
#define TDVAR pnltxt[PNLTXT_BG]
	TDVAR = TextDrawCreate(320.0, 360.0, "~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.5, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 0x00000099);
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
	TextDrawBoxColor(TDVAR, 0x00000099);
	TextDrawTextSize(TDVAR, 476.0, 7.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_BG_SPD]
	TDVAR = TextDrawCreate(203.0, 383.0, "~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 0x00000099);
	TextDrawTextSize(TDVAR, 100.0, 35.0);
#undef TDVAR

#define TDVAR pnltxt[PNLTXT_BG_ALT]
	TDVAR = TextDrawCreate(436.0, 383.0, "~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawSetOutline(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 0x00000099);
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

hook ONPLAYERCONNECT(playerid)
{
#define TEXT_COLOR_METER2 0x989898FF

#define TDVAR playerpnltxt[playerid][PNLTXT_SPD_METER]
	TDVAR = CreatePlayerTextDraw(playerid, 220.0, 360.0, "220-~n~210-~n~~n~~n~~n~~n~200-~n~190-");
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.25, 1.0);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_SPD_METER2]
	TDVAR = CreatePlayerTextDraw(playerid, 217.0, 380.0, "7~n~~n~5");
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.3, 1.2);
	PlayerTextDrawColor(playerid, TDVAR, TEXT_COLOR_METER2);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_SPD]
	TDVAR = CreatePlayerTextDraw(playerid, 222.0, 389.0, "206");
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.4, 1.6);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_ALT_METER]
	TDVAR = CreatePlayerTextDraw(playerid, 453.0, 360.0, "100-~n~50-~n~~n~~n~~n~~n~0-~n~-50-");
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.25, 1.0);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_ALT_METER2]
	TDVAR = CreatePlayerTextDraw(playerid, 446.0, 380.0, "40~n~~n~20");
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.3, 1.2);
	PlayerTextDrawColor(playerid, TDVAR, TEXT_COLOR_METER2);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_ALT]
	TDVAR = CreatePlayerTextDraw(playerid, 458.0, 389.0, "031");
	PlayerTextDrawAlignment(playerid, TDVAR, 3);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.4, 1.6);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_HDG_METER]
	TDVAR = CreatePlayerTextDraw(playerid, 320.0, 423.0, "271_272_______274_275");
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.3, 1.2);
	PlayerTextDrawColor(playerid, TDVAR, TEXT_COLOR_METER2);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR

#define TDVAR playerpnltxt[playerid][PNLTXT_HDG]
	TDVAR = CreatePlayerTextDraw(playerid, 320.0, 420.0, "273");
	PlayerTextDrawAlignment(playerid, TDVAR, 2);
	PlayerTextDrawFont(playerid, TDVAR, 2);
	PlayerTextDrawLetterSize(playerid, TDVAR, 0.4, 1.6);
	PlayerTextDrawColor(playerid, TDVAR, 0xFFFFFFFF);
	PlayerTextDrawSetOutline(playerid, TDVAR, 0);
	PlayerTextDrawSetShadow(playerid, TDVAR, 0);
	PlayerTextDrawSetProportional(playerid, TDVAR, 0);
#undef TDVAR
}

