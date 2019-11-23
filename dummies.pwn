
// vim: set filetype=c ts=8 noexpandtab:

/* vendor/a_mysql_min.inc */

/* afk.pwn */

//@summary see {@link cache_get_row}
//@param row row index (zero based)
//@param field field index (zero based)
//@param dest destination buffer
//@remarks Is implemented as a preprocessor replacement.
//@reamrks this is replaced into a normal assigned instead of by ref
stock cache_get_field_str(row, field, dest[]) {
	this_function _ should_not _ be_called
}

//@summary see {@link cache_get_row_int}
//@param row row index (zero based)
//@param field field index (zero based)
//@param dest destination variable
//@remarks Is implemented as a preprocessor replacement.
//@reamrks this is replaced into a normal assigned instead of by ref
stock cache_get_field_int(row, field, &dest) {
	this_function _ should_not _ be_called
}

//@summary see {@link cache_get_row_float}
//@param row row index (zero based)
//@param field field index (zero based)
//@param dest destination variable
//@remarks Is implemented as a preprocessor replacement.
//@reamrks this is replaced into a normal assigned instead of by ref
stock cache_get_field_flt(row, field, &Float:dest) {
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

