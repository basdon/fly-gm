
// vim: set filetype=c ts=8 noexpandtab:

#namespace "objects"

// radar from base offsets: (base facing W, radar on E pos)
// 4.7, -0.2, 12.8
#define OBJ_RADAR_LA_POS 1383.3, -2422.4, 30.2
#define OBJ_RADAR_LV_POS 1296.7, 1502.5, 26.0
#define OBJ_RADAR_SF_POS -1692.8, -620.9, 29.6

varinit
{
	new obj_radar_la, obj_radar_lv, obj_radar_sf
	new Float:obj_radar_z_rot = 0.0
	new obj_loop_idx = 0
}

hook OnGameModeInit()
{
	CreateObject 7981, 1388.0, -2422.2, 17.6, 0.0, 0.0, 180.0  // radar base LA
	obj_radar_la = CreateObject(1682, OBJ_RADAR_LA_POS, 0.0, 0.0, 0.0)
	obj_radar_lv = CreateObject(1682, OBJ_RADAR_LV_POS, 0.0, 0.0, 0.0)
	obj_radar_sf = CreateObject(1682, OBJ_RADAR_SF_POS, 0.0, 0.0, 0.0)
	obj_rotate_radars
}

hook OnObjectMoved(objectid)
{
	if (objectid == obj_radar_lv) {
		obj_rotate_radars
	}
}

hook OnPlayerConnect(playerid)
{
	RemoveBuildingForPlayer playerid, 1682, 1295.1, 1502.9, 26.2, 1.2 // LV radar
	RemoveBuildingForPlayer playerid, 1682, 1709.4, -2362.7, 31.7, 2.2 // LA radar1
	RemoveBuildingForPlayer playerid, 1682, 1663.6, -2362.7, 31.7, 2.2 // LA radar2
	RemoveBuildingForPlayer playerid, 1682, -1691.6, -619.7, 29.6, 1.2 // SF radar
	RemoveBuildingForPlayer playerid, 3664, 2042.8, -2442.2, 19.3, 1.2 // LA ramp random
	RemoveBuildingForPlayer playerid, 3664, 1388.0, -2494.3, 19.3, 1.2 // LA ramp runwayN
	RemoveBuildingForPlayer playerid, 3664, 1388.0, -2593.0, 19.3, 1.2 // LA ramp runwayS
	//RemoveBuildingForPlayer playerid, 1378, 2232.4, -2458.6, 36.2, 1.2 // LA annoying dock crane
	//RemoveBuildingForPlayer playerid, 1396, 2232.4, -2458.6, 36.2, 1.2 // LA annoying dock crane LOD
	// (need the cable & blue control thing ^)
}

//@summary Rotates the radar objects placed at LSA, LVA, SFA
//@remarks Is called once at startup and then retriggered by {@link OnObjectMoved}
obj_rotate_radars()
{
	obj_loop_idx ^= 1
	obj_radar_z_rot += 179.99
	if (obj_radar_z_rot > 360.0) {
		obj_radar_z_rot -= 360.0
	}
	new Float: zoff = obj_loop_idx * 0.006
	MoveObject obj_radar_la, OBJ_RADAR_LA_POS + zoff, 0.002, 0.0, 0.0, obj_radar_z_rot
	MoveObject obj_radar_lv, OBJ_RADAR_LV_POS + zoff, 0.002, 0.0, 0.0, obj_radar_z_rot
	MoveObject obj_radar_sf, OBJ_RADAR_SF_POS + zoff, 0.002, 0.0, 0.0, obj_radar_z_rot
}

#printhookguards

