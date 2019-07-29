
// vim: set filetype=c ts=8 noexpandtab:

#namespace "veh"

varinit
{
	#define RESPAWN_DELAY 300 // in seconds
	#define FUEL_WARNING_SOUND 3200 // air horn

	new lastvehicle[MAX_PLAYERS]
	new vv[MAX_VEHICLES] // vehicle reincarnation value

	// for odo and stuff
	new Float:lastvehx[MAX_PLAYERS]
	new Float:lastvehy[MAX_PLAYERS]
	new Float:lastvehz[MAX_PLAYERS]
	new Float:playerodo[MAX_PLAYERS]
	// total flight time of user, multiple of 60s
	new flighttimeold[MAX_PLAYERS]
	// amount of seconds flight time of user that is not yet added to flighttimeold,
	//   to increase player's score when this reaches 60
	new flighttimenew[MAX_PLAYERS]
	new lastcontrolactivity[MAX_PLAYERS]
}

hook loop1splayers(playerid)
{
	new vid
	if (GetPlayerVehicleSeat(playerid) == 0 &&
		(vid = GetPlayerVehicleID(playerid)))
	{
		if (Game_IsAirVehicle(GetVehicleModel(vid)) && vid == lastvehicle[playerid]) {
			new Float:qw, Float:qx, Float:qy, Float:qz
			GetVehicleRotationQuat vid, qw, qx, qy, qz
			if (Missions_UpdateSatisfaction(playerid, vid, qw, qx, qy, qz, buf144)) {
				PlayerTextDrawSetString playerid, passenger_satisfaction[playerid], buf144
			}
			new engine
			GetVehicleParamsEx vid, engine, tmp1, tmp1, tmp1, tmp1, tmp1, tmp1
			if (engine && !isAfk(playerid)) {
				new _tmp
				GetPlayerKeys playerid, _tmp, tmp1, tmp1
				if (Veh_ConsumeFuel(vid, .throttle=_tmp & KEY_SPRINT, .isOutOfFuel=_tmp, .buf=buf144)) {
					PlayerPlaySound playerid, FUEL_WARNING_SOUND, 0.0, 0.0, 0.0
					SendClientMessage playerid, COL_WARN, buf144
					if (_tmp) {
						SetVehicleParamsEx vid, .engine=0, .lights=0, .alarm=0, .doors=0, .bonnet=0, .boot=0, .objective=0
					}
				}
				if (lastcontrolactivity[playerid] > gettime() - 30) {
					if (++flighttimenew[playerid] >= 60) {
						SetPlayerScore(playerid, GetPlayerScore(playerid) + 1)
						flighttimeold[playerid] += 60
						flighttimenew[playerid] -= 60
					}
				}
			}
			new Float:_x, Float:_y, Float:_z
			GetVehiclePos vid, _x, _y, _z
			playerodo[playerid] = Veh_AddOdo(vid, playerid, lastvehx[playerid], lastvehy[playerid], lastvehz[playerid], _x, _y, _z, playerodo[playerid])
			lastvehx[playerid] = _x
			lastvehy[playerid] = _y
			lastvehz[playerid] = _z
			if (Missions_GetState(playerid) == MISSION_STAGE_FLIGHT) {
				GetVehicleHealthSafe playerid, vid, qw
				GetVehicleVelocity vid, qx, qy, qz
				if (Missions_CreateTrackerMessage(playerid, vid, qw, _x, _y, qx, qy, qz, _z, buf144)) {
					socket_send_array trackerSocket, buf144, 24
				}
			}
		}
		if (!Veh_IsPlayerAllowedInVehicle(userid[playerid], vid, buf144)) {
			ClearAnimations playerid, .forcesync=1 // should remove from vehicle
			SendClientMessage playerid, COL_WARN, buf144
			ac_disallowedVehicle1s playerid
		}
	}
	new Float:x, Float:y, Float:z
	GetPlayerPos playerid, x, y, z
	updateServicePointsForPlayer playerid, x, y
}

hook loop5000()
{
	if (Veh_GetNextUpdateQuery(buf144)) {
		mysql_tquery 1, buf144
	}
}

