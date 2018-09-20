
// vim: set filetype=c ts=8 noexpandtab:

#namespace "game_sa"

#define MODEL_LEVIATHAN 417 // 0, 0x2000
#define MODEL_HUNTER 425 // 0, 0x2000000
#define MODEL_SEASPARROW 447 // 1, 0x8000
#define MODEL_SKIMMER 460 // 1, 0x10000000
#define MODEL_RCBARON 464 // 2, 0x0
#define MODEL_RCRAIDER 465 // 2, 0x1
#define MODEL_SPARROW 469 // 2, 0x20
#define MODEL_RUSTLER 476 // 2, 0x1000
#define MODEL_MAVERICK 487 // 2, 0x800000
#define MODEL_NEWSCHOPPER 488 // 2, 0x1000000
#define MODEL_POLMAVERICK 497 // 3, 0x2
#define MODEL_RCGOBLIN 501 // 3, 0x20
#define MODEL_BEAGLE 511 // 3, 0x8000
#define MODEL_CROPDUSTER 512 // 3, 10000
#define MODEL_STUNTPLANE 513 // 3, 0x20000
#define MODEL_SHAMAL 519 // 3, 0x80000
#define MODEL_HYDRA 520 // 3, 0x1000000
#define MODEL_CARGOBOB 548 // 4, 0x100000
#define MODEL_NEVADA 553 // 4, 0x200000
#define MODEL_RAINDANCE 563 // 5, 0x8
#define MODEL_AT400 577 // 5, 0x20000
#define MODEL_ANDROMADA 592 // 6, 0x1
#define MODEL_DODO 593 // 6, 0x2

#define MODEL_TOTAL (611-400)

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

