
// vim: set filetype=c ts=8 noexpandtab:

#namespace "tracker"

varinit
{
	new ssocket:trackerSocket;
	#define TRACKER_PORT 7766
}

hook OnGameModeInit()
{
	trackerSocket = ssocket_create()
	if (_:trackerSocket == -1) {
		print "E-T01"
	} else {
		ssocket_connect trackerSocket, "127.0.0.1", TRACKER_PORT
		buf32[0] = 0x04594C46;
		ssocket_send trackerSocket, buf32, 4
	}
}

hook OnGameModeExit()
{
	if (_:trackerSocket != INVALID_SOCKET) {
		buf32[0] = 0x05594C46;
		ssocket_send trackerSocket, buf32, 4
		ssocket_destroy trackerSocket
	}
}

#printhookguards

