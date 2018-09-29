
// vim: set filetype=c ts=8 noexpandtab:

#namespace "game_sa"

varinit
{
	#define isInAirVehicle(%0) IsAirVehicle(GetVehicleModel(GetPlayerVehicleID(%0)))
}

#printhookguards

