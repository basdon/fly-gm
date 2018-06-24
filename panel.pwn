
// vim: set filetype=c ts=8 noexpandtab:

#define HI 1
#define TEXT_BG 0
#define TEXT_BG_SPD 1
#define TEXT_BG_ALT 2

>> INIT
	new Text:text[2]
<<

>> LOOP150
<<

>> ONGAMEMODEINIT
#define TEXT_GREY 0x777777FF

	text[0] = TextDrawCreate(320.0, 360.0, "~n~~n~~n~~n~~n~~n~~n~~n~");
/*
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.5, 1.0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 153);
	TextDrawTextSize(TDVAR, 100.0, 270.0);

	TDVAR = TextDrawCreate(320.0, 360.0, "DIS_________________ETA_________________CRS________");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.25, 1.0);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 1);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(220.0, 360.0, "220-~n~210-~n~~n~~n~~n~~n~200-~n~190-");
	TextDrawAlignment(TDVAR, 3);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.25, 1.0);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(222.0, 389.0, "206");
	TextDrawAlignment(TDVAR, 3);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.4, 1.6);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(217.0, 380.0, "7~n~~n~5");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.3, 1.2);
	TextDrawColor(TDVAR, -1734829825);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(203.0, 383.0, "~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 153);
	TextDrawTextSize(TDVAR, 100.0, 35.0);

	TDVAR = TextDrawCreate(436.0, 383.0, "~n~~n~~n~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 1);
	TextDrawLetterSize(TDVAR, 0.3, 1.0);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 1);
	TextDrawSetShadow(TDVAR, 1);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 153);
	TextDrawTextSize(TDVAR, 100.0, 35.0);

	TDVAR = TextDrawCreate(446.0, 380.0, "40~n~~n~20");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.3, 1.2);
	TextDrawColor(TDVAR, -1734829825);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(458.0, 389.0, "031");
	TextDrawAlignment(TDVAR, 3);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.4, 1.6);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(453.0, 360.0, "100-~n~50-~n~~n~~n~~n~~n~0-~n~-50-");
	TextDrawAlignment(TDVAR, 3);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.25, 1.0);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(320.0, 420.0, "273");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.4, 1.6);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(320.0, 423.0, "271_272_______274_275");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.3, 1.2);
	TextDrawColor(TDVAR, 0x777777FF);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);

	TDVAR = TextDrawCreate(465.0, 365.0, "-2~n~-~n~-1~n~-~n~-0~n~-~n~-1~n~-~n~-2");
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.200000, 0.8);
	TextDrawColor(TDVAR, -1);
	TextDrawSetProportional(TDVAR, 0);
	TextDrawSetShadow(TDVAR, 0);
	TextDrawUseBox(TDVAR, 1);
	TextDrawBoxColor(TDVAR, 0x777777FF);
	TextDrawTextSize(TDVAR, 476.0, 0.0);

	TDVAR = TextDrawCreate(459.0, 392.0, "~>~");
	TextDrawAlignment(TDVAR, 2);
	TextDrawFont(TDVAR, 2);
	TextDrawLetterSize(TDVAR, 0.25, 1.0);
	TextDrawColor(TDVAR, 0xFFFFFFFF);
	TextDrawSetShadow(TDVAR, 0);
	TextDrawSetProportional(TDVAR, 0);
*/
<<

