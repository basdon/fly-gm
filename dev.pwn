
// vim: set filetype=c ts=8 noexpandtab:

#ifdef PROD
#endinput
#endif

#namespace "dev"

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
		GetVehicleHealth(GetPlayerVehicleID(playerid), res)
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
	case -1399044829: if (Command_Is(cmdtext, "/jetpack", idx)) {
		SetPlayerSpecialAction playerid, SPECIAL_ACTION_USEJETPACK
		#return 1
	}
	case 46697485: if (Command_Is(cmdtext, "/kill", idx)) {
		SetPlayerHealth playerid, 0.0
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
	case 1926344525: if (Command_Is(cmdtext, "/kickme", idx)) {
		SendClientMessage playerid, -1, "you're kicked, bye"
		KickDelayed playerid
		#return 1
	}
	case 1333092464: if (Command_Is(cmdtext, "/crashme", idx)) {
		GameTextForPlayer playerid, "Wasted~~k~SWITCH_DEBUG_CAM_ON~~k~~TOGGLE_DPAD~~k~~NETWORK_TALK~~k~~SHOW_MOUSE_POINTER_TOGGLE~", 5, 5
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

