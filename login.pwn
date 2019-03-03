
// vim: set filetype=c ts=8 noexpandtab:

#namespace "login"

#define LOGGED_NO 0
#define LOGGED_IN 1
#define LOGGED_GUEST 2

#define MAX_LOGIN_ATTEMPTS 4

#define BCRYPT_COST 12

varinit
{
	#define isPlaying(%0) (loggedstatus[%0])
	#define isRegistered(%0) (loggedstatus[%0] == LOGGED_IN)
	#define isGuest(%0) (loggedstatus[%0] == LOGGED_GUEST)

	new loggedstatus[MAX_PLAYERS]
	new failedlogins[MAX_PLAYERS char]
	new userid[MAX_PLAYERS]
	new sessionid[MAX_PLAYERS]

	new REGISTER_CAPTION[] = "Register"

	new LOGIN_CAPTION[] = "Login"
	new LOGIN_TEXT[] =
		""ECOL_WARN"Incorrect password!\n\n"ECOL_DIALOG_TEXT""\
		"Welcome! This account is registered.\n"\
		"Please sign in or change your name."
	#define LOGIN_TEXT_NOPWERR_OFFSET 37

	new CHANGEPASS_CAPTION[] = "Change password"

	new NAMECHANGE_CAPTION[] = "Change name"
	new NAMECHANGE_TEXT[] =
		""ECOL_WARN"Invalid name or name is taken (press tab).\n\n"ECOL_DIALOG_TEXT""\
		"Enter your new name (3-20 length, 0-9a-zA-Z=()[]$@._).\n"\
		"Names starting with @ are reserved for guests."
	#define NAMECHANGE_TEXT_NOERR_OFFSET 60

	new ninespaces[] = "         "
}

hook loop30s()
{
	foreach (new playerid : players) {
		updatePlayerLastseen playerid, .isdisconnect=0
	}
}

hook OnPlayerDisconnect(playerid, reason)
{
	if (isPlaying(playerid)) {
		new reasons[] = "\4\12\17\4timeout\0quit\0kicked"
		new str[MAX_PLAYER_NAME + 6 + 21 + 8 + 1]
		format str, sizeof(str), "%s[%d] left the server (%s)", NAMEOF(playerid), playerid, reasons[reasons[reason & 3]]
		SendClientMessageToAll COL_QUIT, str
	}
	updatePlayerLastseen playerid, .isdisconnect=1
	loggedstatus[playerid] = LOGGED_NO
	Login_PasswordConfirmFree playerid
	Login_FreePassword playerid
}

hook OnPlayerConnect(playerid)
{
	userid[playerid] = -1
	sessionid[playerid] = -1
	failedlogins{playerid} = 0

	#assert PLAYERNAMEVER == 1
	while (playernames[playerid][1] == '@') {
		SendClientMessage playerid, COL_SAMP_GREEN, "Names starting with '@' are reserved for guest players."
		// wiki states that SetPlayerName does not propagate for the user
		// if used in OnPlayerConnect, but tests have proven otherwise.
		if (NAMELEN(playerid) <= 3 || SetPlayerName(playerid, playernames[playerid][2]) != 1) {
			SendClientMessage playerid, COL_WARN,
				WARN"Failed to change your nickname. Please come back with a different name."
			KickDelayed playerid
			#allowreturn
			return 0
		}
	}

	ensureDialogTransaction playerid, TRANSACTION_LOGIN
	checkUserExist playerid, ""#PUB_LOGIN_USERCHECK_CB""
}

hook OnPlayerRequestSpawn(playerid)
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#return 0
	}
}

hook OnPlayerCommandText(playerid, cmdtext[])
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#return 1
	}
}

hook OnPlayerText(playerid, text[])
{
	if (!isPlaying(playerid)) {
		SendClientMessage playerid, COL_WARN, WARN"Log in first."
		#return 0
	}
}

