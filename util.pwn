
// vim: set filetype=c ts=8 noexpandtab:

//@summary Hides any possible shown game text for a player
//@param playerid the player to hide any possible shown game text for
//@remarks Is implemented as a preprocessor replacement.
stock hideGameTextForPlayer(playerid) {
	this_function _ should_not _ be_called
}
#define hideGameTextForPlayer(%0) GameTextForPlayer(%0, TXT_EMPTY_CONST, 2, 3)

//@summary Delayed kick to be able to send some messages first
//@param playerid player to kick
//@remarks Is implemented as a preprocessor replacement.
//@seealso Kick
stock KickDelayed(playerid) {
	this_function _ should_not _ be_called
}
#define KickDelayed SetTimerEx #PUB_KICKEX,25,0,"i",

