
// vim: set filetype=c ts=8 noexpandtab:

#namespace "tracker"

varinit
{
	new Socket:trackerSocket;
	#define TRACKER_PORT 7766
}

hook OnGameModeInit()
{
	trackerSocket = socket_create(UDP)
	if (_:trackerSocket == INVALID_SOCKET) {
		print "E-T01"
	} else {
		socket_connect trackerSocket, "127.0.0.1", TRACKER_PORT
	}
}

hook OnGameModeExit()
{
	if (_:trackerSocket != INVALID_SOCKET) {
		socket_destroy trackerSocket
	}
}

#printhookguards