hook OnPlayerCommandTextCase(playerid, cmdtext[])
{
	case 258772946: if (IsCommand(cmdtext, "/register", idx)) if (isGuest(playerid)) {
		if (sessionid[playerid] == -1 || userid[playerid] == -1) {
			ShowPlayerDialog\
				playerid,
				DIALOG_DUMMY,
				DIALOG_STYLE_MSGBOX,
				REGISTER_CAPTION,
				""#ECOL_WARN"You are not on an active guest session."\
					" Please reconnect if you want to register.",
				"Ok", ""
			#return 1
		}
		Login_FormatGuestRegisterBox playerid, buf4096, .step=0
		ShowPlayerDialog\
			playerid,
			DIALOG_GUESTREGISTER_CHOOSENAME,
			DIALOG_STYLE_INPUT,
			REGISTER_CAPTION,
			buf4096,
			"Next", "Cancel",
			TRANSACTION_GUESTREGISTER
		#return 1
	} else {
		SendClientMessage playerid, COL_WARN, #WARN"You're already registered!"
		#return 1
	}
	case -1292722118: if (!isGuest(playerid) && IsCommand(cmdtext, "/changepassword", idx)) {
		Login_FormatChangePasswordBox buf4096, .step=0
		ShowPlayerDialog\
			playerid,
			DIALOG_CHANGEPASS_PREVPASS,
			DIALOG_STYLE_PASSWORD,
			CHANGEPASS_CAPTION,
			buf4096,
			"Next", "Cancel",
			TRANSACTION_CHANGEPASS
		#return 1
	}
}