hook OnGameModeInit()
{
	new Cache:veh = mysql_query(1, !"SELECT veh.i,veh.m,veh.o,veh.x,veh.y,veh.z,veh.r,veh.c,veh.d,veh.odo,usr.n FROM veh LEFT OUTER JOIN usr ON veh.o = usr.i WHERE veh.e=1")
	rowcount = cache_get_row_count()
	Veh_Init rowcount
	while (rowcount--) {
		new dbid, model, owneruserid, Float:x, Float:y, Float:z, Float:r, col1, col2, odo, ownername[MAX_PLAYER_NAME + 1]
		cache_get_field_int(rowcount, 0, dbid)
		cache_get_field_int(rowcount, 1, model)
		cache_get_field_int_nullable_default0_usebuf32(rowcount, 2, owneruserid)
		cache_get_field_flt(rowcount, 3, x)
		cache_get_field_flt(rowcount, 4, y)
		cache_get_field_flt(rowcount, 5, z)
		cache_get_field_flt(rowcount, 6, r)
		cache_get_field_int(rowcount, 7, col1)
		cache_get_field_int(rowcount, 8, col2)
		cache_get_field_int(rowcount, 9, odo)
		cache_get_field_str(rowcount, 10, ownername)
		Veh_Add(dbid, model, owneruserid, x, y, z, r, col1, col2, odo, ownername)
		// only spawn public vehicles statically
		if (owneruserid == 0) {
			new vehicleid = AddStaticVehicleEx(model, x, y, z, r, col1, col2, RESPAWN_DELAY)
			if (vehicleid != INVALID_VEHICLE_ID) {
				Veh_UpdateSlot vehicleid, dbid
			}
		}
	}
	cache_delete veh
	veh = mysql_query(1, !"SELECT s.id,s.x,s.y,s.z FROM svp s JOIN apt a ON s.apt=a.i WHERE a.e=1")
	rowcount = cache_get_row_count()
	Veh_InitServicePoints rowcount
	while (rowcount--) {
		new id, Float:x, Float:y, Float:z
		cache_get_field_int(rowcount, 0, id)
		cache_get_field_flt(rowcount, 1, x)
		cache_get_field_flt(rowcount, 2, y)
		cache_get_field_flt(rowcount, 3, z)
		Veh_AddServicePoint rowcount, id, x, y, z
	}
	cache_delete veh
}

