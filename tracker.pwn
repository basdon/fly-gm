
// vim: set filetype=c ts=8 noexpandtab:

#namespace "tracker"

varinit
{
	new Socket:trackerSocket;
}

hook OnGameModeInit()
{
	trackerSocket = socket_create(UDP)
	if (_:trackerSocket == INVALID_SOCKET) {
		print "E-T01"
	} else {
		socket_connect trackerSocket, "127.0.0.1", 4455
		// TODO tracker port stuff
	}
}

hook OnGameModeExit()
{
	if (_:trackerSocket != INVALID_SOCKET) {
		socket_destroy trackerSocket
	}
}

#printhookguards

