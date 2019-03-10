
// vim: set filetype=c ts=8 noexpandtab:

#ifdef PROD
#endinput
#endif

#namespace "dev"

varinit
{
	new dev_vehicle
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1575: if (Command_Is(cmdtext, "/v", idx)) {
		new modelid
		if (!Command_GetIntParam(cmdtext, idx, modelid)) {
			WARNMSG("Syntax: /v <modelid>")
			#return 1
		}
		printf "value %d", modelid
		if (dev_vehicle != 0) {
			DestroyVehicle dev_vehicle
		}
		new Float:x, Float:y, Float:z
		new Float:r
		GetPlayerPos playerid, x, y, z
		GetPlayerFacingAngle playerid, r
		dev_vehicle = CreateVehicle(modelid, x, y, z, r, 0, 0, -1)
		if (dev_vehicle == INVALID_VEHICLE_ID) {
			dev_vehicle = 0
		} else {
			PutPlayerInVehicle playerid, dev_vehicle, .seatid=0
		}
		#return 1
	}
}

#printhookguards

