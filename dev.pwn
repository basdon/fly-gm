
// vim: set filetype=c ts=8 noexpandtab:

#ifdef PROD
#endinput
#endif

#namespace "dev"

varinit
{
	new dev_vehicle
}

hook OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp(cmdtext, "/vhpnan") == 0) {
		SetVehicleHealth(GetPlayerVehicleID(playerid), Float:0x7F800100);
		#return 1
	}
	if (strcmp(cmdtext, "/vhppinf") == 0) {
		SetVehicleHealth(GetPlayerVehicleID(playerid), FLOAT_PINF);
		#return 1
	}
	if (strcmp(cmdtext, "/vhpninf") == 0) {
		SetVehicleHealth(GetPlayerVehicleID(playerid), FLOAT_NINF);
		#return 1
	}
	if (strcmp(cmdtext, "/vehrespawn") == 0) {
		SetVehicleToRespawn(GetPlayerVehicleID(playerid))
		#return 1
	}
	if (strcmp(cmdtext, "/vhp") == 0) {
		new Float:res
#undef GetVehicleHealth
		GetVehicleHealth(GetPlayerVehicleID(playerid), res)
#define GetVehicleHealth GetVehicleHealth@@
		format buf144, sizeof(buf144), "hp %f", res
		SendClientMessage playerid, -1, buf144
		#return 1
	}
	if (strcmp(cmdtext, "/testpargm", bool:1, 10) == 0) {
		new i, idx
		if (!Command_Is(cmdtext, "/testpargm", idx)) {
			WARNMSG("wtf not /testpargm")
		}
		if (Command_GetIntParam(cmdtext, idx, i)) {
			format buf32, sizeof(buf32), "int %d", i
			SendClientMessage playerid, -1, buf32
		}
		if (Command_GetPlayerParam(cmdtext, idx, i)) {
			format buf32, sizeof(buf32), "player %d", i
			SendClientMessage playerid, -1, buf32
		}
		if (Command_GetStringParam(cmdtext, idx, buf144)) {
			format buf32, sizeof(buf32), "string -%s-", buf144
			SendClientMessage playerid, -1, buf32
		}
		if (Command_GetIntParam(cmdtext, idx, i)) {
			format buf32, sizeof(buf32), "int %d", i
			SendClientMessage playerid, -1, buf32
		}
		#return 1;
	}
}

hook OnPlayerCommandTextCase(playerid, hash, cmdtext[])
{
	case 46578: if (Command_Is(cmdtext, "/*m", idx)) {
		new m
		if (Command_GetIntParam(cmdtext, idx, m)) {
			if (m < 0) {
				money_takeFrom playerid, -m
			} else {
				money_giveTo playerid, m
			}
		}
		#return 1
	}
	case -1399044829: if (Command_Is(cmdtext, "/jetpack", idx)) {
		SetPlayerSpecialAction playerid, SPECIAL_ACTION_USEJETPACK
		#return 1
	}
	case 46697485: if (Command_Is(cmdtext, "/kill", idx)) {
		SetPlayerHealth playerid, 0.0
		#return 1
	}
	case -449545731: if (Command_Is(cmdtext, "/fweather", idx)) {
		new weatherid
		if (!Command_GetIntParam(cmdtext, idx, weatherid)) {
			#return WARNMSG("Syntax: /fweather <weatherid>")
		}
		lockedweather = upcomingweather = currentweather = weatherid // timecyc hack
		forceTimecycForPlayer playerid
		SendClientMessageToAll -1, "forced weather"
		#return 1
	}
	case -1820004817: if (Command_Is(cmdtext, "/tweather", idx)) {
		new weatherid
		if (!Command_GetIntParam(cmdtext, idx, weatherid)) {
			#return WARNMSG("Syntax: /tweather <weatherid>")
		}
		setWeather weatherid
		SendClientMessageToAll -1, "changing weather"
		#return 1
	}
	case 608035061: if (Command_Is(cmdtext, "/nweather", idx)) {
		PUB_TIMECYC_NEXTWEATHER
		#return 1
	}
	case 1455197760: if (Command_Is(cmdtext, "/sound", idx)) {
		new soundid
		if (!Command_GetIntParam(cmdtext, idx, soundid)) {
			#return WARNMSG("Syntax: /sound <soundid>")
		}
		PlayerPlaySound playerid, soundid, 0.0, 0.0, 0.0
		#return 1
	}
	case 1455934588: if (Command_Is(cmdtext, "/timex", idx)) {
		new h, m
		if (!Command_GetIntParam(cmdtext, idx, h) || !Command_GetIntParam(cmdtext, idx, m)) {
			#return WARNMSG("Syntax: /timex <h> <m>")
		}
		SetPlayerTime playerid, h, m
		#return 1
	}
	case 1926344525: if (Command_Is(cmdtext, "/kickme", idx)) {
		SendClientMessage playerid, -1, "you're kicked, bye"
		KickDelayed playerid
		#return 1
	}
	case 1333092464: if (Command_Is(cmdtext, "/crashme", idx)) {
		GameTextForPlayer playerid, "Wasted~~k~SWITCH_DEBUG_CAM_ON~~k~~TOGGLE_DPAD~~k~~NETWORK_TALK~~k~~SHOW_MOUSE_POINTER_TOGGLE~", 5, 5
		#return 1
	}
	case 1575: if (Command_Is(cmdtext, "/v", idx)) {
		new modelid
		if (!Command_GetIntParam(cmdtext, idx, modelid)) {
			WARNMSG("Syntax: /v <modelid>")
			#return 1
		}
		if (dev_vehicle != 0) {
			DestroyVehicleSafe dev_vehicle
		}
		new Float:x, Float:y, Float:z, Float:r
		GetPlayerPos playerid, x, y, z
		GetPlayerFacingAngle playerid, r
		dev_vehicle = CreateVehicle(modelid, x, y, z, r, 0, 0, -1)
		if (dev_vehicle == INVALID_VEHICLE_ID) {
			dev_vehicle = 0
		} else {
			PutPlayerInVehicleSafe playerid, dev_vehicle, .seatid=0
		}
		#return 1
	}
	case 48348: if (Command_Is(cmdtext, "/cp", idx)) {
		new Float:x, Float:y, Float:z
		new vid
		if ((vid = GetPlayerVehicleID(playerid))) {
			GetVehiclePos vid, x, y, z
		} else {
			GetPlayerPos playerid, x, y, z
		}
		SetPlayerRaceCheckpoint playerid, 2, x, y, z, 0.0, 0.0, 0.0, 8.0
		#return 1
	}
	case 48476: if (Command_Is(cmdtext, "/gt", idx)) {
		new style
		if (Command_GetStringParam(cmdtext, idx, buf32) && Command_GetIntParam(cmdtext, idx, style)) {
			GameTextForPlayer playerid, buf144, 4000, style
		}
		#return 1
	}
	default: printf "command '%s' hash: %d", cmdtext, hash
}

#printhookguards