hook OnDialogResponseCase(playerid, dialogid, response, listitem, inputtext[])
{
	case DIALOG_REGISTER_FIRSTPASS: {
		if (!response) {
			Login_PasswordConfirmFree playerid
			if (giveGuestName(playerid)) {
				loginAndSpawnAsGuest playerid
			}
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		Login_PasswordConfirmStore playerid, pwhash
		Login_FormatOnJoinRegisterBox buf4096, .step=1
		ShowPlayerDialog\
			playerid,
			DIALOG_REGISTER_CONFIRMPASS,
			DIALOG_STYLE_PASSWORD,
			REGISTER_CAPTION,
			buf4096,
			"Confirm",
			"Cancel",
			TRANSACTION_LOGIN
		#return 1
	}
	case DIALOG_REGISTER_CONFIRMPASS: {
		if (!response) {
			Login_PasswordConfirmFree playerid
			Login_FormatOnJoinRegisterBox buf4096, .step=0
			showRegisterDialog playerid, buf4096
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		if (!Login_PasswordConfirmValidate(playerid, pwhash)) {
			Login_FormatOnJoinRegisterBox buf4096, .pwmismatch=1, .step=0
			showRegisterDialog playerid, buf4096
			#return 1
		}

		GameTextForPlayer playerid, "~b~Making your account...", 0x800000, 3
		bcrypt_hash inputtext, BCRYPT_COST, #PUB_LOGIN_REGISTER_HASHPW_CB, "i", playerid
		ensureDialogTransaction playerid, TRANSACTION_LOGIN

		#outline
		//@summary Callback for hashing password during register process
		//@param playerid player that wants to register
		export __SHORTNAMED PUB_LOGIN_REGISTER_HASHPW_CB(playerid)
		{
			bcrypt_get_hash buf144
			Login_UsePassword playerid, buf144
			Login_FormatCreateUser playerid, buf4096, .password=buf144, .group=4
			mysql_tquery 1, buf4096, #PUB_LOGIN_REGISTER_CB, "i", playerid

			#outline
			//@summary Callback for register call
			//@param playerid player that wants to register
			export __SHORTNAMED PUB_LOGIN_REGISTER_CB(playerid)
			{
				userid[playerid] = cache_insert_id()
				PlayerData_SetUserId playerid, userid[playerid]
				if (userid[playerid] == -1 || !Login_FormatCreateSession(playerid, buf4096)) {
					hideGameTextForPlayer(playerid)
					WARNMSG("An error occured while registering.")
					WARNMSG("You will be spawned as a guest.")
					if (giveGuestName(playerid)) {
						loginAndSpawnAsGuest playerid
					}
					return
				}
				mysql_tquery 1, buf4096, #PUB_LOGIN_CREATE_NEWUSER_SES, "i", playerid
				GameTextForPlayer playerid, "~b~Creating game session...", 0x800000, 3
			}

			#outline
			//@summary Callback for creating game session for just registered account
			//@param playerid player that just registered and needs game session
			export __SHORTNAMED PUB_LOGIN_CREATE_NEWUSER_SES(playerid)
			{
				endDialogTransaction playerid, TRANSACTION_LOGIN
				hideGameTextForPlayer(playerid)
				sessionid[playerid] = cache_insert_id()
				loginPlayer playerid, LOGGED_IN
				/*
				if (sessionid[playerid] == -1) {
					// failed to create session
					// no real problem, but time will not be registered
				}
				*/
				format\
					buf144,
					sizeof(buf144),
					"%s[%d] just registered an account, welcome!",
					NAMEOF(playerid),
					playerid
				SendClientMessageToAll COL_JOIN, buf144
			}
		}
		#return 1
	}
	case DIALOG_LOGIN_LOGIN_OR_NAMECHANGE: {
		if (!response) {
			showLoginNamechangeDialog playerid
			#return 1
		}
		GameTextForPlayer playerid, "~b~Logging in...", 0x800000, 3
		new pw[65]
		Login_GetPassword playerid, pw
		bcrypt_check inputtext, pw, #PUB_LOGIN_PWVERIFY_CB, "i", playerid
		ensureDialogTransaction playerid, TRANSACTION_LOGIN

		#outline
		//@summary Callback for login password verification call
		//@param playerid player that wanted to login
		export __SHORTNAMED PUB_LOGIN_PWVERIFY_CB(playerid)
		{
			endDialogTransaction playerid, TRANSACTION_LOGIN
			hideGameTextForPlayer(playerid)

			if (!bcrypt_is_equal()) {
				// failed login
				if ((failedlogins{playerid} += 2) > (MAX_LOGIN_ATTEMPTS - 1) * 2) {
					SendClientMessage playerid, COL_WARN, #WARN"Too many failed login attempts!"
					KickDelayed playerid
					return
				}
				showLoginDialog playerid, .show_invalid_pw_error=1
				return
			}

			// great, correct password, do stuff
			GameTextForPlayer playerid, "~b~Loading account...", 0x800000, 3
			PlayerData_SetUserId playerid, userid[playerid]
			Login_FormatLoadAccountData userid[playerid], buf4096
			mysql_tquery 1, buf4096, #PUB_LOGIN_LOADACCOUNT_CB, "i", playerid

			#outline
			//@summary Callback for loading account data
			//@param playerid player
			export __SHORTNAMED PUB_LOGIN_LOADACCOUNT_CB(playerid)
			{
				hideGameTextForPlayer(playerid)

				if (!cache_get_row_count() ||
					!Login_FormatCreateUserSession(playerid, buf4096))
				{
					ShowPlayerDialog\
						playerid,
						DIALOG_LOGIN_LOADACCOUNTERROR,
						DIALOG_STYLE_MSGBOX,
						LOGIN_CAPTION,
						""#ECOL_WARN"An error occured, please try again",
						"Ok", ""
					return
				}

				GameTextForPlayer playerid, "~b~Creating game session...", 0x800000, 3
				new score
				cache_get_field_int(0, 0, score)
				SetPlayerScore playerid, score

				mysql_tquery 1, buf4096[1]
				mysql_tquery 1, buf4096[buf4096[0]], #PUB_LOGIN_CREATEGAMESESSION_CB, "i", playerid
			}

			#outline
			//@summary Callback when creating game session
			//@param playerid player
			//@remarks spawns the player at the end
			export __SHORTNAMED PUB_LOGIN_CREATEGAMESESSION_CB(playerid)
			{
				sessionid[playerid] = cache_insert_id()
				loginPlayer playerid, LOGGED_IN
				format\
					buf144,
					sizeof(buf144),
					"%s[%d] just logged in, welcome back!",
					NAMEOF(playerid),
					playerid
				SendClientMessageToAll COL_JOIN, buf144
			}
		}

		#return 1
	}
	case DIALOG_LOGIN_LOADACCOUNTERROR: {
		showLoginDialog playerid
		#return 1
	}
	case DIALOG_LOGIN_NAMECHANGE: {
		if (!response) {
			// Play as guest
			if (giveGuestName(playerid)) {
				loginAndSpawnAsGuest playerid
			}
			#return 1
		}
		// Change

		// edge: if input is empty, go back to login box
		if (!inputtext[0]) {
			showLoginDialog playerid
			#return 1
		}

		if (!changePlayerNameFromInput(playerid, inputtext)) {
			showLoginNamechangeDialog playerid, .show_invalid_name_error=1
			#return 1
		}
		userid[playerid] = -1
		checkUserExist playerid, ""#PUB_LOGIN_USERCHECK_CB""
		ensureDialogTransaction playerid, TRANSACTION_LOGIN
		#return 1
	}
	case DIALOG_GUESTREGISTER_CHOOSENAME: {
		if (!response) {
			#return 1
		}
		if (!changePlayerNameFromInput(playerid, inputtext)) {
			Login_FormatGuestRegisterBox playerid, buf4096, .invalid_name_error=1, .step=0
			ShowPlayerDialog\
				playerid,
				DIALOG_GUESTREGISTER_CHOOSENAME,
				DIALOG_STYLE_INPUT,
				REGISTER_CAPTION,
				buf4096,
				"Next", "Cancel",
				TRANSACTION_GUESTREGISTER
			#return 1
		}
		checkUserExist playerid, ""#PUB_LOGIN_GUESTREGISTERUSERCHECK_CB""
		ensureDialogTransaction playerid, TRANSACTION_GUESTREGISTER

		#outline
		//@summary Callback for usercheck done after renaming while guest is registering from existing guest session.
		//@param playerid player that has been checked
		export __SHORTNAMED PUB_LOGIN_GUESTREGISTERUSERCHECK_CB(playerid)
		{
			endDialogTransaction playerid, TRANSACTION_GUESTREGISTER
			hideGameTextForPlayer(playerid)

			if (!cache_get_row_count()) {
				printf "E-U12"
				ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
					""#ECOL_WARN"An error occurred, you will be spawned as a guest", "Ok", ""
				WARNMSG("An error occured while contacting the login server.")
				goto giveguestname
			}

			new failedattempts, pw[65]

			cache_get_field_int(0, 0, failedattempts)
			if (failedattempts > 10) {
				ShowPlayerDialog\
					playerid,
					DIALOG_DUMMY,
					DIALOG_STYLE_MSGBOX,
					LOGIN_CAPTION,
					""#ECOL_WARN"You cannot register right now because there"\
						" are too many failed logins from your location",
					"Ok", ""
				goto giveguestname
			}

			cache_get_field_str(0, 1, pw)
			if (ismysqlnull(pw)) {
				// user doesn't exist
				Login_FormatGuestRegisterBox playerid, buf4096, .step=1
				ShowPlayerDialog\
					playerid,
					DIALOG_GUESTREGISTER_FIRSTPASS,
					DIALOG_STYLE_PASSWORD,
					REGISTER_CAPTION,
					buf4096,
					"Next", "Cancel",
					TRANSACTION_GUESTREGISTER
				return
			}

			// user does exist
			ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
				""#ECOL_WARN"This name is registered, please retry with a different name.",
				"Ok", "", TRANSACTION_GUESTREGISTER
		giveguestname:
			if (giveGuestName(playerid)) {
				savePlayerName playerid
			}
		}

		#return 1
	}
	case DIALOG_GUESTREGISTER_FIRSTPASS: {
		if (!response) {
			Login_PasswordConfirmFree playerid
			if (giveGuestName(playerid)) {
				savePlayerName playerid
			}
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		Login_PasswordConfirmStore playerid, pwhash
		Login_FormatGuestRegisterBox playerid, buf4096, .step=2
		ShowPlayerDialog\
			playerid,
			DIALOG_GUESTREGISTER_CONFIRMPASS,
			DIALOG_STYLE_PASSWORD,
			REGISTER_CAPTION,
			buf4096,
			"Next", "Cancel",
			TRANSACTION_GUESTREGISTER
		#return 1
	}
	case DIALOG_GUESTREGISTER_CONFIRMPASS: {
		if (!response) {
			Login_PasswordConfirmFree playerid
			if (giveGuestName(playerid)) {
				savePlayerName playerid
			}
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		if (!Login_PasswordConfirmValidate(playerid, pwhash)) {
			Login_FormatGuestRegisterBox playerid, buf4096, .pwmismatch=1, .step=1
			ShowPlayerDialog\
				playerid,
				DIALOG_GUESTREGISTER_FIRSTPASS,
				DIALOG_STYLE_PASSWORD,
				REGISTER_CAPTION,
				buf4096,
				"Next", "Cancel",
				TRANSACTION_GUESTREGISTER
			#return 1
		}
		GameTextForPlayer playerid, "~b~Making your account...", 0x800000, 3
		ensureDialogTransaction playerid, TRANSACTION_GUESTREGISTER
		bcrypt_hash inputtext, BCRYPT_COST, #PUB_LOGIN_GUESTREGISTER_HASHPW_CB, "i", playerid

		#outline
		//@summary Callback after hash pw when guest wants to register their account
		//@param playerid player
		export __SHORTNAMED PUB_LOGIN_GUESTREGISTER_HASHPW_CB(playerid)
		{
			// dialog transaction should still be active (TRANSACTION_GUESTREGISTER)
			bcrypt_get_hash buf144
			Login_UsePassword playerid, buf144
			if (Login_FormatUpgradeGuestAcc(playerid, buf144, buf4096)) {
				// it should always return 1
				mysql_tquery 1, buf4096, #PUB_LOGIN_GUESTREGISTER_CB, "i", playerid
			}

			#outline
			//@summary Callback after query to upgrade guest account to real registered account
			//@param playerid player that wanted to register
			export __SHORTNAMED PUB_LOGIN_GUESTREGISTER_CB(playerid)
			{
				endDialogTransaction playerid, TRANSACTION_GUESTREGISTER
				hideGameTextForPlayer(playerid)

				if (cache_affected_rows(1)) {
					loggedstatus[playerid] = LOGGED_IN
					ShowPlayerDialog\
						playerid,
						DIALOG_DUMMY,
						DIALOG_STYLE_MSGBOX,
						LOGIN_CAPTION,
						""#ECOL_SUCC"Your account has been registered and "\
							"your stats are saved, welcome!",
						"Ok", "",
						TRANSACTION_GUESTREGISTER

					new str[MAX_PLAYER_NAME + 6 + 46 + 1]
					format\
						str,
						sizeof(str),
						"Guest %s[%d] just registered their account, welcome!",
						NAMEOF(playerid),
						playerid
					SendClientMessageToAll COL_JOIN, str
					return
				} else {
					// TODO log
					ShowPlayerDialog\
						playerid,
						DIALOG_DUMMY,
						DIALOG_STYLE_MSGBOX,
						LOGIN_CAPTION,
						""#ECOL_WARN"An occurred, please try again later.",
						"Ok", "",
						TRANSACTION_GUESTREGISTER
					if (giveGuestName(playerid)) {
						savePlayerName playerid
					}
				}
			}
		}

		#return 1
	}
	case DIALOG_CHANGEPASS_PREVPASS: {
		if (!response) {
			#return 1
		}
		if (!Login_GetPassword(playerid, buf144)) {
			ShowPlayerDialog\
				playerid,
				DIALOG_DUMMY,
				DIALOG_STYLE_MSGBOX,
				LOGIN_CAPTION,
				!""#ECOL_WARN"An error occurred, please try again after reconnecting.",
				"Ok", ""
			#return 1
		}
		GameTextForPlayer playerid, "~b~Verifying...", 0x800000, 3
		ensureDialogTransaction playerid, TRANSACTION_CHANGEPASS
		bcrypt_check inputtext, buf144, #PUB_LOGIN_CHANGEPASS_CHECK_CB, "i", playerid

		#outline
		//@summary Callback after checking a player's current password during change password process
		//@param playerid player that wanted to change password
		export __SHORTNAMED PUB_LOGIN_CHANGEPASS_CHECK_CB(playerid)
		{
			hideGameTextForPlayer(playerid)
			endDialogTransaction playerid, TRANSACTION_CHANGEPASS
			if (bcrypt_is_equal()) {
				Login_FormatChangePasswordBox buf4096, .step=1
				ShowPlayerDialog\
					playerid,
					DIALOG_CHANGEPASS_FIRSTPASS,
					DIALOG_STYLE_PASSWORD,
					CHANGEPASS_CAPTION,
					buf4096,
					"Next", "Cancel",
					TRANSACTION_CHANGEPASS
			} else {
				ShowPlayerDialog\
					playerid,
					DIALOG_DUMMY,
					DIALOG_STYLE_MSGBOX,
					CHANGEPASS_CAPTION,
					""#ECOL_WARN"Incorrect password",
					"Ok", ""
			}
		}

		#return 1
	}
	case DIALOG_CHANGEPASS_FIRSTPASS: {
		if (!response) {
			Login_PasswordConfirmFree playerid
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		Login_PasswordConfirmStore playerid, pwhash
		Login_FormatChangePasswordBox buf4096, .step=2
		ShowPlayerDialog\
			playerid,
			DIALOG_CHANGEPASS_CONFIRMPASS,
			DIALOG_STYLE_PASSWORD,
			CHANGEPASS_CAPTION,
			buf4096,
			"Next", "Cancel",
			TRANSACTION_CHANGEPASS
		#return 1
	}
	case DIALOG_CHANGEPASS_CONFIRMPASS: {
		if (!response) {
			Login_PasswordConfirmFree playerid
			#return 1
		}
		new pwhash[PW_HASH_LENGTH]
		SHA256_PassHash inputtext, /*salt*/REGISTER_CAPTION, pwhash, PW_HASH_LENGTH
		if (!Login_PasswordConfirmValidate(playerid, pwhash)) {
			Login_FormatChangePasswordBox buf4096, .pwmismatch=1, .step=1
			ShowPlayerDialog\
				playerid,
				DIALOG_CHANGEPASS_FIRSTPASS,
				DIALOG_STYLE_PASSWORD,
				CHANGEPASS_CAPTION,
				buf4096,
				"Next", "Cancel",
				TRANSACTION_CHANGEPASS
			#return 1
		}

		GameTextForPlayer playerid, "~b~Updating...", 0x800000, 3

		bcrypt_hash inputtext, BCRYPT_COST, #PUB_LOGIN_CHANGEPASS_HASHPW_CB, "i", playerid
		ensureDialogTransaction playerid, TRANSACTION_CHANGEPASS

		#outline
		//@summary Callback after hash pw when guest wants to register their account
		//@param playerid player
		export __SHORTNAMED PUB_LOGIN_CHANGEPASS_HASHPW_CB(playerid)
		{
			// dialog transaction should still be active (TRANSACTION_CHANGEPASS)
			bcrypt_get_hash buf144
			Login_UsePassword playerid, buf144
			Login_FormatChangePassword userid[playerid], buf144, buf4096
			mysql_tquery 1, buf4096, #PUB_LOGIN_CHANGEPASS_CHANGE_CB, "i", playerid

			#outline
			//@summary Callback after call to change a player's password
			//@param playerid player that wanted to change password
			export __SHORTNAMED PUB_LOGIN_CHANGEPASS_CHANGE_CB(playerid)
			{
				hideGameTextForPlayer(playerid)
				if (cache_affected_rows(1)) {
					ShowPlayerDialog\
						playerid,
						DIALOG_DUMMY,
						DIALOG_STYLE_MSGBOX,
						CHANGEPASS_CAPTION,
						""#ECOL_SUCC"Password changed!",
						"Ok", "",
						TRANSACTION_CHANGEPASS
				} else {
					// TODO: log
					ShowPlayerDialog\
						playerid,
						DIALOG_DUMMY,
						DIALOG_STYLE_MSGBOX,
						CHANGEPASS_CAPTION,
						""#ECOL_WARN"An error occurred, "\
							"please try again later.",
						"Ok", "",
						TRANSACTION_CHANGEPASS
				}
			}
		}

		#return 1
	}
}

//@summary Changes a player's name to the specified string, checking for validity (length, guest symbol) first
//@param playerid the playerid that needs the new name
//@param inputtext the name to change to
//@returns {@code 0} if the input was not valid or name is already taken by a player
changePlayerNameFromInput(playerid, inputtext[])
{
	new len = strlen(inputtext)
	return 2 < len && len < 21 && inputtext[0] != '@' && SetPlayerName(playerid, inputtext) == 1;
}

//@summary Check if a user with username of {@param playerid} exists
//@param playerid the player to check if their username is registered
//@param callback the callback that will be notified when api call reponds
checkUserExist(playerid, callback[])
{
	GameTextForPlayer playerid, "~b~Contacting login server...", 0x800000, 3
	Login_FormatCheckUserExist playerid, buf4096
	mysql_tquery 1, buf4096, callback, "i", playerid
}

//@summary Shows register dialog for player
//@param playerid player to show register dialog for
//@param text dialog body text, use {@link Login_FormatOnJoinRegisterBox}
showRegisterDialog(playerid, text[])
{
	ShowPlayerDialog playerid,
		DIALOG_REGISTER_FIRSTPASS,
		DIALOG_STYLE_PASSWORD,
		REGISTER_CAPTION,
		text,
		"Next",
		"Play as guest",
		TRANSACTION_LOGIN
}

//@summary Shows login dialog for player
//@param playerid player to show login dialog for
//@param show_invalid_pw_error whether to show invalid password error message (optional={@code 0})
showLoginDialog(playerid, show_invalid_pw_error=0)
{
	ShowPlayerDialog playerid,
		DIALOG_LOGIN_LOGIN_OR_NAMECHANGE,
		DIALOG_STYLE_PASSWORD,
		LOGIN_CAPTION,
		LOGIN_TEXT[((show_invalid_pw_error & 1) ^ 1) * LOGIN_TEXT_NOPWERR_OFFSET],
		"Login",
		"Change name",
		TRANSACTION_LOGIN
}

//@summary Shows namechange dialog for player (during login phase)
//@param playerid player to show namechange dialog for
//@param show_invalid_name_error whether to show invalid name error message (optional={@code 0})
showLoginNamechangeDialog(playerid, show_invalid_name_error=0)
{
	ShowPlayerDialog playerid,
		DIALOG_LOGIN_NAMECHANGE,
		DIALOG_STYLE_INPUT,
		NAMECHANGE_CAPTION,
		NAMECHANGE_TEXT[((show_invalid_name_error & 1) ^ 1) * NAMECHANGE_TEXT_NOERR_OFFSET],
		"Change",
		"Play as guest",
		TRANSACTION_LOGIN
}

//@summary Callback for usercheck done in {@link OnPlayerConnect} and after changing name during login.
//@param playerid player that has been checked
export __SHORTNAMED PUB_LOGIN_USERCHECK_CB(playerid)
{
	endDialogTransaction playerid, TRANSACTION_LOGIN
	hideGameTextForPlayer(playerid)

	if (!cache_get_row_count()) {
		printf "E-U02"
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"An error occurred, you will be spawned as a guest", "Ok", ""
		SendClientMessage playerid, COL_WARN, WARN"An error occured while contacting the login server."
		goto asguest
	}

	new failedattempts, id, pw[65]

	cache_get_field_int(0, 0, failedattempts)
	if (failedattempts > 10) {
		ShowPlayerDialog playerid, DIALOG_DUMMY, DIALOG_STYLE_MSGBOX, LOGIN_CAPTION,
			""#ECOL_WARN"You will be spawned as guest due to too many failed logins from your location", "Ok", ""
asguest:
		SendClientMessage playerid, COL_SAMP_GREEN, "You will be spawned as a guest."
		if (giveGuestName(playerid)) {
			loginAndSpawnAsGuest playerid
		}
		return
	}

	cache_get_field_str(0, 1, pw)
	if (ismysqlnull(pw)) {
		// user doesn't exist
		Login_FormatOnJoinRegisterBox buf4096, .step=0
		showRegisterDialog playerid, buf4096
		return
	}

	// user does exist
	Login_UsePassword playerid, pw
	cache_get_field_int(0, 2, id)
	userid[playerid] = id
	showLoginDialog playerid
}

//@summary Saves a player's name in db
//@param playerid player to save the name of
savePlayerName(playerid)
{
	#assert MAX_PLAYER_NAME == 24
	static query[] = "UPDATE usr SET n='_________________________ WHERE i=__________"
	memcpy query, ninespaces, 53 * 4, 9 * 4
	format query[52], 10, _pd, userid[playerid]
	memcpy query, "                       ", 20 * 4, 23 * 4
	memcpy query, NAMEOF(playerid), 18 * 4, NAMELEN(playerid) * 4
	query[18 + NAMELEN(playerid)] = '\'';
	mysql_tquery 1, query
}

//@summary Renames a player to a guest name
//@param playerid the player to give a guest name to
//@returns {@code 0} if it was unsuccessful, which means the player is getting kicked
//@remarks player will be kicked when the name {@code @playername} is already taken and it failed to give a random name 5 times
giveGuestName(playerid)
{
	new newname[MAX_PLAYER_NAME]
	newname[0] = '@'
	memcpy(newname, NAMEOF(playerid), 4, NAMELEN(playerid) * 4 + 4)
	if (SetPlayerName(playerid, newname) == 1) {
		return 1
	}
	new guard = 5;
	while (guard-- > 0) {
		for (new i = 1; i < 10; i++) {
			newname[i] = 'a' + random('z' - 'a' + 1)
		}
		if (SetPlayerName(playerid, newname) == 1) {
			return 1
		}
	}
	print "F-U0C"
	SendClientMessage playerid, COL_WARN, WARN"Fatal error, please reconnect!"
	KickDelayed playerid
	return 0
}

//@summary Creates a guest account and session for player and log them in and spawn as guest.
//@param playerid the player to login and spawn as guest
loginAndSpawnAsGuest(playerid)
{
	GameTextForPlayer playerid, "~b~Creating guest account...", 0x800000, 3
	if (!Login_FormatCreateUser(playerid, buf4096, .password="", .group=0)) {
		spawnWithoutGuestSession playerid
		return
	}
	mysql_tquery 1, buf4096, #PUB_LOGIN_CREATE_GUEST_USR, "i", playerid

	#outline
	//@summary Callback after create a guest user account
	//@param playerid the player a guest account was made for
	export __SHORTNAMED PUB_LOGIN_CREATE_GUEST_USR(playerid)
	{
		GameTextForPlayer playerid, "~b~Creating game session...", 0x800000, 3
		userid[playerid] = cache_insert_id()
		PlayerData_SetUserId playerid, userid[playerid]
		if (userid[playerid] == -1 || !Login_FormatCreateSession(playerid, buf4096)) {
			spawnWithoutGuestSession playerid
			return
		}
		mysql_tquery 1, buf4096, #PUB_LOGIN_CREATE_GUEST_SES, "i", playerid

		#outline
		//@summary Callback for query to create guest account
		//@param playerid player that needed a guest account
		export __SHORTNAMED PUB_LOGIN_CREATE_GUEST_SES(playerid)
		{
			hideGameTextForPlayer(playerid)
			loginPlayer playerid, LOGGED_GUEST
			sessionid[playerid] = cache_insert_id()
			/*
			if (sessionid[playerid] == -1) {
				// failed to create session
				// no real problem, but time will not be registered
			}
			*/
			format\
				buf144,
				sizeof(buf144),
				"%s[%d] joined as a guest, welcome!",
				NAMEOF(playerid),
				playerid
			SendClientMessageToAll COL_JOIN, buf144
			SendClientMessage\
				playerid,
				COL_INFO,
				""#INFO"You are now playing as a guest. "\
					"You can use /register at any time to save your stats."
		}
	}
}

//@summary Spawns a player without having a guest session and tells them
//@remarks also hides game text
spawnWithoutGuestSession(playerid)
{
	hideGameTextForPlayer(playerid)
	WARNMSG("An error occurred while creating a guest session.")
	WARNMSG("You can play, but you won't be able to save your stats later.")
	loginPlayer playerid, LOGGED_GUEST
}

//@summary Updates a player's last seen (usr and ses) and total/actual time value in db
//@param playerid playerid to update
//@param isdisconnect is this call made from {@link OnPlayerDisconnect}?
//@remarks This function first checks if the player has a valid userid and sessionid
//@remarks If {@param isdisconnect} is {@code 0}, {@code 30} gets added to player's total time (inaccurate), \
otherwise player's totaltime is set to sum of session times (accurate)
updatePlayerLastseen(playerid, isdisconnect)
{
	static sessionquery1[] = "UPDATE usr SET l=UNIX_TIMESTAMP(),t=t+30,a=a+__________ WHERE i=__________"
	static sessionquery2[] = "UPDATE ses SET e=UNIX_TIMESTAMP() WHERE i=__________"
	static sessionquery3[] = "UPDATE usr SET t=(SELECT SUM(e-s) FROM ses WHERE u=usr.i) WHERE i=__________"
	if (userid[playerid] != -1 && sessionid[playerid] != -1) {
		if (isdisconnect) {
			memcpy sessionquery3, ninespaces, 67 * 4, 9 * 4
			format sessionquery3[66], 10, _pd, userid[playerid]
			mysql_tquery 1, sessionquery3
			sessionquery1[38] = '0'
		}
		memcpy sessionquery1, ninespaces, 46 * 4, 9 * 4
		format sessionquery1[45], 10, _pd, getAndClearUncommittedPlaytime(playerid)
		sessionquery1[45 + strlen(sessionquery1[45])] = ' '
		memcpy sessionquery1, ninespaces, 65 * 4, 9 * 4
		format sessionquery1[64], 10, _pd, userid[playerid]
		format sessionquery2[42], 10, _pd, sessionid[playerid]
		mysql_tquery 1, sessionquery1
		mysql_tquery 1, sessionquery2
		sessionquery1[38] = '3'
	}
}

//@summary Sets a player's logged status and triggers class selection for them
//@param playerid The player to login
//@param status the logged status to give, should be either {@code LOGGED_IN} or {@code LOGGED_GUEST}
loginPlayer(playerid, status)
{
	loggedstatus[playerid] = status
	iter_add(players, playerid)
	OnPlayerRequestClassImpl playerid
}

#printhookguards

