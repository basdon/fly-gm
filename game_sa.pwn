
// vim: set filetype=c ts=8 noexpandtab:

#namespace "game_sa"

varinit
{
	#define isInAirVehicle(%0) IsAirVehicle(GetVehicleModel(GetPlayerVehicleID(%0)))
}

#define _isInAirVehicle isInAirVehicle
#undef isInAirVehicle
//@summary Checks if a player is in a vehicle in the category 'air'
//@param playerid the id of the player to check
//@remarks No need to check if player is in vehicle (or connected even)
//@returns {@code 1} if the player is in an air vehicle.
//@seealso IsAirVehicle
stock isInAirVehicle(playerid) {
	this_function _ should_not _ be_called
}
#define isInAirVehicle _isInAirVehicle
#undef _isInAirVehicle

#printhookguards

