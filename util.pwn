
// vim: set filetype=c ts=8 noexpandtab:

//@summary Hides any possible shown game text for a player
//@param playerid the player to hide any possible shown game text for
//@remarks Is implemented as a preprocessor replacement.
stock hideGameTextForPlayer(playerid) {
	this_function _ should_not _ be_called
}
#define hideGameTextForPlayer(%0) GameTextForPlayer(%0, TXT_EMPTY_CONST, 2, 3)

#define LIMITSTRLEN(%0,%1) if(strlen(%0)>%1)%0[%1-1]=0

