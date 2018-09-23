
// vim: set filetype=c ts=8 noexpandtab:

#namespace "game_sa"

varinit
{
	new airvehicles[] = { 0x02020000, 0x10008000, 0x01801023, 0x01838022, 0x02100000, 0x00020008, 0x00000003 }
}

//@summary Checks if a player is in a vehicle in the category 'air'
//@param playerid the id of the player to check
//@remarks No need to check if player is in vehicle (or connected even)
//@returns {@code 1} if the player is in an air vehicle.
isInAirVehicle(playerid)
{
	new model = GetVehicleModel(GetPlayerVehicleID(playerid)) - 400
	return model != -400 && ((airvehicles[model / 32] >> (model & 31)) & 1);
}

#printhookguards