hook OnGameModeExit()
{
	Veh_Destroy
	while (Veh_GetNextUpdateQuery(buf144)) {
		mysql_tquery 1, buf144
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 1501574: if (Command_Is(cmdtext, "/fix", idx)) {
		repairVehicleForPlayer playerid
		#return 1
	}
	case 2123432060: if (Command_Is(cmdtext, "/repair", idx)) {
		repairVehicleForPlayer playerid
		#return 1
	}
	case 2123153240: if (Command_Is(cmdtext, "/refuel", idx)) {
		refuelVehicleForPlayer playerid
		#return 1
	}
	case 1438658898: if (Command_Is(cmdtext, "/at400", idx)) {
		if (GetPlayerVehicleID(playerid)) {
			#return 1
		}
		new Float:vx, Float:vy, Float:vz, found_vehicle_id = 0, Float:shortest_distance = FLOAT_PINF, Float:tmpdistance
		for (new i = 1, m = GetVehiclePoolSize(); i <= m; i++) {
			if (GetVehicleModel(i) == MODEL_AT400 &&
				GetVehiclePos(i, vx, vy, vz) &&
				Veh_IsPlayerAllowedInVehicle(userid[playerid], i, buf4096) &&
				(tmpdistance = GetPlayerDistanceFromPoint(playerid, vx, vy, vz)) < shortest_distance &&
				findPlayerInVehicleSeat(i, .seatid=0) == INVALID_PLAYER_ID)
			{
				shortest_distance = tmpdistance
				found_vehicle_id = i
			}
		}
		if (found_vehicle_id && shortest_distance < 25.0) {
			PutPlayerInVehicleSafe playerid, found_vehicle_id, 0
		}
		#return 1
	}
}

hook OnPlayerConnect(playerid)
{
	playerodo[playerid] = 0.0
	flighttimenew[playerid] = flighttimeold[playerid] = 0
}

hook OnPlayerDisconnect(playerid, reason)
{
	Veh_OnPlayerDisconnect playerid

	new vehamount = Veh_CollectSpawnedVehicles(userid[playerid], buf144)
	new idx = 0
	while (vehamount--) {
		DestroyVehicle buf144[idx]
		// destroyvehicle will stream out vehicle for players, so no need to destroy label here
		Veh_UpdateSlot buf144[idx], -1
		idx++
	}

	tmp1 = lastvehicle[playerid]
	if (tmp1 && IsValidVehicle(tmp1)) {
		new p = findPlayerInVehicleSeat(tmp1, .seatid=0)
		if (!p || p == playerid) {
			SetVehicleToRespawn tmp1
		}
	}
	lastvehicle[playerid] = 0
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (!ispassenger && !Veh_IsPlayerAllowedInVehicle(userid[playerid], vehicleid, buf144)) {
		ClearAnimations playerid, .forcesync=1
		SendClientMessage playerid, COL_WARN, buf144
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	lastcontrolactivity[playerid] = gettime()
	if (newkeys & KEY_NO && (oldkeys & KEY_NO) == 0) {
		new vid
		if ((vid = GetPlayerVehicleID(playerid)) && GetPlayerVehicleSeat(playerid) == 0) {
			new engine
			GetVehicleParamsEx vid, engine, tmp1, tmp1, tmp1, tmp1, tmp1, tmp1
			if (engine) {
				new Float:_x, Float:_y, Float:_z
				GetVehicleVelocity vid, _x, _y, _z
				_x *= _x
				_y *= _y
				_z *= _z
				#assert VEL_VER == 2
				if (_x + _y + _z > 0.00027714) { // 3kph
					WARNMSGPB144("You can't shut down the engine while moving!")
				} else {
					SetVehicleParamsEx vid, .engine=0, .lights=0, .alarm=0, .doors=0, .bonnet=0, .boot=0, .objective=0
					SendClientMessage playerid, COL_INFO, INFO"engine stopped"
				}
			} else if (Veh_IsFuelEmpty(vid)) {
				WARNMSGPB144("You can't start the engine, there is no fuel!")
			} else {
				SetVehicleParamsEx vid, .engine=1, .lights=0, .alarm=0, .doors=0, .bonnet=0, .boot=0, .objective=0
				SendClientMessage playerid, COL_INFO, INFO"engine started"
			}
		}
	}
}

hook OnPlayerLogin(playerid)
{
	spawnPlayerVehicles userid[playerid]
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vid
	if (oldstate == PLAYER_STATE_DRIVER &&
		(vid = lastvehicle[playerid]) &&
		findPlayerInVehicleSeat(vid, .seatid=0) == INVALID_PLAYER_ID)
	{
		for (new p : players) {
			if (IsVehicleStreamedIn(vid, p)) {
				createVehicleOwnerLabel vid, p
			}
		}
	}

	if (newstate == PLAYER_STATE_DRIVER && (vid = GetPlayerVehicleID(playerid))) {
		onPlayerNowDriving playerid, vid
		for (new p : players) {
			destroyVehicleOwnerLabel vid, p
		}
	}
}

hook OnPlayerUpdate(playerid)
{
	new vid = GetPlayerVehicleID(playerid)
	if (vid && lastvehicle[playerid] != vid) {
		lastvehicle[playerid] = vid
		Veh_ResetPanelTextCache playerid
	}
}

hook onPutPlayerInVehicle(playerid, vehicleid)
{
	new Float:x, Float:y, Float:z
	GetVehiclePos vehicleid, x, y, z
	updateServicePointsForPlayer playerid, x, y
}

hook onPutPlayerInVehicleDriver(playerid, vehicleid)
{
	onPlayerNowDriving playerid, vehicleid
}

hook onSetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	updateServicePointsForPlayer playerid, x, y
}

hook OnVehicleSpawn(vehicleid)
{
	vv[vehicleid]++
	Veh_EnsureHasFuel vehicleid
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
	if (findPlayerInVehicleSeat(vehicleid, .seatid=0) == INVALID_PLAYER_ID) {
		createVehicleOwnerLabel vehicleid, forplayerid
	}
}

hook OnVehicleStreamOut(vehicleid, forplayerid)
{
	destroyVehicleOwnerLabel vehicleid, forplayerid
}

//@summary Created an owner label on a vehicle for a player if needed
//@param vehicleid vehicle of whom to create the owner label for
//@param playerid player for who to create the owner label for
createVehicleOwnerLabel(vehicleid, playerid)
{
	if (Veh_ShouldCreateLabel(vehicleid, playerid, buf144)) {
		new PlayerText3D:labelid
		labelid = CreatePlayer3DTextLabel(playerid, buf144, 0xFFFF00FF, 0.0, 0.0, 0.0, 75.0, INVALID_PLAYER_ID, vehicleid, .testLOS=1)
		if (_:labelid != INVALID_3DTEXT_ID) {
			Veh_RegisterLabel vehicleid, playerid, labelid
		}
	}
}

//@summary Destroys an owner label on a vehicle for a player if needed
//@param vehicleid vehicle of whom to destroy the owner label for
//@param playerid player for who to destroy the owner label for
destroyVehicleOwnerLabel(vehicleid, playerid)
{
	new PlayerText3D:labelid
	if (Veh_GetLabelToDelete(vehicleid, playerid, labelid)) {
		DeletePlayer3DTextLabel playerid, labelid
	}
}

//@summary Finds the player that is in the given seat in the vehicle
//@param vehicleid vehicle where the player should be
//@param seatid seat where the player should be
//@returns {@code INVALID_PLAYER_ID} if there's no player in that seat, playerid otherwise
findPlayerInVehicleSeat(vehicleid, seatid)
{
	for (new p : players) {
		if (IsPlayerInVehicle(p, vehicleid) && GetPlayerVehicleSeat(p) == seatid) {
			return p;
		}
	}
	return INVALID_PLAYER_ID
}

//@summary Function to call when a player is now driver of a vehicle
//@param playerid playerid that is now driving in a new vehicle
//@param vehicleid vehicle player is driving in
onPlayerNowDriving(playerid, vehicleid)
{
	GetVehiclePos vehicleid, lastvehx[playerid], lastvehy[playerid], lastvehz[playerid]
	if (Veh_IsFuelEmpty(vehicleid)) {
		WARNMSGPB144("This vehicle has no fuel left!")
		SetVehicleParamsEx vehicleid, .engine=0, .lights=0, .alarm=0, .doors=0, .bonnet=0, .boot=0, .objective=0
	} else {
		SetVehicleParamsEx vehicleid, .engine=1, .lights=0, .alarm=0, .doors=0, .bonnet=0, .boot=0, .objective=0
	}
}

//@summary Repairs vehicle for player, taking money from the player to fix it
//@param playerid player that needs their vehicle fixed
//@remarks also notifies the mission script about the vehicle's new hp
//@remarks passengers can also repair vehicles
repairVehicleForPlayer(playerid)
{
	// passengers may also repair the vehicle, why not?
	new vehicleid = GetPlayerVehicleID(playerid)
	if (vehicleid == 0) {
		WARNMSGPB144("You must be in a vehicle to do this!")
		return
	}
	new Float:hp, Float:newhp, Float:x, Float:y, Float:z
	GetVehiclePos vehicleid, x, y, z
	GetVehicleHealthSafe playerid, vehicleid, hp
	new cost = Veh_Repair(x, y, z, vehicleid, playerid, playermoney[playerid], hp, newhp, buf144, buf4096)
	if (!cost) {
		SendClientMessage playerid, COL_WARN, buf144
		return
	}

	if (buf4096[0]) {
		mysql_tquery 1, buf4096
	}
	money_takeFrom playerid, cost
	SendClientMessage playerid, COL_INFO, buf144
	RepairVehicle vehicleid
	SetVehicleHealth vehicleid, newhp
	if (GetPlayerVehicleSeat(playerid) != 0) {
		new driverid = findPlayerInVehicleSeat(vehicleid, .seatid=0)
		if (driverid == INVALID_PLAYER_ID) {
			return
		}
		format buf144, sizeof(buf144), INFO"Player %s[%d] repaired your vehicle!", NAMEOF(playerid), playerid
		SendClientMessage driverid, COL_INFO, buf144
		playerid = driverid
	}
	Missions_OnVehicleRepaired playerid, vehicleid, hp, newhp
}

//@summary Refuels vehicle for player, taking money from the player to refuel it
//@param playerid player that needs their vehicle refueled
//@remarks also notifies the mission script about the vehicle's new hp
//@remarks passengers can also refuel vehicles
refuelVehicleForPlayer(playerid)
{
	// passengers may also refuel the vehicle, why not?
	new vehicleid = GetPlayerVehicleID(playerid)
	if (vehicleid == 0) {
		WARNMSGPB144("You must be in a vehicle to do this!")
		return
	}

	new engine
	GetVehicleParamsEx vehicleid, engine, tmp1, tmp1, tmp1, tmp1, tmp1, tmp1
	if (engine) {
		WARNMSGPB144("The engine must be turned off first. Press n or check out /helpkeys")
		return
	}

	new Float:refuelamount, Float:x, Float:y, Float:z
	GetVehiclePos vehicleid, x, y, z
	new cost = Veh_Refuel(x, y, z, vehicleid, playerid, 1.2, playermoney[playerid], refuelamount, buf144, buf4096)
	if (!cost) {
		SendClientMessage playerid, COL_WARN, buf144
		return
	}

	if (buf4096[0]) {
		mysql_tquery 1, buf4096
	}
	money_takeFrom playerid, cost
	SendClientMessage playerid, COL_INFO, buf144
	if (GetPlayerVehicleSeat(playerid) != 0) {
		new driverid = findPlayerInVehicleSeat(vehicleid, .seatid=0)
		if (driverid == INVALID_PLAYER_ID) {
			return
		}
		format buf144, sizeof(buf144), INFO"Player %s[%d] refueled your vehicle!", NAMEOF(playerid), playerid
		SendClientMessage driverid, COL_INFO, buf144
		playerid = driverid
	}
	Missions_OnVehicleRefueled playerid, vehicleid, refuelamount
}

//@summary Spawns vehicles owned by a player
//@param usrid user id of the player for who their vehicles should be spawned
spawnPlayerVehicles(usrid)
{
	new vehamount = Veh_CollectPlayerVehicles(usrid, buf4096)
	new vid
	#emit CONST.pri buf4096
	#emit STOR.pri tmp1
	while (vehamount--) {
		#emit PUSH.C 0 // addsiren
		#assert RESPAWN_DELAY == 300
		#emit PUSH.C 300 // respawn delay
		#emit LOAD.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // col2
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // col1
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // r
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // z
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // y
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // x
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit LREF.alt tmp1
		#emit PUSH.alt // model
		#emit ADD.C 4
		#emit STOR.pri tmp1
		#emit PUSH.C 36
		#emit SYSREQ.C CreateVehicle
		#emit STACK 40
		#emit STOR.S.pri vid

		if (vid != INVALID_VEHICLE_ID) {
			#emit LREF.alt tmp1
			#emit PUSH.alt
			#emit PUSH.S vid
			#emit PUSH.C 8
			#emit SYSREQ.C Veh_UpdateSlot
			#emit STACK 12
		}

		numargs // NOP, inline asm direcly after conditionals get included in the conditional
		#emit LOAD.pri tmp1
		#emit ADD.C 4
		#emit STOR.pri tmp1
	}

	/*
	new idx = 0
	while (vehamount--) {
		vid = CreateVehicle(\
			buf4096[idx+6],
			Float:buf4096[idx+5],
			Float:buf4096[idx+4],
			Float:buf4096[idx+3],
			Float:buf4096[idx+2],
			buf4096[idx+1],
			buf4096[idx],
			300)
		if (vid != INVALID_VEHICLE_ID) {
			Veh_UpdateSlot vid, buf4096[idx+7]
		}
		idx += 8
	}
	*/
}

//@summary Updates service point map icons and 3D text labels for a player.
//@param playerid player to update for
//@param x x-position of the player
//@param y y-position of the player
updateServicePointsForPlayer(playerid, Float:x, Float:y)
{
	new amount = Veh_UpdateServicePtsVisibility(playerid, x, y, buf4096)
	new idx = 0;
	while (amount--) {
		switch (buf4096[idx]) {
		case -2: break
		case -1: {
			tmp1 = buf4096[idx + 1]
			x = Float:buf4096[idx + 2]
			y = Float:buf4096[idx + 3]
			new Float:z = Float:buf4096[idx + 4]
			SetPlayerMapIcon playerid, tmp1, x, y, z, 38, 0, MAPICON_GLOBAL
			new PlayerText3D:id = CreatePlayer3DTextLabel(playerid, "Service Point\n/repair - /refuel", -1, x, y, z, 50.0)
			Veh_UpdateServicePointTextId playerid, tmp1, id
		}
		default: {
			RemovePlayerMapIcon playerid, buf4096[idx + 1]
			tmp1 = buf4096[idx]
			if (tmp1 != INVALID_3DTEXT_ID) {
				DeletePlayer3DTextLabel playerid, PlayerText3D:tmp1
			}
		}
		}
		idx += 5
	}
}

#printhookguards

