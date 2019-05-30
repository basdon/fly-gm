
// vim: set filetype=c ts=8 noexpandtab:

#namespace "protips"

varinit
{
	new protipdelay
	new protips[][] = {
		//------------------------------------------------------------------------------------------------------------------------------------------------
		!"Pro Tip: Use /w(ork) to start a random mission. /s(top) to cancel your mission ($5000 fine).",
		!"Pro Tip: Use /nearest to get a list of all airports, sorted by proximity!",
		!"Pro Tip: Enable navigation with /adf [beacon] or /vor [beacon][runway]",
		!"Pro Tip: ILS can be toggled using /ils when VOR is already active.",
		!"Pro Tip: Press the 'CONVERSATION - NO' key (default: n, /helpkeys) to turn off your engine and preserve fuel.",
		!"Pro Tip: Confused about key bindings? Check out /helpkeys",
		!"Pro Tip: Check /p(references) to tweak your personal preferences while playing on this server.",
		!"Pro Tip: Use /autow to toggle automatically getting a new mission after finishing one (see also /p).",
		!"Pro Tip: Send private messages to other players using /pm [id/name/part of name] [message]",
		!"Pro Tip: Can't get into an AT-400? We got you covered, just type /at400",
		!"Pro Tip: Always try to land on the back wheels."
	}
}

hook loop1m()
{
	if (++protipdelay == 8) {
		protipdelay = 0;
		strunpack buf144, protips[random(sizeof(protips))]
		SendClientMessageToAll COL_INFO_LIGHT, buf144
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 2078167997: if (Command_Is(cmdtext, "/protip", idx)) {
		strunpack buf144, protips[random(sizeof(protips))]
		SendClientMessage playerid, COL_INFO_LIGHT, buf144
		#return 1
	}
}

#printhookguards

