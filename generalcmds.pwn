
// vim: set filetype=c ts=8 noexpandtab:

#namespace "gcmds"

varinit
{
#define LAST_PMTARGET_NOBODY -1
#define LAST_PMTARGET_INVALID -2
	new lastpmtarget[MAX_PLAYERS]
}

hook OnPlayerConnect(playerid)
{
	lastpmtarget[playerid] = LAST_PMTARGET_NOBODY
}

hook OnPlayerDisconnect(playerid, reason)
{
	foreach (new pid : players) {
		if (lastpmtarget[pid] == playerid) {
			lastpmtarget[pid] = LAST_PMTARGET_INVALID
		}
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 48748: if (IsCommand(cmdtext, "/pm", idx)) {
		new targetid;
		if (!Params_GetPlayer(cmdtext, idx, targetid)) {
msg_synerr:
			WARNMSG("Syntax: /pm [id/name] [message]")
			#return 1
		}
		if (targetid == INVALID_PLAYER_ID) {
			WARNMSG("That player is not online")
			#return 1
		}
		if (cmdtext[idx] == 0) {
			goto msg_synerr
		}
		sendpm playerid, targetid, cmdtext[idx]
		#return 1
	}
	case 1571: if (IsCommand(cmdtext, "/r", idx)) {
		switch (lastpmtarget[playerid]) {
		case LAST_PMTARGET_NOBODY: WARNMSG("Nobody has sent you a PM yet! Use /pm [id/name] [message]")
		case LAST_PMTARGET_INVALID: WARNMSG("The person who last sent you a PM has gone away")
		default: sendpm playerid, lastpmtarget[playerid], cmdtext[idx]
		}
		#return 1
	}
}

//@summary Send a pm
//@param from The player that sent the pm
//@param to The player that should receive the pm
//@param msg the pm text
//@remarks The {@param to} player is assumed to be online.
sendpm(from, to, msg[])
{
	format buf144, sizeof(buf144), ">> %s(%d): %s", NAMEOF(to), to, msg
	SendClientMessage from, COL_PRIVMSG, buf144
	format buf144, sizeof(buf144), "** %s(%d): %s", NAMEOF(from), from, msg
	SendClientMessage to, COL_PRIVMSG, buf144
	PlayerPlaySound to, 1139, 0.0, 0.0, 0.0
	if (lastpmtarget[to] == LAST_PMTARGET_NOBODY) {
		SendClientMessage to, COL_PRIVMSG_HINT, INFO"Use /r to quickly reply to the message"
	}
	lastpmtarget[to] = from
	lastpmtarget[from] = to
}

#printhookguards

