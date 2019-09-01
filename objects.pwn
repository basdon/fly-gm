
// vim: set filetype=c ts=8 noexpandtab:

#namespace "objects"

// radar from base offsets: (base facing W, radar on E pos)
// 4.7, -0.2, 12.8
#define OBJ_RADAR_LA_POS 1383.3, -2422.4, 29.0
#define OBJ_RADAR_LV_POS 1296.7, 1502.5, 26.0
#define OBJ_RADAR_SF_POS -1692.8, -620.9, 29.6

varinit
{
	new obj_radar_la, obj_radar_lv, obj_radar_sf
}

hook OnGameModeInit()
{
	CreateObject 7981, 1388.0, -2422.2, 17.6, 0.0, 0.0, 180.0, 200.0  // radar base LA
	obj_radar_la = CreateObject(1682, OBJ_RADAR_LA_POS, 0.0, 0.0, 0.0, 200.0)
	obj_radar_lv = CreateObject(1682, OBJ_RADAR_LV_POS, 0.0, 0.0, 0.0, 200.0)
	obj_radar_sf = CreateObject(1682, OBJ_RADAR_SF_POS, 0.0, 0.0, 0.0, 200.0)
}

hook OnPlayerConnect(playerid)
{
	RemoveBuildingForPlayer playerid, 1682, 1295.1, 1502.9, 26.2, 1.2 // LV radar
	//RemoveBuildingForPlayer playerid, 1682, 1709.4, -2362.7, 31.7, 2.2 // LA radar1
	//RemoveBuildingForPlayer playerid, 1682, 1663.6, -2362.7, 31.7, 2.2 // LA radar2
	RemoveBuildingForPlayer playerid, 1682, 1686.5, -2362.7, 31.7, 23.5
	RemoveBuildingForPlayer playerid, 1682, -1691.6, -619.7, 29.6, 1.2 // SF radar
	//RemoveBuildingForPlayer playerid, 3664, 2042.8, -2442.2, 19.3, 1.2 // LA ramp random
	//RemoveBuildingForPlayer playerid, 3664, 1388.0, -2494.3, 19.3, 1.2 // LA ramp runwayN
	//RemoveBuildingForPlayer playerid, 3664, 1388.0, -2593.0, 19.3, 1.2 // LA ramp runwayS
	RemoveBuildingForPlayer playerid, 3664, 1715.4, -2517.6, 19.3, 387.5

	RemoveBuildingForPlayer playerid, 1378, 2232.4375, -2458.5781, 36.1953, 0.25 // LA annoying dock crane
	RemoveBuildingForPlayer playerid, 1396, 2232.4375, -2458.5781, 36.1953, 0.25 // LA annoying dock crane LOD
	RemoveBuildingForPlayer playerid, 1377, 2201.6250, -2458.5781, 38.9844, 0.25 // cable or blue control
	RemoveBuildingForPlayer playerid, 1376, 2227.1016, -2458.5938, 31.6797, 0.25 // cable or blue control

	//RemoveBuildingForPlayer playerid, 3663, 1580.09, -2433.83, 14.5703, 1.2 // LA stairs (lasstepsa_LAS)
	//RemoveBuildingForPlayer playerid, 3663, 1664.45, -2439.8, 14.4688, 1.2 // LA stairs (lasstepsa_LAS)
	//RemoveBuildingForPlayer playerid, 3663, 1832.45, -2388.44, 14.4688, 1.2 // LA stairs (lasstepsa_LAS)
	//RemoveBuildingForPlayer playerid, 3663, 1882.27, -2395.78, 14.4688, 1.2 // LA stairs (lasstepsa_LAS)
	RemoveBuildingForPlayer playerid, 3663, 1731.18, -2417.79, 14.4688, 175.0
}

hook loop5000()
{
	static Float:obj_radar_z_rot = 0.0
	static obj_loop_idx = 0
	obj_loop_idx ^= 1
	obj_radar_z_rot += 179.99
	if (obj_radar_z_rot > 360.0) {
		obj_radar_z_rot -= 360.0
	}
	new Float: zoff = obj_loop_idx * 0.006
	MoveObject obj_radar_la, OBJ_RADAR_LA_POS + zoff, 0.0012, 0.0, 0.0, obj_radar_z_rot
	MoveObject obj_radar_lv, OBJ_RADAR_LV_POS + zoff, 0.0012, 0.0, 0.0, obj_radar_z_rot
	MoveObject obj_radar_sf, OBJ_RADAR_SF_POS + zoff, 0.0012, 0.0, 0.0, obj_radar_z_rot
}

#printhookguards

