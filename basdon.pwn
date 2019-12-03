
// vim: set filetype=c ts=8 noexpandtab:

#pragma dynamic 128 // might be enough

native printf(const format[], {Float,_}:...)
native B_Validate(
	buf4096[], buf144[], buf64[], buf32[], buf32_1[],
	emptystring[], underscorestring[])

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

new buf4096[4096], buf144[144], buf64[64], buf32[32], buf32_1[32]
new emptystring[] = "", underscorestring[] = "_"

#define NATIVE_ENTRY ();native
forward __UNUSED
#include "natives"
#undef _inc_natives
()
#undef NATIVE_ENTRY

export dummies()
{
#define NATIVE_ENTRY
#include "natives"
#undef _inc_natives
}

main()
{
}

export OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
#emit STACK 0x8
#emit SYSREQ.C B_OnDialogResponse
#emit STACK 0xfffffff8
#emit RET
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
#emit RET
}

export OnPlayerCommandText(playerid, cmdtext[])
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerCommandText
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerConnect(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerConnect
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerDeath(playerid, killerid, reason)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerDeath
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerDisconnect(playerid, reason)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerDisconnect
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerEnterRaceCheckpoint(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerEnterRaceCP
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerEnterVehicle
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerKeyStateChange
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerRequestClass(playerid, classid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerRequestClass
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerRequestSpawn(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerRequestSpawn
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerSpawn(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerSpawn
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerStateChange(playerid, newstate, oldstate)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerStateChange
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerText(playerid, text[])
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerText
#emit STACK 0xfffffff8
#emit RET
}

export OnPlayerUpdate(playerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnPlayerUpdate
#emit STACK 0xfffffff8
#emit RET
}

export OnVehicleSpawn(vehicleid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnVehicleSpawn
#emit STACK 0xfffffff8
#emit RET
}

export OnVehicleStreamIn(vehicleid, forplayerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnVehicleStreamIn
#emit STACK 0xfffffff8
#emit RET
}

export OnVehicleStreamOut(vehicleid, forplayerid)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnVehicleStreamOut
#emit STACK 0xfffffff8
#emit RET
}

export SSocket_OnRecv(ssocket:handle, data[], len)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnRecv
#emit STACK 0xfffffff8
#emit RET
}

export OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnQueryError
#emit STACK 0xfffffff8
#emit RET
}

export MM(function, data)
{
#emit STACK 0x8
#emit SYSREQ.C B_OnCallbackHit
#emit STACK 0xfffffff8
#emit RET
}
