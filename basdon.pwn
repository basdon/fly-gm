
// vim: set filetype=c ts=8 noexpandtab:

// stack/heap size:
// - compiler report says estimated max is 16 cells
// - that does not include heap space needed for vararg calls
// - might not include heap space needed for pass-by-reference parameters
// - on top of that, samp/plugins might push strings, which need heapspace...
// TODO: lower this again (to 512?) when ssocket is added into the plugin
#pragma dynamic 8192

#define export%0\32%1(%2) forward %1(%2);public %1(%2)

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
#emit RETN
}

export OnGameModeInit()
{
#emit STACK 0x8
#emit SYSREQ.C B_OnGameModeInit
#emit STACK 0xfffffff8
#emit RETN
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
