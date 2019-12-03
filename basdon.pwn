
// vim: set filetype=c ts=8 noexpandtab:

native printf(const format[], {Float,_}:...)
native B_Validate(
	buf4096[], buf144[], buf64[], buf32[], buf32_1[],
	emptystring[], underscorestring[])

#pragma tabsize 0 // it does not go well with some macros and preprocess

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

new buf4096[4096], buf144[144], buf64[64], buf32[32], buf32_1[32]
new emptystring[] = "", underscorestring[] = "_"

#define NATIVE_ENTRY ();native
forward __UNUSED
###include "natives"
()
#undef NATIVE_ENTRY

export dummies()
{
#define NATIVE_ENTRY
###include "natives"
}

main()
{
}

export OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
#emit STACK 0x8
#emit SYSREQ.C B_OnDialogResponse
#emit STACK 0xfffffff8
#emit RETN
}

export OnGameModeInit()
{
	B_Validate(
		buf4096, buf144, buf64, buf32, buf32_1,
		emptystring, underscorestring)
	return B_OnGameModeInit()
}

export OnGameModeExit()
{
#emit STACK 0x8
#emit SYSREQ.C B_OnGameModeExit
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerCommandText(playerid, cmdtext[])
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerCommandText
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerConnect(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerConnect
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerDeath(playerid, killerid, reason)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerDeath
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerDisconnect(playerid, reason)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerDisconnect
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerEnterRaceCheckpoint(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerEnterRaceCP
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerEnterVehicle
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerKeyStateChange
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerRequestClass(playerid, classid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerRequestClass
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerRequestSpawn(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerRequestSpawn
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerSpawn(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerSpawn
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerStateChange(playerid, newstate, oldstate)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerStateChange
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerText(playerid, text[])
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerText
#emit STACK 0xfffffff8
#emit RETN
}

export OnPlayerUpdate(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerUpdate
#emit STACK 0xfffffff8
#emit RETN
}

export OnVehicleSpawn(vehicleid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnVehicleSpawn
#emit STACK 0xfffffff8
#emit RETN
}

export OnVehicleStreamIn(vehicleid, forplayerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnVehicleStreamIn
#emit STACK 0xfffffff8
#emit RETN
}

export OnVehicleStreamOut(vehicleid, forplayerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnVehicleStreamOut
#emit STACK 0xfffffff8
#emit RETN
}

export SSocket_OnRecv(ssocket:handle, data[], len)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnRecv
#emit STACK 0xfffffff8
#emit RETN
}

export OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnQueryError
#emit STACK 0xfffffff8
#emit RETN
}

export MM(function, data)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnCallbackHit
#emit STACK 0xfffffff8
#emit RETN
}
