
// vim: set filetype=c ts=8 noexpandtab:

/* afk.pwn */

//@summary Check if a player is afk.
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@remarks A player is considered to be ask if they has not sent an update for over {@b 1000ms}.
//@remarks {@b A player is also marked afk when they are not spawned (dead or in class select)!}
//@returns {@code 0} if the player is not afk
//@seealso isSpawned
stock isAfk(playerid) {
	this_function _ should_not _ be_called
}

/* game_sa.pwn */

//@summary Checks if a player is in a vehicle in the category 'air'
//@param playerid the id of the player to check
//@remarks No need to check if player is in vehicle (or connected even)
//@returns {@code 1} if the player is in an air vehicle.
//@seealso IsAirVehicle
stock isInAirVehicle(playerid) {
	this_function _ should_not _ be_called
}

/* login.pwn*/

//@summary Check if a player is playing (=past the login screen, can be guest)
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isSpawned
//@seealso isGuest
//@seealso isRegistered
//@returns {@code 0} if the player is not playing
stock isPlaying(playerid) {
	this_function _ should_not _ be_called
}

//@summary Check if a player has an account (=is not a guest)
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isPlaying
//@seealso isGuest
//@returns {@code 0} if the player is not registered
stock isRegistered(playerid) {
	this_function _ should_not _ be_called
}

//@summary Check if a player is playing as a guest
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@seealso isPlaying
//@seealso isRegistered
//@returns {@code 0} if the player is not logged in
stock isGuest(playerid) {
	this_function _ should_not _ be_called
}

/* playername.pwn */

//@summary Gets the cached name of a player
//@param playerid the player to get the name of
//@remarks Is implemented as a preprocessor replacement.
//@seealso NAMELEN
//@returns ptr to the player's name
stock NAMEOF(playerid) {
	this_function _ should_not _ be_called
}

//@summary Gets the length of the name of a player
//@param playerid the player to get the name length of
//@remarks Is implemented as a preprocessor replacement.
//@seealso NAMEOF
//@returns the length of the player's name
stock NAMELEN(playerid) {
	this_function _ should_not _ be_called
}

/* spawn.pwn */

//@summary Check if a player is spawned.
//@param playerid the playerid to check
//@remarks Is implemented as a preprocessor replacement.
//@returns {@code 0} if the player is not spawned
//@seealso isPlaying
stock isSpawned(playerid) {
	this_function _ should_not _ be_called
}

//@summary Gets a player's class
//@param playerid the player to check
//@remarks Is implemented as a preprocessor replacement.
//@returns The player's class, should be one of the {@code CLASS_*} constants.
stock getPlayerClass(playerid) {
	this_function _ should_not _ be_called
}

